//
//  PersonView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/10/23.
//

import SwiftUI

struct PersonView: View {
    @ObservedObject var presenter: PersonPresenter
    @State var personQuery = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                if presenter.loadingState {
                    ProgressView("Loading")
                } else {
                    if presenter.personPopular.isEmpty {
                        EmptyView(emptyTitle: "No Person Found")
                    } else {
                        List(presenter.personPopular) { personPopular in
                            presenter.toPersonDetailView(personId: personPopular.id) {
                                PersonItemView(personPopular: personPopular)
                            }
                        }
                    }
                }
            }.onAppear {
                if presenter.personPopular.count == 0 {
                    presenter.getPopularPerson()
                }
            }
            .navigationTitle("Popular Person")
        }
        .searchable(text: $personQuery, placement: .automatic)
        .onChange(of: personQuery) { _, query in
            if !query.isEmpty {
                presenter.searchPerson(query: query)
            } else {
                presenter.getPopularPerson()
            }
        }
    }
}

#Preview {
    PersonView(
        presenter: PersonPresenter(personUseCase: Injection.init().providePersonUseCase())
    )
}
