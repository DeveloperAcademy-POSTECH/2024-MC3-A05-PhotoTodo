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
        NavigationLink{
            DashboardView()
        } label : {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .shadow(radius: 8)
                .frame(minHeight: 25, maxHeight: 75)
                .overlay(
                    VStack{
                        HStack{
                            Text("이번달에 네잎클로버 ") +
                            Text("\(deletionCount / 4)개").foregroundStyle(.green) +
                            Text("를 모았어요!")
                            Image(systemName: "chevron.right")
                        }
                    }
                        .frame(maxHeight: 75)
                )
                .padding()
        }
        TodoCompositeGridView(viewType: .doneList)
    }
}


#Preview {
    DoneListView()
}
