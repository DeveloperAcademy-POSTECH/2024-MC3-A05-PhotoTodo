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
}

struct MakeTodoView: View {
    
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var cameraVM: CameraViewModel
    @Binding var chosenFolder: Folder
    var startViewType: startViewType
    
    // 내부 컨텐츠
    @Binding var contentAlarm: Date
    @State private var folderMenuisActive: Bool = false
    @State private var alarmisActive: Bool = false
    @Binding var alarmDataisEmpty: Bool
    @State private var memoisActive: Bool = false
    @Binding var memo: String
    @Query private var folders: [Folder]
    @State private var chosenFolderName: String = "기본폴더"
    @State private var chosenFolderColor: Color = Color.red

    var body: some View {
        
        VStack(alignment: .center){
            
            Image(uiImage: UIImage(data: cameraVM.photoData.first ?? Data()))
                .resizable()
                .skeleton(with: cameraVM.photoData.isEmpty,
                          animation: .pulse(),
                          appearance: .solid(color: Color.paleGray, background: Color.lightGray),
                          shape: .rectangle,
                          lines: 1,
                          scales: [1: 1])
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
                                        chosenFolderName = folder.name
                                        chosenFolderColor = changeStringToColor(colorName: folder.color)
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
                            Text(alarmDataisEmpty ? "없음" : "\(contentAlarm)")
                        }
                    }
                    .sheet(isPresented: $alarmisActive, content: {
                        VStack{
                            HStack{
                                Spacer()
                                Button(action: {
                                    contentAlarm = Date()
                                    alarmDataisEmpty = true
                                    alarmisActive.toggle()
                                }, label: {
                                    Text("리셋")
                                })
                                Button(action: {
                                    alarmDataisEmpty = false
                                    alarmisActive.toggle()
                                }, label: {
                                    Text("완료")
                                })
                            }
                            
                            DatePicker(
                                "Select Date",
                                selection: $contentAlarm,
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
                                TextField("메모를 입력해주세요.", text: $memo)
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
        .onAppear(perform: {
            print(chosenFolder.name)
            chosenFolderName = chosenFolder.name
            chosenFolderColor = changeStringToColor(colorName: chosenFolder.color)
            if startViewType == .edit {
            }
        })
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
                
                let newTodo: Todo = Todo(folder: chosenFolder, id: UUID(), image: cameraVM.photoData.first ?? Data(), createdAt: Date(), options: Options(alarm: contentAlarm, memo: memo), isDone: false)
                modelContext.insert(newTodo)
            } label: {
                Text("Add")
            }

        })
    }
}

#Preview {
    @State var cameraVM = CameraViewModel()
    @State var chosenFolder: Folder = Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
    @State var contentAlarm = Date()
    @State var memo: String = ""
    @State var alarmDataisEmpty: Bool = true
    return MakeTodoView(cameraVM: cameraVM, chosenFolder: $chosenFolder, startViewType: .camera, contentAlarm: $contentAlarm, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo)
    
}
