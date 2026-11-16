import SDWebImageSwiftUI
import SwiftUI

struct DetailToolbar: View {
    @Environment(\.dismiss) private var dismiss
    let title: String

    var body: some View {
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

            Text(title)
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)
        }
        .foregroundStyle(DashboardDesign.text)
        .frame(minHeight: 56)
    }
}

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

struct DetailBackdrop: View {
    let path: String

    var body: some View {
        DetailArtwork(path: path, baseURL: API.backdropBaseUrl, fallback: DashboardDesign.mediaFooter)
            .aspectRatio(16.0 / 9, contentMode: .fit)
            .clipped()
    }
}

struct DetailOverview: View {
    let posterPath: String
    let overview: String
    let rating: Double
    let voteCount: Int?

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            DetailArtwork(path: posterPath, baseURL: API.imageBaseUrl)
                .frame(width: 96, height: 144)
                .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                if rating > 0 || (voteCount ?? 0) > 0 {
                    ratingBadge
                }

                Text("Overview")
                    .font(.subheadline.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)

                let summary = overview.trimmingCharacters(in: .whitespacesAndNewlines)
                Text(summary.isEmpty || summary == "-" ? "Overview unavailable" : summary)
                    .font(.footnote)
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var ratingBadge: some View {
        VStack(alignment: .leading, spacing: 4) {
            if rating > 0 {
                let score = rating.formatted(.number.precision(.fractionLength(1)))
                Label(score, systemImage: "star.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DashboardDesign.surface)
                    .padding(.horizontal, 8)
                    .frame(minHeight: 24)
                    .background(DashboardDesign.text, in: RoundedRectangle(cornerRadius: 8))
                    .accessibilityLabel("Rating \(score) out of 10")
            }

            if let count = voteCount, count > 0 {
                Text(count == 1 ? "1 vote" : "\(count.formatted(.number.notation(.compactName))) votes")
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
        }
    }
}

struct DetailCastAvatar: View {
    let credit: CreditModel
    let diameter: CGFloat

    var body: some View {
        let initials = String(credit.name.split(whereSeparator: \.isWhitespace).prefix(2).compactMap(\.first)).uppercased()

        Circle()
            .fill(DashboardDesign.surfaceDim)
            .overlay {
                Text(initials)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DashboardDesign.accent)
            }
            .overlay {
                if !credit.profilePath.isEmpty, let url = URL(string: API.profileImageBaseUrl + credit.profilePath) {
                    WebImage(url: url)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: diameter, height: diameter)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}

struct DetailCastCard: View {
    let credit: CreditModel

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            DetailCastAvatar(credit: credit, diameter: 56)

            VStack(alignment: .center, spacing: 2) {
                Text(credit.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DashboardDesign.text)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                if !credit.characterName.isEmpty {
                    Text(credit.characterName)
                        .font(.caption2)
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(width: 132, height: 136, alignment: .top)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DashboardDesign.cardRadius)
                .strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

struct DetailPosterCard: View {
    let title: String
    let posterPath: String
    let releaseDate: String

    var body: some View {
        let year = String(releaseDate.prefix(4))

        return VStack(alignment: .leading, spacing: 4) {
            DetailArtwork(path: posterPath, baseURL: API.imageBaseUrl)
                .frame(width: 109, height: 164)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.text)
                .lineLimit(2)

            if !year.isEmpty {
                Text(year)
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
        }
        .frame(width: 109, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

struct DetailSectionHeading: View {
    let title: String
    let seeAll: Bool

    init(_ title: String, seeAll: Bool = false) {
        self.title = title
        self.seeAll = seeAll
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)

            if seeAll {
                Button {} label: {
                    DetailSeeAllLabel()
                }
                .buttonStyle(.plain)
                .disabled(true)
            }
        }
    }
}

struct DetailSeeAllLabel: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("See All")
            Image(systemName: "arrow.right")
                .accessibilityHidden(true)
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(DashboardDesign.accent)
    }
}

struct DetailArtwork: View {
    let path: String
    let baseURL: String
    var fallback: Color = DashboardDesign.surfaceDim

    var body: some View {
        fallback.overlay {
            if !path.isEmpty, let url = URL(string: baseURL + path) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}
