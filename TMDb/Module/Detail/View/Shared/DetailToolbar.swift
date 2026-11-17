import SwiftUI

struct DetailToolbar: View {
    @Environment(\.dismiss) private var dismiss
    let title: String

    var body: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 44, height: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Text(title)
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)
        }
        .foregroundStyle(DashboardDesign.text)
        .frame(minHeight: 56)
    }
}

#if DEBUG
#Preview("DetailToolbar") {
    DetailToolbar(title: "Movie Details")
}
#endif
