import Foundation
import UIKit
import SwiftData

@Model
class Folder: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, todos
    }
    
    let id: UUID
    var name: String
    var todos: [Todo]
    
    init(id: UUID, name: String, todos: [Todo]) {
        self.id = id
        self.name = name
        self.todos = todos
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        todos = try container.decode([Todo].self, forKey: .todos)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(todos, forKey: .todos)
    }
}

@Model
class Todo: Codable {
    enum CodingKeys: String, CodingKey {
        case id, image, createdAt, options
    }

    let id: UUID
    @Attribute(.externalStorage) var image: Data
    var createdAt: Date
    var options: Options

    init(id: UUID, image: Data, createdAt: Date, options: Options) {
        self.id = id
        self.image = image
        self.createdAt = createdAt
        self.options = options
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        image = try container.decode(Data.self, forKey: .image)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        options = try container.decode(Options.self, forKey: .options)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(image, forKey: .image)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(options, forKey: .options)
    }
}

@Model
class Options: Codable {
    enum CodingKeys: String, CodingKey {
        case alarm, memo
    }

    var alarm: Date?
    var memo: String?

    init(alarm: Date? = nil, memo: String? = nil) {
        self.alarm = alarm
        self.memo = memo
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alarm = try container.decodeIfPresent(Date.self, forKey: .alarm)
        memo = try container.decodeIfPresent(String.self, forKey: .memo)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(alarm, forKey: .alarm)
        try container.encodeIfPresent(memo, forKey: .memo)
    }
}
