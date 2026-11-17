import SwiftUI

struct DetailBackdrop: View {
    let path: String

    var body: some View {
        DetailArtwork(path: path, baseURL: API.backdropBaseUrl, fallback: DashboardDesign.mediaFooter)
            .aspectRatio(16.0 / 9, contentMode: .fit)
            .clipped()
    }
}

#if DEBUG
#Preview("DetailBackdrop") {
    DetailBackdrop(path: "")
}
#endif
