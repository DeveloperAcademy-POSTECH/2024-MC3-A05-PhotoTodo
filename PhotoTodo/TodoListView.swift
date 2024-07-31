//
//  TodoView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI

enum SortOption {
    case byDate
    case byName
    case byStatus
}

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @State var folder: Folder
    @State private var selectedTodos = Set<UUID>()
    @State private var editMode: EditMode = .inactive
    @State private var sortOption: SortOption = .byDate
    
    var sortedTodos: [Todo] {
        switch sortOption {
        case .byDate:
            return folder.todos.sorted { $0.createdAt < $1.createdAt }
        case .byName:
            return folder.todos.sorted { $0.options.memo ?? "" < $1.options.memo ?? "" }
        case .byStatus:
            return folder.todos.sorted { $0.isDone && !$1.isDone }
        }
    }
    //TODO: folder.todos를 여러 옵션으로 정렬하기
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                //TODO: 각 Todo에 대한 DetailView Link 연결시키기
                //TODO: 이미지 비율 맞추기
                
                ForEach(sortedTodos) { todo in
                    TodoItemView(editMode: $editMode, todo: todo)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTodos.contains(todo.id) ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            if editMode == .active {
                                if selectedTodos.contains(todo.id) {
                                    selectedTodos.remove(todo.id)
                                } else {
                                    selectedTodos.insert(todo.id)
                                }
                            }
                        }
                }
                //TODO: delete 제대로 작동하게 만들기
                .onDelete(perform: deleteTodos)
            }
            .navigationBarTitle(folder.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .onChange(of: editMode) { newEditMode in
                            if newEditMode == .inactive {
                                selectedTodos.removeAll()
                            }
                        }
                }
                ToolbarItem {
                    editMode == .active ?
                    //MARK: 다중선택된 아이템 삭제
                    Button(action: deleteSelectedTodos) {
                        Label("Delete Item", systemImage: "trash")
                    } :
                    Button(action: addTodos) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
    
    private func addTodos() {
        withAnimation {
            let newTodo = Todo(
                id: UUID(),
                image: UIImage(contentsOfFile: "filledCoffee")?.pngData() ?? Data(),
                createdAt: Date(),
                options: Options(
                    alarm : nil,
                    memo : nil
                ),
                isDone : false
            )
            folder.todos.append(newTodo)
            modelContext.insert(newTodo)
        }
    }
    
    private func deleteTodos(at offsets: IndexSet) {
        folder.todos.remove(atOffsets: offsets)
    }
    
    private func deleteSelectedTodos() {
        withAnimation {
            folder.todos.removeAll { selectedTodos.contains($0.id) }
            selectedTodos.removeAll() // Clear selected items after deletion
        }
    }
}



struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView(folder: previewFolder)
    }
    
    static var previewFolder: Folder {
        let sampleTodo = Todo(
            id: UUID(),
            image: UIImage(systemName: "star")?.pngData() ?? Data(),
            createdAt: Date(),
            options: Options(
                alarm: nil,
                memo: nil
            ),
            isDone: false
        )
        
        return Folder(
            id: UUID(),
            name: "예제폴더",
            todos: [sampleTodo]
        )
    }
}
