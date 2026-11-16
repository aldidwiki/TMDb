import SwiftUI

struct FullCastView: View {
    enum Media {
        case movie
        case tv

        var label: String {
            switch self {
            case .movie: "Movie"
            case .tv: "TV series"
            }
        }
    }

    let title: String
    let media: Media
    let cast: [CreditModel]

    private let router = DetailRouter()

    var body: some View {
        GeometryReader { geometry in
            let inset = max(16, (geometry.size.width - DashboardDesign.contentWidth) / 2)

            VStack(spacing: 0) {
                DetailToolbar(title: "Full Cast")
                    .padding(.horizontal, inset)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        header

                        ForEach(cast) { credit in
                            NavigationLink {
                                router.makePersonDetailView(for: credit.id)
                            } label: {
                                FullCastRow(credit: credit, media: media)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, inset)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(DashboardDesign.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)

            Text("\(media.label) · \(cast.count) cast")
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 2)
    }
}

private struct FullCastRow: View {
    let credit: CreditModel
    let media: FullCastView.Media

    private var subtitle: String {
        let character = credit.characterName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard media == .tv, credit.episodeCount > 0 else { return character }

        let episodes = credit.episodeCount == 1 ? "1 episode" : "\(credit.episodeCount) episodes"
        return character.isEmpty ? episodes : "\(character) • \(episodes)"
    }

    var body: some View {
        let detail = subtitle
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        HStack(spacing: 10) {
            DetailCastAvatar(credit: credit, diameter: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(credit.name)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DashboardDesign.text)

                if !detail.isEmpty {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(DashboardDesign.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(DashboardDesign.surface, in: shape)
        .overlay {
            shape.strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
    }
}
