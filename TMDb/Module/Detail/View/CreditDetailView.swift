//
//  CreditDetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/06/23.
//

import SwiftUI

struct CreditDetailView: View {
    @ObservedObject var presenter: CreditDetailPresenter
    var creditModelList: [CreditModel]
    
    var body: some View {
        List(creditModelList) { credit in
            if presenter.navigateType == NavigateType.personView {
                presenter.toPersonView(for: credit.id) {
                    CreditDetailItemView(creditModel: credit)
                }
            } else {
                presenter.toMovieDetailView(for: credit.id) {
                    CreditDetailItemView(creditModel: credit)
                }
            }
        }
        .listStyle(.plain)
    }
}

struct CreditDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CreditDetailView(
            presenter: CreditDetailPresenter(navigateType: NavigateType.personView),
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
