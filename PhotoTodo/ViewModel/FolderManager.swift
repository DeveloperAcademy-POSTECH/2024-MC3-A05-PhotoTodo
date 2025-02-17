//
//  FolderManager.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 2/17/25.
//

import SwiftData
import SwiftUI

/// 폴더의 삭제와, 순서 조정 등에 관한 함수를 모은 매니저
struct FolderManager {
    func deleteFolder(_ folder: Folder?, _ folderOrders: [FolderOrder], _ modelContext: ModelContext) {
        guard let folder = folder else { return }
        if let folderOrder = folderOrders.first {
            modelContext.delete(folder)
            folderOrder.uuidOrder.removeAll { $0 == folder.id }
            try? modelContext.save()
        }
    }

    func getOrderedFolder(_ folders: [Folder], _ folderOrders: [FolderOrder]) -> [Folder] {
        let uuidLookup = Dictionary(grouping: folders, by: { $0.id })
        return folderOrders.first?.uuidOrder.compactMap({ uuidLookup[$0]?.first }) ?? []
    }
    
    func setFolderOrder(_ folders: [Folder], _ folderOrders: [FolderOrder], _ modelContext: ModelContext) {
        if folderOrders.count == 0 {
            let folderOrder = FolderOrder()
            modelContext.insert(folderOrder)
            try? modelContext.save()
        }
        
        guard let folderOrder = folderOrders.first else {
            return
        }
        
        DispatchQueue.global().async(){
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
            try? modelContext.save()
        }
    }
}
