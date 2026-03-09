//
//  TvShowDetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Observation
import Combine
import SwiftUI
import SwiftData

@MainActor
@Observable
class TvShowDetailPresenter {
    private var cancellable: Set<AnyCancellable> = []
    
    private let router = DetailRouter()
    private let tvShowUseCase: TvShowUseCase
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
    
    private var context: ModelContext {
        SwiftDataContextManager.shared.context
    }
    
    init(tvShowUseCase: TvShowUseCase) {
        self.tvShowUseCase = tvShowUseCase
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
        let descriptor = FetchDescriptor<FavoriteEntity>(predicate: #Predicate { $0.id == tvId })
        let results = (try? context.fetch(descriptor)) ?? []
        isFavorite = !results.isEmpty
    }
    
    func toggleFavorite() {
        if isFavorite {
            deleteFavorite()
        } else {
            addFavorite()
        }
    }
    
    private func addFavorite() {
        context.insert(Mapper.mapTvShowDetailModelToFavoriteEntity(input: tvShow))
        isFavorite = true
    }
    
    private func deleteFavorite() {
        let tvId = tvShow.id // Assuming your movie model has an id
        
        // 1. Create a predicate to find the EXISTING entity
        let predicate = #Predicate<FavoriteEntity> { favorite in
            favorite.id == tvId
        }
        
        // 2. Fetch the entity from the context
        let descriptor = FetchDescriptor<FavoriteEntity>(predicate: predicate)
        
        do {
            // 3. If it exists in the DB, delete THAT specific instance
            if let entityToDelete = try context.fetch(descriptor).first {
                context.delete(entityToDelete)
                isFavorite = false
                // try context.save() // Optional: force the write
            }
        } catch {
            print("Failed to fetch favorite for deletion: \(error)")
        }
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
