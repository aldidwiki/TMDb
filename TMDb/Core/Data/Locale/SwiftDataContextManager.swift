//
//  SwiftDataContextManager.swift
//  TMDb
//
//  Created by Macbook on 04/03/26.
//

import Foundation
import SwiftData

@MainActor // Ensures all DB operations happen on the main thread for UI reactivity
class SwiftDataContextManager {
    static let shared = SwiftDataContextManager()
    
    let container: ModelContainer
    let context: ModelContext
    
    private init() {
        do {
            // 1. Initialize the container
            let schema = Schema([FavoriteEntity.self])
            let config = ModelConfiguration(schema: schema)
            container = try ModelContainer(for: schema, configurations: [config])
            
            // 2. IMPORTANT: Use the mainContext, not a new ModelContext(container)
            // This ensures @Query in your Views and this Manager stay in sync.
            context = container.mainContext
            
            // Optional: Enable autosave if you want changes to persist immediately
            context.autosaveEnabled = true
            
        } catch {
            fatalError("Could not initialize SwiftData: \(error)")
        }
    }
}
