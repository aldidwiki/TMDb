//
//  TMDbApp.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI
import AlamofireNetworkActivityLogger

@main
struct TMDbApp: App {
    init() {
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .debug
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
