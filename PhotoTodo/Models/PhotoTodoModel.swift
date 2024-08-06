import Foundation
import SwiftData
import SwiftUI

@Model
// MARK: Folder Model에 color 추가해야 할 것 같아욥 by 룰루
class Folder {
    @Attribute(.unique) let id : UUID
    var name: String
    var color: String
    @Relationship(deleteRule:.cascade) var todos: [Todo]
    init(id: UUID, name: String, color: String, todos: [Todo]) {
        self.id = id
        self.name = name
        self.color = color
        self.todos = todos
    }
}


@Model
class Todo {
    var folder: Folder?
    @Attribute(.unique) let id: UUID
    @Attribute(.externalStorage) var image: Data
    var createdAt: Date
    var options: Options
    var isDone: Bool
    var isDoneAt: Date?
    
    init(folder: Folder? = nil, id: UUID, image: Data, createdAt: Date, options: Options, isDone: Bool, isDoneAt: Date? = nil) {
        self.folder = folder
        self.id = id
        self.image = image
        self.createdAt = createdAt
        self.options = options
        self.isDone = isDone
        self.isDoneAt = isDoneAt
    }
}

@Model
class Options {
//    enum CodingKeys: String, CodingKey {
//        case alarm, memo
//    }

    var alarm: Date?
    var memo: String?

    init(alarm: Date? = nil, memo: String? = nil) {
        self.alarm = alarm
        self.memo = memo
    }

//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        alarm = try container.decodeIfPresent(Date.self, forKey: .alarm)
//        memo = try container.decodeIfPresent(String.self, forKey: .memo)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encodeIfPresent(alarm, forKey: .alarm)
//        try container.encodeIfPresent(memo, forKey: .memo)
//    }
}

