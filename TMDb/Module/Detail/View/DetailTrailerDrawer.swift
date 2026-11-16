import SwiftUI

struct DetailActions: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let videos: [VideoModel]
    let isFavorite: Bool
    @Binding var presentedTrailers: [TrailerLink]?
    let onFavoriteToggle: () -> Bool

    var body: some View {
        let trailers = videos.compactMap(TrailerLink.init)
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))

        return layout {
            if trailers.count > 1 {
                Button {
                    presentedTrailers = trailers
                } label: {
                    trailerLabel
                }
                .buttonStyle(.plain)
            } else if let trailer = trailers.first {
                Link(destination: trailer.url) {
                    trailerLabel
                }
                .buttonStyle(.plain)
            }

            AnimatedFavoriteButton(isFavorite: isFavorite, onToggle: onFavoriteToggle)
        }
    }

    private var trailerLabel: some View {
        Label("Watch Trailer", systemImage: "play.fill")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(DashboardDesign.surface)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(DashboardDesign.accent, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
    }
}

extension View {
    func detailTrailerDrawer(_ presentedTrailers: Binding<[TrailerLink]?>) -> some View {
        modifier(DetailTrailerOverlay(presentedTrailers: presentedTrailers))
    }
}

private struct DetailTrailerOverlay: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var presentedTrailers: [TrailerLink]?

    func body(content: Content) -> some View {
        content
            .accessibilityHidden(presentedTrailers != nil)
            .overlay { trailerOverlay }
    }

    private var trailerOverlay: some View {
        ZStack(alignment: .bottom) {
            if let trailers = presentedTrailers {
                DashboardDesign.text.opacity(0.42)
                    .ignoresSafeArea()
                    .onTapGesture { presentedTrailers = nil }
                    .accessibilityHidden(true)
                    .transition(.opacity)

                TrailerDrawer(trailers: trailers) { presentedTrailers = nil }
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: presentedTrailers != nil)
        .allowsHitTesting(presentedTrailers != nil)
    }
}

private struct TrailerDrawer: View {
    @Environment(\.openURL) private var openURL
    @State private var selectedTrailerID: String?

    let trailers: [TrailerLink]
    let onClose: () -> Void

    private let rowHeight: CGFloat = 42
    private let rowSpacing: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(DashboardDesign.color(0xC7D1E3))
                .frame(width: 48, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 9)
                .accessibilityHidden(true)

            HStack {
                Text("Watch trailer")
                    .font(.title3.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 8)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .frame(width: 32, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close trailers")
            }
            .padding(.horizontal, 20)

            Text("Choose a video to play")
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
                .padding(.bottom, 16)
                .padding(.horizontal, 20)

            ViewThatFits(in: .vertical) {
                trailerRows
                ScrollView {
                    trailerRows
                        .padding(.horizontal, 20)
                }
            }
            .frame(
                maxHeight: CGFloat(trailers.count) * rowHeight + CGFloat(trailers.count) * rowSpacing
            )
        }
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(DashboardDesign.surface)
                .ignoresSafeArea(edges: [.horizontal, .bottom])
        }
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape, onClose)
    }

    private var trailerRows: some View {
        VStack(spacing: rowSpacing) {
            ForEach(trailers) { trailer in
                trailerRow(trailer)
            }

            Spacer()
        }
    }

    private func trailerRow(_ trailer: TrailerLink) -> some View {
        let isSelected = trailer.id == (selectedTrailerID ?? trailers.first?.id)
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        return Button {
            selectedTrailerID = trailer.id
            openURL(trailer.url)
        } label: {
            HStack(spacing: 12) {
                Text(trailer.name)
                    .font(.footnote.weight(.regular))
                    .foregroundStyle(DashboardDesign.text)
                    .lineLimit(2)

                Spacer(minLength: 0)

                Image(systemName: "play.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DashboardDesign.accent)
                    .frame(width: 20)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 6)
            .frame(minHeight: rowHeight)
            .background(DashboardDesign.surface, in: shape)
            .overlay {
                shape.strokeBorder(DashboardDesign.border)
                    .allowsHitTesting(false)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct TrailerLink: Identifiable {
    let id: String
    let name: String
    let url: URL

    init?(_ video: VideoModel) {
        guard !video.key.isEmpty, let url = URL(string: Constants.youtubeBaseUrl + video.key) else { return nil }
        id = video.id
        name = video.name
        self.url = url
    }
}
