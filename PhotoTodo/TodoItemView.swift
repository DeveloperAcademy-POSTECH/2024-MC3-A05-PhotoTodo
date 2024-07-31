//
//  TodoItemView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/30/24.
//

import SwiftUI

struct TodoItemView: View {
    @Binding var editMode: EditMode
    var todo: Todo
    
    var body: some View {
        ZStack{
            Image("FilledCoffee")
                .resizable()
                .frame(width: 180, height: 200)
                .scaledToFit()
            //TODO: overlay하고 alignment로 top 주기
                .overlay(alignment: .topLeading) {
                    Button{
                        todo.isDone.toggle()
                    } label : {
                        todo.isDone ?
                        Image(systemName: "circle.fill")
                            .padding(4)
                            .background(Color.black)
                            .foregroundColor(.white)
                        :
                        Image(systemName: "circle")
                            .padding(4)
                            .background(Color.black)
                            .foregroundColor(.white)
                    }
                    .disabled(editMode == .active)
                }

        }
    }
}

#Preview {
    var newTodo = Todo(
        id: UUID(),
        image: UIImage(systemName: "star")?.pngData() ?? Data(),
        createdAt: Date(),
        options: Options(
            alarm: nil,
            memo: nil
        ),
        isDone: false
    )
    
    @State var editMode: EditMode = .inactive
    return TodoItemView(editMode: $editMode, todo: newTodo)
}


