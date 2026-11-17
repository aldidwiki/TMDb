//
//  SplashView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 23/06/23.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    let content: () -> ContentView

    init(content: @escaping () -> ContentView = { ContentView() }) {
        self.content = content
    }
    
    var body: some View {
        ZStack {
            if isActive {
                content()
                    .transition(.scale)
            } else {
                SplashArtwork()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

#if DEBUG
#Preview("Splash") {
    SplashView(content: PreviewFixtures.contentView)
}
#endif
