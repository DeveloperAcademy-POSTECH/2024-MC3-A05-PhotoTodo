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

enum ToastOption {
    case none
    case moveToDone
    case discoverOrigin
    case moveToOrigin
    case discoverDone
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
    @AppStorage("deletionCount") var deletionCount: Int = 0
    
    // 토글버튼에 따라서 토스트 메시지 설정 변수
    @State private var toastMassage: Todo? = nil
    @State private var toastOption: ToastOption = .none
    
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
            return "포토투두"
        case .doneList:
            return "완료함"
        }
    }
    
    
    var body: some View {
        ZStack {
            VStack{
                if todos.isEmpty {
                    Spacer()
                    VStack{
                        Image("mainEmptyIcon")
                            .resizable()
                            .frame(width: 56, height: 56)
                        VStack{
                            Text("새로운 사진을 추가하여")
                            Text("포토투두를 만들어보세요!")
                        }
                        .padding(.top)
                        .font(.system(size: 20))
                        .foregroundStyle(Color.gray)
                        .bold()
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack{
                            LazyVGrid(columns: columns, spacing: 12) {
                                //TODO: 이미지 비율 맞추기
                                ForEach(sortedTodos) { todo in
                                    TodoItemView(editMode: $editMode, todo: todo, toastMassage: $toastMassage, toastOption: $toastOption)
                                    //각 TodoItem에 체크박스를 오버레이하여 보여줌
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(selectedTodos.contains(todo.id) ? Color("green/green-500") : Color.clear, lineWidth: 4)
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
                            .padding(.bottom)
                        }
                        .padding(.horizontal)
                        
                    }
                }
            }
            VStack{
                if toastOption != .none {
                    if toastOption == .moveToDone {
                        Button {
                            
                        } label: {
                            RoundedRectangle(cornerRadius: 35)
                                    .fill(.paleGray)
                                    .opacity(0.5)
                                    .frame(width: 200, height: 50)
                                    .overlay {
                                        Text("투두가 복구되었어요!")
                                                .fontWeight(.bold)
                                                .font(.system(size: 15))
                                                .foregroundColor(.green)
                                                .padding()
                                    }
                                    .offset(y: 250)
                        }
                        
                    } else if toastOption == .moveToOrigin {
                        
                        RoundedRectangle(cornerRadius: 35)
                                .fill(.paleGray)
                                .opacity(0.5)
                                .frame(width: 200, height: 50)
                                .overlay {
                                    Text("투두가 완료되었어요!")
//                                    Text("완료함으로 이동되었어요!")
                                            .fontWeight(.bold)
                                            .font(.system(size: 15))
                                            .foregroundColor(.green)
                                            .padding()
                                }
                                .offset(y: 250)
                    }
                    //                if toastMassage == nil {
                    //                    Text("복구되었을 때")
                    //                } else {
                    //                    Text("삭제되었을 때")
                    //                }
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
    
    ///완료함에서 삭제한 경우에 DeletionCount를 삭제한 아이템의 개수만큼 늘려줌
    private func addDeletionCount() {
        if viewType != .doneList{
            return
        }
        deletionCount += selectedTodos.count
        print(deletionCount)
    }
    
    private func deleteSelectedTodos() {
        addDeletionCount()
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
