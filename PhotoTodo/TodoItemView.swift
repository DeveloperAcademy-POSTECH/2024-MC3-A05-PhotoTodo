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
    @State private var chosenFolder: Folder? = Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
    @State private var contentAlarm: Date? = Date()
    @State private var memo: String? = ""
    @State private var alarmDataisEmpty: Bool? = true
    @State private var path: NavigationPath = NavigationPath()
    @State private var home: Bool? = false
    
    // 토글 시 토스트 메세지 설정 관련 변수
    @Binding var toastMessage: Todo?
    @Binding var toastOption: ToastOption
    
    var body: some View {
        ZStack{
            Button {
                editTodoisActive.toggle()
                cameraVM.photoData = [todo.image]
            } label: {
                Image(uiImage: UIImage(data: todo.image))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    //MARK: 삭제될 날까지의 D-Day 표시
                    .overlay(alignment: .bottomTrailing){
                        RoundedRectangle(cornerRadius: 35)
                            .fill(.paleGray)
                            .opacity(0.5)
                            .frame(width: 100, height: 40)
                            .overlay {
                                Text(todo.isDone ? "\(dayOfYear(from : Date())-dayOfYear(from : todo.isDoneAt ?? Date())+30)일남음" : "")
                                    .font(.callout).foregroundStyle(.green).padding()
                            }
                    }
                    //MARK: 체크박스 표시
                    .overlay(alignment: .topLeading) {
                        Button{
                            todo.isDoneAt = nil
                            if (todo.isDone) {
                                // 완료상태 -> 미완료상태로 변경
//                                withAnimation {
                                    todo.isDone.toggle()
//                                }
                                todo.isDoneAt = nil
//                                toastMassage = todo
                                toastOption = .moveToOrigin
                                DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                                    DispatchQueue.main.async {
//                                        toastMassage = nil
                                        toastOption = .none
                                    }
                                })
                                print("메인함으로 보내버림")
                            } else {
                                // 미완료상태 -> 완료상태로 변경
//                                withAnimation {
                                    todo.isDone.toggle()
//                                }
                                todo.isDoneAt = Date()
//                                toastMassage = nil
                                toastOption = .moveToDone
                                DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                                    DispatchQueue.main.async {
//                                        toastMassage = todo
                                        toastOption = .none
                                    }
                                })
                                print("완료함으로 보내버림")
                            }
                        } label : {
                            editMode == .active ?
                            nil : //editMode일 때는 체크박스가 보이지 않게 함
                            todo.isDone ?
                            Image("selectedOn")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .padding(4)
                            :
                            Image("selectedOff")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .padding(4)
                        }
                        .disabled(editMode == .active)
                    }

            }
            .disabled(editMode == .active)
            .sheet(isPresented: $editTodoisActive, content: {
                VStack{
                    HStack{
                        // 각 아이템을 클릭하면 나오는 디테일 뷰에서 뒤로가기를 할 때 사용되는 버튼
                        Button {
                            editTodoisActive.toggle()
                        } label: {
                            Text("취소")
                        }
                        Spacer()
                        Button {
                            if alarmDataisEmpty != nil && !alarmDataisEmpty! {
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

func dayOfYear(from date: Date) -> Int {
    let calendar = Calendar.current
    return calendar.ordinality(of: .day, in: .year, for: date) ?? 0
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
    @State var toastMessage: Todo? = nil
    @State var toastOption: ToastOption = .none
    return TodoItemView(editMode: $editMode, todo: newTodo, toastMessage: $toastMessage, toastOption: $toastOption)
}


