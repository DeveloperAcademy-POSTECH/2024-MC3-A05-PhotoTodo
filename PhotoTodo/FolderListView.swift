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
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(folders) { folder in
                    NavigationLink {
                        //TODO: TodoList View로 이동하기
                        TodoListView(folder: folder)
                    } label: {
                        Text(folder.name)
                    }
                }
                .onDelete(perform: deleteItems)
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
        
    }
    
    private func addFolders() {
        withAnimation {
            let newFolder = Folder(
                id: UUID(),
                name: "새 폴더",
                todos: [
                    Todo(
                        id: UUID(),
                        image: UIImage(contentsOfFile: "filledCoffee")?.pngData() ?? Data(),
                        createdAt: Date(),
                        options: Options(
                            alarm : nil,
                            memo : nil
                        )
                    )
                ]
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
