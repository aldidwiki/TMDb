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
                header(isEmpty: isEmpty)
                    .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
                    .padding(.horizontal, DashboardDesign.contentInset)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                results(items: items, feed: feed)
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

    private func header(isEmpty: Bool) -> some View {
        let settings = presenter.feed.settings

        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(isEmpty ? "No results" : title)
                    .font(.title3.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)
                Text(isEmpty ? "Try adjusting your filters" : subtitle)
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(ExploreCategory.allCases, id: \.self) { category in
                        ExploreChip(
                            title: category.rawValue,
                            selected: presenter.category == category
                        ) { presenter.selectCategory(category) }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.vertical, 2)

            if presenter.category == .all {
                Text("Browse all content types")
                    .font(.footnote)
                    .foregroundStyle(DashboardDesign.secondaryText)
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 7) {
                        ForEach(presenter.category.collections, id: \.self) { option in
                            ExploreChip(title: option.rawValue, selected: settings.collection == option) {
                                presenter.selectCollection(option)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }

            HStack(spacing: 10) {
                ExploreChip(title: "Filter", symbol: "slider.horizontal.3", selected: settings.filters.isActive) {
                    draftFilters = settings.filters
                    present(.filters)
                }
                Spacer(minLength: 0)
                ExploreChip(title: settings.sort?.rawValue ?? "Sort", symbol: "arrow.up.arrow.down",
                            selected: settings.sort != nil) {
                    draftSort = settings.effectiveSort
                    present(.sort)
                }
            }
        }
    }

    @ViewBuilder
    private func results(items: [ExploreItem], feed: ExplorePresenter.Feed) -> some View {
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
                Button("Retry") { presenter.retry() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if items.isEmpty && !presenter.hasMore {
            ContentUnavailableView {
                Label("No results found", systemImage: "magnifyingglass")
            } description: {
                Text("Reset filters or try another category.")
            } actions: {
                if feed.settings.filters.isActive {
                    Button("Reset Filters") { presenter.applyFilters(ExploreFilters()) }
                } else if feed.settings.collection != nil {
                    Button("Browse \(presenter.category.rawValue)") {
                        if let collection = feed.settings.collection { presenter.selectCollection(collection) }
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
                            ExploreCard(item: item, genres: presenter.genreLabels(for: item))
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
                Button("Retry") { presenter.retry() }
            }
            .frame(maxWidth: .infinity)
        } else if presenter.hasMore {
            if items.isEmpty {
                VStack(spacing: 7) {
                    Text("No matches in results loaded so far.")
                        .font(.footnote)
                        .foregroundStyle(DashboardDesign.secondaryText)
                    if feed.isLoading {
                        ProgressView("Loading more…")
                    } else {
                        Button("Load more") { presenter.loadMore() }
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                ProgressView("Loading more…")
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .task(id: feed.nextPages) { presenter.loadMore() }
            }
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

struct ExploreChip: View {
    let title: String
    var symbol: String? = nil
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let symbol {
                    Image(systemName: symbol)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .multilineTextAlignment(.center)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(selected ? DashboardDesign.surface : DashboardDesign.secondaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(minHeight: 34)
            .background(selected ? DashboardDesign.accent : DashboardDesign.surface, in: Capsule())
            .overlay {
                Capsule().strokeBorder(selected ? Color.clear : DashboardDesign.border)
                    .allowsHitTesting(false)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
