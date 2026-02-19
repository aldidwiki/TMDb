//
//  SearchView.swift
//  TMDb
//
//  Created by Macbook on 13/02/26.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var presenter: SearchPresenter
    
    var body: some View {
        NavigationStack {
            ZStack {
                if presenter.loadingState {
                    ProgressView("Loading")
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            if presenter.searchResults.isEmpty {
                                VStack {
                                    Spacer()
                                    ContentUnavailableView.search(text: presenter.searchQuery)
                                    Spacer()
                                }
                                .animation(.default, value: presenter.searchResults.isEmpty)
                                .frame(minHeight: geometry.size.height)
                                .id("EMPTY_STATE")
                            } else {
                                LazyVStack {
                                    ForEach(presenter.searchResults) { searchResult in
                                        VStack {
                                            self.presenter.linkBuilder(
                                                for: searchResult.id,
                                                mediaType: searchResult.mediaType
                                            ) {
                                                searchResult.destinationView()
                                            }
                                            
                                            if searchResult != self.presenter.searchResults.last {
                                                NativeDivider()
                                            }
                                        }
                                        .onAppear {
                                            if searchResult == self.presenter.searchResults.last {
                                                self.presenter.search(query: self.presenter.searchQuery)
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
            }
            .navigationTitle("Search")
            .searchable(text: $presenter.searchQuery, prompt: "Look for something")
        }
    }
}

#Preview {
    let useCase = Injection.init().provideSearchUseCase()
    SearchView(presenter: SearchPresenter(searchUseCase: useCase))
}
