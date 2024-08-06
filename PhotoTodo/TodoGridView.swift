//
//  TodoView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI
import SwiftData
import UIKit

enum SortOption {
    case byDate
    case byName
    case byStatus
}

struct TodoGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var folders: [Folder]
    @Query var compositeTodos: [Todo]
    @State var currentFolder: Folder? = nil
    var viewType: TodoGridViewType
    @State private var selectedTodos = Set<UUID>()
    @State private var editMode: EditMode = .inactive
    @State private var sortOption: SortOption = .byDate
    @State private var isShowingOptions = false
    
    var todos: [Todo] {
        switch viewType {
        case .singleFolder:
            return currentFolder!.todos.filter { todo in
                todo.isDone == false
            }
        case .main:
            return compositeTodos.filter { todo in
                todo.isDone == false
            }
        case .doneList:
            return compositeTodos.filter { todo in
                todo.isDone == true
            }
        }
    }
    
    
    var sortedTodos: [Todo] {
        switch sortOption {
        case .byDate:
            return todos.sorted { $0.createdAt < $1.createdAt }
        case .byName:
            return todos.sorted { $0.options.memo ?? "" < $1.options.memo ?? "" }
        case .byStatus:
            return todos.sorted { $0.isDone && !$1.isDone }
        }
    }
    //TODO: folder.todos를 여러 옵션으로 정렬하기
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var navigationBarTitle: String {
        switch viewType {
        case .singleFolder:
            return currentFolder?.name ?? folders[0].name
        case .main:
            return "메인뷰"
        case .doneList:
            return "완료함"
        }
    }
    
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                //TODO: 각 Todo에 대한 DetailView Link 연결시키기
                //TODO: 이미지 비율 맞추기
                
                ForEach(sortedTodos) { todo in
                    TodoItemView(editMode: $editMode, todo: todo)
                        //각 TodoItem에 체크박스를 오버레이하여 보여줌
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTodos.contains(todo.id) ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        //편집모드가 활성화되어 있을 시 tap gesture로 여러 아이템을 선택할 수 있게 함
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
            }
            .confirmationDialog("포토투두 추가 방법 선택", isPresented: $isShowingOptions, titleVisibility: .visible) {
                NavigationLink{
                    CameraView(chosenFolder: currentFolder)
                } label : {
                    Text("촬영하기")
                }
//                Button("촬영하기"){
//                    addTodos()
//                }
                Button("앨범에서 가져오기"){
                    print("앨범에서 가져오기")
                }
            }
            .navigationBarTitle(
                navigationBarTitle
            )
            .toolbar {
                ToolbarItem {
                    editMode == .active ?
                    //편집모드에서 다중선택된 아이템 삭제
                    Button(action: deleteSelectedTodos) {
                        Label("Delete Item", systemImage: "trash")
                    } :
                    //편집모드가 아닐 시 아이템 추가 버튼
                    Button(action: toggleAddOptions) {
                        Label("add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .onChange(of: editMode) { newEditMode in
                        //편집모드 해제시 선택정보 삭제
                            if newEditMode == .inactive {
                                selectedTodos.removeAll()
                            }
                        }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
    private func toggleAddOptions(){
        isShowingOptions.toggle()
    }
    
    private func addTodos() {
        withAnimation {
            let newTodo = Todo(
                folder: currentFolder,
                id: UUID(),
                image: UIImage(contentsOfFile: "filledCoffee")?.pngData() ?? Data(),
                createdAt: Date(),
                options: Options(
                    alarm : nil,
                    memo : nil
                ),
                isDone : false
            )
            if let folder = currentFolder {
                //ViewType이 singleFolder인 경우에는 currentFolder 인자가 전달되 오므로 그곳으로 저장
                folder.todos.append(newTodo)
            } else {
                //ViewType이 main, doneList인 경우에는 currentFolder가 nil이므로 저장 불가. 기본 폴더로 저장해야 함.
                folders[0].todos.append(newTodo)
            }
            
            modelContext.insert(newTodo)
        }
    }
    
    
    private func deleteSelectedTodos() {
        withAnimation {
            DispatchQueue.main.async{
                selectedTodos.forEach { id in
                    if let todo = todos.first(where: { $0.id == id }) {
                        modelContext.delete(todo)
                    }
                }
                selectedTodos.removeAll() // Clear selected items after deletion
            }
        }
    }
}



//struct TodoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        var viewType: TodoGridViewType = .singleFolder
//        TodoGridView(defaultStorageFolder: previewFolder, todos: previewFolder.todos, viewType: viewType)
//    }
//    
//    static var previewFolder: Folder {
//        let sampleTodo = Todo(
//            id: UUID(),
//            image: UIImage(systemName: "star")?.pngData() ?? Data(),
//            createdAt: Date(),
//            options: Options(
//                alarm: nil,
//                memo: nil
//            ),
//            isDone: false
//        )
//        
//        return Folder(
//            id: UUID(),
//            name: "예제폴더", 
//            color: "red",
//            todos: [sampleTodo]
//        )
//    }
//}
