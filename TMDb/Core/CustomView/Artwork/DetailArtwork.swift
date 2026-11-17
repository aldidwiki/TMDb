import SwiftUI
import SDWebImageSwiftUI

struct DetailArtwork: View {
    let path: String
    let baseURL: String
    var fallback: Color = DashboardDesign.surfaceDim

    var body: some View {
        fallback.overlay {
            if !path.isEmpty, let url = URL(string: baseURL + path) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

#if DEBUG
#Preview("DetailArtwork") {
    DetailArtwork(path: "", baseURL: API.imageBaseUrl)
        .frame(width: 96, height: 144)
}
#endif
