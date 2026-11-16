import SDWebImageSwiftUI
import SwiftUI
import UIKit

struct PersonPhotoViewer: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var closeButtonFocused: Bool
    @StateObject private var loader = ImageManager()
    @State private var isExpanded = false
    @State private var canZoom = false
    @State private var isClosing = false
    @State private var resetsZoom = false

    let photo: PersonImageModel
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
                .frame(width: destination.width, alignment: .leading)
                .position(x: destination.midX, y: destination.maxY + 24)
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
            ZoomablePersonPhoto(image: image, resetsZoom: resetsZoom, onZoomReset: collapse)
                .allowsHitTesting(!isClosing)
                .accessibilityLabel("Photo")
        } else if let image = thumbnail ?? displayedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
        } else {
            DashboardDesign.surfaceDim
                .overlay {
                    if loader.error != nil {
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
        if let aspectRatio = photo.aspectRatio, aspectRatio.isFinite, aspectRatio > 0 {
            ratio = CGFloat(aspectRatio)
        } else if let thumbnail, thumbnail.size.height > 0 {
            ratio = thumbnail.size.width / thumbnail.size.height
        } else {
            ratio = 9.0 / 16
        }

        let maxWidth = max(1, viewportSize.width - 56)
        let maxHeight = max(1, viewportSize.height - 104)
        let width = min(maxWidth, maxHeight * ratio)
        let height = width / ratio

        return CGRect(
            x: (viewportSize.width - width) / 2,
            y: 56 + (maxHeight - height) / 2,
            width: width,
            height: height
        )
    }

    private var transition: Animation {
        reduceMotion ? .easeInOut(duration: 0.16) : .spring(duration: 0.42, bounce: 0.12)
    }

    private func loadPhoto() {
        loader.error = nil
        loader.load(url: URL(string: API.profileOriginalBaseUrl + photo.filePath), options: [.retryFailed])
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

private struct ZoomablePersonPhoto: UIViewRepresentable {
    let image: UIImage
    let resetsZoom: Bool
    let onZoomReset: () -> Void

    func makeUIView(context: Context) -> PersonPhotoScrollView {
        PersonPhotoScrollView()
    }

    func updateUIView(_ scrollView: PersonPhotoScrollView, context: Context) {
        scrollView.imageView.image = image
        if resetsZoom {
            scrollView.resetZoom(onCompletion: onZoomReset)
        }
    }
}

private final class PersonPhotoScrollView: UIScrollView, UIScrollViewDelegate {
    let imageView = UIImageView()

    private var lastViewportSize = CGSize.zero
    private var hasRequestedReset = false

    init() {
        super.init(frame: .zero)
        delegate = self
        minimumZoomScale = 1
        maximumZoomScale = 4
        bouncesZoom = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != lastViewportSize, !bounds.isEmpty else { return }

        lastViewportSize = bounds.size
        setZoomScale(1, animated: false)
        imageView.frame = CGRect(origin: .zero, size: bounds.size)
        contentSize = bounds.size
        contentOffset = .zero
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func resetZoom(onCompletion: @escaping () -> Void) {
        guard !hasRequestedReset else { return }
        hasRequestedReset = true

        DispatchQueue.main.async {
            guard self.zoomScale > 1.001 else {
                onCompletion()
                return
            }

            UIView.animate(withDuration: 0.18, delay: 0, options: [.beginFromCurrentState, .curveEaseOut]) {
                self.setZoomScale(1, animated: false)
                self.setContentOffset(.zero, animated: false)
            } completion: { _ in
                onCompletion()
            }
        }
    }
}
