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
                FavoriteHeader(count: presenter.favorites.count, sort: presenter.sort) {
                draftSort = presenter.sort
                setSortPresented(true)
            }
                FavoritesList(favorites: presenter.sortedFavorites, loadFailed: presenter.loadFailed,
                              reload: presenter.load, remove: presenter.remove)
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

struct FavoriteSurface: ViewModifier {
    var radius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius)
        content
            .background(DashboardDesign.surface, in: shape)
            .overlay { shape.strokeBorder(DashboardDesign.border).allowsHitTesting(false) }
    }
}

#if DEBUG
#Preview("Favorites") {
    FavoriteView(favoriteUseCase: PreviewFixtures.favorites()) { SwiftUI.EmptyView() }
}
#endif
