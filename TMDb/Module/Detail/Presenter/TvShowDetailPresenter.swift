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
    enum SimilarShowsState {
        case idle
        case loading
        case loaded([TvShowModel])
        case failed
    }

    private let router = DetailRouter()
    private let tvShowUseCase: TvShowUseCase
    private let favoriteUseCase: FavoriteUseCase
    private let tvShowId: Int
    private var detailRequest: AnyCancellable?
    private var similarRequest: AnyCancellable?

    let seasonDetails: TvShowSeasonDetailPresenter
    private(set) var tvShow: TvShowDetailModel?
    private(set) var isLoading = false
    private(set) var detailFailed = false
    private(set) var similarShows: SimilarShowsState = .idle
    private(set) var seasons: [TvShowSeasonModel] = []
    private(set) var selectedSeason: TvShowSeasonModel?
    private(set) var isFavorite = false
    var showsFavoriteError = false

    init(tvShowUseCase: TvShowUseCase, favoriteUseCase: FavoriteUseCase, tvShowId: Int) {
        self.tvShowUseCase = tvShowUseCase
        self.favoriteUseCase = favoriteUseCase
        self.tvShowId = tvShowId
        seasonDetails = TvShowSeasonDetailPresenter(tvShowUseCase: tvShowUseCase, tvShowId: tvShowId)
    }

    var topCast: [CreditModel] {
        var seen: Set<Int> = []
        let cast = (tvShow?.credits ?? []).sorted { $0.order < $1.order }
        return Array(cast.filter {
            $0.id > 0 && !$0.name.isEmpty && seen.insert($0.id).inserted
        }.prefix(10))
    }

    var regularSeasonCount: Int {
        seasons.filter { $0.seasonNumber > 0 }.count
    }

    func load() {
        if tvShow == nil && !detailFailed { loadTvShow() }
        if case .idle = similarShows { loadSimilarShows() }
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

    func loadSimilarShows() {
        if case .loading = similarShows { return }
        similarShows = .loading

        similarRequest = tvShowUseCase.getSimilarTvShows(tvShowId: tvShowId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure = completion {
                    similarShows = .failed
                } else if case .loading = similarShows {
                    similarShows = .loaded([])
                }
            } receiveValue: { [weak self] shows in
                guard let self else { return }
                var seen: Set<Int> = [tvShowId]
                similarShows = .loaded(Array(shows.filter { $0.id > 0 && seen.insert($0.id).inserted }.prefix(10)))
            }
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

    func toSimilarShow<Content: View>(for tvShowId: Int, @ViewBuilder content: () -> Content) -> some View {
        NavigationLink {
            router.makeTvShowDetailView(for: tvShowId)
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
