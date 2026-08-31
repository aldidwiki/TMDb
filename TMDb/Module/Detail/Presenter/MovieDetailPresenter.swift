//
//  DetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI
import Combine
import Observation

@Observable
class MovieDetailPresenter {
    private var cancellable: Set<AnyCancellable> = []
    
    private let router = DetailRouter()
    
    private let detailUseCase: DetailUseCase
    private let favoriteUseCase: FavoriteUseCase
    
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
    
    init(detailUseCase: DetailUseCase, favoriteUseCase: FavoriteUseCase) {
        self.detailUseCase = detailUseCase
        self.favoriteUseCase = favoriteUseCase
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
        favoriteUseCase.isFavorited(mediaId: movieId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorited in
                self?.isFavorite = isFavorited
            }
            .store(in: &cancellable)
    }
    
    func toggleFavorite() {
        let request = FavoriteRequest(mediaType: "movie", mediaId: movie.id, isFavorite: !isFavorite)
        
        favoriteUseCase
            .addToFavorite(request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                guard isSuccess, let self = self else { return }
                self.isFavorite = !self.isFavorite
            }
            .store(in: &cancellable)
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
