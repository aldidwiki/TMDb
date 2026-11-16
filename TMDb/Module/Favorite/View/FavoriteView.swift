//
//  FavoriteView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SDWebImageSwiftUI
import SwiftUI

struct FavoriteView<BottomBar: View>: View {
    @State private var presenter: FavoritePresenter
    @State private var showsSort = false
    @State private var draftSort: FavoritePresenter.Sort = .recent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let bottomBar: BottomBar
    private let router = FavoriteRouter()

    init(favoriteUseCase: FavoriteUseCase, @ViewBuilder bottomBar: () -> BottomBar) {
        _presenter = State(initialValue: FavoritePresenter(favoriteUseCase: favoriteUseCase))
        self.bottomBar = bottomBar()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DashboardDesign.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
            .accessibilityHidden(showsSort)
            .overlay(alignment: .bottom) { sortOverlay }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: FavoriteModel.ID.self) { id in
                router.destination(for: id)
            }
            .onAppear { presenter.load() }
            .alert("Couldn’t remove favorite", isPresented: $presenter.showsRemovalError) {
                Button("OK", role: .cancel) {}
            }
        }
        .preferredColorScheme(.light)
    }

    private var header: some View {
        let count = presenter.favorites.count

        return ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 12) {
                heading(count: count)
                Spacer(minLength: 0)
                sortButton
            }

            VStack(alignment: .leading, spacing: 8) {
                heading(count: count)
                sortButton
            }
        }
        .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
        .padding(.horizontal, DashboardDesign.contentInset)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }

    private func heading(count: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Favorites")
                .font(.title3.bold())
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)

            Text(count == 1 ? "1 favorite" : "\(count) favorites")
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    private var sortButton: some View {
        Button {
            draftSort = presenter.sort
            setSortPresented(true)
        } label: {
            Label(presenter.sort.rawValue, systemImage: "arrow.up.arrow.down")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.accent)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 12)
                .frame(minHeight: 32)
                .modifier(FavoriteSurface(radius: DashboardDesign.controlRadius))
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Sort favorites")
        .accessibilityValue(presenter.sort.rawValue)
    }

    @ViewBuilder
    private var content: some View {
        if presenter.loadFailed && presenter.favorites.isEmpty {
            ContentUnavailableView {
                Label("Couldn’t load favorites", systemImage: "heart.slash")
            } actions: {
                Button("Retry", action: presenter.load)
            }
            .frame(maxHeight: .infinity)
        } else if presenter.favorites.isEmpty {
            ContentUnavailableView(
                "No favorites yet",
                systemImage: "heart",
                description: Text("Save a movie, TV show, or person from its detail page.")
            )
            .frame(maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(presenter.sortedFavorites) { favorite in
                        if favorite.id.mediaType == .person {
                            personCard(favorite)
                        } else {
                            mediaCard(favorite)
                        }
                    }
                }
                .frame(maxWidth: DashboardDesign.contentWidth)
                .padding(.horizontal, DashboardDesign.contentInset)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
            }
            .refreshable { presenter.load() }
        }
    }

    private func mediaCard(_ favorite: FavoriteModel) -> some View {
        let isMovie = favorite.id.mediaType == .movie
        let type = isMovie ? "Movie" : "TV"
        let year = String(favorite.releaseDate.prefix(4))

        return HStack(alignment: .top, spacing: 12) {
            DashboardDesign.color(isMovie ? 0x292667 : 0x175469)
                .frame(width: 86, height: 134)
                .overlay { artwork(path: favorite.posterPath, baseURL: API.imageBaseUrl) }
                .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .top, spacing: 4) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(favorite.title)
                            .font(.headline)
                            .foregroundStyle(DashboardDesign.text)
                            .lineLimit(2)

                        Text(year.isEmpty ? type : "\(type) · \(year)")
                            .font(.caption)
                            .foregroundStyle(DashboardDesign.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    removeButton(favorite)
                }

                if favorite.rating > 0 {
                    let rating = favorite.rating.formatted(.number.precision(.fractionLength(1)))
                    Label(rating, systemImage: "star.fill")
                        .font(.footnote.bold())
                        .foregroundStyle(DashboardDesign.rating)
                        .accessibilityLabel("Rating \(rating) out of 10")
                }

                if let overview = favorite.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption)
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                NavigationLink(value: favorite.id) {
                    Text("See Details")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(DashboardDesign.surface)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                        .background(
                            DashboardDesign.accent,
                            in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See details for \(favorite.title)")
            }
            .frame(minHeight: 134)
        }
        .padding(10)
        .modifier(FavoriteSurface(radius: DashboardDesign.cardRadius))
    }

    private func personCard(_ favorite: FavoriteModel) -> some View {
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
                        .overlay { artwork(path: favorite.posterPath, baseURL: API.profileImageBaseUrl) }
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

            removeButton(favorite)
        }
        .padding(12)
        .modifier(FavoriteSurface(radius: DashboardDesign.cardRadius))
    }

    private func removeButton(_ favorite: FavoriteModel) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                presenter.remove(favorite.id)
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

    @ViewBuilder
    private func artwork(path: String, baseURL: String) -> some View {
        if !path.isEmpty, let url = URL(string: baseURL + path) {
            WebImage(url: url)
                .resizable()
                .scaledToFill()
        }
    }

    private var sortOverlay: some View {
        ZStack(alignment: .bottom) {
            if showsSort {
                DashboardDesign.text.opacity(0.42)
                    .ignoresSafeArea()
                    .onTapGesture { setSortPresented(false) }
                    .accessibilityHidden(true)
                    .transition(.opacity)
            }

            if showsSort {
                FavoriteSortDrawer(selection: $draftSort) {
                    setSortPresented(false)
                } onApply: {
                    presenter.sort = draftSort
                    setSortPresented(false)
                }
                .transition(reduceMotion ? .opacity : .move(edge: .bottom))
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(showsSort)
    }

    private func setSortPresented(_ presented: Bool) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            showsSort = presented
        }
    }
}

private struct FavoriteSortDrawer: View {
    @Binding var selection: FavoritePresenter.Sort

    let onClose: () -> Void
    let onApply: () -> Void

    var body: some View {
        ViewThatFits(in: .vertical) {
            controls
            ScrollView { controls }
        }
        .frame(maxWidth: .infinity)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(DashboardDesign.surface)
                .ignoresSafeArea(edges: .bottom)
        }
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape, onClose)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Capsule()
                .fill(DashboardDesign.border)
                .frame(width: 48, height: 4)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            HStack {
                Text("Sort favorites")
                    .font(.title3.bold())
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close sort")
            }

            Text("Choose how your favorites are ordered.")
                .font(.subheadline)
                .foregroundStyle(DashboardDesign.secondaryText)

            ForEach(FavoritePresenter.Sort.allCases, id: \.self) { sort in
                sortOption(sort)
            }

            Button(action: onApply) {
                Text("Apply sort")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DashboardDesign.surface)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(
                        DashboardDesign.accent,
                        in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                    )
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(DashboardDesign.text)
        .frame(maxWidth: DashboardDesign.contentWidth)
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
    }

    private func sortOption(_ sort: FavoritePresenter.Sort) -> some View {
        let isSelected = selection == sort
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        return Button {
            selection = sort
        } label: {
            HStack {
                Text(sort.rawValue)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))

                Spacer()

                Image(systemName: isSelected ? "checkmark" : "circle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? DashboardDesign.accent : DashboardDesign.secondaryText)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(isSelected ? DashboardDesign.accent : DashboardDesign.text)
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .background(isSelected ? DashboardDesign.surfaceDim : DashboardDesign.surface, in: shape)
            .overlay {
                shape.strokeBorder(isSelected ? DashboardDesign.accent : DashboardDesign.border)
                    .allowsHitTesting(false)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct FavoriteSurface: ViewModifier {
    var radius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius)
        content
            .background(DashboardDesign.surface, in: shape)
            .overlay { shape.strokeBorder(DashboardDesign.border).allowsHitTesting(false) }
    }
}

#Preview {
    FavoriteView(favoriteUseCase: Injection().provideFavoriteUseCase()) {
        SwiftUI.EmptyView()
    }
}
