//
//  FolderListView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI
import SwiftData

struct FolderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [Folder]
    @AppStorage("hasBeenLaunched") private var hasBeenLaunched = false
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(folders) { folder in
                    NavigationLink {
                        //TODO: TodoList View로 이동하기
                        TodoGridView(folder: folder)
                    } label: {
                        Text(folder.name)
                    }
                }
                .onDelete(perform: deleteItems)
                //TODO: 옵션을 줘서 완료된 것(되지 않은 것)만 필터링해서 보여주기
                NavigationLink {
                    TodoCompositeGridView(folders: folders)
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
