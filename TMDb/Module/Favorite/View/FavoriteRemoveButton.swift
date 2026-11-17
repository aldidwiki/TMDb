import SwiftUI

struct FavoriteRemoveButton: View {
    let favorite: FavoriteModel
    let remove: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                remove()
            }
        } label: {
            if favorite.id.mediaType == .person {
                Image(systemName: "heart.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DashboardDesign.color(0xDB4A63))
                    .frame(width: 40, height: 40)
                    .background(DashboardDesign.surfaceDim, in: Circle())
                    .frame(width: 44, height: 44, alignment: .trailing)
                    .contentShape(Rectangle())
            } else {
                Image(systemName: "heart.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DashboardDesign.color(0xD94261))
                    .frame(width: 44, height: 44, alignment: .topTrailing)
                    .padding(.top, 2)
                    .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove \(favorite.title) from favorites")
    }
}

#if DEBUG
#Preview("FavoriteRemoveButton") {
    FavoriteRemoveButton(favorite: PreviewFixtures.favorite, remove: {})
}
#endif
