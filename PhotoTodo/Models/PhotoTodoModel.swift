//
//  PhotoTodoModel.swift
//  PhotoTodo
//
//  Created by leejina on 7/29/24.
//
 
import Foundation
import UIKit
 
class Folder {
    let id : UUID
    var name : String = ""
    var todos : [Todo] = []
    
    init(id: UUID, name: String, todos: [Todo]) {
        self.id = id
        self.name = name
        self.todos = todos
    }
}
 
class Todo {
    let id : UUID
    var image : UIImage
    var createdAt : Date
    var options: Options
    
    init(id: UUID, image: UIImage, createdAt: Date, options: Options) {
        self.id = id
        self.image = image
        self.createdAt = createdAt
        self.options = options
    }
}
 
class Options {
    var alarm : Date?
    var memo : String?
    
    init(alarm: Date? = nil, memo: String? = nil) {
        self.alarm = alarm
        self.memo = memo
    }
}
