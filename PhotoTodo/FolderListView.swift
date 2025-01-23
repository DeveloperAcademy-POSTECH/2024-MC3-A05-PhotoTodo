

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
                    NavigationLink {
                        TodoGridView(currentFolder: folder, viewType: basicViewType)
                    } label: {
                        FolderRow(folder: folder, viewType: basicViewType)
                    }
                    .swipeActions(
                        allowsFullSwipe: true,
                        content: {
                            Button("Delete", systemImage: "trash") {
                                showingAlert = true
                                selectedFolder = folder
                            }
                            .tint(.red)
                        })
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
                    title: Text("'\(selectedFolder?.name ?? "")'폴더를 삭제하시겠습니까?"),
                    message: Text("이 폴더의 모든 사진이 삭제됩니다."),
                    primaryButton: .default(
                        Text("취소")
                    ),
                    secondaryButton: .destructive(
                        Text("Delete"),
                        action: deleteFolder
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
    
    var body: some View{
        HStack{
            Image(systemName: "folder.fill")
                .foregroundStyle(viewType == .singleFolder ? changeStringToColor(colorName: folder != nil ? folder!.color : "folder-color/green" ) : Color("gray/gray-800"))
            Text(folder != nil ? folder!.name : viewType == .singleFolder ? "" : "완료함")
            Spacer()
        }
    }
}


#Preview {
    FolderListView()
        .modelContainer(for: Folder.self, inMemory: true)
}

