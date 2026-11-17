import SDWebImageSwiftUI
import SwiftUI
import UIKit

struct GalleryPhotoViewer: View {
    enum Layout {
        case landscape
        case portrait
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var closeButtonFocused: Bool
    @StateObject private var loader = ImageManager()
    @State private var isExpanded = false
    @State private var canZoom = false
    @State private var isClosing = false
    @State private var resetsZoom = false

    let layout: Layout
    let url: URL?
    let aspectRatio: Double?
    let thumbnail: UIImage?
    let sourceFrame: CGRect
    let viewportSize: CGSize
    let caption: String
    let onClose: () -> Void

    var body: some View {
        let destination = destinationFrame
        let frame = isExpanded || reduceMotion ? destination : sourceFrame

        return ZStack(alignment: .topTrailing) {
            DashboardDesign.surface.opacity(0.65)
                .ignoresSafeArea()
                .opacity(isExpanded ? 1 : 0)
                .onTapGesture(perform: dismissViewer)
                .accessibilityHidden(true)

            photoContent
                .frame(width: frame.width, height: frame.height)
                .clipShape(RoundedRectangle(cornerRadius: isExpanded || reduceMotion
                    ? DashboardDesign.cardRadius
                    : DashboardDesign.controlRadius))
                .position(x: frame.midX, y: frame.midY)
                .opacity(reduceMotion && !isExpanded ? 0 : 1)

            Text(caption)
                .font(.footnote.weight(.medium))
                .foregroundStyle(DashboardDesign.text)
                .lineLimit(1)
                .padding(.horizontal, layout == .landscape ? 8 : 0)
                .frame(width: destination.width, alignment: .leading)
                .position(x: destination.midX, y: destination.maxY + (layout == .landscape ? 28 : 24))
                .opacity(isExpanded && !isClosing ? 1 : 0)
                .allowsHitTesting(false)
                .accessibilityHidden(!isExpanded || isClosing)

            Button(action: dismissViewer) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DashboardDesign.text)
                    .frame(width: 44, height: 44)
                    .background(DashboardDesign.surface, in: Circle())
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close photo")
            .accessibilityFocused($closeButtonFocused)
            .padding(.top, 8)
            .padding(.trailing, 20)
            .opacity(isExpanded && !isClosing ? 1 : 0)
            .disabled(!isExpanded || isClosing)
        }
        .frame(width: viewportSize.width, height: viewportSize.height)
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape, dismissViewer)
        .task {
            loadPhoto()
            await Task.yield()
            guard !Task.isCancelled, !isClosing else { return }

            withAnimation(transition, completionCriteria: .removed) {
                isExpanded = true
            } completion: {
                guard !isClosing else { return }
                canZoom = true
                closeButtonFocused = true
            }
        }
        .onDisappear { loader.cancel() }
    }

    @ViewBuilder
    private var photoContent: some View {
        if canZoom, let image = displayedImage {
            ZoomablePhoto(image: image, resetsZoom: resetsZoom, onZoomReset: collapse)
                .allowsHitTesting(!isClosing)
                .accessibilityLabel(Text(layout == .landscape ? caption : "Photo"))
        } else if let image = thumbnail ?? displayedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
        } else {
            DashboardDesign.surfaceDim
                .overlay {
                    if url == nil {
                        Image(systemName: "photo")
                            .foregroundStyle(DashboardDesign.secondaryText)
                    } else if loader.error != nil {
                        VStack(spacing: 8) {
                            Text("Couldn’t load photo")
                            Button("Retry", action: loadPhoto)
                                .tint(DashboardDesign.accent)
                        }
                        .font(.footnote)
                        .foregroundStyle(DashboardDesign.text)
                    } else {
                        ProgressView("Loading photo")
                            .font(.footnote)
                            .tint(DashboardDesign.accent)
                    }
                }
        }
    }

    private var displayedImage: UIImage? {
        loader.image ?? thumbnail
    }

    private var destinationFrame: CGRect {
        let ratio: CGFloat
        if let aspectRatio, aspectRatio.isFinite, aspectRatio > 0 {
            ratio = CGFloat(aspectRatio)
        } else if let thumbnail, thumbnail.size.height > 0 {
            ratio = thumbnail.size.width / thumbnail.size.height
        } else {
            ratio = layout == .landscape ? 16.0 / 9 : 9.0 / 16
        }

        let maxWidth = max(1, viewportSize.width - (layout == .landscape ? 40 : 56))
        let maxHeight = max(1, viewportSize.height - (layout == .landscape ? 112 : 104))
        let width = min(maxWidth, maxHeight * ratio)
        let height = width / ratio

        return CGRect(
            x: (viewportSize.width - width) / 2,
            y: layout == .landscape ? (viewportSize.height - height) / 2 : 56 + (maxHeight - height) / 2,
            width: width,
            height: height
        )
    }

    private var transition: Animation {
        reduceMotion ? .easeInOut(duration: 0.16) : .spring(duration: 0.42, bounce: 0.12)
    }

    private func loadPhoto() {
        guard let url else { return }
        loader.error = nil
        loader.load(url: url, options: [.retryFailed])
    }

    private func dismissViewer() {
        guard isExpanded, !isClosing else { return }
        isClosing = true

        if canZoom && displayedImage != nil && !reduceMotion {
            resetsZoom = true
        } else {
            collapse()
        }
    }

    private func collapse() {
        canZoom = false
        withAnimation(transition, completionCriteria: .removed) {
            isExpanded = false
        } completion: {
            onClose()
        }
    }
}

#if DEBUG
#Preview("Portrait photo") {
    GeometryReader { geometry in
        GalleryPhotoViewer(layout: .portrait, url: nil, aspectRatio: 9.0 / 16, thumbnail: PreviewFixtures.thumbnail,
                           sourceFrame: CGRect(x: 20, y: 60, width: 90, height: 120), viewportSize: geometry.size,
                           caption: "Alex Morgan · 1 of 1", onClose: {})
    }
}
#endif
