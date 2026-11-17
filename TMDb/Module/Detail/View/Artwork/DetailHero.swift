import SwiftUI

struct DetailHero<Backdrop: View>: View {
    let title: String
    let metadata: String
    var cornerRadius: CGFloat = 0
    @ViewBuilder let backdrop: () -> Backdrop

    var body: some View {
        backdrop()
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title.bold())
                        .accessibilityAddTraits(.isHeader)

                    if !metadata.isEmpty {
                        Text(metadata)
                            .font(.caption)
                    }
                }
                .foregroundStyle(DashboardDesign.surface)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(alignment: .bottom) {
                    DashboardDesign.mediaFooterGradient
                }
                .allowsHitTesting(false)
            }
            .frame(maxWidth: DashboardDesign.contentWidth)
            .frame(maxWidth: .infinity)
    }
}

#if DEBUG
#Preview("DetailHero") {
    DetailHero(title: "The Last Horizon", metadata: "2025 · Science Fiction") { DetailBackdrop(path: "") }
}
#endif
