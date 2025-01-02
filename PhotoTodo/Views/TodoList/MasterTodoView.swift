//
//  MainView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI

struct MasterTodoView: View {
    var viewType: TodoGridViewType = .main
    var body: some View {
            TodoCompositeGridView(viewType: viewType)
    }
}

#Preview {
    MasterTodoView()
}
