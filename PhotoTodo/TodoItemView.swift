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
    @ObservedObject private var cameraVM = CameraViewModel.shared
    @Environment(\.modelContext) private var modelContext
    @Binding var editMode: EditMode
    @State private var editTodoisActive: Bool = false
    
    // TodoGridView에서 해당하는 todo를 넘겨받음
    var todo: Todo
    @State private var chosenFolder: Folder? = Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
    @State private var contentAlarm: Date? = nil
    @State private var alarmID: String? = ""
    @State private var memo: String? = ""
    @State private var alarmDataisEmpty: Bool? = true
    @State private var path: NavigationPath = NavigationPath()
    @State private var home: Bool? = false
    
    // 토글 시 토스트 메세지 설정 관련 변수
    @Binding var toastMessage: String?
    @Binding var toastOption: ToastOption
    @Binding var recentlyDoneTodo: Todo?
    
    let manager = NotificationManager.instance
    
    var body: some View {
        ZStack{
            //TodoItemView는 하나의 버튼임
            Button {
                //버튼 클릭 시 상태값 세팅
                chosenFolder = todo.folder ?? Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
                if (todo.options.alarm != nil) {
                    contentAlarm = todo.options.alarm!
                    alarmDataisEmpty = false
                }
                memo = todo.options.memo ?? ""
                alarmID = todo.options.alarmUUID ?? ""
                cameraVM.photoData = todo.images
                
                //MakeTodoView로 Navigate하기
                editTodoisActive.toggle()
            } label: {
                Image(uiImage: UIImage(data: todo.images.count > 0 ? todo.images[0] : Data()))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                //MARK: 다중선택 여부 표시
                    .overlay(alignment: . bottomLeading){
                        VStack{
                            Image(systemName: "square.on.square")
                                .font(.title2)
                                .foregroundColor(todo.images.count > 1 ? .paleGray : Color.clear)
                        }
                        .frame(width: 44, height: 44)
                        .padding(8)
                    }
                //MARK: 삭제될 날까지의 D-Day 표시
                    .overlay(alignment: .bottomTrailing){
                        RoundedRectangle(cornerRadius: 35)
                            .fill(todo.isDone ? .paleGray : Color.clear)
                            .opacity(0.8)
                            .frame(width: 100, height: 40)
                            .overlay {
                                Text(todo.isDone ? "\(daysLeft())일남음" : "")
                                    .font(.subheadline).foregroundStyle(.green).padding()
                            }
                            .padding(12)
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
                                recentlyDoneTodo = todo
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
                                recentlyDoneTodo = todo
                                DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                                    DispatchQueue.main.async {
                                        //                                        toastMassage = todo
                                        toastOption = .none
                                    }
                                })
                                print("완료함으로 보내버림")
                            }
                        } label : {
                            VStack{
                                editMode == .active ?
                                nil : //editMode일 때는 체크박스가 보이지 않게 함
                                todo.isDone ?
                                Image("selectedOn")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                                :
                                Image("selectedOff")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                            }
                            .frame(width: 44, height: 44)
                                .padding(8)
                        }
                        .disabled(editMode == .active)
                        .sensoryFeedback(.success, trigger: todo.isDone) { oldValue, newValue in
                            return todo.isDone == true
                        }
                    }
                
            }
            .disabled(editMode == .active)
            .sheet(isPresented: $editTodoisActive, content: {
                NavigationStack{
                    VStack{
                        HStack{
                            // 각 아이템을 클릭하면 나오는 디테일 뷰에서 뒤로가기를 할 때 사용되는 버튼
                            Button {
                                editTodoisActive.toggle()
                            } label: {
                                Text("취소")
                            }
                            Spacer()
                            // 저장 버튼
                            Button {
                                saveTodoItem()
                            } label: {
                                Text("저장")
                            }
                        }
                        .padding()
                        ScrollView{
                            MakeTodoView(chosenFolder: $chosenFolder, startViewType: .edit, contentAlarm: $contentAlarm, alarmID: $alarmID, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo, home: $home)
                                .presentationDragIndicator(.visible)
                        }
                    }
                }
                
            })
            
        }
    }
    
    func saveTodoItem() {
        if todo.options.alarmUUID != nil {
            manager.deleteNotification(withID: alarmID!)
        }
        
        var id: String? = nil
        if alarmDataisEmpty != nil && !alarmDataisEmpty! {
            print("알람 데이터 있음")
            // 알람 생성
            let calendar = Calendar.current
            let year = calendar.component(.year, from: contentAlarm!)
            let month = calendar.component(.month, from: contentAlarm!)
            let day = calendar.component(.day, from: contentAlarm!)
            let hour = calendar.component(.hour, from: contentAlarm!)
            let minute = calendar.component(.minute, from: contentAlarm!)
            
            // Notification 알람 생성 및 id Todo에 저장하기
            id = manager.makeTodoNotification(year: year, month: month, day: day, hour: hour, minute: minute)
        } else {
            print("알람 데이터 없음")
            contentAlarm = nil
            alarmDataisEmpty = true
        }
        //현재 화면에 노출된 변경 가능한 상태들의 현재 상태가 그대로 반영되도록 설 정하기
        todo.folder = chosenFolder
        todo.images = cameraVM.photoData
        todo.options = Options(alarm: contentAlarm, alarmUUID: id, memo: memo)
        editTodoisActive.toggle()
    }
    
    ///삭제되기까지 남은 기간을 계산하는 함수
    func daysLeft() -> Int {
        return 30-(daysPassedSinceJanuaryFirst2024(from : Date())-daysPassedSinceJanuaryFirst2024(from : todo.isDoneAt ?? Date()))
    }
}

#Preview {
    @Previewable @State var toastMessage: String? = nil
    @Previewable @State var editMode: EditMode = .inactive
    @Previewable @State var toastOption: ToastOption = .none
    @Previewable @State var recentlyDoneTodo: Todo? = nil
    let newTodo = Todo(
        id: UUID(),
        images: [UIImage(systemName: "star")?.pngData() ?? Data()],
        createdAt: Date(),
        options: Options(
            alarm: nil,
            memo: nil
        ),
        isDone: false
    )
    return TodoItemView(editMode: $editMode, todo: newTodo, toastMessage: $toastMessage, toastOption: $toastOption,
                        recentlyDoneTodo: $recentlyDoneTodo)
}


