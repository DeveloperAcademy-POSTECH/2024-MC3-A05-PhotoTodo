//
//  pre.swift
//  PhotoTodo
//
//  Created by JiaeShin on 8/5/24.
//

import SwiftUI

struct FolderEditPreview: View {
    @State private var isModalVisible = false
    @State private var folderName = ""
    @State private var folderColor: Color? = nil
    @State private var selectedFolder: Folder? = {
        let mockTodos = [
            Todo(
                id: UUID(),
                images: [Photo(image: UIImage(systemName: "photo")?.pngData() ?? Data())],
                createdAt: Date(),
                options: Options(memo: "샘플 작업"),
                isDone: false
            )
        ]
        return Folder(id: UUID(), name: "샘플 폴더", color: "blue", todos: mockTodos)
    }()

    var body: some View {
        Button("폴더 편집") {
            isModalVisible = true
        }
        .sheet(isPresented: $isModalVisible) {
            FolderEditView(isSheetPresented: $isModalVisible, folderNameInput: $folderName, selectedColor: $folderColor, selectedFolder: $selectedFolder)
        }
    }
}

struct FolderEditPreview_Previews: PreviewProvider {
    static var previews: some View {
        FolderEditPreview()
    }
}
