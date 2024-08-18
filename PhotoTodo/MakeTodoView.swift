//
//  MakeTodoView.swift
//  PhotoTodo
//
//  Created by leejina on 7/31/24.
//

import SwiftUI
import SkeletonUI
import UIKit
import SwiftData

enum startViewType {
    case camera
    case edit
    case gridMain
    case gridSingleFolder
}

struct MakeTodoView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var cameraVM: CameraViewModel
    @Binding var chosenFolder: Folder?
    var startViewType: startViewType
    
    // 내부 컨텐츠
    @Binding var contentAlarm: Date?
    @Binding var alarmID: String?
    @State private var folderMenuisActive: Bool = false
    @State private var alarmisActive: Bool = false
    @Binding var alarmDataisEmpty: Bool?
    @State private var memoisActive: Bool = false
    @Binding var memo: String?
    @Query private var folders: [Folder]
    @Binding var home: Bool?
    
    // 이미지 처리관련
    @State private var imageClickisActive: Bool = false
    
    let manager = NotificationManager.instance
    
    
    var chosenFolderColor : Color{
        return chosenFolder != nil ? changeStringToColor(colorName: chosenFolder?.color ?? "green") : changeStringToColor(colorName: folders[0].color)
    }
    var chosenFolderName : String{
        return chosenFolder != nil ? chosenFolder!.name : folders[0].name
    }
    
    var body: some View {
        
        VStack(alignment: .center){
            TabView {
                ForEach(cameraVM.photoData.indices, id: \.self) { index in
                    let imageData: Data = cameraVM.photoData[index]
                    let uiImage = UIImage(data: imageData)
                    Button(action: {
                        imageClickisActive = true
                    }, label: {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .skeleton(with: cameraVM.photoData.isEmpty,
                                      animation: .pulse(),
                                      appearance: .solid(color: Color.paleGray, background: Color.lightGray),
                                      shape: .rectangle,
                                      lines: 1,
                                      scales: [1: 1])
                            .frame(width: 350, height: 500)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    })
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(width: 350, height: 500)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            
            List {
                Section{
                    HStack{
                        Image(systemName: "folder")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("폴더명")
                        Spacer()
                        Group{
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(chosenFolderColor)
                            
                            Menu {
                                ForEach(folders, id: \.self.id){ folder in
                                    Button(action: {
                                        chosenFolder = folder
                                        //                                        chosenFolderName = folder.name
                                        //                                        chosenFolderColor = changeStringToColor(colorName: folder.color)
                                    }) {
                                        Label("\(folder.name)", systemImage: "circle")
                                    }
                                }
                            } label: {
                                Text("\(chosenFolderName)")
                                //                                Text(chosenFolder.name)
                                Image(systemName: "chevron.up.chevron.down")
                                    .resizable()
                                    .frame(width: 10, height: 15)
                            }
                            
                            
                        }
                    }
                    
                    //                    HStack{
                    //                        Image(systemName: "alarm")
                    //                            .resizable()
                    //                            .frame(width: 15, height: 15)
                    //                        Text("알람설정")
                    //                        Spacer()
                    //                        DatePicker(
                    //                            "Select Date",
                    //                            selection: $contentAlarm,
                    //                            displayedComponents: [.date, .hourAndMinute]
                    //                        )
                    //                        .labelsHidden()
                    //                        .datePickerStyle(.compact)
                    //                    }
                    //
                    //
                    Button {
                        alarmisActive.toggle()
                    } label: {
                        HStack{
                            Image(systemName: "alarm")
                                .resizable()
                                .frame(width: 15, height: 15)
                            Text("알람설정")
                            Spacer()
                            Text(alarmDataisEmpty ?? true ? "없음" : Date().makeAlarmDate(alarmData: contentAlarm ?? Date()))
                        }
                    }
                    .sheet(isPresented: $alarmisActive, content: {
                        VStack{
                            HStack{
                                Button(action: {
                                    contentAlarm = Date()
                                    alarmDataisEmpty = true
                                    alarmisActive.toggle()
                                }, label: {
                                    Text("리셋")
                                })
                                Spacer()
                                Button(action: {
                                    alarmDataisEmpty = false
                                    alarmisActive.toggle()
                                }, label: {
                                    Text("완료")
                                })
                            }
                            
                            DatePicker(
                                "Select Date",
                                selection: $contentAlarm.withDefault(Date()),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                        }
                        .padding()
                        .presentationDetents([.height(CGFloat(300))])
                    })
                    
                    
                    Button(action: {
                        memoisActive.toggle()
                    }, label: {
                        HStack{
                            Image(systemName: "pencil")
                                .resizable()
                                .frame(width: 15, height: 15)
                            Text("메모하기")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 8, height: 12)
                        }
                    })
                    .sheet(isPresented: $memoisActive, content: {
                        VStack{
                            HStack{
                                Spacer()
                                Button(action: {
                                    memoisActive.toggle()
                                }, label: {
                                    Text("완료")
                                })
                            }
                            
                            VStack{
                                TextField("메모를 입력해주세요.", text: $memo.withDefault(""))
                            }.frame(height: 100, alignment: .top)
                            
                            Spacer()
                        }
                        .padding()
                        .presentationDetents([.height(CGFloat(200))])
                    })
                }
                .listRowBackground(Color.paleGray)
                .foregroundStyle(Color.black)
            }
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
        }
        
        .toolbar(content: {
            Button {
                //SwiftData 저장 작업
                // 알람 데이터 없을 때
                //                if alarmDataisEmpty {
                //                    let newTodo: Todo = Todo(folder: chosenFolder, id: UUID(), image: cameraVM.photoData.first ?? Data(), createdAt: Date(), options: Options( memo: memo), isDone: false)
                //                    modelContext.insert(newTodo)
                //                } else { // 알람 데이터 있을 때
                //                    let newTodo: Todo = Todo(folder: chosenFolder, id: UUID(), image: cameraVM.photoData.first ?? Data(), createdAt: Date(), options: Options(alarm: contentAlarm, memo: memo), isDone: false)
                //                    modelContext.insert(newTodo)
                //                }
                
                var id: String = ""
                // 알람 데이터가 있으면
                
                // MARK: 생성 시 만들어 지는 곳 -> 알람 데이터 삭제 필요 없음
                if alarmDataisEmpty != nil && !alarmDataisEmpty! {
                    // alarmDataisEmpty == false일 경우 알림을 설정하는 것이기 때문에 데이터가 무조건 있다고 봄
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: contentAlarm!)
                    let month = calendar.component(.month, from: contentAlarm!)
                    let day = calendar.component(.day, from: contentAlarm!)
                    let hour = calendar.component(.hour, from: contentAlarm!)
                    let minute = calendar.component(.minute, from: contentAlarm!)
                    
                    // Notification 알람 생성 및 id Todo에 저장하기
                    id = manager.makeTodoNotification(year: year, month: month, day: day, hour: hour, minute: minute)
                }
                
                
                
                let newTodo: Todo = Todo(folder: chosenFolder, id: UUID(), images: cameraVM.photoData, createdAt: Date(), options: Options(alarm: alarmDataisEmpty ?? true ? nil : contentAlarm, alarmUUID: alarmDataisEmpty ?? true ? nil : id,  memo: memo), isDone: false)
                if let chosenFolder = chosenFolder {
                    chosenFolder.todos.append(newTodo)
                } else {
                    folders[0].todos.append(newTodo)
                }
                modelContext.insert(newTodo)
                home = true
                
                if startViewType == .gridMain {  //startViewType이 .gridMain일 경우 (.gridSingleFolder의 경우에는 제외)
                    chosenFolder = nil //model에 삽입이 끝난 후 chosneFolder를 초기화함
                }
                if startViewType == .gridMain || startViewType == .gridSingleFolder {
                    alarmDataisEmpty = nil //model에 삽입 후 바인딩되어 넘어온 값들을 초기화함 → 다음 추가시 초기화되어 있을 수 있도록
                    contentAlarm = nil
                    memo = nil
                    cameraVM.photoData = []
                }
                
                dismiss()
            } label: {
                Text("완료")
            }
            
        })
    }
}

extension Binding {
    func withDefault<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return Binding<T>(get: {
            self.wrappedValue ?? defaultValue
        }, set: { newValue in
            self.wrappedValue = newValue
        })
    }
}

#Preview {
    @State var cameraVM = CameraViewModel()
    @State var chosenFolder: Folder? = Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
    @State var contentAlarm = Date()
    @State var memo: String = ""
    @State var alarmDataisEmpty: Bool = true
    @State var home: Bool = false
    @State var alarmID = ""
    return MakeTodoView(cameraVM: cameraVM, chosenFolder: $chosenFolder, startViewType: .camera, contentAlarm: .constant(Date()), alarmID: .constant(""), alarmDataisEmpty: .constant(true), memo: .constant(""), home: .constant(true))
    
}
