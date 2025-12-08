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
            FolderOrder.self,
            Todo.self,
            Photo.self,
            Options.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, migrationPlan: PhotoTodoMigrationPlan.self, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init(){
        UIView.appearance(for: UITraitCollection(userInterfaceStyle: .light),
          whenContainedInInstancesOf: [UIAlertController.self])
            .tintColor = UIColor(Color("AccentColor"))

        UIView.appearance(for: UITraitCollection(userInterfaceStyle: .dark),
          whenContainedInInstancesOf: [UIAlertController.self])
            .tintColor = UIColor(Color("AccentColor"))
    }

    var body: some Scene {
        WindowGroup {
            if let defaults = UserDefaults(suiteName: "group.PhotoTodo-com.2024-MC3-A05-team5.PhotoTodo") {
                TabBarView()
                    .defaultAppStorage(defaults)
            }
            else {
                Text("Failed to load UserDefaults")
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

