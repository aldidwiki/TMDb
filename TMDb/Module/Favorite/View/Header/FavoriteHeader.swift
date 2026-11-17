import SwiftUI

struct FavoriteHeader: View {
    let count: Int
    let sort: FavoritePresenter.Sort
    let openSort: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 12) {
                heading(count: count)
                Spacer(minLength: 0)
                sortButton
            }

            VStack(alignment: .leading, spacing: 8) {
                heading(count: count)
                sortButton
            }
        }
        .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
        .padding(.horizontal, DashboardDesign.contentInset)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }

    private func heading(count: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Favorites")
                .font(.title3.bold())
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)

            Text(count == 1 ? "1 favorite" : "\(count) favorites")
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    private var sortButton: some View {
        Button {
            openSort()
        } label: {
            Label(sort.rawValue, systemImage: "arrow.up.arrow.down")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.accent)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 12)
                .frame(minHeight: 32)
                .modifier(FavoriteSurface(radius: DashboardDesign.controlRadius))
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Sort favorites")
        .accessibilityValue(sort.rawValue)
    }
}

#if DEBUG
#Preview("FavoriteHeader") {
    FavoriteHeader(count: 2, sort: FavoritePresenter.Sort.allCases[0], openSort: {})
}
#endif
