//
//  MovieDetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SDWebImageSwiftUI
import SwiftUI

struct MovieDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
                toolbar
                    .padding(.horizontal, inset)
                detailContent(inset: inset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(DashboardDesign.background.ignoresSafeArea())
        .accessibilityHidden(presentedTrailers != nil)
        .overlay { trailerOverlay }
        .toolbar(.hidden, for: .navigationBar)
        .tint(DashboardDesign.accent)
        .onAppear { presenter.checkFavoriteStatus(movieId: movieId) }
        .task { presenter.load(movieId: movieId) }
        .alert("Couldn’t update favorites", isPresented: $presenter.showsFavoriteError) {
            Button("OK", role: .cancel) {}
        }
    }

    private var toolbar: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 44, height: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Text("Movie Details")
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)
        }
        .foregroundStyle(DashboardDesign.text)
        .frame(minHeight: 56)
    }

    @ViewBuilder
    private func detailContent(inset: CGFloat) -> some View {
        if let movie = presenter.movie {
            ScrollView {
                VStack(spacing: 24) {
                    hero(movie)

                    VStack(spacing: 16) {
                        overview(movie)
                        actions(movie)
                    }
                    .padding(.horizontal, inset)

                    topCast(inset: inset)
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
        let metadata = [
            String(movie.releaseDate.prefix(4)),
            movie.genre
        ].filter { !$0.isEmpty }.joined(separator: " · ")

        return Group {
            if movie.backdropPath.isEmpty {
                movieBackdrop(movie)
                    .accessibilityHidden(true)
            } else {
                presenter.toMovieImageGallery(for: movie.id, title: movie.title) {
                    movieBackdrop(movie)
                }
                .accessibilityLabel("View movie photos")
            }
        }
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)

                if !metadata.isEmpty {
                    Text(metadata)
                        .font(.caption)
                }
            }
            .foregroundStyle(DashboardDesign.surface)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(alignment: .bottom) {
                DashboardDesign.mediaFooterGradient
            }
            .allowsHitTesting(false)
        }
        .frame(maxWidth: DashboardDesign.contentWidth)
        .frame(maxWidth: .infinity)
    }

    private func movieBackdrop(_ movie: MovieDetailModel) -> some View {
        artwork(movie.backdropPath, baseURL: API.backdropBaseUrl, fallback: DashboardDesign.mediaFooter)
            .aspectRatio(16.0 / 9, contentMode: .fit)
            .clipped()
    }

    private func overview(_ movie: MovieDetailModel) -> some View {
        HStack(alignment: .top, spacing: 16) {
            artwork(movie.posterPath, baseURL: API.imageBaseUrl)
                .frame(width: 96, height: 144)
                .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                if movie.rating > 0 || (movie.voteCount ?? 0) > 0 {
                    rating(movie)
                }

                Text("Overview")
                    .font(.subheadline.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)

                let summary = movie.overview.trimmingCharacters(in: .whitespacesAndNewlines)
                Text(summary.isEmpty || summary == "-" ? "Overview unavailable" : summary)
                    .font(.footnote)
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func rating(_ movie: MovieDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if movie.rating > 0 {
                let score = movie.rating.formatted(.number.precision(.fractionLength(1)))
                Label(score, systemImage: "star.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DashboardDesign.surface)
                    .padding(.horizontal, 8)
                    .frame(minHeight: 24)
                    .background(DashboardDesign.text, in: RoundedRectangle(cornerRadius: 8))
                    .accessibilityLabel("Rating \(score) out of 10")
            }

            if let count = movie.voteCount, count > 0 {
                Text(count == 1 ? "1 vote" : "\(count.formatted(.number.notation(.compactName))) votes")
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
        }
    }

    private func actions(_ movie: MovieDetailModel) -> some View {
        let trailers = movie.videos.compactMap(TrailerLink.init)
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))

        return layout {
            if trailers.count > 1 {
                Button {
                    setTrailerDrawer(trailers)
                } label: {
                    trailerLabel
                }
                .buttonStyle(.plain)
            } else if let trailer = trailers.first {
                Link(destination: trailer.url) {
                    trailerLabel
                }
                .buttonStyle(.plain)
            }

            AnimatedFavoriteButton(isFavorite: presenter.isFavorite) {
                let previousValue = presenter.isFavorite
                presenter.toggleFavorite()
                return previousValue != presenter.isFavorite
            }
        }
    }

    private var trailerLabel: some View {
        Label("Watch Trailer", systemImage: "play.fill")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(DashboardDesign.surface)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(DashboardDesign.accent, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
    }

    private var trailerOverlay: some View {
        ZStack(alignment: .bottom) {
            if let trailers = presentedTrailers {
                DashboardDesign.text.opacity(0.42)
                    .ignoresSafeArea()
                    .onTapGesture { setTrailerDrawer(nil) }
                    .accessibilityHidden(true)
                    .transition(.opacity)

                MovieTrailerDrawer(trailers: trailers) { setTrailerDrawer(nil) }
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(presentedTrailers != nil)
    }

    private func setTrailerDrawer(_ trailers: [TrailerLink]?) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            presentedTrailers = trailers
        }
    }

    private func topCast(inset: CGFloat) -> some View {
        let cast = presenter.topCast

        return VStack(alignment: .leading, spacing: 12) {
            sectionHeading("Top cast", seeAll: true)
                .padding(.horizontal, inset)

            if cast.isEmpty {
                sectionMessage("No cast available")
                    .padding(.horizontal, inset)
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 12) {
                        ForEach(cast) { credit in
                            presenter.toPersonDetail(for: credit.id) {
                                castCard(credit)
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, inset, for: .scrollContent)
                .scrollIndicators(.hidden)
            }
        }
    }

    private func castCard(_ credit: CreditModel) -> some View {
        let initials = String(credit.name.split(whereSeparator: \.isWhitespace).prefix(2).compactMap(\.first)).uppercased()

        return VStack(alignment: .center, spacing: 5) {
            Circle()
                .fill(DashboardDesign.surfaceDim)
                .overlay {
                    Text(initials)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(DashboardDesign.accent)
                }
                .overlay {
                    if !credit.profilePath.isEmpty, let url = URL(string: API.profileImageBaseUrl + credit.profilePath) {
                        WebImage(url: url)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .center, spacing: 2) {
                Text(credit.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DashboardDesign.text)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                if !credit.characterName.isEmpty {
                    Text(credit.characterName)
                        .font(.caption2)
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(width: 132, height: 136, alignment: .top)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DashboardDesign.cardRadius)
                .strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
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
                sectionHeading("Movie info")

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
            sectionHeading("Similar Movies", seeAll: true)
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
                                similarMovieCard(movie)
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

    private func similarMovieCard(_ movie: MovieModel) -> some View {
        let year = String(movie.releaseDate.prefix(4))

        return VStack(alignment: .leading, spacing: 4) {
            artwork(movie.posterPath, baseURL: API.imageBaseUrl)
                .frame(width: 109, height: 164)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            Text(movie.title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.text)
                .lineLimit(2)

            if !year.isEmpty {
                Text(year)
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
        }
        .frame(width: 109, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private func sectionHeading(_ title: String, seeAll: Bool = false) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)

            if seeAll {
                Button {} label: {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "arrow.right")
                            .accessibilityHidden(true)
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.accent)
                .buttonStyle(.plain)
                .disabled(true)
            }
        }
    }

    private func sectionMessage(_ message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(DashboardDesign.secondaryText)
    }

    private func artwork(_ path: String, baseURL: String, fallback: Color = DashboardDesign.surfaceDim) -> some View {
        fallback.overlay {
            if !path.isEmpty, let url = URL(string: baseURL + path) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

private struct MovieTrailerDrawer: View {
    @Environment(\.openURL) private var openURL
    @State private var selectedTrailerID: String?

    let trailers: [TrailerLink]
    let onClose: () -> Void

    private let rowHeight: CGFloat = 42
    private let rowSpacing: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(DashboardDesign.color(0xC7D1E3))
                .frame(width: 48, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 9)
                .accessibilityHidden(true)

            HStack {
                Text("Watch trailer")
                    .font(.title3.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 8)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .frame(width: 32, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close trailers")
            }
            .padding(.horizontal, 20)

            Text("Choose a video to play")
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
                .padding(.bottom, 16)
                .padding(.horizontal, 20)

            ViewThatFits(in: .vertical) {
                trailerRows
                ScrollView {
                    trailerRows
                        .padding(.horizontal, 20)
                }
            }
            .frame(
                maxHeight: CGFloat(trailers.count) * rowHeight + CGFloat(trailers.count) * rowSpacing
            )
        }
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(DashboardDesign.surface)
                .ignoresSafeArea(edges: [.horizontal, .bottom])
        }
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape, onClose)
    }

    private var trailerRows: some View {
        VStack(spacing: rowSpacing) {
            ForEach(trailers) { trailer in
                trailerRow(trailer)
            }
            
            Spacer()
        }
    }

    private func trailerRow(_ trailer: TrailerLink) -> some View {
        let isSelected = trailer.id == (selectedTrailerID ?? trailers.first?.id)
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        return Button {
            selectedTrailerID = trailer.id
            openURL(trailer.url)
        } label: {
            HStack(spacing: 12) {
                Text(trailer.name)
                    .font(.footnote.weight(.regular))
                    .foregroundStyle(DashboardDesign.text)
                    .lineLimit(2)

                Spacer(minLength: 0)

                Image(systemName: "play.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DashboardDesign.accent)
                    .frame(width: 20)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 6)
            .frame(minHeight: rowHeight)
            .background(DashboardDesign.surface, in: shape)
            .overlay {
                shape.strokeBorder(DashboardDesign.border)
                    .allowsHitTesting(false)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct TrailerLink: Identifiable {
    let id: String
    let name: String
    let url: URL

    init?(_ video: VideoModel) {
        guard !video.key.isEmpty, let url = URL(string: Constants.youtubeBaseUrl + video.key) else { return nil }
        id = video.id
        name = video.name
        self.url = url
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
