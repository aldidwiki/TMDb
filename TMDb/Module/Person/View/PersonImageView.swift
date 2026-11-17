//
//  PersonImageView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 15/02/24.
//

import SDWebImageSwiftUI
import SwiftUI
import UIKit

struct PersonImageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var presenter: PersonPresenter
    @State private var hasRequestedPhotos = false
    @State private var selection: PersonPhotoSelection?

    private let personId: Int
    private let personName: String
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    init(personUseCase: PersonUseCase, personId: Int, personName: String) {
        _presenter = State(initialValue: PersonPresenter(personUseCase: personUseCase))
        self.personId = personId
        self.personName = personName
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            galleryHeading
            galleryContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DashboardDesign.background.ignoresSafeArea())
        .allowsHitTesting(selection == nil)
        .accessibilityHidden(selection != nil)
        .overlayPreferenceValue(PersonPhotoTileBounds.self) { bounds in
            if let selection {
                GeometryReader { geometry in
                    let sourceFrame = bounds[selection.photo.id].map { geometry[$0] } ?? selection.sourceFrame
                    GalleryPhotoViewer(
                        layout: .portrait,
                        url: selection.photo.filePath.isEmpty ? nil : URL(string: API.profileOriginalBaseUrl + selection.photo.filePath),
                        aspectRatio: selection.photo.aspectRatio,
                        thumbnail: selection.thumbnail,
                        sourceFrame: sourceFrame,
                        viewportSize: geometry.size,
                        caption: "\(personName) · \(selection.index + 1) of \(presenter.personImages.count)"
                    ) {
                        self.selection = nil
                    }
                }
            }
        }
        .coordinateSpace(name: "personPhotoGallery")
        .toolbar(.hidden, for: .navigationBar)
        .task {
            guard !hasRequestedPhotos else { return }
            hasRequestedPhotos = true
            presenter.getPersonImage(personId: personId)
        }
    }

    private var toolbar: some View {
        insetContent {
            HStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44, alignment: .leading)
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

    private var galleryHeading: some View {
        let count = presenter.personImages.count

        return insetContent {
            VStack(alignment: .leading, spacing: 4) {
                Text(personName)
                    .font(.title2.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)

                if hasRequestedPhotos && !presenter.loadingState && presenter.errorMessage.isEmpty {
                    Text(count == 1 ? "1 photo" : "\(count) photos")
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
        if !hasRequestedPhotos || presenter.loadingState {
            insetContent {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<3) { _ in
                        PersonPhotoPlaceholder()
                            .aspectRatio(9.0 / 16, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Loading photos")
            }
        } else if !presenter.errorMessage.isEmpty {
            ContentUnavailableView {
                Label(presenter.errorMessage, systemImage: "wifi.exclamationmark")
            } actions: {
                Button("Retry") { presenter.getPersonImage(personId: personId) }
                    .tint(DashboardDesign.accent)
            }
            .frame(maxHeight: .infinity)
        } else if presenter.personImages.isEmpty {
            ContentUnavailableView("No photos available", systemImage: "photo")
                .frame(maxHeight: .infinity)
        } else {
            photoGrid
        }
    }

    private var photoGrid: some View {
        ScrollView {
            insetContent {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(presenter.personImages.enumerated()), id: \.element.id) { index, photo in
                        PersonPhotoTile(
                            photo: photo,
                            index: index,
                            isHidden: selection?.photo.id == photo.id && !reduceMotion
                        ) { image, frame in
                            selection = PersonPhotoSelection(
                                photo: photo,
                                index: index,
                                thumbnail: image,
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

private struct PersonPhotoSelection {
    let photo: PersonImageModel
    let index: Int
    let thumbnail: UIImage?
    let sourceFrame: CGRect
}

struct PersonPhotoTileBounds: PreferenceKey {
    static let defaultValue: [String: Anchor<CGRect>] = [:]

    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { _, latest in latest })
    }
}

#if DEBUG
#Preview("Person gallery") {
    NavigationStack { PersonImageView(personUseCase: PreviewFixtures.UseCases(), personId: 3, personName: "Alex Morgan") }
}
#endif
