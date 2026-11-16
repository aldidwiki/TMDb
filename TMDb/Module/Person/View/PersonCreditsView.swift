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
                                .toolbar(.visible, for: .navigationBar)
                        } label: {
                            creditRow(item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }

    private func creditRow(_ item: PersonPresenter.CreditListItem) -> some View {
        let mediaLabel: String
        let fallbackColor: Color

        switch item.id {
        case .movie:
            mediaLabel = "Movie"
            fallbackColor = DashboardDesign.color(0x493255)
        case .tv:
            if item.episodeCount > 0 {
                let episodes = item.episodeCount == 1 ? "episode" : "episodes"
                mediaLabel = "TV • \(item.episodeCount.formatted()) \(episodes)"
            } else {
                mediaLabel = "TV"
            }
            fallbackColor = DashboardDesign.color(0x1C5060)
        }

        let shape = RoundedRectangle(cornerRadius: DashboardDesign.cardRadius)

        return HStack(spacing: 12) {
            fallbackColor
                .frame(width: 82, height: 114)
                .overlay {
                    if !item.posterPath.isEmpty, let url = URL(string: API.imageBaseUrl + item.posterPath) {
                        WebImage(url: url)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.releaseYear.map { "\(item.title) (\($0))" } ?? item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DashboardDesign.text)

                if !item.roles.isEmpty {
                    Text(item.roles.joined(separator: " · "))
                        .font(.footnote)
                }

                Text(mediaLabel)
                    .font(.caption)
            }
            .foregroundStyle(DashboardDesign.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(DashboardDesign.surface, in: shape)
        .overlay {
            shape.strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
    }

    private func insetContent<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
            .padding(.horizontal, contentInset)
            .frame(maxWidth: .infinity)
    }
}
