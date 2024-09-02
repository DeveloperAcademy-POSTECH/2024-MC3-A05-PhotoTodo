//
//  PhotoTodoCameraWidgetView.swift
//  PhotoTodoWidget-extensionExtension
//
//  Created by Lyosha's MacBook   on 9/2/24.
//

import SwiftUI
import WidgetKit

struct PhotoTodoCameraWidgetView: View {
    
    var entry: PhotoTodoProvider.Entry
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .containerBackground(for: .widget) {
                Color.yellow
            }
    }
}

//#Preview {
//    PhotoTodoCameraWidgetView()
//}
