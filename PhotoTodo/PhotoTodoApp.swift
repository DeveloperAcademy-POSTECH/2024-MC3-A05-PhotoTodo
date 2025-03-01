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
            Options.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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
            TabBarView()
        }
        .modelContainer(sharedModelContainer)
    }
}
