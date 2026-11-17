import SwiftUI
import SDWebImageSwiftUI

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

#if DEBUG
#Preview("DetailCastAvatar") {
    DetailCastAvatar(credit: PreviewFixtures.credit, diameter: 56)
}
#endif
