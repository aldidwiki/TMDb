import SwiftUI
import SDWebImageSwiftUI

struct RemoteArtwork: View {
    let path: String?
    let baseURL: String
    let placeholder: Color

    var body: some View {
        GeometryReader { geometry in
            if let path, !path.isEmpty, let url = URL(string: baseURL + path) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
        }
        .background(placeholder)
        .accessibilityHidden(true)
    }
}

#Preview("Artwork placeholder") {
    RemoteArtwork(path: nil, baseURL: API.imageBaseUrl, placeholder: DashboardDesign.surfaceDim)
        .frame(width: 96, height: 144)
}
