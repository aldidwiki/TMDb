//
//  SearchView.swift
//  TMDb
//
//  Created by Macbook on 13/02/26.
//

import SDWebImageSwiftUI
import SwiftUI

struct SearchView<BottomBar: View>: View {
    @State private var presenter: SearchPresenter
    @FocusState private var isSearchFocused: Bool

    private let bottomBar: BottomBar
    private let router = SearchRouter()

    init(searchUseCase: SearchUseCase, @ViewBuilder bottomBar: () -> BottomBar) {
        _presenter = State(initialValue: SearchPresenter(searchUseCase: searchUseCase))
        self.bottomBar = bottomBar()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    header
                        .padding(.bottom, 24)
                    searchField
                        .padding(.bottom, 8)
                    filters
                    if presenter.phase == .results {
                        resultsHeading
                            .padding(.top, 6)
                            .padding(.bottom, 12)
                    }
                }
                .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
                .padding(.horizontal, DashboardDesign.contentInset)
                .padding(.top, 4)

                resultsContent
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DashboardDesign.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
            .navigationDestination(for: SearchModel.ID.self) { id in
                router.destination(for: id)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.light)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Search")
                .font(.title3.bold())
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)
            Text("Movies, shows, people")
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
        }
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .accessibilityHidden(true)

            TextField("Search movies, shows, people", text: $presenter.searchQuery)
                .foregroundStyle(DashboardDesign.text)
                .submitLabel(.search)
                .focused($isSearchFocused)
                .onSubmit { isSearchFocused = false }

            if !presenter.searchQuery.isEmpty {
                Button {
                    presenter.searchQuery = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .font(.subheadline)
        .foregroundStyle(DashboardDesign.secondaryText)
        .padding(.leading, 14)
        .padding(.trailing, presenter.searchQuery.isEmpty ? 14 : 0)
        .frame(minHeight: 48)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                .strokeBorder(isSearchFocused ? DashboardDesign.accent : DashboardDesign.border)
                .allowsHitTesting(false)
        }
    }

    private var filters: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(SearchPresenter.Filter.allCases, id: \.self) { filter in
                    let isSelected = filter == presenter.filter
                    let count = presenter.count(for: filter)

                    Button {
                        presenter.filter = filter
                    } label: {
                        Text("\(filter.rawValue) \(count)")
                            .font(.footnote.weight(.semibold))
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 7)
                            .frame(minHeight: 32)
                            .foregroundStyle(isSelected ? DashboardDesign.surface : DashboardDesign.secondaryText)
                            .background(isSelected ? DashboardDesign.accent : DashboardDesign.surface, in: Capsule())
                            .overlay {
                                Capsule().strokeBorder(isSelected ? .clear : DashboardDesign.border)
                            }
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var resultsHeading: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Results")
                .font(.headline)
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 12)

            let count = presenter.count(for: presenter.filter)
            Text(count == 1 ? "1 match" : "\(count) matches")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.secondaryText)
        }
    }

    @ViewBuilder
    private var resultsContent: some View {
        switch presenter.phase {
        case .idle:
            ContentUnavailableView("Search TMDb", systemImage: "magnifyingglass")
                .frame(maxHeight: .infinity)
        case .loading:
            ProgressView("Searching")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed:
            ContentUnavailableView {
                Label("Couldn’t load results", systemImage: "wifi.exclamationmark")
            } actions: {
                Button("Retry", action: presenter.retrySearch)
            }
            .frame(maxHeight: .infinity)
        case .results:
            resultsList
        }
    }

    private var resultsList: some View {
        let results = presenter.visibleResults

        return ScrollView {
            LazyVStack(spacing: 8) {
                if results.isEmpty {
                    ContentUnavailableView {
                        Label("No results", systemImage: "magnifyingglass")
                    } description: {
                        Text(presenter.canLoadMore ? "Load more results or change the filter." : "Try another search or filter.")
                    }
                }

                ForEach(results) { result in
                    resultCard(result)
                        .onAppear {
                            if result.id == results.last?.id && !presenter.hasPaginationError {
                                presenter.loadMore()
                            }
                        }
                }

                if presenter.canLoadMore {
                    paginationFooter
                }
            }
            .frame(maxWidth: DashboardDesign.contentWidth)
            .padding(.horizontal, DashboardDesign.contentInset)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .id(presenter.filter)
    }

    @ViewBuilder
    private var paginationFooter: some View {
        if presenter.isLoadingMore {
            ProgressView("Loading more results")
                .padding(.vertical, 12)
        } else {
            Button(
                presenter.hasPaginationError ? "Couldn’t load more. Retry" : "Load more",
                action: presenter.loadMore
            )
            .font(.footnote.weight(.semibold))
            .foregroundStyle(DashboardDesign.accent)
            .frame(minHeight: 44)
        }
    }

    @ViewBuilder
    private func resultCard(_ result: SearchModel) -> some View {
        if result.id.mediaType == .person {
            NavigationLink(value: result.id) {
                personCard(result)
            }
            .buttonStyle(.plain)
        } else {
            mediaCard(result)
        }
    }

    private func personCard(_ result: SearchModel) -> some View {
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

    private func mediaCard(_ result: SearchModel) -> some View {
        let isMovie = result.id.mediaType == .movie
        let type = isMovie ? "Movie" : "TV"
        let year = String(result.releaseDate.prefix(4))

        return HStack(alignment: .top, spacing: 12) {
            ZStack {
                DashboardDesign.color(isMovie ? 0x292667 : 0x175469)
                if !result.imagePath.isEmpty {
                    WebImage(url: PosterURLType.movie(path: result.imagePath).url)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 86, height: 134)
            .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(result.name)
                    .font(.headline)
                    .foregroundStyle(DashboardDesign.text)
                    .lineLimit(2)

                Text(year.isEmpty ? type : "\(type) · \(year)")
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)

                if let rating = result.voteAverage, rating > 0 {
                    Label {
                        Text(rating, format: .number.precision(.fractionLength(1)))
                    } icon: {
                        Image(systemName: "star.fill")
                            .accessibilityHidden(true)
                    }
                    .font(.footnote.bold())
                    .foregroundStyle(DashboardDesign.rating)
                    .accessibilityLabel("Rating \(rating.formatted(.number.precision(.fractionLength(1)))) out of 10")
                }

                if !result.overview.isEmpty {
                    Text(result.overview)
                        .font(.caption)
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                NavigationLink(value: result.id) {
                    Text("See Details")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(DashboardDesign.surface)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                        .background(DashboardDesign.accent, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See details for \(result.name)")
            }
            .frame(minHeight: 134)
        }
        .padding(10)
        .modifier(SearchCardStyle())
    }
}

private struct SearchCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: DashboardDesign.cardRadius)
                    .strokeBorder(DashboardDesign.border)
                    .allowsHitTesting(false)
            }
    }
}

extension SearchView where BottomBar == SwiftUI.EmptyView {
    init(searchUseCase: SearchUseCase) {
        self.init(searchUseCase: searchUseCase) { SwiftUI.EmptyView() }
    }
}

#Preview {
    SearchView(searchUseCase: Injection().provideSearchUseCase())
}
