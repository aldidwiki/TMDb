//
//  FavoritePresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI
import Combine
import Observation

@Observable
class FavoritePresenter {
    private var cancellable: Set<AnyCancellable> = []
    
    private let router = FavoriteRouter()
    
    func linkBuilder<Content: View>(
        for favoriteModel: FavoriteModel,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink {
            if favoriteModel.mediaType == Constants.movieType {
                router.makeDetailView(movieId: favoriteModel.id)
            } else if favoriteModel.mediaType == Constants.tvType {
                router.makeTvDetailView(tvShowId: favoriteModel.id)
            } else if favoriteModel.mediaType == Constants.personType {
                router.makePersonDetailView(personId: favoriteModel.id)
            }
        } label: {
            content()
        }
        .buttonStyle(.plain)
    }
}
