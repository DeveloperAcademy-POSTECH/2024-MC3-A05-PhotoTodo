//
//  CameraView.swift
//  PhotoTodo
//
//  Revised by Lullu's MacBook on 7/29/24.
//

import SwiftUI
import AVFoundation
import SwiftData

enum CameraCaptureState {
    case single
    case plural
}

enum FolderColor {
    case yellow
    case black
    case blue
    case pink
    case orange
}



struct CameraView: View {
    
    // 카메라 촬영 관련
    @StateObject private var cameraVM: CameraViewModel = CameraViewModel()
    @State private var cameraCaptureState: CameraCaptureState = .single
    @State private var cameraCaptureisActive = false
    @State private var photoData: [Data] = []
    
    // 폴더 관련
    @State private var chosenFolder: Folder = Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
    @Query private var folders: [Folder]
    
    var body: some View {
        VStack(alignment: .center){
            cameraPreview
                .frame(width: 350, height: 500)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            
            FolderCarouselView(chosenFolder: $chosenFolder)
                .frame(height: 80)
                .padding(.top)
            
            if cameraCaptureState == .single {
                HStack(alignment: .center) {
                    ZStack{
                        VStack {
                            Button {
                                cameraVM.takePhoto()
                                cameraCaptureisActive.toggle()
                            } label: {
                                ZStack{
                                    Circle().frame(width: 80, height: 80)
                                        .foregroundStyle(Color.green)
                                    Circle().frame(width: 60, height: 60)
                                        .foregroundStyle(Color.green)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 4)
                                        )
                                }
                            }
                            .navigationDestination(isPresented: $cameraCaptureisActive) {
                                MakeTodoView(cameraVM: cameraVM, chosenFolder: $chosenFolder)
                            }
                        }
//                        HStack{
//                            Spacer()
//                            Button(action: {
//                                cameraCaptureState = .plural
//                            }, label: {
//                                VStack{
//                                    Image(systemName: "square.stack.3d.down.right")
//                                        .resizable()
//                                        .frame(width: 48, height: 52)
//                                    Text("다중촬영")
//                                }
//                            })
//                            .padding(.trailing, 35)
//                        }
                    }
                }
            } else {
                HStack(alignment: .center) {
                    ZStack{
                        VStack {
                            Button {
                                cameraVM.takePhoto()
                                cameraCaptureisActive.toggle()
                            } label: {
                                ZStack{
                                    Circle().frame(width: 80, height: 80)
                                        .foregroundStyle(Color.green)
                                    Circle().frame(width: 60, height: 60)
                                        .foregroundStyle(Color.green)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 4) // 테두리 색상과 두께
                                        )
                                }
                            }
                            .navigationDestination(isPresented: $cameraCaptureisActive) {
                                MakeTodoView(cameraVM: cameraVM, chosenFolder: $chosenFolder)
                                    .toolbar {
                                        Button("Add") {
                                        }
                                    }
                            }
                        }
                        HStack{
                            Spacer()
                            Button(action: {
                                cameraCaptureState = .plural
                            }, label: {
                                VStack{
                                    Image(systemName: "square.stack.3d.down.right")
                                        .resizable()
                                        .frame(width: 45, height: 52)
                                    Text("다중촬영")
                                }
                            })
                            .padding(.trailing, 35)
                        }
                    }
                }
            }
        }.onAppear(perform: {
            // MARK: Preview에 생성이 안되있어서 오류가 날 뿐, 디폴드 폴더는 삭제가 안되게 구현 예정이여서 문제 없습니다.
            chosenFolder = folders.first!
        })
        
    }
    
    private var cameraPreview: some View {
        GeometryReader { geo in
            CameraPreview(cameraVM: cameraVM, frame: CGRect(x: 0, y: 0, width: 350, height: 500))
                .onAppear(){
                    print("열였을 때")
                    cameraVM.requestAccessAndSetup()
                }
                .onDisappear() {
                    print("닫았을 때")
                    cameraVM.stopSession()
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    CameraView()
}
