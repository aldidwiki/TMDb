import SwiftUI

struct GenreMovieListingView: View {
    private enum FilterSheet: String, Identifiable {
        case sort, year, rating
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .sort: "Sort by"
            case .year: "Release year"
            case .rating: "Minimum rating"
            }
        }
        
        var action: String {
            switch self {
            case .sort: "Apply sort"
            case .year: "Apply year"
            case .rating: "Apply rating"
            }
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var presenter = GenrePresenter()
    @State private var activeSheet: FilterSheet?
    @State private var draftSort: GenrePresenter.Sort = .popularity
    @State private var draftYear: GenrePresenter.ReleaseYear = .all
    @State private var draftRating: GenrePresenter.MinimumRating = .any
    
    let genre: GenreRoute
    private let router = GenreRouter()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 26)
            
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    chip(presenter.sort.rawValue, selected: true, showsChevron: true) { open(.sort) }
                    chip(presenter.releaseYear == .all ? "Release: All" : "Release: \(presenter.releaseYear.rawValue)") { open(.year) }
                    chip(presenter.minimumRating == .any ? "★ Any rating" : "★ \(presenter.minimumRating.rawValue)") { open(.rating) }
                }
                .padding(.horizontal, 18)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 20)
            
            ScrollView(.vertical, showsIndicators: true) {
                Group {
                    if presenter.movies.isEmpty {
                        ContentUnavailableView("No movies found", systemImage: "movieclapper",
                                               description: Text("Try another year or rating."))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(presenter.movies) { movie in
                                movieCard(movie)
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.visible)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DashboardDesign.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: Int.self) { movieID in
            router.goToMovieDetailView(for: movieID)
        }
        .overlay {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    if activeSheet != nil {
                        DashboardDesign.text.opacity(0.42)
                            .ignoresSafeArea()
                            .onTapGesture { closeSheet() }
                            .transition(.opacity)
                    }
                    
                    if let sheet = activeSheet {
                        filterSheet(sheet)
                            .frame(width: geometry.size.width, height: 440)
                            .background(DashboardDesign.surface)
                            .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
                            .transition(.move(edge: .bottom))
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .ignoresSafeArea()
            .allowsHitTesting(activeSheet != nil)
        }
    }
    
    private var header: some View {
        HStack(alignment: .top, spacing: 8) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DashboardDesign.text)
                    .frame(width: 34, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(genre.name) Movies")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(DashboardDesign.text)
                Text("\(presenter.movies.count) titles available")
                    .font(.system(size: 11))
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
            .padding(.top, 3)
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
    
    private func movieCard(_ movie: GenreListingMovie) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(DashboardDesign.color(movie.posterColor))
                .frame(width: 86, height: 134)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(movie.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(DashboardDesign.text)
                    .lineLimit(1)
                Text("\(movie.year) · \(movie.duration) min")
                    .font(.system(size: 11))
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .padding(.top, 4)
                Text("★ \(movie.rating.formatted(.number.precision(.fractionLength(1))))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(DashboardDesign.color(0xF59E0B))
                    .padding(.top, 4)
                Text(movie.overview)
                    .font(.system(size: 11))
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .lineLimit(1)
                    .padding(.top, 4)
                
                NavigationLink(value: movie.id) {
                    Text("See Details")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(DashboardDesign.surface)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(DashboardDesign.accent, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .padding(.top, 11)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: 14))
    }
    
    private func open(_ sheet: FilterSheet) {
        draftSort = presenter.sort
        draftYear = presenter.releaseYear
        draftRating = presenter.minimumRating
        withAnimation(.easeInOut(duration: 0.25)) { activeSheet = sheet }
    }
    
    private func closeSheet() {
        withAnimation(.easeInOut(duration: 0.25)) { activeSheet = nil }
    }
    
    private func apply(_ sheet: FilterSheet) {
        switch sheet {
        case .sort: presenter.sort = draftSort
        case .year: presenter.releaseYear = draftYear
        case .rating: presenter.minimumRating = draftRating
        }
        closeSheet()
    }
    
    private func filterSheet(_ sheet: FilterSheet) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(DashboardDesign.border)
                .frame(width: 48, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 9)
            
            HStack {
                Text(sheet.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(DashboardDesign.text)
                Spacer()
                Button { closeSheet() } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .frame(width: 28, height: 28)
                }
                .accessibilityLabel("Close")
            }
            
            Text(helper(for: sheet))
                .font(.system(size: 13))
                .foregroundStyle(DashboardDesign.secondaryText)
                .padding(.top, 7)
                .padding(.bottom, 9)
            
            VStack(spacing: 9) {
                switch sheet {
                case .sort:
                    optionRows(GenrePresenter.Sort.allCases, selection: $draftSort)
                case .year:
                    optionRows(GenrePresenter.ReleaseYear.allCases, selection: $draftYear)
                case .rating:
                    optionRows(GenrePresenter.MinimumRating.allCases, selection: $draftRating)
                }
            }
            
            Button { apply(sheet) } label: {
                Text(sheet.action)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DashboardDesign.surface)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(DashboardDesign.accent, in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 9)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func helper(for sheet: FilterSheet) -> String {
        switch sheet {
        case .sort: "Choose how \(genre.name) movies are ordered."
        case .year: "Filter the list by release year."
        case .rating: "Show titles at or above this rating."
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

#Preview {
    NavigationStack {
        GenreMovieListingView(genre: GenreRoute(id: 878, name: "Sci-Fi"))
    }
}
