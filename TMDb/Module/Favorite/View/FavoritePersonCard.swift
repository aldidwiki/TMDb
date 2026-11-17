import SwiftUI
import SDWebImageSwiftUI

struct FavoritePersonCard: View {
    let favorite: FavoriteModel
    let remove: () -> Void

    var body: some View {
        let initials = String(favorite.title.split(whereSeparator: \.isWhitespace).prefix(2).compactMap(\.first))
        let department = favorite.department?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let role = department == "Acting" ? "Actor" : department

        return HStack(spacing: 4) {
            NavigationLink(value: favorite.id) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(DashboardDesign.surfaceDim)
                        .frame(width: 64, height: 64)
                        .overlay {
                            Text(initials.uppercased())
                                .font(.title3.bold())
                                .foregroundStyle(DashboardDesign.accent)
                        }
                        .overlay { FavoriteArtwork(path: favorite.posterPath, baseURL: API.profileImageBaseUrl) }
                        .clipShape(Circle())
                        .overlay { Circle().strokeBorder(DashboardDesign.border) }
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(favorite.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DashboardDesign.text)
                        Text(role.isEmpty || role == "-" ? "Person" : "Person · \(role)")
                            .font(.caption2)
                            .foregroundStyle(DashboardDesign.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 84)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            FavoriteRemoveButton(favorite: favorite, remove: remove)
        }
        .padding(12)
        .modifier(FavoriteSurface(radius: DashboardDesign.cardRadius))
    }
}

#if DEBUG
#Preview("FavoritePersonCard") {
    NavigationStack { FavoritePersonCard(favorite: PreviewFixtures.favoritePerson, remove: {}) }
}
#endif
