

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
    @Query private var folderOrders: [FolderOrder]
    @State var isShowingSheet = false
    @State var folderNameInput = ""
    @State var selectedColor: Color?
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
                    ZStack{ //editMode에서 chevron을 숨기고, FolderRow의 Text의 투명도를 그대로 유지하기 위해서 ZStack을 활용했습니다.
                        NavigationLink {
                            TodoGridView(currentFolder: folder, viewType: basicViewType)
                        } label: {
                            EmptyView()
                        }
                        .opacity(editMode == .active ? 0 : 1)
                        .swipeActions(content: {
                            Button("Delete", systemImage: "trash", role:  .destructive) {
                                deleteFolder(folder)
                            }
                        })
                        FolderRow(folder: folder, viewType: basicViewType)
                    }
                }
                .onMove(perform: handleMove)
//                .onDelete { _ in
//                    // editMode일 때 UI가 반응하도록 하기 위해 빈 클로저를 남겼습니다.
//                    // 실제 삭제 실행시에는 swipeActions으로 넘겨받은 클로저가 호출됩니다.
//                }
                //TODO: 옵션을 줘서 완료된 것(되지 않은 것)만 필터링해서 보여주기
                //리스트 뷰의 마지막에는 완료함이 위치함
                NavigationLink {
                    DoneListView()
                } label : {
                    FolderRow(folder: nil, viewType: doneListViewType)
                }
            }
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
    
    private func deleteFolder(_ folder: Folder) {
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
    @AppStorage("defaultFolderID") private var defaultFolderID: String?
    @State private var showingAlert = false
    @Query var folderOrders: [FolderOrder]
    
    var isShowingMemu: Bool {
        return editMode?.wrappedValue == .active && viewType == .singleFolder && folder?.id != UUID(uuidString: defaultFolderID ?? UUID().uuidString)
    }
    
    
    
    var body: some View {
        HStack{
            Image(systemName: "folder.fill")
                .foregroundStyle(viewType == .singleFolder ? changeStringToColor(colorName: folder != nil ? folder!.color : "folder-color/green" ) : Color("gray/gray-800"))
            Text(folder != nil ? folder!.name : viewType == .singleFolder ? "" : "완료함")
            Spacer()
            Menu {
                Button {
                    print("Rename tapped")
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
                    .foregroundStyle(Color(.accent))
            }
            .opacity(isShowingMemu ? 1 : 0) // 편집 모드가 아닐 때 숨기기
            .disabled(!isShowingMemu) // 인터렉션을 막기
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
}
                          


#Preview {
    FolderListView()
        .modelContainer(for: Folder.self, inMemory: true)
}

