//
//  MovieDetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI

struct MovieDetailView: View {
    @State private var presenter: MovieDetailPresenter
    @State private var presentedTrailers: [TrailerLink]?

    private let movieId: Int

    init(detailUseCase: DetailUseCase, favoriteUseCase: FavoriteUseCase, movieId: Int) {
        _presenter = State(initialValue: MovieDetailPresenter(
            detailUseCase: detailUseCase,
            favoriteUseCase: favoriteUseCase
        ))
        self.movieId = movieId
    }

    var body: some View {
        GeometryReader { geometry in
            let inset = max(20, (geometry.size.width - DashboardDesign.contentWidth) / 2)

            VStack(spacing: 0) {
                DetailToolbar(title: "Movie Details")
                    .padding(.horizontal, inset)
                detailContent(inset: inset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(DashboardDesign.background.ignoresSafeArea())
        .detailTrailerDrawer($presentedTrailers)
        .toolbar(.hidden, for: .navigationBar)
        .tint(DashboardDesign.accent)
        .onAppear { presenter.checkFavoriteStatus(movieId: movieId) }
        .task { presenter.load(movieId: movieId) }
        .alert("Couldn’t update favorites", isPresented: $presenter.showsFavoriteError) {
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func detailContent(inset: CGFloat) -> some View {
        if let movie = presenter.movie {
            ScrollView {
                VStack(spacing: 24) {
                    hero(movie)

                    VStack(spacing: 16) {
                        DetailOverview(
                            posterPath: movie.posterPath,
                            overview: movie.overview,
                            rating: movie.rating,
                            voteCount: movie.voteCount
                        )
                        DetailActions(
                            videos: movie.videos,
                            isFavorite: presenter.isFavorite,
                            presentedTrailers: $presentedTrailers
                        ) {
                            let previousValue = presenter.isFavorite
                            presenter.toggleFavorite()
                            return previousValue != presenter.isFavorite
                        }
                    }
                    .padding(.horizontal, inset)

                    topCast(title: movie.title, inset: inset)
                    movieInfo(movie)
                        .padding(.horizontal, inset)
                    similarMovies(inset: inset)
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        } else if presenter.movieFailed {
            ContentUnavailableView {
                Label("Couldn’t load movie details", systemImage: "wifi.exclamationmark")
            } actions: {
                Button("Retry") { presenter.getMovie(movieId: movieId) }
            }
            .frame(maxHeight: .infinity)
        } else {
            ProgressView("Loading movie details")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func hero(_ movie: MovieDetailModel) -> some View {
        let metadata = [String(movie.releaseDate.prefix(4)), movie.genre]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")

        return DetailHero(title: movie.title, metadata: metadata) {
            if movie.backdropPath.isEmpty {
                DetailBackdrop(path: movie.backdropPath)
                    .accessibilityHidden(true)
            } else {
                presenter.toMovieImageGallery(for: movie.id, title: movie.title) {
                    DetailBackdrop(path: movie.backdropPath)
                }
                .accessibilityLabel("View movie photos")
            }
        }
    }

    private func topCast(title: String, inset: CGFloat) -> some View {
        let cast = presenter.cast

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                DetailSectionHeading("Top cast")
                if !cast.isEmpty {
                    presenter.toFullCast(title: title, cast: cast) {
                        DetailSeeAllLabel()
                    }
                    .accessibilityLabel("See all cast")
                }
            }
            .padding(.horizontal, inset)

            if cast.isEmpty {
                sectionMessage("No cast available")
                    .padding(.horizontal, inset)
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 12) {
                        ForEach(cast.prefix(10)) { credit in
                            presenter.toPersonDetail(for: credit.id) {
                                DetailCastCard(credit: credit)
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, inset, for: .scrollContent)
                .scrollIndicators(.hidden)
            }
        }
    }

    @ViewBuilder
    private func movieInfo(_ movie: MovieDetailModel) -> some View {
        let fields: [(label: String, value: String?)] = [
            ("Director", movie.director),
            ("US release", movie.usReleaseDate?.formatDateString(output: "MMM d, yyyy")),
            ("Runtime", movie.runtime > 0 ? "\(movie.runtime) min" : nil),
            ("Music", movie.composer)
        ]
        let values = fields.compactMap { field -> (label: String, value: String)? in
            guard let value = field.value, !value.isEmpty else { return nil }
            return (field.label, value)
        }

        if !values.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                DetailSectionHeading("Movie info")

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .topLeading), count: 2),
                          alignment: .leading, spacing: 12) {
                    ForEach(values, id: \.label) { field in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(field.label)
                                .font(.caption)
                                .foregroundStyle(DashboardDesign.secondaryText)
                            Text(field.value)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(DashboardDesign.text)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                .padding(13)
                .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                        .strokeBorder(DashboardDesign.border)
                        .allowsHitTesting(false)
                }
            }
        }
    }

    private func similarMovies(inset: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionHeading("Similar Movies", seeAll: true)
                .padding(.horizontal, inset)

            switch presenter.similarMovies {
            case .idle, .loading:
                ProgressView("Loading similar movies")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            case .loaded(let movies) where movies.isEmpty:
                sectionMessage("No similar movies available")
                    .padding(.horizontal, inset)
            case .loaded(let movies):
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 12) {
                        ForEach(movies) { movie in
                            presenter.toSimilarMovie(for: movie.id) {
                                DetailPosterCard(title: movie.title, posterPath: movie.posterPath, releaseDate: movie.releaseDate)
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, inset, for: .scrollContent)
                .scrollIndicators(.hidden)
            case .failed:
                VStack(alignment: .leading, spacing: 6) {
                    sectionMessage("Couldn’t load similar movies")
                    Button("Retry") { presenter.getSimilarMovies(movieId: movieId) }
                        .font(.footnote.weight(.semibold))
                }
                .padding(.horizontal, inset)
            }
        }
    }

    private func sectionMessage(_ message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(DashboardDesign.secondaryText)
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(
            detailUseCase: Injection().provideDetailUseCase(),
            favoriteUseCase: Injection().provideFavoriteUseCase(),
            movieId: 693134
        )
    }
}
