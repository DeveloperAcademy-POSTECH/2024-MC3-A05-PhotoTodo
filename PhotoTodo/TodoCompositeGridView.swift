//
//  TodoView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI
import SwiftData
    
struct TodoCompositeGridView: View {
    @State var viewType: TodoGridViewType
    
    var body: some View {
        TodoGridView(viewType: viewType)
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
            images: [Photo(image: UIImage(systemName: "photo")?.pngData() ?? Data())],
            createdAt: Date(),
            options: Options(memo: "사진 정리하기"),
            isDone: false
        ),
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "phone")?.pngData() ?? Data())],
            createdAt: Date().addingTimeInterval(-7200),
            options: Options(alarm: Date().addingTimeInterval(3600), memo: "전화하기"),
            isDone: false
        ),
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "calendar")?.pngData() ?? Data())],
            createdAt: Date().addingTimeInterval(-86400),
            options: Options(memo: "일정 확인"),
            isDone: false
        ),
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "checkmark.circle")?.pngData() ?? Data())],
            createdAt: Date().addingTimeInterval(-172800),
            options: Options(memo: "완료된 작업"),
            isDone: true,
            isDoneAt: Date().addingTimeInterval(-86400)
        )
    ]
    
    let folder = Folder(id: UUID(), name: "기본", color: "green", todos: mockTodos)
    container.mainContext.insert(folder)
    
    return TodoCompositeGridView(viewType: .main)
        .modelContainer(container)
}
