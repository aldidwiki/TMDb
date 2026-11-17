import SwiftUI

struct MovieInfoSection: View {
    let movie: MovieDetailModel

    var body: some View {
        let fields: [(label: String, value: String?)] = [
            ("Director", movie.director),
            ("US release", movie.usReleaseDate?.formatDateString(output: "MMM d, yyyy")),
            ("Runtime", movie.runtime > 0 ? "\(movie.runtime) min" : nil),
            ("Music", movie.composer)
        ]
        let values = fields.compactMap { field -> (label: String, value: String)? in
            guard let value = field.value, !value.isEmpty else { return nil }
            return (field.label, value)
        }

        if !values.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                DetailSectionHeading("Movie info")

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .topLeading), count: 2),
                          alignment: .leading, spacing: 12) {
                    ForEach(values, id: \.label) { field in
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
#Preview("MovieInfoSection") {
    MovieInfoSection(movie: PreviewFixtures.movieDetail)
}
#endif
