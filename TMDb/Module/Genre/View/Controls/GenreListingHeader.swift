import SwiftUI

struct GenreListingHeader: View {
    let title: String
    let count: Int
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DashboardDesign.text)
                    .frame(width: 34, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: 2) {
                Text("\(title) Movies")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(DashboardDesign.text)
                Text("\(count) titles available")
                    .font(.system(size: 11))
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
            .padding(.top, 3)
        }
    }
}

#if DEBUG
#Preview("GenreListingHeader") {
    GenreListingHeader(title: "Sci-Fi", count: 3, dismiss: {})
}
#endif
