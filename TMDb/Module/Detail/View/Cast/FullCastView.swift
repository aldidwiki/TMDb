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

#if DEBUG
#Preview("FullCastView") {
    NavigationStack { FullCastView(title: "The Last Horizon", media: .movie, cast: [PreviewFixtures.credit]) }
}
#endif
