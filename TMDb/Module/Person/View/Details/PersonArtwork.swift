import SwiftUI
import SDWebImageSwiftUI

struct PersonArtwork: View {
    let path: String
    let baseURL: String
    let fallback: Color
    let width: CGFloat
    let height: CGFloat
    let radius: CGFloat

    var body: some View {
        ZStack {
            fallback
            if let path = path.nonPlaceholderText {
                WebImage(url: URL(string: baseURL + path))
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

#if DEBUG
#Preview("PersonArtwork") {
    PersonArtwork(path: "", baseURL: API.profileImageBaseUrl, fallback: DashboardDesign.surfaceDim,
                  width: 120, height: 180, radius: 14)
}
#endif
