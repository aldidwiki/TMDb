//
//  CreditDetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/06/23.
//

import SwiftUI

struct CreditDetailView: View {
    var presenter: DetailPresenter
    var creditModelList: [CreditModel]
    
    var body: some View {
        List(creditModelList) { credit in
            presenter.toPersonDetail(for: credit.id) {
                CreditDetailItemView(creditModel: credit)
            }
        }
        .listStyle(.plain)
    }
}

struct CreditDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let detailUseCase = Injection.init().provideDetailUseCase(movieId: 436270)
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        
        CreditDetailView(
            presenter: DetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase),
            creditModelList: [
                CreditModel(
                    id: 73457,
                    name: "Chris Pratt",
                    profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
                    characterName: "Peter Quill / Star-Lord",
                    order: 0
                ),
                CreditModel(
                    id: 73457,
                    name: "Chris Pratt",
                    profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
                    characterName: "Peter Quill / Star-Lord",
                    order: 0
                ),
                CreditModel(
                    id: 73457,
                    name: "Chris Pratt",
                    profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
                    characterName: "Peter Quill / Star-Lord",
                    order: 0
                )
            ])
    }
}
