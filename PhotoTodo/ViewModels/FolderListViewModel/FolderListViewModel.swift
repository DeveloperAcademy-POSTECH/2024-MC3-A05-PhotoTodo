//
//  TodoGridViewModel.swift
//  PhotoTodo
//
//  Created by leejina on 1/6/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class FolderListViewModel {
    func deleteItems(offsets: IndexSet, modelContext: ModelContext, folders: [Folder]) {
        withAnimation {
            for index in offsets {
                modelContext.delete(folders[index+1])
            }
        }
    }

}
