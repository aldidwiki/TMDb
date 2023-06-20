//
//  CreditDetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/06/23.
//

import Foundation
import SwiftUI

class CreditDetailPresenter: ObservableObject {
    private let router = CreditDetailRouter()
    @Published var navigateType: NavigateType
    
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
    
    func toMovieDetailView<Content: View>(
        for movieId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeMovieDetailView(for: movieId)) {
            content()
        }
    }
}

enum NavigateType {
    case personView
    case detailView
}
