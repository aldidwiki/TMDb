import SwiftUI

struct AnimatedFavoriteButton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animationTrigger = 0

    let isFavorite: Bool
    /// Returns true when the toggle changed the saved favorite state.
    let onToggle: () -> Bool

    var body: some View {
        let reduceMotion = self.reduceMotion
        let isFavorite = self.isFavorite
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        Button {
            if onToggle() && !reduceMotion {
                animationTrigger += 1
            }
        } label: {
            Label {
                Text(isFavorite ? "Favorited" : "Favorite")
            } icon: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
                    .keyframeAnimator(initialValue: CGFloat(1), trigger: animationTrigger) { icon, scale in
                        icon.scaleEffect(reduceMotion ? 1 : scale)
                    } keyframes: { _ in
                        CubicKeyframe(isFavorite ? 1.25 : 0.78, duration: 0.10)
                        SpringKeyframe(1, duration: 0.26, spring: .snappy)
                    }
                    .accessibilityHidden(true)
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(DashboardDesign.accent)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(isFavorite ? DashboardDesign.surfaceDim : DashboardDesign.surface, in: shape)
            .overlay {
                shape.strokeBorder(isFavorite ? DashboardDesign.accent : DashboardDesign.border)
                    .allowsHitTesting(false)
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: isFavorite)
        }
        .buttonStyle(FavoritePressStyle(reduceMotion: reduceMotion))
        .accessibilityHint(isFavorite ? "Removes from favorites" : "Adds to favorites")
    }
}

private struct FavoritePressStyle: ButtonStyle {
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .animation(reduceMotion ? nil : .spring(duration: 0.24, bounce: 0.16), value: configuration.isPressed)
    }
}

#if DEBUG
#Preview("AnimatedFavoriteButton") {
    AnimatedFavoriteButton(isFavorite: true, onToggle: { true })
}
#endif
