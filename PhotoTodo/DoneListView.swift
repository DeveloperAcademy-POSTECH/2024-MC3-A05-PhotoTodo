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
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .paleGray , radius: 8)
                .frame(minHeight: 25, maxHeight: 75)
                .overlay(
                    HStack{
                        VStack{
                            HStack{
                                Text("이번달에 네잎클로버 ").foregroundStyle(.black).bold() +
                                Text("\(deletionCount / 4)개").foregroundStyle(.green).bold() +
                                Text("를 모았어요!").foregroundStyle(.black).bold()
                                Spacer()
                            }.padding(.leading, 12)
                            HStack{
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(Color("gray/gray-700"))
                                    
                                Text("완료한 사진을 지우면 탄소배출을 줄일 수 있어요").foregroundStyle(Color("gray/gray-700"))
                                    .font(.callout)
                            }
                        }
                        Image(systemName: "chevron.right")

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
