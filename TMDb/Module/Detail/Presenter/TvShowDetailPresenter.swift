//
//  TvShowDetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Observation
import Combine
import SwiftUI

@Observable
class TvShowDetailPresenter {
    private var cancellable: Set<AnyCancellable> = []
    
    private let router = DetailRouter()
    private let tvShowUseCase: TvShowUseCase
    private let favoriteUseCase: FavoriteUseCase
    private let maxVisibleNetworks = 3
    
    var isFavorite = false
    var errorMessage = ""
    var loadingState = false
    var tvShow = TvShowDetailModel(
        id: 0,
        backdropPath: "",
        releaseDate: "",
        title: "",
        overview: "",
        posterPath: "",
        tagline: "",
        status: "",
        type: "",
        genre: "",
        rating: 0.0,
        runtime: 0,
        spokenLanguage: "",
        contentRating: "",
        instagramId: "",
        facebookId: "",
        twitterId: "",
        imdbId: "",
        videos: [],
        credits: [],
        networks: [],
        seasons: []
    )
    
    var tvShowImages: [ImageModel] = []
    
    var showMoreButtonForNetworks: Bool {
        return tvShow.networks.count >= maxVisibleNetworks
    }
    
    var isNetworksExpanded: Bool = false
    
    var allowedVisibleNetworks: [NetworkModel] {
        if isNetworksExpanded {
            return tvShow.networks
        } else {
            return tvShow.networks.take(length: maxVisibleNetworks)
        }
    }
    
    init(tvShowUseCase: TvShowUseCase, favoriteUseCase: FavoriteUseCase) {
        self.tvShowUseCase = tvShowUseCase
        self.favoriteUseCase = favoriteUseCase
    }
    
    func getTvShow(tvShowId: Int) {
        self.loadingState = true
        tvShowUseCase.getTvShow(tvShowId: tvShowId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { tvShow in
                self.tvShow = tvShow
            }.store(in: &cancellable)
    }
    
    func checkFavoriteStatus(tvId: Int) {
        favoriteUseCase.isFavorited(mediaId: tvId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorited in
                self?.isFavorite = isFavorited
            }
            .store(in: &cancellable)
    }
    
    func toggleFavorite() {
        let request = FavoriteRequest(mediaType: "tv", mediaId: tvShow.id, isFavorite: !isFavorite)
        
        favoriteUseCase.addToFavorite(request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                guard isSuccess, let self = self else { return }
                self.isFavorite = !self.isFavorite
            }
            .store(in: &cancellable)
    }
    
    func getTvShowBackdrop(tvShowId: Int) {
        tvShowUseCase.getTvShowBackdrop(tvId: tvShowId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { images in
                self.tvShowImages = images
            }.store(in: &cancellable)
        
    }
    
    func toPersonView<Content: View>(
        for personId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makePersonDetailView(for: personId)) {
            content()
        }
        .buttonStyle(.plain)
    }
    
    func toCreditDetailView<Content: View>(
        for creditModel: [CreditModel],
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeCreditDetailView(for: creditModel)) {
            content()
        }
    }
    
    func toTvShowSeasonView<Content: View>(
        for tvShowSeasonList: [TvShowSeasonModel],
        title tvShowTitle: String,
        id tvShowId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeTvShowSeasonView(for: tvShowSeasonList, title: tvShowTitle, id: tvShowId)) {
            content()
        }
    }
    
    func toTvShowEpisodeView<Content: View>(
        tvShowId: Int,
        seasonNumber: Int,
        seasonName: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeTvShowSeasonDetailView(
            tvShowId: tvShowId,
            seasonNumber: seasonNumber,
            seasonName: seasonName
        )) {
            content()
        }
    }
    
    func toTvShowImageGallery<Content: View>(
        tvShowId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeTvShowImageGalleryView(tvShowId: tvShowId)) {
            content()
        }
    }
}
