//
//  TvShowRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 12/08/23.
//

import Foundation
import SwiftUI

class TvShowRouter {
    func makeTvShowDetailView(for tvShowId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        return TvShowDetailView(tvShowUseCase: tvShowUseCase, tvShowId: tvShowId)
    }
}
