import SwiftUI

struct DashboardTrailerButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if isLoading {
                    ProgressView()
                        .tint(DashboardDesign.surface)
                        .controlSize(.small)
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                }
                Text("Watch Trailer")
            }
            .font(.system(size: 13, weight: .semibold))
            .frame(width: 170, height: 42)
        }
        .buttonStyle(TrailerButtonStyle())
        .disabled(isLoading)
    }
}

#if DEBUG
#Preview("DashboardTrailerButton") {
    DashboardTrailerButton(isLoading: false, action: {})
}
#endif

private struct TrailerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(DashboardDesign.surface)
            .background(
                configuration.isPressed ? DashboardDesign.accentPressed : DashboardDesign.accent,
                in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
            )
    }
}
