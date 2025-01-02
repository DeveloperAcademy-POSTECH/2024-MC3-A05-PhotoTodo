//
//  TodoView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI
import SwiftData
    
struct TodoCompositeGridView: View {
    @State var viewType: TodoGridViewType
    
    var body: some View {
        TodoGridView(viewType: viewType)
        }
    }
