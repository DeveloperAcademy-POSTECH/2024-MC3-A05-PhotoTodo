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

struct MakeTodoView: View {
    
    @ObservedObject var cameraVM: CameraViewModel
    @Binding var chosenFolder: Folder
    
    // 내부 컨텐츠
    @State private var contentAlarm = Date()
    @State private var folderMenuisActive: Bool = false
    @State private var memoisActive: Bool = false
    @State private var memo: String = ""
    @Query private var folders: [Folder]
    //SwiftData 테스트용 데이터
    @State private var testFolders: [Folder] = [
        Folder(id: UUID(), name: "기본폴더", color: "red", todos: []),
        Folder(id: UUID(), name: "아카데미", color: "blue", todos: []),
        Folder(id: UUID(), name: "해커톤", color: "green", todos: []),
        Folder(id: UUID(), name: "공지사항", color: "yellow", todos: []),
        Folder(id: UUID(), name: "쇼핑", color: "pink", todos: []),
        Folder(id: UUID(), name: "룰루랄라", color: "cyan", todos: [])]
    @State private var chosenFolderName: String = "기본폴더"

    var body: some View {
        
        VStack(alignment: .center){
            
            Image(uiImage: UIImage(data: cameraVM.photoData.first ?? Data()))
                .resizable()
                .skeleton(with: cameraVM.photoData.isEmpty,
                          animation: /*.linear(duration: 5, delay: 0, speed: 3, autoreverses: true)*/.pulse(),
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
                                .foregroundStyle(Color.yellow)
                            
                            Menu {
                                ForEach(testFolders, id: \.self.id){ folder in
                                    Button(action: {
                                        chosenFolder = folder
                                        chosenFolderName = folder.name
                                        print(folder.name)
                                    }) {
                                        Label("\(folder.name)", systemImage: "circle")
                                            .foregroundColor(.blue)
                                            
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
                    
                    HStack{
                        Image(systemName: "alarm")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("알람설정")
                        Spacer()
                        DatePicker(
                            "Select Date",
                            selection: $contentAlarm,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    }
                    
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
        })
    }
}

#Preview {
    @State var cameraVM = CameraViewModel()
    @State var chosenFolder: Folder = Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
    return MakeTodoView(cameraVM: cameraVM, chosenFolder: $chosenFolder)
    
}
