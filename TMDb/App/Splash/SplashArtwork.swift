import SwiftUI

struct SplashArtwork: View {
    var body: some View {
        ZStack {
            Rectangle()
                .background(Color("primary_color"))

            Color("primary_color")

            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview("Splash artwork") {
    SplashArtwork()
}
#endif
