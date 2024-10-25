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

    var body: some View {
        Button("폴더 편집") {
            isModalVisible = true
        }
        .sheet(isPresented: $isModalVisible) {
            FolderEditView(isSheetPresented: $isModalVisible, folderNameInput: $folderName, selectedColor: $folderColor)
        }
    }
}

struct FolderEditPreview_Previews: PreviewProvider {
    static var previews: some View {
        FolderEditPreview()
    }
}
