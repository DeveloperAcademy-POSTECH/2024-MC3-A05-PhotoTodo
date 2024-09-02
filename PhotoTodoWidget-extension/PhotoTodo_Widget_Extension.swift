//
//  PhotoTodo_Widget_Extension.swift
//  PhotoTodoWidget-extensionExtension
//
//  Created by Lyosha's MacBook   on 9/2/24.
//

import WidgetKit
import SwiftUI

@main
struct PhotoTodo_Widget_Extension: Widget {
    
    let kind: String = "Create-With-Swift-Example_Widget"
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: PhotoTodoProvider(),
            content: {PhotoTodoCameraWidgetView(entry: $0)}
        )
        .supportedFamilies([
            .systemMedium,
        ])
    }
}

#Preview(as : .systemMedium) {
    PhotoTodo_Widget_Extension()
} timeline: {
    PhotoTodoEntry(date: .now)
}

