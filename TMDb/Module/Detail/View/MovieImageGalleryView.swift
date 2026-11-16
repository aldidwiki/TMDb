//
//  MovieImageGalleryView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/03/24.
//

import SDWebImageSwiftUI
import SwiftUI
import UIKit

struct MovieImageGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var gallerySpace
    @State private var presenter: MovieImageGalleryPresenter
    @State private var selection: MovieBackdropSelection?

    private let movieId: Int
    private let movieTitle: String
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)

    init(detailUseCase: DetailUseCase, movieId: Int, movieTitle: String) {
        _presenter = State(initialValue: MovieImageGalleryPresenter(detailUseCase: detailUseCase))
        self.movieId = movieId
        self.movieTitle = movieTitle
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
        .overlayPreferenceValue(MovieBackdropBounds.self) { bounds in
            if let selection {
                GeometryReader { geometry in
                    MoviePhotoViewer(
                        photo: selection.photo,
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
        .task { presenter.load(movieId: movieId) }
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
                Text(movieTitle)
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
                        MovieBackdropPlaceholder()
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
                Button("Retry") { presenter.load(movieId: movieId) }
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
                        MovieBackdropTile(
                            photo: photo,
                            number: index + 1,
                            gallerySpace: gallerySpace,
                            isHidden: selection?.photo.filePath == photo.filePath && !reduceMotion
                        ) { thumbnail, frame in
                            selection = MovieBackdropSelection(
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

private struct MovieBackdropSelection {
    let photo: ImageModel
    let number: Int
    let total: Int
    let thumbnail: UIImage?
    let sourceFrame: CGRect
}

private struct MovieBackdropTile: View {
    @StateObject private var loader = ImageManager()

    let photo: ImageModel
    let number: Int
    let gallerySpace: Namespace.ID
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
        .anchorPreference(key: MovieBackdropBounds.self, value: .bounds) { [photo.filePath: $0] }
        .task {
            if loader.image == nil {
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
        } else if loader.error != nil {
            DashboardDesign.surfaceDim
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(DashboardDesign.secondaryText)
                }
        } else {
            MovieBackdropPlaceholder()
        }
    }
}

private struct MovieBackdropBounds: PreferenceKey {
    static let defaultValue: [String: Anchor<CGRect>] = [:]

    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { _, latest in latest })
    }
}

private struct MovieBackdropPlaceholder: View {
    var body: some View {
        DashboardDesign.surfaceDim
            .overlay {
                ProgressView("Loading")
                    .font(.caption2)
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .tint(DashboardDesign.accent)
            }
    }
}

#Preview {
    NavigationStack {
        MovieImageGalleryView(
            detailUseCase: Injection().provideDetailUseCase(),
            movieId: 693134,
            movieTitle: "Dune: Part Two"
        )
    }
}
