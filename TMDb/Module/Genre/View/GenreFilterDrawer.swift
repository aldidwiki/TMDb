import SwiftUI

struct GenreFilterDrawer: View {
    let isSort: Bool
    let genreName: String
    @Binding var draftSort: GenrePresenter.Sort
    @Binding var draftRating: GenrePresenter.MinimumRating
    let close: () -> Void
    let apply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(DashboardDesign.border)
                .frame(width: 48, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 9)

            HStack {
                Text(isSort ? "Sort by" : "Minimum rating")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(DashboardDesign.text)
                Spacer()
                Button(action: close) {
                    Image(systemName: "xmark")
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .frame(width: 28, height: 28)
                }
                .accessibilityLabel("Close")
            }

            Text(isSort ? "Choose how \(genreName) movies are ordered." : "Show titles at or above this rating.")
                .font(.system(size: 13))
                .foregroundStyle(DashboardDesign.secondaryText)
                .padding(.top, 7)
                .padding(.bottom, 9)

            VStack(spacing: 9) {
                if isSort {
                    optionRows(GenrePresenter.Sort.allCases, selection: $draftSort)
                } else {
                    optionRows(GenrePresenter.MinimumRating.allCases, selection: $draftRating)
                }
            }

            Button(action: apply) {
                Text(isSort ? "Apply sort" : "Apply rating")
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
#Preview("GenreFilterDrawer") {
    GenreFilterDrawer(isSort: true, genreName: "Science Fiction", draftSort: .constant(.popularity),
                      draftRating: .constant(.any), close: {}, apply: {})
        .frame(height: 440)
}
#endif
