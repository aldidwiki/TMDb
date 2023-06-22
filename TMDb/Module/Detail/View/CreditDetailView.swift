//
//  CreditDetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/06/23.
//

import SwiftUI

struct CreditDetailView: View {
    @ObservedObject var presenter: CreditDetailPresenter
    @State var creditModelList: [CreditModel]
    
    @State var isPopularSelected = true
    @State var isNameSelected = false
    @State var isCharacterSelected = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ChipsView(isPopularSelected: $isPopularSelected, isNameSelected: $isNameSelected, isCharactedSelected: $isCharacterSelected)
                .padding(.horizontal)
                .onChange(of: [isNameSelected, isCharacterSelected, isPopularSelected]) { _ in
                    if isNameSelected {
                        self.creditModelList = creditModelList.sorted {
                            $0.name < $1.name
                        }
                    } else if isCharacterSelected {
                        self.creditModelList = creditModelList.sorted {
                            $0.characterName < $1.characterName
                        }
                    } else if isPopularSelected {
                        self.creditModelList = creditModelList.sorted {
                            $0.popularity > $1.popularity
                        }
                    }
                }
            
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
                    order: 0,
                    popularity: 47.542
                ),
                CreditModel(
                    id: 73457,
                    name: "Chris Pratt",
                    profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
                    characterName: "Peter Quill / Star-Lord",
                    order: 0,
                    popularity: 47.542
                ),
                CreditModel(
                    id: 73457,
                    name: "Chris Pratt",
                    profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
                    characterName: "Peter Quill / Star-Lord",
                    order: 0,
                    popularity: 47.542
                )
            ])
    }
}
