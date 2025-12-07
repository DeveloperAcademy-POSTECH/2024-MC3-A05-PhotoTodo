//
//  PhotoTodoMigrationPlan.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 12/7/25.
//

import SwiftData

enum PhotoTodoMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [PhotoTodoSchemaV1.self, PhotoTodoSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: PhotoTodoSchemaV1.self,
        toVersion: PhotoTodoSchemaV2.self,
        willMigrate: { context in
            print("migrate!")
        }, didMigrate: nil
    )
}
