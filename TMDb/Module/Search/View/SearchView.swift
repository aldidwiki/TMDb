//
//  SearchView.swift
//  TMDb
//
//  Created by Macbook on 13/02/26.
//

import SDWebImageSwiftUI
import SwiftUI

struct SearchView<BottomBar: View>: View {
    @State private var presenter: SearchPresenter

    private let bottomBar: BottomBar
    private let router = SearchRouter()

    init(searchUseCase: SearchUseCase, @ViewBuilder bottomBar: () -> BottomBar) {
        self.init(presenter: SearchPresenter(searchUseCase: searchUseCase), bottomBar: bottomBar)
    }

    fileprivate init(presenter: SearchPresenter, @ViewBuilder bottomBar: () -> BottomBar) {
        _presenter = State(initialValue: presenter)
        self.bottomBar = bottomBar()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    SearchHeading()
                        .padding(.bottom, 24)
                    SearchField(query: $presenter.searchQuery)
                        .padding(.bottom, 8)
                    SearchFilters(selected: $presenter.filter, count: presenter.count)
                    if presenter.phase == .results {
                        SearchResultsHeading(count: presenter.count(for: presenter.filter))
                            .padding(.top, 6)
                            .padding(.bottom, 12)
                    }
                }
                .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
                .padding(.horizontal, DashboardDesign.contentInset)
                .padding(.top, 4)

                SearchResults(
                    phase: presenter.phase, filter: presenter.filter, results: presenter.visibleResults,
                    canLoadMore: presenter.canLoadMore, isLoadingMore: presenter.isLoadingMore,
                    hasPaginationError: presenter.hasPaginationError,
                    onRetry: presenter.retrySearch, onLoadMore: presenter.loadMore
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DashboardDesign.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
            .navigationDestination(for: SearchModel.ID.self) { id in
                router.destination(for: id)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.light)
    }

}

struct SearchCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: DashboardDesign.cardRadius)
                    .strokeBorder(DashboardDesign.border)
                    .allowsHitTesting(false)
            }
    }
}

extension SearchView where BottomBar == SwiftUI.EmptyView {
    init(searchUseCase: SearchUseCase) {
        self.init(searchUseCase: searchUseCase) { SwiftUI.EmptyView() }
    }
}

#if DEBUG
#Preview("Search") {
    SearchView(presenter: PreviewFixtures.searchPresenter()) { SwiftUI.EmptyView() }
}
#endif
