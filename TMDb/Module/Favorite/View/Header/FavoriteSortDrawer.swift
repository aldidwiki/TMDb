import SwiftUI

struct FavoriteSortDrawer: View {
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

#if DEBUG
#Preview("FavoriteSortDrawer") {
    FavoriteSortDrawer(selection: .constant(FavoritePresenter.Sort.allCases[0]), onClose: {}, onApply: {})
}
#endif
