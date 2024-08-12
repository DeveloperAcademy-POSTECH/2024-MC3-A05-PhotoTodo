//
//  TodoView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI
import SwiftData
import UIKit
import PhotosUI
import OrderedCollections

enum SortOption {
    case byDate
    case byName
    case byStatus
    case byDueDate
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
    @State private var showingImagePicker = false
    @State private var isActive = false
    @StateObject var cameraVM: CameraViewModel = CameraViewModel()
    @AppStorage("deletionCount") var deletionCount: Int = 0
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    @State private var selectedItem: PhotosPickerItem?
    
    //새로운 사진 업로드 시 MakeTodoView에서 필요한 상태들
    @State var contentAlarm: Date? = nil
    @State var memo: String? = nil
    @State var alarmDataisEmpty: Bool? = nil
    @State var home: Bool? = nil
    @State var alarmID: String? = nil
    
    // 토글버튼에 따라서 토스트 메시지 설정 변수
    @State private var toastMessage: Todo? = nil
    @State private var toastOption: ToastOption = .none

    @State private var alarmSetting: Bool = false
    
    
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
        case .byDueDate:
            return todos.sorted { $0.options.alarm ?? Date() < $1.options.alarm ?? Date() }
            
        }
    }
    //TODO: folder.todos를 여러 옵션으로 정렬하기
    
    var todosGroupedByDate: [[Todo]] {
        return Array(getTodosGroupedByDate().values)
    }
    
    
    var navigationBarTitle: String {
        switch viewType {
        case .singleFolder:
            return currentFolder?.name ?? folders[0].name
        case .main:
            return ""
        case .doneList:
            return "완료함"
        }
    }
    
    
    var body: some View {
        VStack{
            viewType == .main ? AnyView(customNavBar) : AnyView(EmptyView())
        }
        ZStack {
            VStack{
                todos.isEmpty && viewType != .doneList
                ?
                AnyView(guideLineView)
                :
                AnyView(scrollView)

            }
            VStack{
                if toastOption == .moveToDone {
                    toastView(toastOption: .moveToDone, toastMessage: "투두가 완료되었어요!")
                    
                } else if toastOption == .moveToOrigin {
                    toastView(toastOption: .moveToOrigin, toastMessage: "투두가 복구되었어요!")
                }
                //                if toastMassage == nil {
                //                    Text("복구되었을 때")
                //                } else {
                //                    Text("삭제되었을 때")
                //                }
            }
        }
        .confirmationDialog("포토투두 추가 방법 선택", isPresented: $isShowingOptions, titleVisibility: .visible) {
            NavigationLink{
                CameraView(chosenFolder: currentFolder)
            } label : {
                Text("촬영하기")
            }
            Button("앨범에서 가져오기"){
                showingImagePicker.toggle()
            }
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem)
        .onChange(of: selectedItem, loadImage)
        .navigationTitle(navigationBarTitle)
        .navigationBarHidden( viewType == .main ? true : false)
        //PhotosPicker에서 아이템 선택 완료 시, isActive가 true로 바뀌고, MakeTodoView로 전환됨
        .navigationDestination(isPresented: $isActive) {
            MakeTodoView(cameraVM: cameraVM, chosenFolder: $currentFolder, startViewType: viewType == .singleFolder ? .gridSingleFolder : .gridMain , contentAlarm: $contentAlarm, alarmID: $alarmID, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo, home: $home)
        }
        .toolbar {
            ToolbarItem {
                editMode == .active ?
                //편집모드에서 다중선택된 아이템 삭제
                Button(action: deleteSelectedTodos) {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 18, height: 18)
                }.frame(width: 45) :
                //편집모드가 아닐 시 아이템 추가 버튼
                Button(action: toggleAddOptions) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 18, height: 18)
                }.frame(width: 45)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .frame(width: 38)
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
    
    var customNavBar: some View {
        HStack{
            Button(action: {
                alarmSetting.toggle()
            }, label: {
                Image(systemName: "alarm")
                    .resizable()
                    .frame(width: 18, height: 18)
            })
            .padding(.leading)
            Spacer()
            //편집모드에서 다중선택된 아이템 삭제
            Button(action: editMode == .active ? deleteSelectedTodos : toggleAddOptions) {
                if editMode == .active {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 18, height: 18)
                } else {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
            }
            .frame(width: 40)
            EditButton()
                .frame(width: 50)
                .onChange(of: editMode) { newEditMode in
                    //편집모드 해제시 선택정보 삭제
                    if newEditMode == .inactive {
                        selectedTodos.removeAll()
                    }
                }
        }
        .sheet(isPresented: $alarmSetting, content: {
            AlarmSettingView()
                .presentationDetents([.height(CGFloat(450))])
        })
        .frame(height: 33.5)
        .padding(.trailing, 5.7)
        .environment(\.editMode, $editMode)
    }
    
    
    var guideLineView: some View {
        VStack{
            if viewType == .main {
                customTitle
            }
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
        }

    }
    
    
    var scrollView: some View {
        ScrollView {
            if viewType == .main {
                customTitle
            }
            viewType != .main ? 
            AnyView(gridView(sortedTodos: sortedTodos, toastMessage: $toastMessage, toastOption: $toastOption, selectedTodos: $selectedTodos, editMode: $editMode)) :
            AnyView(groupedGridView)
        }
    }
    
    var groupedGridView: some View {
        ForEach(todosGroupedByDate.indices, id: \.self) { groupIndex in
            VStack{
                Text(getDateString(todosGroupedByDate[groupIndex][0].createdAt))
                gridView(sortedTodos: todosGroupedByDate[groupIndex], toastMessage: $toastMessage, toastOption: $toastOption, selectedTodos: $selectedTodos, editMode: $editMode)
            }
        }
    }
    
    var customTitle: some View {
        VStack{
            HStack{
                Text("해야 할 일이")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            todos.count == 0 ?
            HStack{
                Text("모두 완료되었어요!")
                    .font(.title)
                    .bold()
            }.frame(maxWidth: .infinity, alignment: .leading)
            :
            HStack{
                Text("\(todos.count)").font(.title).bold().foregroundStyle(.green) +
                Text("장 남았어요").font(.title).bold()
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
    
    private func getDateString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 d일"
        return dateFormatter.string(from: date)
    }
    
    private func getTodosGroupedByDate() -> OrderedDictionary<Int, [Todo]> {
        if sortedTodos.count == 0 {
            return [dayOfYear(from : Date()): sortedTodos]
        }
        var groupedTodos: OrderedDictionary<Int, [Todo]> = [:]
        var i = 0
        var currDate: Int
        while i != sortedTodos.count {
            switch sortOption {
            case .byDate:
                currDate = dayOfYear(from : sortedTodos[i].createdAt)
            case .byDueDate:
                currDate = dayOfYear(from : sortedTodos[i].options.alarm ?? Date())
            default:
                currDate = dayOfYear(from : sortedTodos[i].createdAt)
            }
            groupedTodos[currDate, default: []].append(sortedTodos[i])
            i += 1
        }
        return groupedTodos
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
    
    ///a method that will be called when the ImagePicker view has been dismissed
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            cameraVM.photoData.append(imageData)
            selectedItem = nil
            isActive = true
        }
    }
}

private struct toastView: View {
    @State var toastOption: ToastOption
    @State var toastMessage: String
    
    var body: some View {
        Button {
            
        } label: {
            RoundedRectangle(cornerRadius: 35)
                .fill(.paleGray)
                .opacity(0.5)
                .frame(width: 200, height: 50)
                .overlay {
                    Text(toastMessage)
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .foregroundColor(.green)
                        .padding()
                }
                .offset(y: 250)
        }
    }
}

private struct gridView: View {
    @State var sortedTodos: [Todo]
    @Binding var toastMessage: Todo?
    @Binding var toastOption: ToastOption
    @Binding var selectedTodos: Set<UUID>
    @Binding var editMode: EditMode
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack{
            LazyVGrid(columns: columns, spacing: 12) {
                //TODO: 이미지 비율 맞추기
                ForEach(sortedTodos) { todo in
                    TodoItemView(editMode: $editMode, todo: todo, toastMessage: $toastMessage, toastOption: $toastOption)
                    //tap gesture로 선택되었을 시 라인으로 표시됨
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
