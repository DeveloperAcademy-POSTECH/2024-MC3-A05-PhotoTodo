//
//  PhotoTodoApp.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/28/24.
//

import SwiftUI
import SwiftData

@main
struct PhotoTodoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Folder.self,
            Todo.self,
            Options.self
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
            TabBarView()
//            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
