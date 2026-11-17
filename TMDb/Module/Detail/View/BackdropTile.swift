import SwiftUI
import SDWebImageSwiftUI
import UIKit

struct BackdropTile: View {
    @StateObject private var loader = ImageManager()

    let photo: ImageModel
    let number: Int
    let gallerySpace: AnyHashable
    let isHidden: Bool
    let onOpen: (UIImage?, CGRect) -> Void

    var body: some View {
        GeometryReader { geometry in
            Button {
                onOpen(loader.image, geometry.frame(in: .named(gallerySpace)))
            } label: {
                artwork
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Backdrop \(number)")
            .opacity(isHidden ? 0 : 1)
        }
        .aspectRatio(16.0 / 9, contentMode: .fit)
        .anchorPreference(key: BackdropBounds.self, value: .bounds) { [photo.filePath: $0] }
        .task {
            if loader.image == nil, !photo.filePath.isEmpty {
                loader.load(url: URL(string: API.backdropThumbnailBaseUrl + photo.filePath))
            }
        }
        .onDisappear { loader.cancel() }
    }

    @ViewBuilder
    private var artwork: some View {
        if let image = loader.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if loader.error != nil || photo.filePath.isEmpty {
            DashboardDesign.surfaceDim
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(DashboardDesign.secondaryText)
                }
        } else {
            BackdropPlaceholder()
        }
    }
}

#if DEBUG
#Preview("BackdropTile") {
    BackdropTile(photo: PreviewFixtures.backdrop, number: 1, gallerySpace: "Backdrop preview",
                 isHidden: false, onOpen: { _, _ in })
        .coordinateSpace(.named("Backdrop preview"))
}
#endif
