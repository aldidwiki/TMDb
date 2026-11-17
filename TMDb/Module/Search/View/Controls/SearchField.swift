import SwiftUI

struct SearchField: View {
    @Binding var query: String
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .accessibilityHidden(true)

            TextField("Search movies, shows, people", text: $query)
                .foregroundStyle(DashboardDesign.text)
                .submitLabel(.search)
                .focused($isSearchFocused)
                .onSubmit { isSearchFocused = false }

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .font(.subheadline)
        .foregroundStyle(DashboardDesign.secondaryText)
        .padding(.leading, 14)
        .padding(.trailing, query.isEmpty ? 14 : 0)
        .frame(minHeight: 48)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                .strokeBorder(isSearchFocused ? DashboardDesign.accent : DashboardDesign.border)
                .allowsHitTesting(false)
        }
    }
}

#if DEBUG
#Preview("SearchField") {
    SearchField(query: .constant("Horizon"))
}
#endif
