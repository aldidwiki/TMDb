import SwiftUI

struct TrailerDrawer: View {
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

#if DEBUG
#Preview("TrailerDrawer") {
    TrailerDrawer(trailers: [PreviewFixtures.video].compactMap(TrailerLink.init), onClose: {})
}
#endif
