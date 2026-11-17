import SwiftUI

struct SearchFilters: View {
    @Binding var selected: SearchPresenter.Filter
    let count: (SearchPresenter.Filter) -> Int

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(SearchPresenter.Filter.allCases, id: \.self) { filter in
                    let isSelected = filter == selected
                    let count = count(filter)

                    Button {
                        selected = filter
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
}

#if DEBUG
#Preview("SearchFilters") {
    SearchFilters(selected: .constant(.all), count: { _ in 3 })
}
#endif
