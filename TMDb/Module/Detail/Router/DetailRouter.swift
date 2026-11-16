//
//  DetailRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation
import SwiftUI

class DetailRouter {
    func makeMovieDetailView(for movieId: Int) -> some View {
        let injection = Injection()
        return MovieDetailView(
            detailUseCase: injection.provideDetailUseCase(),
            favoriteUseCase: injection.provideFavoriteUseCase(),
            movieId: movieId
        )
    }

    func makeTvShowDetailView(for tvShowId: Int) -> some View {
        let injection = Injection()
        return TvShowDetailView(
            tvShowUseCase: injection.provideTvShowUseCase(),
            favoriteUseCase: injection.provideFavoriteUseCase(),
            tvShowId: tvShowId
        )
    }

    func makeSimilarTitlesView(
        sourceTitle: String,
        genres: String,
        media: SimilarTitlesView.Media,
        presenter: SimilarTitlesPresenter
    ) -> some View {
        SimilarTitlesView(sourceTitle: sourceTitle, genres: genres, media: media, presenter: presenter)
    }

    @ViewBuilder
    func makeSimilarTitleDetailView(for id: Int, media: SimilarTitlesView.Media) -> some View {
        switch media {
        case .movie: makeMovieDetailView(for: id)
        case .tv: makeTvShowDetailView(for: id)
        }
    }

    func makePersonDetailView(for personId: Int) -> some View {
        let personUseCase = Injection.init().providePersonUseCase()
        return PersonDetailView(
            personUseCase: personUseCase,
            personId: personId
        )
    }
    
    func makeFullCastView(title: String, media: FullCastView.Media, cast: [CreditModel]) -> some View {
        FullCastView(title: title, media: media, cast: cast)
    }
    
    func makeTvShowEpisodeView(season: TvShowSeasonModel, episodes: [TvShowSeasonDetailModel]) -> some View {
        TvShowEpisodeView(season: season, episodes: episodes)
    }
    
    func makeMovieImageGalleryView(movieId: Int, title: String) -> some View {
        let useCase = Injection().provideDetailUseCase()
        return BackdropGalleryView(title: title) {
            useCase.getMovieBackdrops(movieId: movieId)
        }
    }
    
    func makeTvShowImageGalleryView(tvShowId: Int, title: String) -> some View {
        let useCase = Injection().provideTvShowUseCase()
        return BackdropGalleryView(title: title) {
            useCase.getTvShowBackdrop(tvId: tvShowId)
        }
    }
}
