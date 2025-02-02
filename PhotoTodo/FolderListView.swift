

//
//  FolderListView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI
import SwiftData

enum TodoGridViewType {
    case singleFolder
    case main
    case doneList
}

struct FolderListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var editMode: EditMode = .inactive
    @Query private var folders: [Folder]
    
    //폴더 삭제시
    @State private var showingAlert = false
    @State private var selectedFolder: Folder? = nil
    @State private var pendingCompletion: (() -> Void)?
    
    //폴더 생성 및 편집 관련 sheet에서 쓰임
    @State var isShowingSheet = false
    @State var folderNameInput = ""
    @State var selectedColor: Color?
    
    @Query private var folderOrders: [FolderOrder]
    
    private var basicViewType: TodoGridViewType = .singleFolder
    private var doneListViewType: TodoGridViewType = .doneList
    @AppStorage("defaultFolderID") private var defaultFolderID: String?
    
    
    // 유저가 설정한 순서대로 폴더를 정렬해 보여줌
    var orderedFolder: [Folder] {
        let uuidLookup = Dictionary(grouping: folders, by: { $0.id })
        return folderOrders.first?.uuidOrder.compactMap({ uuidLookup[$0]?.first }) ?? []
    }
    
    
    var body: some View {
        List {
            //기본 폴더(인덱스 0에 있음) → 삭제 불가능하게 만들기 위해 따로 뺌
            NavigationLink{
                TodoGridView(currentFolder: folders.count > 0 ? folders.first(where: {$0.id.uuidString == defaultFolderID}) : nil, viewType: basicViewType)
            } label : {
                FolderRow(folder: folders.count > 0 ? folders.first(where: {$0.id.uuidString == defaultFolderID}) : nil, viewType: basicViewType)
            }
            
            
            //기본 폴더를 제외하고는 모두 삭제 가능
            ForEach(orderedFolder.filter({$0.id.uuidString != defaultFolderID})) { folder in
                ZStack{
                    FolderRowView(actions: [
                        Action(color: .red, name: "delete", systemIcon: "trash.fill", action: { completion in
                            selectedFolder = folder
                            pendingCompletion = completion
                            showingAlert = true
                        })]) {
                            NavigationLink {
                                TodoGridView(currentFolder: folder, viewType: basicViewType)
                            } label: {
                                FolderRow(folder: folder, viewType: basicViewType)
                            }
                        }
                        .opacity( editMode == .active ? 0 : 1)
                        .disabled(editMode == .active)
                    FolderRow(folder: folder, viewType: basicViewType)
                        .padding(.leading, 16)
                        .opacity( editMode == .active ? 1 : 0)
                        
                }
                .listRowInsets(EdgeInsets(top: -5, leading: 0, bottom: -5, trailing: 0))

            }
            .onMove(perform: handleMove)
            // .onDelete { _ in
            //     // editMode일 때 UI가 반응하도록 하기 위해 빈 클로저를 남겼습니다.
            //     // 실제 삭제 실행시에는 swipeActions으로 넘겨받은 클로저가 호출됩니다.
            // }
            //TODO: 옵션을 줘서 완료된 것(되지 않은 것)만 필터링해서 보여주기
            //리스트 뷰의 마지막에는 완료함이 위치함
            NavigationLink {
                DoneListView()
            } label : {
                FolderRow(folder: nil, viewType: doneListViewType)
            }
        }
        .animation(.default, value: folders) //폴더의 변화가 자연스럽게 반영되도록 설정
        .onAppear {
            // 기본폴더 세팅 로직
            if defaultFolderID == nil {
                defaultFolderID = folders.first(where: {$0.name == "기본"})?.id.uuidString
            }
            
            //folderOrder 세팅 로직
            setFolderOrders()
        }
        
        .scrollContentBackground(.hidden)
        //            .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("폴더")
        .toolbar {
            ToolbarItem {
                if editMode == .inactive {
                    Button(action: toggleShowingSheet) {
                        Label("add a folder", systemImage: "plus")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .frame(width: 38)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("'\(selectedFolder?.name ?? "")' 폴더를 삭제하시겠습니까?"),
                message: Text("이 폴더의 모든 사진이 삭제됩니다."),
                primaryButton: .default(
                    Text("취소"),
                    action: {
                        pendingCompletion?()
                        pendingCompletion = nil
                    }
                ),
                secondaryButton: .destructive(
                    Text("삭제"),
                    action: {
                        deleteFolder(selectedFolder)
                        pendingCompletion?()
                        pendingCompletion = nil
                    }
                ))
        }
        .sheet(isPresented: $isShowingSheet, content: {
            FolderEditView(isSheetPresented: $isShowingSheet, folderNameInput: $folderNameInput, selectedColor: $selectedColor)
                .presentationDetents([.medium, .large])
        })
        .environment(\.editMode, $editMode)
    }
}


extension FolderListView {
    private func toggleShowingSheet(){
        isShowingSheet.toggle()
    }
    
    private func addFolders() {
        withAnimation {
            let newFolder = Folder(
                id: UUID(),
                name: "새 폴더",
                color: "green",
                todos: []
            )
            modelContext.insert(newFolder)
            folderOrders.first?.uuidOrder.append(newFolder.id)
        }
    }
    
    private func deleteFolder(_ folder: Folder?) {
        guard let folder = folder else { return }
        if let folderOrder = folderOrders.first {
            modelContext.delete(folder)
            folderOrders.first?.uuidOrder.removeAll { $0 == folder.id }
        }
    }
    
    private func setFolderOrders() {
        if folderOrders.count == 0 {
            let folderOrder = FolderOrder()
            modelContext.insert(folderOrder)
        }
        
        guard let folderOrder = folderOrders.first else {
            return
        }
        
        if folderOrder.uuidOrder.count < folders.count {
            for folder in folders {
                if !folderOrder.uuidOrder.contains(folder.id) {
                    folderOrders.first?.uuidOrder.append(folder.id)
                }
            }
        }
        
        if folderOrder.uuidOrder.count > folders.count {
            folderOrders.first?.uuidOrder = folders.map {$0.id}
        }
    }
    
    
    func handleMove(indices: IndexSet, newOffset: Int) {
        if let defaultID = defaultFolderID, var newOrder = folderOrders.first?.uuidOrder.filter({$0 != UUID(uuidString: defaultID)}) {
            newOrder.move(fromOffsets: indices, toOffset: newOffset)
            folderOrders.first?.uuidOrder = [UUID(uuidString: defaultID)!] + newOrder
        }
    }
}


private struct FolderRow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) private var editMode
    @State var folder: Folder?
    @State var viewType: TodoGridViewType
    @Query private var todos: [Todo]
    @State private var doneCount: Int = 0 // 뷰가 업데이트될 때마다 다시 계산하는 대신, 값을 미리 계산하여 사용
    @State private var incompleteTodosCount: Int = 0
    
    var folderString: String {
        return folder != nil ? folder!.name : viewType == .singleFolder ? "" : "완료함"
    }
    
    var folderCountString: String {
        return folder != nil ? "\(incompleteTodosCount)장" : viewType == .singleFolder ? "" : "\(doneCount)장"
    }
    
    @AppStorage("defaultFolderID") private var defaultFolderID: String?
    @State private var showingAlert = false
    @Query var folderOrders: [FolderOrder]
    @State private var isRenamingFolder: Bool = false
    @State private var newFolderName: String = ""
    
    var body: some View {
        HStack{
            Image(systemName: "folder.fill")
                .foregroundStyle(viewType == .singleFolder ? changeStringToColor(colorName: folder != nil ? folder!.color : "folder-color/green" ) : Color("gray/gray-800"))
            Text(folderString)
            Spacer()
            ZStack{
                Text(folderCountString)
                    .foregroundColor(Color("gray/gray-500"))
                    .opacity(editMode?.wrappedValue == .active ? 0 : 1)
                menu
            }

        }
        .onAppear {
            // 뷰가 업데이트될 때마다 다시 계산하는 대신, 값을 미리 계산하여 사용
            if folder == nil && viewType != .singleFolder {
                doneCount = todos.filter { $0.isDone }.count
            }
            if folder != nil && viewType == .singleFolder {
                incompleteTodosCount = folder!.todos.filter { !$0.isDone }.count
            }
        }
        .alert("폴더 이름 변경", isPresented: $isRenamingFolder) {
            TextField("\(newFolderName)", text: $newFolderName)
            Button{
                changeFolderName()
            } label : {
                Text("저장")
            }
            .disabled(newFolderName.isEmpty)
            Button("취소", role: .cancel) { }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("'\(folder?.name ?? "")'폴더를 삭제하시겠습니까?"),
                message: Text("이 폴더의 모든 사진이 삭제됩니다."),
                primaryButton: .default(
                    Text("취소")
                ),
                secondaryButton: .destructive(
                    Text("삭제"),
                    action: deleteFolder
                ))
        }
    }
    
    private func deleteFolder(){
        guard let folder = folder else {return}
        if folderOrders.first != nil {
            modelContext.delete(folder)
            folderOrders.first?.uuidOrder.removeAll { $0 == folder.id }
        }
    }
    
    private func changeFolderName(){
        guard let folder = folder else {return}
        folder.name = newFolderName
        newFolderName = ""
    }
}

/// 메뉴와 관련된 코드 모음
extension FolderRow {
    var isShowingMemu: Bool {
        return editMode?.wrappedValue == .active && viewType == .singleFolder && folder?.id != UUID(uuidString: defaultFolderID ?? UUID().uuidString)
    }
    
    var menu: some View {
        Menu {
            Button {
                isRenamingFolder.toggle()
                newFolderName = folder?.name ?? ""
            } label : {
                HStack{
                    Text("폴더 이름 수정")
                    Spacer()
                    Image(systemName: "pencil")
                }
                
            }
            Button(role: .destructive) {
                showingAlert.toggle()
            } label : {
                HStack{
                    Text("폴더 삭제")
                    Spacer()
                    Image(systemName: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(Color("green/green-600"))
        }
        .opacity(isShowingMemu ? 1 : 0) // 편집 모드가 아닐 때 숨기기
        .disabled(!isShowingMemu) // 인터렉션을 막기
    }
}



#Preview {
    FolderListView()
        .modelContainer(for: Folder.self, inMemory: true)
}

