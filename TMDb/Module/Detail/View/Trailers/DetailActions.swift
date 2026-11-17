import SwiftUI

struct DetailActions: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let videos: [VideoModel]
    let isFavorite: Bool
    @Binding var presentedTrailers: [TrailerLink]?
    let onFavoriteToggle: () -> Bool

    var body: some View {
        let trailers = videos.compactMap(TrailerLink.init)
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))

        return layout {
            if trailers.count > 1 {
                Button {
                    presentedTrailers = trailers
                } label: {
                    trailerLabel
                }
                .buttonStyle(.plain)
            } else if let trailer = trailers.first {
                Link(destination: trailer.url) {
                    trailerLabel
                }
                .buttonStyle(.plain)
            }

            AnimatedFavoriteButton(isFavorite: isFavorite, onToggle: onFavoriteToggle)
        }
    }

    private var trailerLabel: some View {
        Label("Watch Trailer", systemImage: "play.fill")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(DashboardDesign.surface)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(DashboardDesign.accent, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
    }
}

#if DEBUG
#Preview("DetailActions") {
    DetailActions(videos: [PreviewFixtures.video], isFavorite: false, presentedTrailers: .constant(nil), onFavoriteToggle: { true })
}
#endif
