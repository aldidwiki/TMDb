//
//  TMDbApp.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI
import SwiftData

@main
struct TMDbApp: App {
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(SwiftDataContextManager.shared.container)
    }
}
