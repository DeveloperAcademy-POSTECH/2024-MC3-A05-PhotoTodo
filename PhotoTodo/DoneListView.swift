//
//  DoneListView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 8/7/24.
//

import SwiftUI

struct DoneListView: View {
    @AppStorage("deletionCount") var deletionCount: Int = 0
    
    var body: some View {
        //TODO: 배너 넣기
        TodoCompositeGridView(viewType: .doneList)
    }
}


#Preview {
    DoneListView()
}
