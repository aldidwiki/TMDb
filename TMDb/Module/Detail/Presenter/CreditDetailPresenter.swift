//
//  CreditDetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/06/23.
//

import Observation
import SwiftUI

@Observable
class CreditDetailPresenter {
    private let router = CreditDetailRouter()
    var navigateType: NavigateType
    
    init(navigateType: NavigateType) {
        self.navigateType = navigateType
    }
    
    func toPersonView<Content: View>(
        for personId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makePersonDetailView(for: personId)) {
            content()
        }
    }
    
    func toContentDetailView<Content: View>(
        contentId: Int,
        mediaType: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let contentDestination = if mediaType == Constants.movieResponseType {
            AnyView(router.makeMovieDetailView(for: contentId))
        } else {
            AnyView(router.makeTvShowDetailView(for: contentId))
        }
        
        return NavigationLink(destination: contentDestination) {
            content()
        }
    }
}
