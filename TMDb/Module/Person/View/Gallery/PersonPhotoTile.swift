import SwiftUI
import SDWebImageSwiftUI
import UIKit

struct PersonPhotoTile: View {
    @StateObject private var loader = ImageManager()

    let photo: PersonImageModel
    let index: Int
    let isHidden: Bool
    let onOpen: (UIImage?, CGRect) -> Void

    var body: some View {
        GeometryReader { geometry in
            Button {
                onOpen(loader.image, geometry.frame(in: .named("personPhotoGallery")))
            } label: {
                ZStack {
                    if let image = loader.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else if loader.error != nil || photo.filePath.isEmpty {
                        DashboardDesign.surfaceDim
                        Image(systemName: "photo")
                            .foregroundStyle(DashboardDesign.secondaryText)
                    } else {
                        PersonPhotoPlaceholder()
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Photo \(index + 1)")
            .opacity(isHidden ? 0 : 1)
        }
        .aspectRatio(9.0 / 16, contentMode: .fit)
        .anchorPreference(key: PersonPhotoTileBounds.self, value: .bounds) { [photo.id: $0] }
        .task {
            if loader.image == nil, !photo.filePath.isEmpty {
                loader.load(url: URL(string: API.profileImageBaseUrl + photo.filePath))
            }
        }
        .onDisappear { loader.cancel() }
    }
}

#if DEBUG
#Preview("PersonPhotoTile") {
    PersonPhotoTile(photo: PreviewFixtures.portrait, index: 0, isHidden: false, onOpen: { _, _ in })
}
#endif
