import SwiftUI

struct FavoritesList: View {
    let favorites: [FavoriteModel]
    let loadFailed: Bool
    let reload: () -> Void
    let remove: (FavoriteModel.ID) -> Void

    var body: some View {
        if loadFailed && favorites.isEmpty {
            ContentUnavailableView {
                Label("Couldn’t load favorites", systemImage: "heart.slash")
            } actions: {
                Button("Retry", action: reload)
            }
            .frame(maxHeight: .infinity)
        } else if favorites.isEmpty {
            ContentUnavailableView(
                "No favorites yet",
                systemImage: "heart",
                description: Text("Save a movie, TV show, or person from its detail page.")
            )
            .frame(maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(favorites) { favorite in
                        if favorite.id.mediaType == .person {
                            FavoritePersonCard(favorite: favorite) { remove(favorite.id) }
                        } else {
                            FavoriteMediaCard(favorite: favorite) { remove(favorite.id) }
                        }
                    }
                }
                .frame(maxWidth: DashboardDesign.contentWidth)
                .padding(.horizontal, DashboardDesign.contentInset)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
            }
            .refreshable { reload() }
        }
    }
}

#if DEBUG
#Preview("FavoritesList") {
    NavigationStack {
        FavoritesList(favorites: [PreviewFixtures.favorite, PreviewFixtures.favoritePerson], loadFailed: false, reload: {}, remove: { _ in })
    }
}
#endif
