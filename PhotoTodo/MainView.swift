//
//  MainView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    var viewType: TodoGridViewType = .main
    var body: some View {
            TodoCompositeGridView(viewType: viewType)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Folder.self, Todo.self, Photo.self, Options.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let mockTodos = [
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "sun.max.fill")?.pngData() ?? Data())],
            createdAt: Date(),
            options: Options(memo: "아침 루틴"),
            isDone: false
        ),
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "cup.and.saucer.fill")?.pngData() ?? Data())],
            createdAt: Date().addingTimeInterval(-1800),
            options: Options(alarm: Date().addingTimeInterval(3600), memo: "커피 타임"),
            isDone: false
        ),
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "laptopcomputer")?.pngData() ?? Data())],
            createdAt: Date().addingTimeInterval(-7200),
            options: Options(memo: "작업하기"),
            isDone: false
        ),
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "moon.stars.fill")?.pngData() ?? Data())],
            createdAt: Date().addingTimeInterval(-86400),
            options: Options(memo: "저녁 루틴"),
            isDone: true,
            isDoneAt: Date()
        )
    ]
    
    let folder = Folder(id: UUID(), name: "기본", color: "green", todos: mockTodos)
    container.mainContext.insert(folder)
    
    return MainView()
        .modelContainer(container)
}
