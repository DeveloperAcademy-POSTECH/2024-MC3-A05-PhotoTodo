//
//  _024_MC3_A05_PhotoTodoApp.swift
//  2024-MC3-A05-PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/28/24.
//

import SwiftUI
import SwiftData

@main
struct _024_MC3_A05_PhotoTodoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
