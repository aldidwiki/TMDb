import SwiftUI

enum BottomTab: String, CaseIterable {
    case home = "Home"
    case explore = "Explore"
    case search = "Search"
    case favorites = "Favorites"

    var symbol: String {
        switch self {
        case .home: "house"
        case .explore: "diamond.inset.filled"
        case .search: "magnifyingglass"
        case .favorites: "heart"
        }
    }
}

struct BottomNavigation: View {
    @Binding var activePage: BottomTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(BottomTab.allCases, id: \.self) { tab in
                let isSelected = tab == activePage

                Button {
                    activePage = tab
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab == .favorites && isSelected ? "heart.fill" : tab.symbol)
                            .font(.system(size: 16, weight: .semibold))
                            .accessibilityHidden(true)
                        Text(tab.rawValue)
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundStyle(isSelected ? DashboardDesign.accent : DashboardDesign.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .frame(height: 60)
        .background {
            DashboardDesign.surface.ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            DashboardDesign.border.frame(height: 1)
        }
    }
}

#if DEBUG
#Preview("BottomNavigation") {
    BottomNavigation(activePage: .constant(.home))
}
#endif
