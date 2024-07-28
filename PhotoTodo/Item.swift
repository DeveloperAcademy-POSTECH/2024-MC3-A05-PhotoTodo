//
//  Item.swift
//  2024-MC3-A05-PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/28/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
