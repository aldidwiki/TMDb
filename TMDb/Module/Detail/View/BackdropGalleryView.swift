//
//  BackdropGalleryView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/03/24.
//

import Combine
import SDWebImageSwiftUI
import SwiftUI
import UIKit

struct BackdropGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var gallerySpace
    @State private var presenter: BackdropGalleryPresenter
    @State private var selection: BackdropSelection?

    private let title: String
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)

    init(title: String, fetchBackdrops: @escaping () -> AnyPublisher<[ImageModel], Error>) {
        _presenter = State(initialValue: BackdropGalleryPresenter(fetchBackdrops: fetchBackdrops))
        self.title = title
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            heading
            galleryContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DashboardDesign.background.ignoresSafeArea())
        .allowsHitTesting(selection == nil)
        .accessibilityHidden(selection != nil)
        .overlayPreferenceValue(BackdropBounds.self) { bounds in
            if let selection {
                GeometryReader { geometry in
                    GalleryPhotoViewer(
                        layout: .landscape,
                        url: selection.photo.filePath.isEmpty ? nil : URL(string: API.backdropOriginalBaseUrl + selection.photo.filePath),
                        aspectRatio: selection.photo.aspectRatio,
                        thumbnail: selection.thumbnail,
                        sourceFrame: bounds[selection.photo.filePath].map { geometry[$0] } ?? selection.sourceFrame,
                        viewportSize: geometry.size,
                        caption: "Backdrop \(selection.number) of \(selection.total)"
                    ) {
                        self.selection = nil
                    }
                }
            }
        }
        .coordinateSpace(name: gallerySpace)
        .toolbar(.hidden, for: .navigationBar)
        .task { presenter.load() }
    }

    private var toolbar: some View {
        insetContent {
            HStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 40, height: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")

                Text("Photos")
                    .font(.title3.bold())
                    .accessibilityAddTraits(.isHeader)
            }
            .foregroundStyle(DashboardDesign.text)
            .frame(minHeight: 56)
        }
    }

    private var heading: some View {
        insetContent {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)

                if case .loaded(let backdrops) = presenter.state {
                    let count = backdrops.count
                    Text(count == 1 ? "1 backdrop" : "\(count) backdrops")
                        .font(.subheadline)
                        .foregroundStyle(DashboardDesign.secondaryText)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 14)
        }
    }

    @ViewBuilder
    private var galleryContent: some View {
        switch presenter.state {
        case .idle, .loading:
            insetContent {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<4) { _ in
                        BackdropPlaceholder()
                            .aspectRatio(16.0 / 9, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Loading backdrops")
            }
        case .loaded(let backdrops) where backdrops.isEmpty:
            ContentUnavailableView("No backdrops available", systemImage: "photo")
                .frame(maxHeight: .infinity)
        case .loaded(let backdrops):
            backdropGrid(backdrops)
        case .failed:
            ContentUnavailableView {
                Label("Couldn’t load backdrops", systemImage: "wifi.exclamationmark")
            } actions: {
                Button("Retry") { presenter.load() }
                    .tint(DashboardDesign.accent)
            }
            .frame(maxHeight: .infinity)
        }
    }

    private func backdropGrid(_ backdrops: [ImageModel]) -> some View {
        ScrollView {
            insetContent {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(backdrops.enumerated()), id: \.element.filePath) { index, photo in
                        BackdropTile(
                            photo: photo,
                            number: index + 1,
                            gallerySpace: gallerySpace,
                            isHidden: selection?.photo.filePath == photo.filePath && !reduceMotion
                        ) { thumbnail, frame in
                            selection = BackdropSelection(
                                photo: photo,
                                number: index + 1,
                                total: backdrops.count,
                                thumbnail: thumbnail,
                                sourceFrame: frame
                            )
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .scrollDisabled(selection != nil)
    }

    private func insetContent<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
    }
}

private struct BackdropSelection {
    let photo: ImageModel
    let number: Int
    let total: Int
    let thumbnail: UIImage?
    let sourceFrame: CGRect
}

struct BackdropBounds: PreferenceKey {
    static let defaultValue: [String: Anchor<CGRect>] = [:]

    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { _, latest in latest })
    }
}

#if DEBUG
#Preview("Backdrop gallery") {
    NavigationStack {
        BackdropGalleryView(title: "The Last Horizon", fetchBackdrops: { PreviewFixtures.UseCases().getMovieBackdrops(movieId: 1) })
    }
}
#endif
