import SwiftUI
import UIKit

struct ZoomablePhoto: UIViewRepresentable {
    let image: UIImage
    let resetsZoom: Bool
    let onZoomReset: () -> Void

    func makeUIView(context: Context) -> PhotoZoomScrollView {
        PhotoZoomScrollView()
    }

    func updateUIView(_ scrollView: PhotoZoomScrollView, context: Context) {
        scrollView.imageView.image = image
        if resetsZoom {
            scrollView.resetZoom(onCompletion: onZoomReset)
        }
    }
}

final class PhotoZoomScrollView: UIScrollView, UIScrollViewDelegate {
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
