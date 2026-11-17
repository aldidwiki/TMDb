import SwiftUI

struct ExploreCard: View {
    let item: ExploreItem
    let genres: [String]

    var body: some View {
        let person = item.id.media == .person
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.cardRadius)

        HStack(alignment: person ? .center : .top, spacing: 12) {
            if person {
                avatar
            } else {
                DetailArtwork(path: item.imagePath ?? "", baseURL: API.imageBaseUrl)
                    .frame(width: 86, height: 134)
                    .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top, spacing: 8) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(DashboardDesign.text)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(item.id.media.label.uppercased())
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .overlay { Capsule().strokeBorder(DashboardDesign.border) }
                        .accessibilityHidden(true)
                }

                if person {
                    let department = item.department == "Acting" ? "Actor" : item.department
                    metadata(["Person", department].compactMap { $0 })
                } else {
                    let year = item.date.map { String($0.prefix(4)) } ?? ""
                    metadata(([year] + genres.prefix(2)).filter { !$0.isEmpty })

                    if let rating = item.rating, rating > 0 {
                        Label(rating.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DashboardDesign.rating)
                    }

                    if let overview = item.overview, !overview.isEmpty {
                        Text(overview)
                            .font(.caption2)
                            .foregroundStyle(DashboardDesign.secondaryText)
                            .lineLimit(2)
                    }

                    Text("See Details")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DashboardDesign.surface)
                        .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                        .padding(.horizontal, 12)
                        .background(DashboardDesign.accent, in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .frame(minHeight: person ? 106 : 154)
        .background(DashboardDesign.surface, in: shape)
        .overlay { shape.strokeBorder(DashboardDesign.border).allowsHitTesting(false) }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func metadata(_ parts: [String]) -> some View {
        if !parts.isEmpty {
            Text(parts.joined(separator: " · "))
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
        }
    }

    private var avatar: some View {
        let initials = String(item.title.split(whereSeparator: \.isWhitespace).prefix(2).compactMap(\.first))

        return Text(initials.uppercased())
            .font(.headline)
            .foregroundStyle(DashboardDesign.accent)
            .frame(width: 64, height: 64)
            .background(DashboardDesign.surfaceDim, in: Circle())
            .overlay {
                if let path = item.imagePath, !path.isEmpty {
                    DetailArtwork(path: path, baseURL: API.profileImageBaseUrl, fallback: .clear)
                        .clipShape(Circle())
                }
            }
            .accessibilityHidden(true)
    }
}
