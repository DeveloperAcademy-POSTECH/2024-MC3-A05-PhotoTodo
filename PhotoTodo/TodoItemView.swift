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
    @State private var cameraVM = CameraViewModel.shared
    @Environment(\.modelContext) private var modelContext
    @Binding var editMode: EditMode
    @State private var editTodoisActive: Bool = false
    @State private var previewImage: UIImage? = nil

    
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
        ZStack {
            //TodoItemView는 하나의 버튼임
            Button {
                onTodoItemTapped()
            } label: {
                if let image = previewImage {
                    Image(uiImage: image)
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
                            checkBoxButton
                        }
                } else {
                    ProgressView()
                           .frame(width: 170, height: 170)
                }
            }
            .disabled(editMode == .active)
            .sheet(isPresented: $editTodoisActive, content: {
                NavigationStack{
                    VStack{
                        ScrollView{
                            MakeTodoView(chosenFolder: $chosenFolder, startViewType: .edit, onSave: saveTodoItem, contentAlarm: $contentAlarm, alarmID: $alarmID, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo, home: $home)
                                .presentationDragIndicator(.visible)
                        }
                    }
                }
                
            })
            
        }
        .task(priority: .background) {
            await loadPreviewImage()
        }

    }
    
    private var checkBoxButton: some View {
            Button {
                onCheckBoxButtonTapped()
                } label : {
                VStack{
                    editMode == .active ?
                    nil : //editMode일 때는 체크박스가 보이지 않게 함
                    todo.isDone ?
                    Image("selectedOn")
                        .aspectRatio(contentMode: .fit)
                    :
                    Image("selectedOff")
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: 44, height: 44)
                    .padding(8)
            }
            .disabled(editMode == .active)
            .sensoryFeedback(.success, trigger: todo.isDone) { oldValue, newValue in
                return todo.isDone == true
            }
    }
    
    func onCheckBoxButtonTapped() {
        todo.isDoneAt = nil
        if (todo.isDone) {
            // 완료상태 -> 미완료상태로 변경
            todo.isDone.toggle()
            todo.isDoneAt = nil
            toastOption = .moveToOrigin
            recentlyDoneTodo = todo
            DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                DispatchQueue.main.async {
                    toastOption = .none
                }
            })
            print("메인함으로 보내버림")
        } else {
            todo.isDone.toggle()
            todo.isDoneAt = Date()
            toastOption = .moveToDone
            recentlyDoneTodo = todo
            DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                DispatchQueue.main.async {
                    toastOption = .none
                }
            })
            print("완료함으로 보내버림")
        }
        try? modelContext.save()
    }
    
    func onTodoItemTapped() {
        //버튼 클릭 시 상태값 세팅
        chosenFolder = todo.folder ?? Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
        if (todo.options.alarm != nil) {
            contentAlarm = todo.options.alarm!
            alarmDataisEmpty = false
        }
        memo = todo.options.memo ?? ""
        alarmID = todo.options.alarmUUID ?? ""
        
        //UI Hang 방지 위해 백그라운드 작업
        DispatchQueue.global().async() {
            cameraVM.photoData = todo.images.map {$0.image}
        }
        
        //MakeTodoView로 Navigate하기
        editTodoisActive.toggle()
    }
    
    func saveTodoItem() {
        if todo.options.alarmUUID != nil {
            manager.deleteNotification(withID: alarmID!)
        }
        
        var id: String? = nil
        if alarmDataisEmpty != nil && !alarmDataisEmpty! {
            print("알림 데이터 있음")
            // 알림 생성
            let calendar = Calendar.current
            let year = calendar.component(.year, from: contentAlarm ?? .now)
            let month = calendar.component(.month, from: contentAlarm ?? .now)
            let day = calendar.component(.day, from: contentAlarm ?? .now)
            let hour = calendar.component(.hour, from: contentAlarm ?? .now)
            let minute = calendar.component(.minute, from: contentAlarm ?? .now)
            
            // Notification 알림 생성 및 id Todo에 저장하기
            id = manager.makeTodoNotification(year: year, month: month, day: day, hour: hour, minute: minute)
        } else {
            print("알림 데이터 없음")
            contentAlarm = nil
            alarmDataisEmpty = true
        }
        //현재 화면에 노출된 변경 가능한 상태들의 현재 상태가 그대로 반영되도록 설정하기
        todo.folder = chosenFolder
        todo.images = cameraVM.photoData.map{ Photo(image: $0) }
        todo.options = Options(alarm: contentAlarm, alarmUUID: id, memo: memo)
        editTodoisActive.toggle()
        try? modelContext.save()
    }
    
    ///삭제되기까지 남은 기간을 계산하는 함수
    func daysLeft() -> Int {
        return 30-(daysPassedSinceJanuaryFirst2024(from : Date())-daysPassedSinceJanuaryFirst2024(from : todo.isDoneAt ?? Date()))
    }
    
    func loadPreviewImage() async {
        guard !todo.images.isEmpty else { return }
        let data = todo.images[0].image

        let image = await Task.detached(priority: .userInitiated) {
            guard let originalImage = UIImage(data: data) else { return UIImage(data: Data()) }
                // 메모리 최적화: 디스플레이 크기로 리사이징 (170x170)
                return originalImage.resizedImage(targetSize: CGSize(width: 340, height: 340))
            }.value

        if let image {
            await MainActor.run {
                self.previewImage = image
            }
        }
    }
}

// MARK: - UIImage Extension for Memory Optimization
extension UIImage {
    /// 메모리 효율적으로 이미지 리사이징
    func resizedImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // 작은 비율을 선택하여 aspect ratio 유지
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        return scaledImage
    }
}

#Preview {
    @Previewable @State var toastMessage: String? = nil
    @Previewable @State var editMode: EditMode = .inactive
    @Previewable @State var toastOption: ToastOption = .none
    @Previewable @State var recentlyDoneTodo: Todo? = nil
    let newTodo = Todo(
        id: UUID(),
        images: [Photo(image: UIImage(systemName: "star")?.pngData() ?? Data())],
        createdAt: Date(),
        options: Options(
            alarm: nil,
            memo: nil
        ),
        isDone: false
    )
    TodoItemView(editMode: $editMode, todo: newTodo, toastMessage: $toastMessage, toastOption: $toastOption,
                        recentlyDoneTodo: $recentlyDoneTodo)
}


