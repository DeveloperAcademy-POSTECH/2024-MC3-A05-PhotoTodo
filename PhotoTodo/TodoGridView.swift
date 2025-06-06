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
    @Query private var folders: [Folder]
    @State var currentFolder: Folder? = nil
    var viewType: TodoGridViewType
    @State private var selectedTodos = Set<UUID>()
    @State private var editMode: EditMode = .inactive
    @AppStorage("sortOption") private var sortOption: SortOption = .byDateIncreasing
    @State private var isShowingOptions = false
    @State private var showingImagePicker = false
    @State private var isDoneSelecting = false
    @State private var cameraVM = CameraViewModel.shared
    @AppStorage("deletionCount") var deletionCount: Int = 0
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    //    @State private var selectedItem: PhotosPickerItem?
    
    //새로운 사진 업로드 시 MakeTodoView에서 필요한 상태들
    @State private var contentAlarm: Date? = nil
    @State private var memo: String? = nil
    @State private var alarmDataisEmpty: Bool? = nil
    @State private var home: Bool? = nil
    @State private var alarmID: String? = nil
    @State private var alarmSetting: Bool = false
    
    // 토글버튼에 따라서 토스트 메시지 설정 변수
    @State private var toastMessage: String? = nil
    @State private var toastOption: ToastOption = .none
    @State private var recentlyDoneTodo: Todo? = nil
    
    /// 카메라 뷰 진입시 필요한 변수임. False일 때는 sheet에서 진입하는 것이 아님, true일 때는 sheet에서 진입함. 두 개 상황에서 뷰가 다르게 그려짐.
    @State private var isCameraSheetOn: Bool = false
    @State private var isCameraNavigate: Bool = false
    
    private var compositeTodos: [Todo] {
        folders.flatMap { $0.todos }
    }
    
    private var todos: [Todo] {
        switch viewType {
        case .singleFolder:
            return currentFolder?.todos.filter { !$0.isDone } ?? []
        case .main:
            return compositeTodos.filter { !$0.isDone }
        case .doneList:
            return compositeTodos.filter { $0.isDone }
        }
    }
    
    
    private var sortedTodos: [Todo] {
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
    
    private var filteredTodos: [Todo] {
        switch viewType {
        case .singleFolder:
            if let currentFolder = currentFolder {
                return sortedTodos.filter { $0.folder == currentFolder }
            } else {
                return sortedTodos
            }
        case .main:
            return sortedTodos
        case .doneList:
            return sortedTodos //뷰상에서 한번 거르는 로직이 있음
        }
    }
    
    //TODO: folder.todos를 여러 옵션으로 정렬하기
    var todosGroupedByDate: OrderedDictionary<Int, [Todo]> {
        return getTodosGroupedByDate()
    }
    
    
    private var navigationBarTitle: String {
        switch viewType {
        case .singleFolder:
            return currentFolder?.name ?? folders[0].name
        case .main:
            return ""
        case .doneList:
            return "완료함"
        }
    }
    
    @State var toastHeight: CGFloat = 0
    private var sortOptionString: String {
        switch sortOption {
        case .byDateIncreasing:
            "오래된순"
        case .byDateDecreasing:
            "최신순"
        default:
            "기타"
        }
    }

    
    var body: some View {
        VStack(spacing: 0) {
            if viewType == .main {
                customNavBar
            }
            ZStack {
                Color("gray/gray-200").ignoresSafeArea()
                VStack {
                    if todos.isEmpty && viewType != .doneList {
                        GuideLineView(viewType: viewType, todos: todos, navigationBarTitle: navigationBarTitle, folder: currentFolder) //데이터 없을 시
                    } else {
                        scrollableGridView //데이터 있을 시
                    }
                }
                //토스트 알림
                VStack{
                    if toastOption == .moveToDone {
                        ToastView(toastOption: .moveToDone, toastMessage: "투두가 완료되었어요!", recentlyDoneTodo: $recentlyDoneTodo, toastHeight: $toastHeight)
                        
                    } else if toastOption == .moveToOrigin {
                        ToastView(toastOption: .moveToOrigin, toastMessage: "투두가 복구되었어요!", recentlyDoneTodo: $recentlyDoneTodo, toastHeight: $toastHeight)
                    }
                }
            }
        }
        .onAppear {
            toastHeight = UIScreen.main.bounds.height / 2 - 127 - 50
        }
        .confirmationDialog("포토투두 추가 방법 선택", isPresented: $isShowingOptions, titleVisibility: .visible) {
            Button("촬영하기") {
                isCameraNavigate = true
                home = false
            }
            Button("앨범에서 가져오기"){
                cameraVM.photoData.removeAll()
                showingImagePicker.toggle()
            }
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedItems,  maxSelectionCount: 10, matching: .not(.videos))
        .onChange(of: selectedItems, loadImage)
        .navigationBarHidden( viewType == .main ? true : false)
        .sheet(isPresented: $isCameraNavigate, content: {
            NavigationStack{
                CameraView(chosenFolder: currentFolder, isCameraSheetOn: $isCameraSheetOn, home: $home)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("취소") {
                                isCameraNavigate = false
                            }
                        }
                    }
                    .presentationDragIndicator(.visible)
            }
        })
        .sheet(isPresented: $isDoneSelecting, content: {
            NavigationStack{
                VStack{
                    ScrollView{
                        MakeTodoView(chosenFolder: $currentFolder, startViewType: .camera, contentAlarm: $contentAlarm, alarmID: $alarmID, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo, home: $home)
                            .presentationDragIndicator(.visible)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("취소") {
                                        isDoneSelecting = false
                                    }
                                }
                            }
                    }
                }
            }
        })
        .toolbar {
            ToolbarItem {
                //편집모드에서 다중선택된 아이템 삭제
                if editMode == .active {
                    Button(action: deleteSelectedTodos) {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }.frame(width: 45)
                } else {
                    //편집모드가 아닐 시 아이템 추가 버튼
                    Button(action: toggleAddOptions) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    .frame(width: 45)
                    .disabled(viewType == .doneList)
                    .opacity(viewType == .doneList ? 0 : 1)
                }
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
    
    private var customNavBar: some View {
        HStack(spacing: 0) {
            Spacer()
            
            //편집모드에서 다중선택된 아이템 삭제
            Button(action: editMode == .active ? deleteSelectedTodos : toggleAddOptions) {
                if editMode == .active {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundStyle(Color("green/green-700"))
                } else {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(Color("green/green-700"))
                }
            }
            .frame(width: 44)
            
            EditButton()
                .frame(width: 44)
                .onChange(of: editMode) { _, newEditMode in
                    //편집모드 해제시 선택정보 삭제
                    if newEditMode == .inactive {
                        selectedTodos.removeAll()
                    }
                }
            
            Menu {
                Button {
                    alarmSetting.toggle()
                } label: {
                    HStack {
                        Text("정기 알람 설정")
                        Image(systemName: "alarm")
                    }
                }
                
                Button {
                    
                } label: {
                    HStack {
                        Text("도움말")
                        Image(systemName: "info.circle")
                    }
                }
                
                Button {
                    
                } label: {
                    HStack {
                        Text("팀소개")
                        Image(systemName: "leaf")
                    }
                }
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .foregroundStyle(Color("green/green-700"))
            }
            .frame(width: 44)
        }
        .sheet(isPresented: $alarmSetting, content: {
            AlarmSettingView()
                .presentationDetents([.height(CGFloat(450))])
                .presentationDragIndicator(.visible)
        })
        .frame(height: 44)
        .padding(.horizontal, 20)
        .padding(.top, 5)
        .environment(\.editMode, $editMode)
    }
    
    private var sortMenu: some View {
        HStack {
            Spacer()
            Menu {
                Picker("정렬", selection: $sortOption) {
                    Text("최신순").tag(SortOption.byDateDecreasing)
                    Text("오래된순").tag(SortOption.byDateIncreasing)
                }
            } label: {
                HStack(spacing: 2) {
                    Text("\(sortOptionString)")
                        .tint(Color.black)
                    Image(systemName: "chevron.down")
                        .tint(Color.black)
                }
                .font(.callout)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .frame(height: 44)
        }
        .padding(.horizontal, 20)
    }
    
    private var scrollableGridView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                CustomTitle(todos: todos, viewType: viewType, navigationBarTitle: navigationBarTitle, folder: currentFolder)
                sortMenu
                if viewType == .doneList {
                    GridView(sortedTodos: sortedTodos, toastMessage: $toastMessage, toastOption: $toastOption, recentlyDoneTodo: $recentlyDoneTodo, selectedTodos: $selectedTodos, editMode: $editMode) //메인뷰가 아닐 때는 그리드 뷰 하나로 모든 아이템을 모아서 보여줌
                } else {
                    groupedGridView //메인뷰일 때는 날짜별로 그룹화된 아이템을 보여줌
                }
            }
        }
    }
    
    
    /// 날짜별로 그룹화된 아이템들의 각 그룹 각각에 대응하는 그리드 뷰가  ForEach문으로 그려짐
    private var groupedGridView: some View {
        ForEach(todosGroupedByDate.elements, id: \.key) { element in
            VStack(spacing: 8) {
                HStack {
                    Text(getDateString(element.value[0].createdAt))
                        .font(.callout)
                        .foregroundStyle(Color("gray/gray-700"))
                        .padding(.leading, 10)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
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
            try? modelContext.save()
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
                try? modelContext.save()
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
        if filteredTodos.count == 0 {
            return [dayOfYear(from : Date()): filteredTodos] //dayOfYear는 현재 연도의 몇번째 날짜인지를 리턴함
        }
        var groupedTodos: OrderedDictionary<Int, [Todo]> = [:] //OrderedDictionary 타입을 사용하여
        var i = 0
        var curr: Int
        while i != filteredTodos.count {
            switch sortOption {
            case .byDateIncreasing:
                curr = daysPassedSinceJanuaryFirst2024(from : filteredTodos[i].createdAt)
            case .byDueDate:
                curr = daysPassedSinceJanuaryFirst2024(from : filteredTodos[i].options.alarm ?? Date())
            default: //그룹화는 만들어진 날짜를 기준으로 이루어짐
                curr = daysPassedSinceJanuaryFirst2024(from : filteredTodos[i].createdAt)
            }
            groupedTodos[curr, default: []].append(filteredTodos[i])
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
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 13) {
                    //TODO: 이미지 비율 맞추기
                    ForEach(sortedTodos) { todo in
                        TodoItemView(editMode: $editMode, todo: todo, toastMessage: $toastMessage, toastOption: $toastOption, recentlyDoneTodo: $recentlyDoneTodo)
                        //tap gesture로 선택되었을 시 라인으로 표시됨
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(selectedTodos.contains(todo.id) ? Color("green/green-500") : Color.clear, lineWidth: 4)
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
            }
        }
        .ignoresSafeArea(.keyboard)
        .padding(.bottom, 24)
        .padding(.horizontal)
    }
}

private struct GuideLineView: View {
    var viewType: TodoGridViewType
    var todos: [Todo]
    var navigationBarTitle: String
    var folder: Folder?
    
    var body: some View {
        VStack{
            CustomTitle(todos: todos, viewType: viewType, navigationBarTitle: navigationBarTitle, folder: folder)
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
    var viewType: TodoGridViewType
    var navigationBarTitle: String?
    var folder: Folder?
    
    var body: some View {
        VStack{
            if viewType == .main {
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
            } else {
                HStack{
                    Label {
                        Text(navigationBarTitle ?? "")
                    } icon: {
                        Image(systemName: "folder.fill")
                            .foregroundColor(Color.folderColor(forName: FolderColorName(rawValue: folder?.color ?? "green") ?? .green))
                    }
                    .font(.largeTitle)
                    .bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 20)
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
