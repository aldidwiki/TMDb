import SwiftUI

struct ExploreResults: View {
    let items: [ExploreItem]
    let feed: ExplorePresenter.Feed
    let category: ExploreCategory
    let title: String
    let hasMore: Bool
    let genres: (ExploreItem) -> [String]
    let retry: () -> Void
    let resetFilters: () -> Void
    let selectCollection: (ExploreCollection) -> Void
    let loadMore: () -> Void

    var body: some View {
        if !feed.hasLoaded && (feed.isLoading || feed.failed.isEmpty) {
            ScrollView {
                VStack(spacing: 12) {
                    ProgressView("Loading results…")
                        .font(.footnote)
                        .padding(.vertical, 8)

                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: DashboardDesign.cardRadius)
                            .fill(DashboardDesign.surfaceDim)
                            .frame(height: 140)
                            .accessibilityHidden(true)
                    }
                }
                .frame(maxWidth: DashboardDesign.contentWidth)
                .padding(.horizontal, DashboardDesign.contentInset)
                .frame(maxWidth: .infinity)
            }
        } else if items.isEmpty && !feed.failed.isEmpty {
            ContentUnavailableView {
                Label("Couldn’t load results", systemImage: "wifi.exclamationmark")
            } actions: {
                Button("Retry") { retry() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if items.isEmpty && !hasMore {
            ContentUnavailableView {
                Label("No results found", systemImage: "magnifyingglass")
            } description: {
                Text("Reset filters or try another category.")
            } actions: {
                if feed.settings.filters.isActive {
                    Button("Reset Filters") { resetFilters() }
                } else if feed.settings.collection != nil {
                    Button("Browse \(category.rawValue)") {
                        if let collection = feed.settings.collection { selectCollection(collection) }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(DashboardDesign.text)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(items) { item in
                        NavigationLink(value: item.id) {
                            ExploreCard(item: item, genres: genres(item))
                        }
                        .buttonStyle(.plain)
                    }

                    paginationFooter(items: items, feed: feed)
                }
                .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
                .padding(.horizontal, DashboardDesign.contentInset)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
            }
            .id(feed.revision)
        }
    }

    @ViewBuilder
    private func paginationFooter(items: [ExploreItem], feed: ExplorePresenter.Feed) -> some View {
        if !feed.failed.isEmpty {
            VStack(spacing: 7) {
                Text("Couldn’t load more results.")
                    .font(.footnote)
                    .foregroundStyle(DashboardDesign.secondaryText)
                Button("Retry") { retry() }
            }
            .frame(maxWidth: .infinity)
        } else if hasMore {
            if items.isEmpty {
                VStack(spacing: 7) {
                    Text("No matches in results loaded so far.")
                        .font(.footnote)
                        .foregroundStyle(DashboardDesign.secondaryText)
                    if feed.isLoading {
                        ProgressView("Loading more…")
                    } else {
                        Button("Load more") { loadMore() }
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                ProgressView("Loading more…")
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .task(id: feed.nextPages) { loadMore() }
            }
        }
    }
}

#if DEBUG
#Preview("ExploreResults") {
    NavigationStack {
        ExploreResults(items: [PreviewFixtures.explore], feed: .init(hasLoaded: true),
                       category: .movies, title: "Movies", hasMore: false, genres: { _ in ["Science Fiction"] },
                       retry: {}, resetFilters: {}, selectCollection: { _ in }, loadMore: {})
    }
}
#endif
