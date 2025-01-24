

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
    
    
    private var basicViewType: TodoGridViewType = .singleFolder
    private var doneListViewType: TodoGridViewType = .doneList
    @AppStorage("defaultFolderID") private var defaultFolderID: String?
    
    
    
    var body: some View {
            List {
                //기본 폴더(인덱스 0에 있음) → 삭제 불가능하게 만들기 위해 따로 뺌
                NavigationLink{
                    TodoGridView(currentFolder: folders.count > 0 ? folders.first(where: {$0.id.uuidString == defaultFolderID}) : nil, viewType: basicViewType)
                } label : {
                    FolderRow(folder: folders.count > 0 ? folders.first(where: {$0.id.uuidString == defaultFolderID}) : nil, viewType: basicViewType)
                }

                
                //기본 폴더를 제외하고는 모두 삭제 가능
                ForEach(folders.filter({$0.id.uuidString != defaultFolderID})) { folder in
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
                        .listRowInsets(EdgeInsets(top: -5, leading: 0, bottom: -5, trailing: 0))
                }
                .onDelete { _ in
                    // editMode일 때 UI가 반응하도록 하기 위해 빈 클로저를 남겼습니다.
                    // 실제 삭제 실행시에는 swipeActions으로 넘겨받은 클로저가 호출됩니다.
                }
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
                if defaultFolderID != nil {
                    return
                }
                defaultFolderID = folders.first(where: {$0.name == "기본"})?.id.uuidString
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
                            deleteFolder()
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
    
    private func deleteFolder(){
        guard let folder = selectedFolder else {return}
        modelContext.delete(folder)
    }
    
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
        }
    }
}


private struct FolderRow: View {
    @State var folder: Folder?
    @State var viewType: TodoGridViewType
    @Query private var todos: [Todo]
    
    var body: some View{
        HStack{
            Image(systemName: "folder.fill")
                .foregroundStyle(viewType == .singleFolder ? changeStringToColor(colorName: folder != nil ? folder!.color : "folder-color/green" ) : Color("gray/gray-800"))
            Text(folder != nil ? folder!.name : viewType == .singleFolder ? "" : "완료함")
            Spacer()
            Text (folder != nil ? "\(folder!.todos.count)장" : viewType == .singleFolder ? "" : "\(todos.filter { $0.isDone }.count)장")
                .foregroundColor(Color("gray/gray-500"))
        }
    }
}
    

#Preview {
    FolderListView()
        .modelContainer(for: Folder.self, inMemory: true)
}

