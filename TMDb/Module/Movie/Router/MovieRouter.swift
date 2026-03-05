//
//  MovieRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI

class MovieRouter {
    func makeDetailView(for movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase()
        return MovieDetailView(
            detailUseCase: detailUseCase, movieId: movieId
        )
    }
}
