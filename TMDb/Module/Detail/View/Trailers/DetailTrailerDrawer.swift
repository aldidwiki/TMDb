import SwiftUI

extension View {
    func detailTrailerDrawer(_ presentedTrailers: Binding<[TrailerLink]?>) -> some View {
        modifier(DetailTrailerOverlay(presentedTrailers: presentedTrailers))
    }
}

private struct DetailTrailerOverlay: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var presentedTrailers: [TrailerLink]?

    func body(content: Content) -> some View {
        content
            .accessibilityHidden(presentedTrailers != nil)
            .overlay { trailerOverlay }
    }

    private var trailerOverlay: some View {
        ZStack(alignment: .bottom) {
            if let trailers = presentedTrailers {
                DashboardDesign.text.opacity(0.42)
                    .ignoresSafeArea()
                    .onTapGesture { presentedTrailers = nil }
                    .accessibilityHidden(true)
                    .transition(.opacity)

                TrailerDrawer(trailers: trailers) { presentedTrailers = nil }
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: presentedTrailers != nil)
        .allowsHitTesting(presentedTrailers != nil)
    }
}

struct TrailerLink: Identifiable {
    let id: String
    let name: String
    let url: URL

    init?(_ video: VideoModel) {
        guard !video.key.isEmpty, let url = URL(string: Constants.youtubeBaseUrl + video.key) else { return nil }
        id = video.id
        name = video.name
        self.url = url
    }
}
