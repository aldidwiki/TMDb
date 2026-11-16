//
//  TvShowDetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import SwiftUI

struct TvShowDetailView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var presenter: TvShowDetailPresenter
    @State private var presentedTrailers: [TrailerLink]?
    @State private var showsSeasonPicker = false

    init(tvShowUseCase: TvShowUseCase, favoriteUseCase: FavoriteUseCase, tvShowId: Int) {
        _presenter = State(initialValue: TvShowDetailPresenter(
            tvShowUseCase: tvShowUseCase,
            favoriteUseCase: favoriteUseCase,
            tvShowId: tvShowId
        ))
    }

    var body: some View {
        GeometryReader { geometry in
            let inset = max(20, (geometry.size.width - DashboardDesign.contentWidth) / 2)

            VStack(spacing: 0) {
                DetailToolbar(title: "TV Show Details")
                    .padding(.horizontal, inset)
                detailContent(inset: inset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(DashboardDesign.background.ignoresSafeArea())
        .detailTrailerDrawer($presentedTrailers)
        .toolbar(.hidden, for: .navigationBar)
        .tint(DashboardDesign.accent)
        .onAppear { presenter.checkFavoriteStatus() }
        .task { presenter.load() }
        .sheet(isPresented: $showsSeasonPicker) {
            TvShowSeasonView(
                seasons: presenter.seasons,
                selectedSeasonNumber: presenter.selectedSeason?.seasonNumber,
                onSelect: presenter.selectSeason
            )
        }
        .alert("Couldn’t update favorites", isPresented: $presenter.showsFavoriteError) {
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func detailContent(inset: CGFloat) -> some View {
        if let show = presenter.tvShow {
            ScrollView {
                VStack(spacing: 24) {
                    hero(show)

                    VStack(spacing: 16) {
                        DetailOverview(
                            posterPath: show.posterPath,
                            overview: show.overview,
                            rating: show.rating,
                            voteCount: show.voteCount
                        )
                        DetailActions(
                            videos: show.videos,
                            isFavorite: presenter.isFavorite,
                            presentedTrailers: $presentedTrailers,
                            onFavoriteToggle: presenter.toggleFavorite
                        )
                    }
                    .padding(.horizontal, inset)

                    seasons
                        .padding(.horizontal, inset)

                    if let season = presenter.selectedSeason {
                        episodePreview(season)
                            .padding(.horizontal, inset)
                    }

                    topCast(inset: inset)
                    seriesInfo(show)
                        .padding(.horizontal, inset)
                    similarShows(inset: inset)
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        } else if presenter.detailFailed {
            ContentUnavailableView {
                Label("Couldn’t load TV show details", systemImage: "wifi.exclamationmark")
            } actions: {
                Button("Retry") { presenter.loadTvShow() }
            }
            .frame(maxHeight: .infinity)
        } else {
            ProgressView("Loading TV show details")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func hero(_ show: TvShowDetailModel) -> some View {
        let count = presenter.regularSeasonCount
        let seasonCount = count > 0 ? (count == 1 ? "1 Season" : "\(count) Seasons") : ""
        let metadata = [String(show.releaseDate.prefix(4)), show.genre, seasonCount]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")

        return DetailHero(title: show.title, metadata: metadata, cornerRadius: DashboardDesign.controlRadius) {
            if show.backdropPath.isEmpty {
                DetailBackdrop(path: show.backdropPath)
                    .accessibilityHidden(true)
            } else {
                presenter.toTvShowImageGallery(title: show.title) {
                    DetailBackdrop(path: show.backdropPath)
                }
                .accessibilityLabel("View TV show photos")
            }
        }
    }

    private var seasons: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                DetailSectionHeading("Seasons")

                if presenter.seasons.count > 5 {
                    Button("All Seasons") { showsSeasonPicker = true }
                        .font(.footnote.weight(.semibold))
                        .buttonStyle(.plain)
                        .foregroundStyle(DashboardDesign.accent)
                }
            }

            if let season = presenter.selectedSeason {
                let layout = presenter.seasons.count > 2 || dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                    : AnyLayout(HStackLayout(alignment: .center, spacing: 8))

                layout {
                    seasonChips
                    Text(season.episodeSummary)
                        .font(.caption)
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .fixedSize(horizontal: !dynamicTypeSize.isAccessibilitySize, vertical: true)
                }
            } else {
                sectionMessage("No seasons available")
            }
        }
    }

    private var seasonChips: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(presenter.seasons, id: \.seasonNumber) { season in
                        let isSelected = presenter.selectedSeason?.seasonNumber == season.seasonNumber

                        Button {
                            presenter.selectSeason(season)
                        } label: {
                            Text(season.chipTitle)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(isSelected ? DashboardDesign.surface : DashboardDesign.secondaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 7)
                                .frame(minHeight: 34)
                                .background(isSelected ? DashboardDesign.accent : DashboardDesign.surface, in: Capsule())
                                .overlay {
                                    Capsule().strokeBorder(isSelected ? Color.clear : DashboardDesign.border)
                                        .allowsHitTesting(false)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                        .id(season.seasonNumber)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onChange(of: presenter.selectedSeason?.seasonNumber, initial: true) { previous, current in
                guard let current else { return }
                withAnimation(previous == current || reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    proxy.scrollTo(current, anchor: .center)
                }
            }
        }
    }

    private func episodePreview(_ season: TvShowSeasonModel) -> some View {
        let state = presenter.seasonDetails.state(for: season.seasonNumber)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                DetailSectionHeading("Episodes")

                if case .loaded(let episodes) = state, episodes.count > 3 {
                    presenter.toEpisodeList(for: season, episodes: episodes) {
                        Text("See All Episodes")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(DashboardDesign.accent)
                    }
                    .buttonStyle(.plain)
                }
            }

            switch state {
            case .idle, .loading:
                ProgressView("Loading episodes")
                    .frame(maxWidth: .infinity, minHeight: 64)
            case .loaded(let episodes) where episodes.isEmpty:
                sectionMessage("No episodes available")
            case .loaded(let episodes):
                ForEach(episodes.prefix(3), id: \.episodeNumber) { episode in
                    episodePreviewRow(episode)
                }
            case .failed:
                sectionMessage("Couldn’t load episodes")
                Button("Retry") { presenter.seasonDetails.load(seasonNumber: season.seasonNumber) }
                    .font(.footnote.weight(.semibold))
            }
        }
    }

    private func episodePreviewRow(_ episode: TvShowSeasonDetailModel) -> some View {
        let airDate = episode.airDate.formatDateString(output: "MMM d, yyyy")

        return HStack(spacing: 12) {
            Text(episode.episodeCode)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DashboardDesign.accent)
                .padding(.horizontal, 8)
                .frame(minWidth: 44, minHeight: 40)
                .background(DashboardDesign.surfaceDim, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(episode.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DashboardDesign.text)
                if !airDate.isEmpty {
                    Text(airDate)
                        .font(.caption)
                        .foregroundStyle(DashboardDesign.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                .strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
        .accessibilityElement(children: .combine)
    }

    private func topCast(inset: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionHeading("Top cast", seeAll: true)
                .padding(.horizontal, inset)

            if presenter.topCast.isEmpty {
                sectionMessage("No cast available")
                    .padding(.horizontal, inset)
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 12) {
                        ForEach(presenter.topCast) { credit in
                            presenter.toPersonView(for: credit.id) {
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
    private func seriesInfo(_ show: TvShowDetailModel) -> some View {
        let fields: [(label: String, value: String)] = [
            ("Creator", show.creators ?? ""),
            ("First aired", show.releaseDate.formatDateString(output: "MMM d, yyyy")),
            ("Executive producer", show.executiveProducers ?? ""),
            ("Status", show.status)
        ].filter { !$0.1.isEmpty }

        if !fields.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                DetailSectionHeading("Series info")

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .topLeading),
                                         count: dynamicTypeSize.isAccessibilitySize ? 1 : 2),
                          alignment: .leading, spacing: 12) {
                    ForEach(fields, id: \.label) { field in
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

    private func similarShows(inset: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailSectionHeading("Similar Shows", seeAll: true)
                .padding(.horizontal, inset)

            switch presenter.similarShows {
            case .idle, .loading:
                ProgressView("Loading similar shows")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            case .loaded(let shows) where shows.isEmpty:
                sectionMessage("No similar shows available")
                    .padding(.horizontal, inset)
            case .loaded(let shows):
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 12) {
                        ForEach(shows) { show in
                            presenter.toSimilarShow(for: show.id) {
                                DetailPosterCard(title: show.title, posterPath: show.posterPath, releaseDate: show.releaseDate)
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, inset, for: .scrollContent)
                .scrollIndicators(.hidden)
            case .failed:
                VStack(alignment: .leading, spacing: 6) {
                    sectionMessage("Couldn’t load similar shows")
                    Button("Retry") { presenter.loadSimilarShows() }
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
        DetailRouter().makeTvShowDetailView(for: 95396)
    }
}
