import SwiftUI
import SDWebImageSwiftUI

struct SearchPersonCard: View {
    let result: SearchModel

    var body: some View {
        let initials = String(result.name.split(whereSeparator: \.isWhitespace).prefix(2).compactMap(\.first)).uppercased()
        let department = result.knownForDepartment == "Acting" ? "Actor" : result.knownForDepartment

        return HStack(spacing: 12) {
            ZStack {
                Circle().fill(DashboardDesign.surfaceDim)
                Text(initials)
                    .font(.title3.bold())
                    .foregroundStyle(DashboardDesign.accent)

                if !result.imagePath.isEmpty {
                    WebImage(url: PosterURLType.person(path: result.imagePath).url)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
            .overlay { Circle().strokeBorder(DashboardDesign.border) }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.headline)
                    .foregroundStyle(DashboardDesign.text)
                Text(department.isEmpty ? "Person" : "Person · \(department)")
                    .font(.subheadline)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }

            Spacer(minLength: 8)
            Image(systemName: "chevron.forward")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.secondaryText)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .frame(minHeight: 108)
        .modifier(SearchCardStyle())
        .contentShape(Rectangle())
    }
}

#if DEBUG
#Preview("SearchPersonCard") {
    SearchPersonCard(result: PreviewFixtures.personSearch)
}
#endif
