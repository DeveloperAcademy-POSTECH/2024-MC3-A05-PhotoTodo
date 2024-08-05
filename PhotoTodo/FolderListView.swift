

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
    @AppStorage("hasBeenLaunched") private var hasBeenLaunched = false
    private var basicViewType: TodoGridViewType = .singleFolder
    private var doneListViewType: TodoGridViewType = .doneList
    
    var body: some View {
        NavigationStack{
            List {
                //기본 폴더(인덱스 0에 있음) → 삭제 불가능하게 만들기 위해 따로 뺌
                NavigationLink{
                    TodoGridView(currentFolder: folders.count > 0 ? folders[0] : nil, viewType: basicViewType)
                } label : {
                    Text(folders.count > 0 ? folders[0].name : "")
                }
                
                //기본 폴더를 제외하고는 모두 삭제 가능
                ForEach(folders.indices.dropFirst(), id: \.self) { index in
                    NavigationLink {
                        TodoGridView(currentFolder: folders[index], viewType: basicViewType)
                    } label: {
                        Text(folders[index].name)
                    }
                }
                .onDelete{ indexSet in
                    // Adjust the indices for the deletion process
                    let adjustedIndices = indexSet.map { $0 + 1 }
                    let adjustedIndexSet = IndexSet(adjustedIndices)
                    deleteItems(offsets: indexSet)
                }
                //TODO: 옵션을 줘서 완료된 것(되지 않은 것)만 필터링해서 보여주기
                //리스트 뷰의 마지막에는 완료함이 위치함
                NavigationLink {
                    TodoCompositeGridView(viewType: doneListViewType)
                } label : {
                    Text("완료함")
                }
            }
            .navigationBarTitle("폴더")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addFolders) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .onAppear {
            //MARK: 최초 1회 실행된 적이 있을 시
            if hasBeenLaunched {
                return
            }

            //MARK: 최초 1회 실행된 적 없을 시 세팅 작업 실행
            let defaultFolder = Folder(
                id: UUID(),
                name: "기본",
                color: "green",
                todos: []
            )
            modelContext.insert(defaultFolder)
            hasBeenLaunched = true
        }
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

#Preview {
    FolderListView()
        .modelContainer(for: Folder.self, inMemory: true)
}

