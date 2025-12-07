//
//  PhotoTodoMigrationPlan.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 12/7/25.
//

import SwiftData
import SwiftUI

enum PhotoTodoMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [PhotoTodoSchemaV1.self, PhotoTodoSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    static var rawImageBackup: [UUID: [Data]] = [:]
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: PhotoTodoSchemaV1.self,
        toVersion: PhotoTodoSchemaV2.self,
        willMigrate: { context in
            let todos = try? context.fetch(FetchDescriptor<PhotoTodoSchemaV1.Todo>())
            todos?.forEach { todo in
                rawImageBackup[todo.id] = todo.images
            }
            try? context.save()
        },
        didMigrate: { context in
            let todos = try? context.fetch(FetchDescriptor<PhotoTodoSchemaV2.Todo>())
            todos?.forEach { todo in
                if let imageData = rawImageBackup[todo.id] {
                    todo.images = imageData.map { image in
                        PhotoTodoSchemaV2.Photo(image: image)
                    }
                }
            }
            try? context.save()
            rawImageBackup.removeAll()
        }
    )
}
