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
        guard let order = folderOrders.first?.uuidOrder else { return folders }
        let folderDict = Dictionary(uniqueKeysWithValues: folders.map { ($0.id, $0) })
        return order.compactMap { folderDict[$0] }
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
    
    func saveFolder(_ folderOrders: [FolderOrder], _ folderNameInput: String, _ selectedFolder: Folder?, _ selectedColor: Color?, _ modelContext: ModelContext){
        if folderNameInput == "" {
            return
        }
        
        if selectedFolder == nil { //현재 바인딩된 폴더가 없음 -> 새로 생성
            withAnimation {
                let newFolder = Folder(
                    id: UUID(),
                    name: folderNameInput,
                    color: selectedColor != nil ? colorDictionary[selectedColor!, default: "green"] : "green",
                    todos: []
                )
                modelContext.insert(newFolder)
                folderOrders.first?.uuidOrder.append(newFolder.id)
            }
        } else { // 바인딩된 폴더가 존재 -> 폴더 수정
            selectedFolder?.name = folderNameInput
            selectedFolder?.color = selectedColor != nil ? colorDictionary[selectedColor!, default: "green"] : "green"
        }
        try? modelContext.save()
    }
    
    func setDefaultFolder(_ modelContext: ModelContext,_  folderOrders: [FolderOrder], _ folders: [Folder]) {
           let defaults = UserDefaults(suiteName: "group.PhotoTodo-com.2024-MC3-A05-team5.PhotoTodo")
           if defaults?.bool(forKey: "hasBeenLaunched") == false {
               if folderOrders.count == 0 {
                   let folderOrder = FolderOrder()
                   modelContext.insert(folderOrder)
               }
               
               let defaultFolder = Folder(
                   id: UUID(),
                   name: "기본",
                   color: "green",
                   todos: []
               )
               
               modelContext.insert(defaultFolder)
               setFolderOrder(folders, folderOrders, modelContext)
               defaults?.set(true, forKey: "hasBeenLaunched")
                try? modelContext.save()
           } else {
               print("UserDefaults key가 이미 있음")
           }
       }
}

let colorDictionary: [Color: String] = [
    Color("folder_color/red"): "red",
    Color("folder_color/sky"): "sky",
    Color("folder_color/yellow"): "yellow",
    Color("folder_color/green"): "green",
    Color("folder_color/blue"): "blue",
    Color("folder_color/purple"): "purple"
]
