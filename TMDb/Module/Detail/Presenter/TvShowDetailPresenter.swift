//
//  TvShowDetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Combine
import Observation
import SwiftUI

@MainActor
@Observable
final class TvShowDetailPresenter {
    private let router = DetailRouter()
    private let tvShowUseCase: TvShowUseCase
    private let favoriteUseCase: FavoriteUseCase
    private let tvShowId: Int
    private var detailRequest: AnyCancellable?

    let seasonDetails: TvShowSeasonDetailPresenter
    private(set) var tvShow: TvShowDetailModel?
    private(set) var isLoading = false
    private(set) var detailFailed = false
    let similarTitles: SimilarTitlesPresenter
    private(set) var seasons: [TvShowSeasonModel] = []
    private(set) var selectedSeason: TvShowSeasonModel?
    private(set) var isFavorite = false
    var showsFavoriteError = false

    init(tvShowUseCase: TvShowUseCase, favoriteUseCase: FavoriteUseCase, tvShowId: Int) {
        self.tvShowUseCase = tvShowUseCase
        self.favoriteUseCase = favoriteUseCase
        self.tvShowId = tvShowId
        seasonDetails = TvShowSeasonDetailPresenter(tvShowUseCase: tvShowUseCase, tvShowId: tvShowId)
        similarTitles = SimilarTitlesPresenter(sourceID: tvShowId) { page in
            tvShowUseCase.getSimilarTvShows(tvShowId: tvShowId, page: page)
        }
    }

    var cast: [CreditModel] {
        CreditModel.castInBillingOrder(tvShow?.credits ?? [])
    }

    var regularSeasonCount: Int {
        seasons.filter { $0.seasonNumber > 0 }.count
    }

    func load() {
        if tvShow == nil && !detailFailed { loadTvShow() }
        similarTitles.load()
    }

    func loadTvShow() {
        guard !isLoading else { return }
        isLoading = true
        detailFailed = false

        detailRequest = tvShowUseCase.getTvShow(tvShowId: tvShowId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                isLoading = false
                if case .failure = completion { detailFailed = true }
                if tvShow == nil { detailFailed = true }
            } receiveValue: { [weak self] show in
                guard let self else { return }
                tvShow = show

                var seen: Set<Int> = []
                let regular = show.seasons.filter {
                    $0.seasonNumber > 0 && seen.insert($0.seasonNumber).inserted
                }.sorted { $0.seasonNumber < $1.seasonNumber }
                let specials = show.seasons.first { $0.seasonNumber == 0 }
                seasons = regular + (specials.map { [$0] } ?? [])

                let today = Date.now.formatted(
                    Date.ISO8601FormatStyle(timeZone: .current).year().month().day()
                )
                let airedSeason = regular.last {
                    let date = $0.seasonAirDate
                    return date.count == 10 && date <= today
                }
                if let season = airedSeason ?? regular.first ?? specials {
                    selectSeason(season)
                }
            }
    }

    func selectSeason(_ season: TvShowSeasonModel) {
        selectedSeason = season
        seasonDetails.load(seasonNumber: season.seasonNumber)
    }

    func checkFavoriteStatus() {
        do {
            isFavorite = try favoriteUseCase.isFavorited(.init(mediaType: .tv, mediaID: tvShowId))
        } catch {
            showsFavoriteError = true
        }
    }

    func toggleFavorite() -> Bool {
        guard let tvShow, tvShow.id > 0 else { return false }
        let previousValue = isFavorite
        do {
            isFavorite = try favoriteUseCase.toggleFavorite(Mapper.mapTvShowToFavorite(tvShow))
        } catch {
            showsFavoriteError = true
        }
        return previousValue != isFavorite
    }

    func toPersonView<Content: View>(for personId: Int, @ViewBuilder content: () -> Content) -> some View {
        NavigationLink {
            router.makePersonDetailView(for: personId)
        } label: {
            content()
        }
        .buttonStyle(.plain)
    }

    func toFullCast<Content: View>(
        title: String,
        cast: [CreditModel],
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink {
            router.makeFullCastView(title: title, media: .tv, cast: cast)
        } label: {
            content()
        }
        .buttonStyle(.plain)
    }

    func toEpisodeList<Content: View>(
        for season: TvShowSeasonModel,
        episodes: [TvShowSeasonDetailModel],
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink {
            router.makeTvShowEpisodeView(season: season, episodes: episodes)
        } label: {
            content()
        }
    }

    func toTvShowImageGallery<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        NavigationLink {
            router.makeTvShowImageGalleryView(tvShowId: tvShowId, title: title)
        } label: {
            content()
        }
        .buttonStyle(.plain)
    }
}
