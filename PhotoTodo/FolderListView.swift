

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
    @Query private var folders: [Folder]
    @State var isShowingSheet = false
    @State var folderNameInput = ""
    @State var selectedColor: Color?
    private var basicViewType: TodoGridViewType = .singleFolder
    private var doneListViewType: TodoGridViewType = .doneList
    
    
    
    var body: some View {
        NavigationStack{
            List {
                //기본 폴더(인덱스 0에 있음) → 삭제 불가능하게 만들기 위해 따로 뺌
                NavigationLink{
                    TodoGridView(currentFolder: folders.count > 0 ? folders[0] : nil, viewType: basicViewType)
                } label : {
                    FolderRow(folder: folders.count > 0 ? folders[0] : nil, viewType: basicViewType)
                }
                
                //기본 폴더를 제외하고는 모두 삭제 가능
                ForEach(folders.indices.dropFirst(), id: \.self) { index in
                    NavigationLink {
                        TodoGridView(currentFolder: folders[index], viewType: basicViewType)
                    } label: {
                        FolderRow(folder: folders[index], viewType: basicViewType)
                    }
                }
                .onDelete{ indexSet in
                    // Adjust the indices for the deletion process
                    let adjustedIndices = indexSet.map { $0 + 1 }
                    let adjustedIndexSet = IndexSet(adjustedIndices)
                    deleteItems(offsets: adjustedIndexSet)
                }
                //TODO: 옵션을 줘서 완료된 것(되지 않은 것)만 필터링해서 보여주기
                //리스트 뷰의 마지막에는 완료함이 위치함
                NavigationLink {
                    DoneListView()
                } label : {
                    FolderRow(folder: nil, viewType: doneListViewType)
                }
            }
            .navigationBarTitle("폴더")
            .toolbar {
                ToolbarItem {
                    Button(action: toggleShowingSheet) {
                        Label("add a folder", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $isShowingSheet, content: {
                FolderEditView(isSheetPresented: $isShowingSheet, folderNameInput: $folderNameInput, selectedColor: $selectedColor)
                    .presentationDetents([.medium, .large])
            })
            
        }
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
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(folders[index])
            }
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

