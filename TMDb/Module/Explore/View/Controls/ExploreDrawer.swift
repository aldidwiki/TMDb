import SwiftUI

struct ExploreDrawer: View {
    let category: ExploreCategory
    let presenter: ExplorePresenter
    @Binding var filters: ExploreFilters
    @Binding var sort: ExploreSort
    let isSort: Bool
    let onClose: () -> Void
    let onCategory: (ExploreCategory) -> Void
    let onPickYear: () -> Void
    let onReset: () -> Void
    let onApply: () -> Void

    private var title: String {
        if isSort {
            switch category {
            case .all: return "Sort all"
            case .movies: return "Sort movies"
            case .shows: return "Sort TV shows"
            case .people: return "Sort people"
            }
        }
        if presenter.feed.settings.filters.isActive { return "Active filters" }
        return category == .all ? "Filter titles" : "Filter \(category.rawValue)"
    }

    private var subtitle: String {
        if isSort {
            return presenter.feed.settings.sort == nil
                ? "Choose how results are ordered."
                : "Current sort. Changes apply only after Apply sort."
        }
        if category == .people { return "Refine by department and known work." }
        return presenter.feed.settings.filters.isActive
            ? "These filters are currently applied." : "Refine results with filters."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Capsule()
                .fill(DashboardDesign.border)
                .frame(width: 48, height: 4)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            HStack {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .frame(width: 44, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }

            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(DashboardDesign.secondaryText)

            ViewThatFits(in: .vertical) {
                options
                ScrollView { options }
            }

            HStack(spacing: 12) {
                if !isSort {
                    DrawerActionButton(title: "Reset Filters", prominent: false, action: onReset)
                }
                DrawerActionButton(title: isSort ? "Apply sort" : "Apply Filters", prominent: true, action: onApply)
            }
        }
        .frame(maxWidth: DashboardDesign.contentWidth)
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(DashboardDesign.surface)
                .ignoresSafeArea(edges: [.horizontal, .bottom])
        }
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape, onClose)
    }

    @ViewBuilder
    private var options: some View {
        if isSort {
            VStack(spacing: 8) {
                ForEach(category.sorts, id: \.self, content: sortOption)
            }
        } else {
            filterOptions
        }
    }

    private var filterOptions: some View {
        VStack(alignment: .leading, spacing: 9) {
            group("Content type") {
                ForEach(ExploreCategory.allCases.filter { $0 != .all }, id: \.self) { type in
                    ExploreChip(title: type.rawValue, selected: category == type) {
                        onCategory(type)
                    }
                }
            }

            if category == .people {
                group("Department") {
                    ForEach(["Acting", "Directing", "Writing", "Production", "Sound"], id: \.self) { department in
                        ExploreChip(title: department, selected: filters.department == department) {
                            filters.department = filters.department == department ? nil : department
                        }
                    }
                }
                group("Known for") {
                    ForEach(ExploreKnownFor.allCases, id: \.self) { option in
                        ExploreChip(title: option.rawValue, selected: filters.knownFor == option) {
                            filters.knownFor = filters.knownFor == option ? nil : option
                        }
                    }
                }
            } else {
                genreOptions
                yearOption
                group("Minimum rating") {
                    ForEach(6...9, id: \.self) { option in
                        ExploreChip(title: "\(option).0+", selected: filters.minimumRating == option) {
                            filters.minimumRating = filters.minimumRating == option ? nil : option
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var yearOption: some View {
        let title = category == .shows ? "First air year" : "Release year"
        let value: String
        switch filters.year {
        case .single(let year): value = "\(year) · Change year"
        case .range(let years): value = "\(years.lowerBound)–\(years.upperBound) · Change range"
        case nil: value = "Any year"
        }
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        return VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)
            Button(action: onPickYear) {
                HStack {
                    Text(value)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
                .font(.subheadline)
                .foregroundStyle(filters.year == nil ? DashboardDesign.secondaryText : DashboardDesign.accent)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .background(DashboardDesign.surface, in: shape)
                .overlay { shape.strokeBorder(DashboardDesign.border) }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(title)
            .accessibilityValue(filters.year?.label ?? "Any year")
        }
    }

    private var genreOptions: some View {
        VStack(alignment: .leading, spacing: 6) {
            group("Genre") {
                ForEach(presenter.genreOptions, id: \.self) { genre in
                    ExploreChip(title: genre, selected: filters.genres.contains(genre)) {
                        if filters.genres.contains(genre) { filters.genres.remove(genre) }
                        else { filters.genres.insert(genre) }
                    }
                }
            }

            if presenter.isLoadingGenres {
                ProgressView("Loading genres…")
                    .font(.footnote)
            }
            if presenter.hasGenreError {
                HStack {
                    Text("Couldn’t load genres.")
                        .foregroundStyle(DashboardDesign.secondaryText)
                    Button("Retry") { presenter.retryGenres() }
                }
                .font(.footnote)
            }
        }
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)
            ExploreChipLayout { content() }
        }
    }

    private func sortOption(_ option: ExploreSort) -> some View {
        let selected = sort == option
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        return Button {
            sort = option
        } label: {
            HStack {
                Text(option.rawValue)
                Spacer()
                Image(systemName: selected ? "checkmark" : "circle")
                    .font(.caption)
                    .accessibilityHidden(true)
            }
            .font(.subheadline)
            .foregroundStyle(selected ? DashboardDesign.accent : DashboardDesign.text)
            .padding(.horizontal, 14)
            .frame(minHeight: 42)
            .background(selected ? DashboardDesign.surfaceDim : DashboardDesign.surface, in: shape)
            .overlay { shape.strokeBorder(selected ? DashboardDesign.accent : DashboardDesign.border) }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct ExploreChipLayout: Layout {
    private let spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? subviews.reduce(CGFloat.zero) { $0 + $1.sizeThatFits(.unspecified).width + spacing }
        let frames = frames(for: subviews, width: width)
        return CGSize(width: width, height: frames.last?.maxY ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (view, frame) in zip(subviews, frames(for: subviews, width: bounds.width)) {
            view.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                       anchor: .topLeading, proposal: ProposedViewSize(frame.size))
        }
    }

    private func frames(for subviews: Subviews, width: CGFloat) -> [CGRect] {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        return subviews.map { view in
            var size = view.sizeThatFits(.unspecified)
            if size.width > width {
                size = view.sizeThatFits(ProposedViewSize(width: width, height: nil))
            }
            if x > 0 && x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            let frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            return frame
        }
    }
}

#if DEBUG
#Preview("ExploreDrawer") {
    ExploreDrawer(category: .movies, presenter: ExplorePresenter(useCase: PreviewFixtures.UseCases()),
                  filters: .constant(.init()), sort: .constant(.popular), isSort: false, onClose: {},
                  onCategory: { _ in }, onPickYear: {}, onReset: {}, onApply: {})
}
#endif
