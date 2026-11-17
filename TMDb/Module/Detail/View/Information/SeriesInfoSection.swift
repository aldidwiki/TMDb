import SwiftUI

struct SeriesInfoSection: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let show: TvShowDetailModel

    var body: some View {
        let fields: [(label: String, value: String)] = [
            ("Creator", show.creators ?? ""),
            ("First aired", show.releaseDate.formatDateString(output: "MMM d, yyyy")),
            ("Executive producer", show.executiveProducers ?? ""),
            ("Status", show.status)
        ].filter { !$0.1.isEmpty }

        if !fields.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                DetailSectionHeading("Series info")

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .topLeading),
                                         count: dynamicTypeSize.isAccessibilitySize ? 1 : 2),
                          alignment: .leading, spacing: 12) {
                    ForEach(fields, id: \.label) { field in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(field.label)
                                .font(.caption)
                                .foregroundStyle(DashboardDesign.secondaryText)
                            Text(field.value)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(DashboardDesign.text)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                .padding(13)
                .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                        .strokeBorder(DashboardDesign.border)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

#if DEBUG
#Preview("SeriesInfoSection") {
    SeriesInfoSection(show: PreviewFixtures.show)
}
#endif
