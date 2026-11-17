import SwiftUI
import SDWebImageSwiftUI

struct FavoriteArtwork: View {
    let path: String
    let baseURL: String

    var body: some View {
        if !path.isEmpty, let url = URL(string: baseURL + path) {
            WebImage(url: url)
                .resizable()
                .scaledToFill()
        }
    }
}

#if DEBUG
#Preview("FavoriteArtwork") {
    FavoriteArtwork(path: "", baseURL: API.imageBaseUrl)
        .frame(width: 86, height: 134)
}
#endif
