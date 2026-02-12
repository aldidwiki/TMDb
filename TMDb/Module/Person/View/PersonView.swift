//
//  PersonView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/10/23.
//

import SwiftUI

struct PersonView: View {
    @ObservedObject var presenter: PersonPresenter
    
    var body: some View {
        NavigationStack {
            ZStack {
                if presenter.loadingState {
                    ProgressView("Loading")
                } else {
                    if presenter.personPopular.isEmpty {
                        EmptyView(emptyTitle: "No Person Found")
                    } else {
                        ScrollView {
                            LazyVStack {
                                ForEach(self.presenter.personPopular) { personPopular in
                                    self.presenter.toPersonDetailView(personId: personPopular.id) {
                                        VStack {
                                            PersonItemView(personPopular: personPopular)
                                            
                                            if personPopular != self.presenter.personPopular.last {
                                                NativeDivider()
                                            }
                                        }
                                    }
                                    .onAppear {
                                        if personPopular == self.presenter.personPopular.last {
                                            self.presenter.getPopularPerson()
                                        }
                                    }
                                }
                                
                                if presenter.isFetchingMore {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .onAppear {
                if presenter.personPopular.count == 0 {
                    presenter.getPopularPerson(reset: true)
                }
            }
            .navigationTitle("Popular Person")
        }
    }
}

#Preview {
    PersonView(
        presenter: PersonPresenter(personUseCase: Injection.init().providePersonUseCase())
    )
}
