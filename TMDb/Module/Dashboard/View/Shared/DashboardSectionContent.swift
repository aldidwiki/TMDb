import SwiftUI

struct DashboardSectionContent<Item, Content: View>: View {
    let state: DashboardPresenter.SectionState<Item>
    let emptyTitle: String
    let retry: () -> Void
    @ViewBuilder let content: ([Item]) -> Content

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 78)
        case .loaded(let items) where items.isEmpty:
            Text(emptyTitle)
                .font(.footnote)
                .foregroundStyle(DashboardDesign.secondaryText)
                .frame(maxWidth: .infinity, minHeight: 78)
        case .loaded(let items):
            content(items)
        case .failed:
            VStack(spacing: 8) {
                Text("Couldn’t load this section.")
                    .foregroundStyle(DashboardDesign.secondaryText)
                Button("Retry", action: retry)
                    .tint(DashboardDesign.accent)
            }
            .font(.footnote)
            .frame(maxWidth: .infinity, minHeight: 78)
        }
    }
}

#Preview("Failed section") {
    DashboardSectionContent(state: DashboardPresenter.SectionState<MovieModel>.failed, emptyTitle: "No movies", retry: {}) { _ in
        SwiftUI.EmptyView()
    }
}
