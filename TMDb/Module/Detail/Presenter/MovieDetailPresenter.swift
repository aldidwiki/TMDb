//
//  DetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI
import Combine
import Observation
import SwiftData

@MainActor
@Observable
class MovieDetailPresenter {
    private var cancellable: Set<AnyCancellable> = []
    
    private let router = DetailRouter()
    
    private let detailUseCase: DetailUseCase
    
    var movie = MovieDetailModel(
        id: 0,
        title: "",
        rating: 7.1,
        posterPath: "/bQXAqRx2Fgc46uCVWgoPz5L5Dtr.jpg",
        overview: "Nearly 5,000 years after he was bestowed with the almighty powers of the Egyptian gods—and imprisoned just as quickly—Black Adam is freed from his earthly tomb, ready to unleash his unique form of justice on the modern world.",
        tagline: "The world needed a hero. It got Black Adam.",
        releaseDate: "2022-10-19",
        backdropPath: "/3CxUndGhUcZdt1Zggjdb2HkLLQX.jpg",
        runtime: 125,
        certification: "NR",
        genre: "Action",
        cast: [],
        budget: 1000,
        revenue: 2000,
        status: "Released",
        spokenLanguage: "English",
        instagramId: "",
        facebookId: "",
        twitterId: "",
        imdbId: "",
        videos: []
    )
    var errorMessage = ""
    var loadingState = false
    var movieImages: [ImageModel] = []
    var isFavorite: Bool = false
    
    private var context: ModelContext {
        SwiftDataContextManager.shared.context
    }
    
    init(detailUseCase: DetailUseCase) {
        self.detailUseCase = detailUseCase
    }
    
    func getMovie(movieId: Int) {
        self.loadingState = true
        detailUseCase.getMovie(movieId: movieId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure:
                    self.errorMessage = String(describing: completion)
                case .finished:
                    self.loadingState = false
                }
            } receiveValue: { movie in
                self.movie = movie
            }.store(in: &cancellable)
    }
    
    func getMovieBackdrops(movieId: Int) {
        detailUseCase.getMovieBackdrops(movieId: movieId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure:
                    self .errorMessage = String(describing: completion)
                default:
                    break
                }
            } receiveValue: { imageModel in
                self.movieImages = imageModel
            }.store(in: &cancellable)
    }
    
    func checkFavoriteStatus(movieId: Int) {
        let descriptor = FetchDescriptor<FavoriteEntity>(predicate: #Predicate { $0.id == movieId })
        let results = (try? context.fetch(descriptor)) ?? []
        self.isFavorite = !results.isEmpty
    }
    
    func toggleFavorite() {
        if isFavorite {
            deleteFavorite()
        } else {
            addFavorite()
        }
    }
    
    private func addFavorite() {
        context.insert(Mapper.mapMovieDetailModelToFavoriteEntity(input: movie))
        isFavorite = true
    }
    
    private func deleteFavorite() {
        let movieId = movie.id // Assuming your movie model has an id
        
        // 1. Create a predicate to find the EXISTING entity
        let predicate = #Predicate<FavoriteEntity> { favorite in
            favorite.id == movieId
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
    
    func toPersonDetail<Content: View>(
        for personId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makePersonDetailView(for: personId)) {
            content()
        }
        .buttonStyle(.plain)
    }
    
    func toCreditDetailView<Content: View>(
        for credits: [CreditModel],
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeCreditDetailView(for: credits)) {
            content()
        }
    }
    
    func toMovieImageGallery<Content: View>(
        for movieId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeMovieImageGalleryView(movieId: movieId)) {
            content()
        }
    }
}
