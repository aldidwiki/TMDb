import SDWebImageSwiftUI
import SwiftUI

struct PersonCreditsView: View {
    @Environment(\.dismiss) private var dismiss

    let personName: String
    let items: [PersonPresenter.CreditListItem]

    private let router = PersonRouter()
    private let contentInset: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {
            header
            personHeading

            if items.isEmpty {
                ContentUnavailableView("No credits available", systemImage: "film")
                    .frame(maxHeight: .infinity)
            } else {
                creditsList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DashboardDesign.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        insetContent {
            HStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")

                Text("All credits")
                    .font(.title3.bold())
                    .accessibilityAddTraits(.isHeader)
            }
            .foregroundStyle(DashboardDesign.text)
            .frame(minHeight: 52)
        }
    }

    private var personHeading: some View {
        insetContent {
            VStack(alignment: .leading, spacing: 4) {
                Text(personName)
                    .font(.title2.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)

                Text("Movies and TV shows")
                    .font(.subheadline)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
            .padding(.vertical, 16)
        }
        .background(DashboardDesign.surface)
    }

    private var creditsList: some View {
        ScrollView {
            insetContent {
                LazyVStack(spacing: 8) {
                    ForEach(items) { item in
                        NavigationLink {
                            router.destination(for: item.id)
                        } label: {
                            PersonCreditRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }

    private func insetContent<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
            .padding(.horizontal, contentInset)
            .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview("PersonCreditsView") {
    NavigationStack { PersonCreditsView(personName: "Alex Morgan", items: [PreviewFixtures.creditItem]) }
}
#endif
