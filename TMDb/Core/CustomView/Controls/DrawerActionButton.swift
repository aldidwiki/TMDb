import SwiftUI

struct DrawerActionButton: View {
    let title: String
    let prominent: Bool
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(prominent ? DashboardDesign.surface : DashboardDesign.accent)
                .padding(8)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(prominent ? DashboardDesign.accent : DashboardDesign.surface, in: shape)
                .overlay { shape.strokeBorder(prominent ? Color.clear : DashboardDesign.border) }
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.45)
    }
}

#if DEBUG
#Preview("DrawerActionButton") {
    DrawerActionButton(title: "Apply", prominent: true, action: {})
        .padding()
}
#endif
