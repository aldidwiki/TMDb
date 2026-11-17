import SwiftUI

struct ExploreHeader: View {
    let category: ExploreCategory
    let settings: ExplorePresenter.Settings
    let isEmpty: Bool
    let title: String
    let subtitle: String
    let onCategory: (ExploreCategory) -> Void
    let onCollection: (ExploreCollection) -> Void
    let onFilter: () -> Void
    let onSort: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                    ForEach(ExploreCategory.allCases, id: \.self) { option in
                        ExploreChip(
                            title: option.rawValue,
                            selected: category == option
                        ) { onCategory(option) }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.vertical, 2)

            if category == .all {
                Text("Browse all content types")
                    .font(.footnote)
                    .foregroundStyle(DashboardDesign.secondaryText)
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 7) {
                        ForEach(category.collections, id: \.self) { option in
                            ExploreChip(title: option.rawValue, selected: settings.collection == option) {
                                onCollection(option)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }

            HStack(spacing: 10) {
                ExploreChip(title: "Filter", symbol: "slider.horizontal.3", selected: settings.filters.isActive) {
                    onFilter()
                }
                Spacer(minLength: 0)
                ExploreChip(title: settings.sort?.rawValue ?? "Sort", symbol: "arrow.up.arrow.down",
                            selected: settings.sort != nil) {
                    onSort()
                }
            }
        }
    }
}

#if DEBUG
#Preview("ExploreHeader") {
    ExploreHeader(category: .all, settings: .init(), isEmpty: false, title: "Explore all",
                  subtitle: "Movies, shows & people", onCategory: { _ in }, onCollection: { _ in },
                  onFilter: {}, onSort: {})
}
#endif
