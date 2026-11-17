import SwiftUI

struct EpisodeSearchField: View {
    @Binding var query: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .accessibilityHidden(true)
            TextField("Search by title or episode number", text: $query)
                .font(.subheadline)
                .foregroundStyle(DashboardDesign.text)
                .submitLabel(.search)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .foregroundStyle(DashboardDesign.secondaryText)
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                .strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
    }
}

#if DEBUG
#Preview("EpisodeSearchField") {
    EpisodeSearchField(query: .constant("Return"))
}
#endif
