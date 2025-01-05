//
//  DashBoardViewModel.swift
//  PhotoTodo
//
//  Created by leejina on 1/5/25.
//
import Foundation
import SwiftUI
import SwiftData

@Observable
class MainTabViewModel {
    
    private var notificationManager: NotificationManager
    
    init() {
        self.notificationManager = NotificationManager()
    }
    
    func removeTodoItemsPastDueDate(todos: [Todo], modelContext: ModelContext, deletionCount: Int) -> Int {
        
        var count: Int = deletionCount
        
        let todoItemsPastDueDate: [Todo] = todos.filter{
            isPastDueDate(todo: $0)
        }
        
        for todo in todoItemsPastDueDate {
            if let todo = todos.first(where: { $0.id == todo.id }) {
                modelContext.delete(todo)
                count += 1
            }
        }
        
        return count
    }
    
    func isPastDueDate(todo: Todo) -> Bool {
        if 30 < daysPassedSinceJanuaryFirst2024(from : Date())-daysPassedSinceJanuaryFirst2024(from : todo.isDoneAt ?? Date()) {
            return true
        }
        return false
    }
    
    func MakeDefaultFolder(modelContext: ModelContext) {
        let defaultFolder = Folder(
            id: UUID(),
            name: "기본",
            color: "green",
            todos: []
        )
        modelContext.insert(defaultFolder)
    }
    
    func activateNotificationRequestAuthorization() {
        self.notificationManager.requestAuthorization()
    }
}
