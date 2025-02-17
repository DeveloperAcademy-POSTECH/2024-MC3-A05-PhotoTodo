

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
    @State private var isShowingSheet = false
    @State private var folderNameInput = ""
    @State private var selectedColor: Color?
    
    @Query private var folderOrders: [FolderOrder]
    
    private var basicViewType: TodoGridViewType = .singleFolder
    private var doneListViewType: TodoGridViewType = .doneList
    @AppStorage("defaultFolderID") private var defaultFolderID: String?
    
    var folderManager = FolderManager()
    
    // 유저가 설정한 순서대로 폴더를 정렬해 보여줌
    var orderedFolder: [Folder] {
        return folderManager.getOrderedFolder(folders, folderOrders)
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
                if editMode == .inactive {
                    FolderRowView(actions: [ // Swipe Action의 동작을 커스텀한 뷰
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
                        .listRowInsets(EdgeInsets(top: -7.5, leading: 0, bottom: -7.5, trailing: 0))
                } else {
                    FolderRow(folder: folder, viewType: basicViewType)
                }
            }
            .onMove(perform: handleMove)
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
            folderManager.setFolderOrder(folders, folderOrders, modelContext)
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
            FolderEditView(isSheetPresented: $isShowingSheet, folderNameInput: $folderNameInput, selectedColor: $selectedColor, selectedFolder: $selectedFolder)
                .presentationDetents([.medium, .large])
        })
        .environment(\.editMode, $editMode)
    }
}


extension FolderListView {
    private func toggleShowingSheet(){
        isShowingSheet.toggle()
    }
    
    private func deleteFolder(_ folder: Folder?) {
        folderManager.deleteFolder(folder, folderOrders, modelContext)
    }

    
    
    func handleMove(indices: IndexSet, newOffset: Int) {
        if let defaultID = defaultFolderID, var newOrder = folderOrders.first?.uuidOrder.filter({$0 != UUID(uuidString: defaultID)}) {
            newOrder.move(fromOffsets: indices, toOffset: newOffset)
            folderOrders.first?.uuidOrder = [UUID(uuidString: defaultID)!] + newOrder
            try? modelContext.save()
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
    
    //폴더 생성 및 편집 관련 sheet에서 쓰임
    @State private var isShowingSheet = false
    @State private var folderNameInput = ""
    @State private var selectedColor: Color?
    
    var folderManager = FolderManager()
    
    var folderString: String {
        return folder != nil ? folder!.name : viewType == .singleFolder ? "" : "완료함"
    }
    
    var folderCountString: String {
        return folder != nil ? "\(incompleteTodosCount)장" : viewType == .singleFolder ? "" : "\(doneCount)장"
    }
    
    @AppStorage("defaultFolderID") private var defaultFolderID: String?
    @State private var showingAlert = false
    @Query var folderOrders: [FolderOrder]

    
    var body: some View {
        HStack{
            Image(systemName: "folder.fill")
                .foregroundStyle(viewType == .singleFolder ? changeStringToColor(colorName: folder != nil ? folder!.color : "folder-color/green" ) : Color("gray/gray-800"))
            Text(folderString)
            Spacer()
            HStack {
                Text(folderCountString)
                    .foregroundColor(Color("gray/gray-500"))

                folderRowMenu
            }

        }
        .onAppear {
            DispatchQueue.global().async() {
                // 뷰가 업데이트될 때마다 다시 계산하는 대신, 값을 미리 계산하여 사용
                if folder == nil && viewType != .singleFolder {
                    doneCount = todos.filter { $0.isDone }.count
                }
                if folder != nil && viewType == .singleFolder {
                    incompleteTodosCount = folder!.todos.filter { !$0.isDone }.count
                }
            }
        }
        .sheet(isPresented: $isShowingSheet, content: {
            FolderEditView(isSheetPresented: $isShowingSheet, folderNameInput: $folderNameInput, selectedColor: $selectedColor, selectedFolder: $folder)
                .presentationDetents([.medium, .large])
        })

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
        folderManager.deleteFolder(folder, folderOrders, modelContext)
    }
}

/// 메뉴와 관련된 코드 모음
extension FolderRow {
    var isShowingMemu: Bool {
        return editMode?.wrappedValue == .active && viewType == .singleFolder && folder?.id != UUID(uuidString: defaultFolderID ?? UUID().uuidString)
    }
    
    var folderRowMenu: some View {
        Menu {
            Button {
                onEditFolderButtonTapped()
            } label : {
                HStack{
                    Text("폴더 정보 수정")
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
                .font(.title2)
                .foregroundStyle(Color("green/green-600"))
        }
        .frame(width: isShowingMemu ? nil : 0, alignment: .trailing)
        .opacity(isShowingMemu ? 1 : 0) // 편집 모드가 아닐 때 숨기기
        .disabled(!isShowingMemu) // 인터렉션을 막기
    }
    
    func onEditFolderButtonTapped() {
        isShowingSheet.toggle()
        folderNameInput = folder?.name ?? ""
        selectedColor = Color.folderColor(forName: FolderColorName(rawValue: (folder?.color)!) ?? .green)
    }
}



#Preview {
    FolderListView()
        .modelContainer(for: Folder.self, inMemory: true)
}

