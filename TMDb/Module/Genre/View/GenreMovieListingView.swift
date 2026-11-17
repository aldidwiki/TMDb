import SwiftUI
import SDWebImageSwiftUI

struct GenreMovieListingView: View {
    private enum FilterSheet {
        case sort, year, rating
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var presenter: GenrePresenter
    @State private var activeSheet: FilterSheet?
    @State private var draftSort: GenrePresenter.Sort = .popularity
    @State private var draftRating: GenrePresenter.MinimumRating = .any
    
    let genre: GenreRoute
    private let router = GenreRouter()

    init(genre: GenreRoute, useCase: GenreUseCase) {
        self.genre = genre
        _presenter = State(initialValue: GenrePresenter(useCase: useCase, genreID: genre.id))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GenreListingHeader(title: genre.name, count: presenter.totalResults, dismiss: { dismiss() })
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 26)
            
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    chip(presenter.sort.rawValue, selected: true, showsChevron: true) { open(.sort) }
                    chip("Release: \(presenter.releaseYear?.label ?? "All")") { open(.year) }
                    chip(presenter.minimumRating == .any ? "★ Any rating" : "★ \(presenter.minimumRating.rawValue)") { open(.rating) }
                }
                .padding(.horizontal, 18)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 20)
            
            GenreMovieList(
                movies: presenter.movies, hasLoaded: presenter.hasLoaded, isLoading: presenter.isLoading,
                isLoadingMore: presenter.isLoadingMore, loadError: presenter.loadError,
                loadMoreError: presenter.loadMoreError, listVersion: presenter.listVersion,
                load: presenter.load, loadMore: presenter.loadNextPage, loadMoreIfNeeded: presenter.loadMoreIfNeeded
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DashboardDesign.background.ignoresSafeArea())
        .task { presenter.load() }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: Int.self) { movieID in
            router.goToMovieDetailView(for: movieID)
        }
        .overlay {
            ZStack(alignment: .bottom) {
                if let sheet = activeSheet {
                    DashboardDesign.text.opacity(0.42)
                        .ignoresSafeArea()
                        .onTapGesture { closeSheet() }
                        .accessibilityHidden(true)
                        .transition(.opacity)

                    sheetContent(sheet)
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(activeSheet != nil)
        }
    }
    
    
    private func chip(_ label: String, selected: Bool = false, showsChevron: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 4) {
                Text(label)
                if showsChevron {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .frame(height: 14, alignment: .center)
                        .accessibilityHidden(true)
                }
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(selected ? DashboardDesign.surface : DashboardDesign.secondaryText)
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background(selected ? DashboardDesign.accent : DashboardDesign.surface, in: Capsule())
            .overlay(Capsule().stroke(selected ? .clear : DashboardDesign.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    
    private func open(_ sheet: FilterSheet) {
        draftSort = presenter.sort
        draftRating = presenter.minimumRating
        withAnimation(.easeInOut(duration: 0.25)) { activeSheet = sheet }
    }
    
    private func closeSheet() {
        withAnimation(.easeInOut(duration: 0.25)) { activeSheet = nil }
    }
    
    private func apply() {
        presenter.apply(sort: draftSort, year: presenter.releaseYear, rating: draftRating)
        closeSheet()
    }

    @ViewBuilder
    private func sheetContent(_ sheet: FilterSheet) -> some View {
        if sheet == .year {
            YearPicker(title: "Release year", selection: presenter.releaseYear, onCancel: closeSheet) { year in
                presenter.apply(sort: presenter.sort, year: year, rating: presenter.minimumRating)
                closeSheet()
            }
        } else {
            GenreFilterDrawer(isSort: sheet == .sort, genreName: genre.name, draftSort: $draftSort,
                              draftRating: $draftRating, close: closeSheet, apply: apply)
                .frame(maxWidth: .infinity)
                .frame(height: 440)
                .background(DashboardDesign.surface)
                .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
                .ignoresSafeArea(.container, edges: [.horizontal, .bottom])
        }
    }

    
    private func optionRows<Option: RawRepresentable & Hashable>(_ options: [Option], selection: Binding<Option>) -> some View where Option.RawValue == String {
        ForEach(options, id: \.self) { option in
            let isSelected = selection.wrappedValue == option
            Button {
                selection.wrappedValue = option
            } label: {
                HStack(alignment: .center, spacing: 8) {
                    Text(option.rawValue)
                        .lineLimit(1)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(width: 18, height: 18, alignment: .center)
                            .accessibilityHidden(true)
                    }
                }
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? DashboardDesign.accent : DashboardDesign.text)
                .padding(.horizontal, 14)
                .frame(height: 42)
                .background(isSelected ? DashboardDesign.color(0xF1F3FF) : DashboardDesign.surface,
                            in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DashboardDesign.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
#Preview("Genre movies") {
    NavigationStack {
        GenreMovieListingView(genre: .init(id: 878, name: "Science Fiction"), useCase: PreviewFixtures.UseCases())
    }
}
#endif
