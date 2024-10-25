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

enum SortOption: String, CaseIterable {
    case byDateIncreasing
    case byDateDecreasing
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
    @AppStorage("sortOption") private var sortOption: SortOption = .byDateIncreasing
    @State private var isShowingOptions = false
    @State private var showingImagePicker = false
    @State private var isDoneSelecting = false
    @ObservedObject private var cameraVM = CameraViewModel.shared
    @AppStorage("deletionCount") var deletionCount: Int = 0
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    //    @State private var selectedItem: PhotosPickerItem?
    
    //새로운 사진 업로드 시 MakeTodoView에서 필요한 상태들
    @State var contentAlarm: Date? = nil
    @State var memo: String? = nil
    @State var alarmDataisEmpty: Bool? = nil
    @State var home: Bool? = nil
    @State var alarmID: String? = nil
    @State private var alarmSetting: Bool = false
    
    // 토글버튼에 따라서 토스트 메시지 설정 변수
    @State private var toastMessage: String? = nil
    @State private var toastOption: ToastOption = .none
    @State private var recentlyDoneTodo: Todo? = nil
    
    /// 카메라 뷰 진입시 필요한 변수임. False일 때는 sheet에서 진입하는 것이 아님, true일 때는 sheet에서 진입함. 두 개 상황에서 뷰가 다르게 그려짐.
    @State var isCameraSheetOn: Bool = false
    
    
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
        case .byDateIncreasing:
            return todos.sorted { $0.createdAt < $1.createdAt }
        case .byDateDecreasing:
            return todos.sorted { $0.createdAt > $1.createdAt }
        case .byName:
            return todos.sorted { $0.options.memo ?? "" < $1.options.memo ?? "" }
        case .byStatus:
            return todos.sorted { $0.isDone && !$1.isDone }
        case .byDueDate:
            return todos.sorted { $0.options.alarm ?? Date() < $1.options.alarm ?? Date() }
            
        }
    }
    //TODO: folder.todos를 여러 옵션으로 정렬하기
    
    var todosGroupedByDate: OrderedDictionary<Int, [Todo]> {
        return getTodosGroupedByDate()
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
            if viewType == .main {
                customNavBar
            }
            ZStack {
                Color("gray/gray-200").ignoresSafeArea()
                VStack{
                    if todos.isEmpty && viewType != .doneList {
                        GuideLineView(viewType: viewType, todos: todos)
                    } else {
                        scrollableGridView
                    }
                }
                VStack{
                    if toastOption == .moveToDone {
                        ToastView(toastOption: .moveToDone, toastMessage: "투두가 완료되었어요!", recentlyDoneTodo: $recentlyDoneTodo)
                        
                    } else if toastOption == .moveToOrigin {
                        ToastView(toastOption: .moveToOrigin, toastMessage: "투두가 복구되었어요!", recentlyDoneTodo: $recentlyDoneTodo)
                    }
                }
            }
        }
        .confirmationDialog("포토투두 추가 방법 선택", isPresented: $isShowingOptions, titleVisibility: .visible) {
            NavigationLink{
                CameraView(chosenFolder: currentFolder, isCameraSheetOn: $isCameraSheetOn)
            } label : {
                Text("촬영하기")
            }
            Button("앨범에서 가져오기"){
                cameraVM.photoData.removeAll()
                showingImagePicker.toggle()
            }
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedItems,  maxSelectionCount: 10, matching: .not(.videos))
        .onChange(of: selectedItems, loadImage)
        .navigationTitle(navigationBarTitle)
        .navigationBarHidden( viewType == .main ? true : false)
        //PhotosPicker에서 아이템 선택 완료 시, isActive가 true로 바뀌고, MakeTodoView로 전환됨
        .navigationDestination(isPresented: $isDoneSelecting) {
            MakeTodoView(chosenFolder: $currentFolder, startViewType: viewType == .singleFolder ? .gridSingleFolder : .gridMain , contentAlarm: $contentAlarm, alarmID: $alarmID, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo, home: $home)
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
                    .onChange(of: editMode) { _, newEditMode in
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
                .onChange(of: editMode) { _, newEditMode in
                    //편집모드 해제시 선택정보 삭제
                    if newEditMode == .inactive {
                        selectedTodos.removeAll()
                    }
                }
        }
        .sheet(isPresented: $alarmSetting, content: {
            AlarmSettingView()
                .presentationDetents([.height(CGFloat(450))])
                .presentationDragIndicator(.visible)
        })
        .frame(height: 33.5)
        .padding(.trailing, 5.7)
        .environment(\.editMode, $editMode)
    }
    
    var sortMenu: some View {
        HStack {
            Spacer()
            Menu {
                Picker("정렬", selection: $sortOption) {
                    Text("최신순").tag(SortOption.byDateDecreasing)
                    Text("오래된순").tag(SortOption.byDateIncreasing)
                }
            } label: {
                HStack {
                    Text("정렬")
                        .tint(Color.black)
                    Image(systemName: "chevron.down")
                        .tint(Color.black)
                }
                .padding(.horizontal)
            }
        }
    }
    
    var scrollableGridView: some View {
        ScrollView {
            if viewType == .main {
                CustomTitle(todos: todos)
            }
            sortMenu
            if viewType != .main {
                GridView(sortedTodos: sortedTodos, toastMessage: $toastMessage, toastOption: $toastOption, recentlyDoneTodo: $recentlyDoneTodo, selectedTodos: $selectedTodos, editMode: $editMode) //메인뷰가 아닐 때는 그리드 뷰 하나로 모든 아이템을 모아서 보여줌
            } else {
                groupedGridView //메인뷰일 때는 날짜별로 그룹화된 아이템을 보여줌
            }
        }
    }
    
    
    /// 날짜별로 그룹화된 아이템들의 각 그룹 각각에 대응하는 그리드 뷰가  ForEach문으로 그려짐
    var groupedGridView: some View {
        ForEach(todosGroupedByDate.elements, id: \.key) { element in
            VStack{
                HStack{
                    Text(getDateString(element.value[0].createdAt))
                        .foregroundStyle(.gray)
                    Spacer()
                }.padding(.leading)
                GridView(sortedTodos: element.value, toastMessage: $toastMessage, toastOption: $toastOption, recentlyDoneTodo: $recentlyDoneTodo, selectedTodos: $selectedTodos, editMode: $editMode)
            }
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
                images: [Data()],
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

extension TodoGridView {
    private func getDateString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 d일"
        return dateFormatter.string(from: date)
    }
    
    /// 날짜별로 투두 아이템을 그루핑한 배열을 모은 배열을 리턴함
    private func getTodosGroupedByDate() -> OrderedDictionary<Int, [Todo]> {
        if sortedTodos.count == 0 {
            return [dayOfYear(from : Date()): sortedTodos] //dayOfYear는 현재 연도의 몇번째 날짜인지를 리턴함
        }
        var groupedTodos: OrderedDictionary<Int, [Todo]> = [:] //OrderedDictionary 타입을 사용하여
        var i = 0
        var curr: Int
        while i != sortedTodos.count {
            switch sortOption {
            case .byDateIncreasing:
                curr = daysPassedSinceJanuaryFirst2024(from : sortedTodos[i].createdAt)
            case .byDueDate:
                curr = daysPassedSinceJanuaryFirst2024(from : sortedTodos[i].options.alarm ?? Date())
            default: //그룹화는 만들어진 날짜를 기준으로 이루어짐
                curr = daysPassedSinceJanuaryFirst2024(from : sortedTodos[i].createdAt)
            }
            groupedTodos[curr, default: []].append(sortedTodos[i])
            i += 1
        }
        return groupedTodos
    }
    
    ///a method that will be called when the ImagePicker view has been dismissed
    func loadImage() {
        Task {
            for item in selectedItems {
                if let imageData = try? await item.loadTransferable(type: Data.self) {
                    cameraVM.photoData.append(imageData)
                }
            }
            selectedItems.removeAll()
            isDoneSelecting = true
        }
    }
}



struct GridView: View {
    var sortedTodos: [Todo]
    @Binding var toastMessage: String?
    @Binding var toastOption: ToastOption
    @Binding var recentlyDoneTodo: Todo?
    @Binding var selectedTodos: Set<UUID>
    @Binding var editMode: EditMode
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack{
            ScrollView{
                LazyVGrid(columns: columns, spacing: 12) {
                    //TODO: 이미지 비율 맞추기
                    ForEach(sortedTodos) { todo in
                        TodoItemView(editMode: $editMode, todo: todo, toastMessage: $toastMessage, toastOption: $toastOption, recentlyDoneTodo: $recentlyDoneTodo)
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
                .padding(.top, 4)
                .padding(.bottom)
            }
        }
        .ignoresSafeArea(.keyboard)
        .padding(.horizontal)
    }
}

private struct GuideLineView: View {
    var viewType: TodoGridViewType
    var todos: [Todo]
    
    var body: some View {
        VStack{
            if viewType == .main {
                CustomTitle(todos: todos)
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
}

private struct CustomTitle: View{
    var todos: [Todo]
    
    var body: some View {
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
