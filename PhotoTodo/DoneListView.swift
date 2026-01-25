//
//  DoneListView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 8/7/24.
//

import SwiftUI
import SwiftData

struct DoneListView: View {
    @AppStorage("deletionCount") var deletionCount: Int = 0
    
    var body: some View {
        //TODO: 배너 넣기
        ZStack{
            Color("gray/gray-200").ignoresSafeArea()
            VStack{
                NavigationLink{
                    DashboardView()
                } label : {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .shadow(color: .paleGray , radius: 8)
                        .frame(minHeight: 25, maxHeight: 85)
                        .overlay(
                            HStack{
                                VStack{
                                    HStack{
                                        Text("지금까지 네잎클로버 ").foregroundStyle(.black).bold().font(.system(size: 20)) +
                                        Text("\(deletionCount / 4)개").foregroundStyle(.green).bold().font(.system(size: 20)) +
                                        Text("를 모았어요!").foregroundStyle(.black).bold().font(.system(size: 20))
                                        Spacer()
                                    }
                                    .padding(.leading, 12)
                                    .padding(.bottom, 3)
                                    
                                    HStack{
                                        Image(systemName: "info.circle.fill")
                                            .foregroundStyle(Color("gray/gray-700"))
                                            .font(.system(size: 14))
                                            
                                        Text("완료한 사진을 지우면 탄소배출을 줄일 수 있어요")
                                            .foregroundStyle(Color("gray/gray-700"))
                                            .font(.system(size: 14))
                                        Spacer()
                                    }.padding(.leading, 12)
                                }
                                Image(systemName: "chevron.right")
                            }
                            .padding(16)
                        )
                        .padding()
                }
                TodoCompositeGridView(viewType: .doneList)
            }
        }
    }
}


#Preview {
    let container = try! ModelContainer(
        for: Folder.self, Todo.self, Photo.self, Options.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let mockDoneTodos = [
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "checkmark.circle.fill")?.pngData() ?? Data())],
            createdAt: Date().addingTimeInterval(-86400),
            options: Options(memo: "완료된 작업 1"),
            isDone: true,
            isDoneAt: Date()
        ),
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "checkmark.square.fill")?.pngData() ?? Data())],
            createdAt: Date().addingTimeInterval(-172800),
            options: Options(memo: "완료된 작업 2"),
            isDone: true,
            isDoneAt: Date().addingTimeInterval(-86400)
        ),
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "checkmark.seal.fill")?.pngData() ?? Data())],
            createdAt: Date().addingTimeInterval(-259200),
            options: Options(memo: "완료된 작업 3"),
            isDone: true,
            isDoneAt: Date().addingTimeInterval(-172800)
        ),
        Todo(
            id: UUID(),
            images: [Photo(image: UIImage(systemName: "checkmark.diamond.fill")?.pngData() ?? Data())],
            createdAt: Date().addingTimeInterval(-345600),
            options: Options(memo: "완료된 작업 4"),
            isDone: true,
            isDoneAt: Date().addingTimeInterval(-259200)
        )
    ]
    
    let folder = Folder(id: UUID(), name: "기본", color: "green", todos: mockDoneTodos)
    container.mainContext.insert(folder)
    
    return DoneListView()
        .modelContainer(container)
}
