//
//  PhotoTodoSchemaV2.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 12/7/25.
//
import Foundation
import SwiftData
import SwiftUI

enum PhotoTodoSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0)}
    static var models: [any PersistentModel.Type] {
        [Folder.self, Todo.self, Photo.self, Options.self, FolderOrder.self]
    }
    
    @Model
    final class Folder {
        @Attribute(.unique) var id : UUID
        var name: String
        var color: String
        @Relationship(deleteRule:.cascade, inverse: \Todo.folder) var todos: [Todo]
        init(id: UUID, name: String, color: String, todos: [Todo]) {
            self.id = id
            self.name = name
            self.color = color
            self.todos = todos
        }
    }


    @Model
    final class Todo {
        var folder: Folder?
        @Attribute(.unique) var id: UUID
        @Attribute var images: [Photo]
        var createdAt: Date
        @Relationship(inverse: \Options.todo) var options: Options
        var isDone: Bool
        var isDoneAt: Date?
        
        init(folder: Folder? = nil, id: UUID, images: [Photo], createdAt: Date, options: Options, isDone: Bool, isDoneAt: Date? = nil) {
            self.folder = folder
            self.id = id
            self.images = images
            self.createdAt = createdAt
            self.options = options
            self.isDone = isDone
            self.isDoneAt = isDoneAt
        }
    }
    
    @Model
    final class Photo {
        @Attribute(.externalStorage) var image: Data
        init(image: Data) {
            self.image = image
        }
    }

    @Model
    final class Options {
        var todo: Todo?
        var alarm: Date?
        var alarmUUID: String?
        var memo: String?
        var tags: [String]?

        init(todo: Todo? = nil, alarm: Date? = nil, alarmUUID: String? = nil, memo: String? = nil, tags: [String]? = nil) {
            self.todo = todo
            self.alarm = alarm
            self.alarmUUID = alarmUUID
            self.memo = memo
            self.tags = tags
        }
    }

    @Model
    final class FolderOrder {
        var uuidOrder: [UUID] // 폴더를 UUID별로 보여줄 배열

        init() {
            uuidOrder = []
        }
    }
}

typealias Folder = PhotoTodoSchemaV2.Folder
typealias Todo = PhotoTodoSchemaV2.Todo
typealias Photo = PhotoTodoSchemaV2.Photo
typealias Options = PhotoTodoSchemaV2.Options
typealias FolderOrder = PhotoTodoSchemaV2.FolderOrder
