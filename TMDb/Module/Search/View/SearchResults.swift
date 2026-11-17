import SwiftUI

struct SearchResults: View {
    let phase: SearchPresenter.Phase
    let filter: SearchPresenter.Filter
    let results: [SearchModel]
    let canLoadMore: Bool
    let isLoadingMore: Bool
    let hasPaginationError: Bool
    let onRetry: () -> Void
    let onLoadMore: () -> Void

    var body: some View {
        switch phase {
        case .idle:
            ContentUnavailableView("Search TMDb", systemImage: "magnifyingglass")
                .frame(maxHeight: .infinity)
        case .loading:
            ProgressView("Searching")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed:
            ContentUnavailableView {
                Label("Couldn’t load results", systemImage: "wifi.exclamationmark")
            } actions: {
                Button("Retry", action: onRetry)
            }
            .frame(maxHeight: .infinity)
        case .results:
            resultsList
        }
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if results.isEmpty {
                    ContentUnavailableView {
                        Label("No results", systemImage: "magnifyingglass")
                    } description: {
                        Text(canLoadMore ? "Load more results or change the filter." : "Try another search or filter.")
                    }
                }

                ForEach(results) { result in
                    resultCard(result)
                        .onAppear {
                            if result.id == results.last?.id && !hasPaginationError {
                                onLoadMore()
                            }
                        }
                }

                if canLoadMore {
                    paginationFooter
                }
            }
            .frame(maxWidth: DashboardDesign.contentWidth)
            .padding(.horizontal, DashboardDesign.contentInset)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .id(filter)
    }

    @ViewBuilder
    private var paginationFooter: some View {
        if isLoadingMore {
            ProgressView("Loading more results")
                .padding(.vertical, 12)
        } else {
            Button(
                hasPaginationError ? "Couldn’t load more. Retry" : "Load more",
                action: onLoadMore
            )
            .font(.footnote.weight(.semibold))
            .foregroundStyle(DashboardDesign.accent)
            .frame(minHeight: 44)
        }
    }

    @ViewBuilder
    private func resultCard(_ result: SearchModel) -> some View {
        if result.id.mediaType == .person {
            NavigationLink(value: result.id) {
                SearchPersonCard(result: result)
            }
            .buttonStyle(.plain)
        } else {
            SearchMediaCard(result: result)
        }
    }
}

#if DEBUG
#Preview("SearchResults") {
    NavigationStack {
        SearchResults(phase: .results, filter: .all, results: [PreviewFixtures.search, PreviewFixtures.personSearch],
                      canLoadMore: false, isLoadingMore: false, hasPaginationError: false, onRetry: {}, onLoadMore: {})
    }
}
#endif
