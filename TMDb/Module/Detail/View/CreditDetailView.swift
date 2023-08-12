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
    
    @State var isSelected = (popular: false, name: false, character: false, recent: true)
    
    var body: some View {
        VStack(alignment: .leading) {
            ChipsView(isSelected: $isSelected, isPersonCredit: presenter.navigateType == NavigateType.personView ? false : true)
                .padding(.horizontal)
                .onChange(of: [isSelected.name, isSelected.character, isSelected.popular, isSelected.recent]) { _ in
                    if isSelected.name {
                        self.creditModelList = creditModelList.sorted {
                            $0.name < $1.name
                        }
                    } else if isSelected.character {
                        self.creditModelList = creditModelList.sorted {
                            $0.characterName < $1.characterName
                        }
                    } else if isSelected.popular {
                        self.creditModelList = creditModelList.sorted {
                            $0.popularity > $1.popularity
                        }
                    } else if isSelected.recent {
                        self.creditModelList = creditModelList.sorted {
                            $0.releaseDate > $1.releaseDate
                        }
                    } else {
                        self.creditModelList = creditModelList.sorted {
                            $0.order < $1.order
                        }
                    }
                }
            
            if presenter.navigateType == NavigateType.personView {
                List(creditModelList) { credit in
                    presenter.toPersonView(for: credit.id) {
                        CreditDetailItemView(creditModel: credit, isFromPersonView: false)
                    }
                }
                .listStyle(.plain)
                .animation(.default, value: creditModelList)
            } else {
                List(creditModelList) { credit in
                    presenter.toMovieDetailView(for: credit.id) {
                        CreditDetailItemView(creditModel: credit, isFromPersonView: true)
                    }
                }
                .listStyle(.plain)
                .animation(.default, value: creditModelList)
            }
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
                    popularity: 47.542,
                    releaseDate: "",
                    episodeCount: 0
                ),
                CreditModel(
                    id: 73457,
                    name: "Chris Pratt",
                    profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
                    characterName: "Peter Quill / Star-Lord",
                    order: 0,
                    popularity: 47.542,
                    releaseDate: "",
                    episodeCount: 0
                ),
                CreditModel(
                    id: 73457,
                    name: "Chris Pratt",
                    profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
                    characterName: "Peter Quill / Star-Lord",
                    order: 0,
                    popularity: 47.542,
                    releaseDate: "",
                    episodeCount: 0
                )
            ])
    }
}
