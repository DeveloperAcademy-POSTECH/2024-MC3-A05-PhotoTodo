//
//  TodoItemView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/30/24.
//

import SwiftUI
import UIKit
import SwiftData

struct TodoItemView: View {
    @StateObject private var cameraVM: CameraViewModel = CameraViewModel()
    @Environment(\.modelContext) private var modelContext
    @Binding var editMode: EditMode
    @State private var editTodoisActive: Bool = false
    // TodoGridView에서 해당하는 todo를 넘겨받음
    var todo: Todo
    @State private var chosenFolder: Folder = Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
    @State private var contentAlarm = Date()
    @State private var memo: String = ""
    @State private var alarmDataisEmpty: Bool = true
    @State private var path: NavigationPath = NavigationPath()
    @State private var home: Bool = false
    
    var body: some View {
        ZStack{
            Button {
                editTodoisActive.toggle()
                cameraVM.photoData = [todo.image]
            } label: {
                Image(uiImage: UIImage(data: todo.image))
                    .resizable()
                    .frame(width: 180, height: 200)
                    .scaledToFit()
                //TODO: overlay하고 alignment로 top 주기
                    .overlay(alignment: .topLeading) {
                        Button{
                            if (todo.isDone) {
                                todo.isDone.toggle()
                                todo.isDoneAt = nil
                            } else {
                                todo.isDone.toggle()
                                todo.isDoneAt = Date()
                            }
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
            .disabled(editMode == .active)
            .sheet(isPresented: $editTodoisActive, content: {
                VStack{
                    HStack{
                        Button {
                            editTodoisActive.toggle()
                        } label: {
                            Text("취소")
                        }
                        Spacer()
                        Button {
                            if !alarmDataisEmpty {
                                let todoData = Todo(folder: chosenFolder, id: todo.id, image: todo.image, createdAt: todo.createdAt, options: Options(alarm: contentAlarm, memo: memo), isDone: todo.isDone)
                                modelContext.insert(todoData)
                                print("알람 데이터 있음")
                            } else {
                                let todoData = Todo(folder: chosenFolder, id: todo.id, image: todo.image, createdAt: todo.createdAt, options: Options(memo: memo), isDone: todo.isDone)
                                modelContext.insert(todoData)
                                print("알람 데이터 없음")
                            }
                            editTodoisActive.toggle()
                        } label: {
                            Text("저장")
                        }

                    }
                    .padding()
                    
                    MakeTodoView(cameraVM: cameraVM, chosenFolder: $chosenFolder, startViewType: .camera, contentAlarm: $contentAlarm, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo, home: $home)
                }
            })
        }
        .onAppear(perform: {
            chosenFolder = todo.folder ?? Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
            if (todo.options.alarm != nil) {
                contentAlarm = todo.options.alarm!
                alarmDataisEmpty = false
            }
            memo = todo.options.memo ?? ""
        })
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


