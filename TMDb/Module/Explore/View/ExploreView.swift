import SwiftUI

struct ExploreView<BottomBar: View>: View {
    private enum Drawer {
        case filters, sort, years
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var presenter: ExplorePresenter
    @State private var drawer: Drawer?
    @State private var draftFilters = ExploreFilters()
    @State private var draftSort: ExploreSort = .popular
    private let bottomBar: BottomBar
    private let router = ExploreRouter()

    init(useCase: ExploreUseCase, @ViewBuilder bottomBar: () -> BottomBar) {
        _presenter = State(initialValue: ExplorePresenter(useCase: useCase))
        self.bottomBar = bottomBar()
    }

    var body: some View {
        NavigationStack {
            let items = presenter.items
            let feed = presenter.feed
            let isEmpty = feed.hasLoaded && items.isEmpty && feed.failed.isEmpty && !presenter.hasMore

            VStack(spacing: 0) {
                ExploreHeader(
                    category: presenter.category, settings: feed.settings, isEmpty: isEmpty,
                    title: title, subtitle: subtitle, onCategory: presenter.selectCategory,
                    onCollection: presenter.selectCollection,
                    onFilter: {
                        draftFilters = feed.settings.filters
                        present(.filters)
                    },
                    onSort: {
                        draftSort = feed.settings.effectiveSort
                        present(.sort)
                    }
                )
                    .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
                    .padding(.horizontal, DashboardDesign.contentInset)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                ExploreResults(
                    items: items, feed: feed, category: presenter.category, title: title, hasMore: presenter.hasMore,
                    genres: presenter.genreLabels, retry: presenter.retry,
                    resetFilters: { presenter.applyFilters(ExploreFilters()) },
                    selectCollection: presenter.selectCollection, loadMore: presenter.loadMore
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DashboardDesign.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
            .accessibilityHidden(drawer != nil)
            .overlay { drawerOverlay }
            .navigationDestination(for: ExploreItem.ID.self) { id in
                router.destination(for: id)
            }
            .toolbar(.hidden, for: .navigationBar)
            .task { presenter.start() }
        }
        .preferredColorScheme(.light)
        .tint(DashboardDesign.accent)
    }

    private var title: String {
        let category = presenter.category
        let settings = presenter.feed.settings
        if settings.filters.isActive { return "\(category.rawValue) · Filtered" }
        if let sort = settings.sort { return "\(category.rawValue) · \(sort.rawValue)" }
        return settings.collection?.rawValue ?? (category == .all ? "Explore all" : category.rawValue)
    }

    private var subtitle: String {
        let settings = presenter.feed.settings
        if settings.filters.isActive { return settings.filters.summary }
        if let sort = settings.sort { return "Sorted by \(sort.rawValue)" }
        switch presenter.category {
        case .all: return "Movies, shows & people"
        case .movies: return "Find your next favorite film"
        case .shows: return "Explore series worth watching"
        case .people: return "Discover cast and creators"
        }
    }

    private var drawerOverlay: some View {
        ZStack(alignment: .bottom) {
            if let drawer {
                DashboardDesign.text.opacity(0.42)
                    .ignoresSafeArea()
                    .onTapGesture { present(drawer == .years ? .filters : nil) }
                    .accessibilityHidden(true)
                    .transition(.opacity)

                drawerContent(drawer)
                .transition(reduceMotion ? .opacity : .move(edge: .bottom))
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(drawer != nil)
    }

    @ViewBuilder
    private func drawerContent(_ drawer: Drawer) -> some View {
        if drawer == .years {
            YearPicker(
                title: presenter.category == .shows ? "First air year" : "Release year",
                selection: draftFilters.year,
                onCancel: { present(.filters) },
                onUse: { year in
                    draftFilters.year = year
                    present(.filters)
                }
            )
        } else {
            ExploreDrawer(
                category: presenter.category, presenter: presenter,
                filters: $draftFilters, sort: $draftSort, isSort: drawer == .sort,
                onClose: { present(nil) },
                onCategory: { category in
                    presenter.selectCategory(category)
                    present(nil)
                },
                onPickYear: { present(.years) },
                onReset: {
                    presenter.applyFilters(ExploreFilters())
                    present(nil)
                },
                onApply: {
                    if drawer == .sort { presenter.applySort(draftSort) }
                    else { presenter.applyFilters(draftFilters) }
                    present(nil)
                }
            )
        }
    }

    private func present(_ newDrawer: Drawer?) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { drawer = newDrawer }
    }
}


#if DEBUG
#Preview("Explore") {
    ExploreView(useCase: PreviewFixtures.UseCases()) { SwiftUI.EmptyView() }
}
#endif
