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
struct CameraView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // 카메라 촬영 관련
    @StateObject private var cameraVM: CameraViewModel = CameraViewModel()
    @State private var cameraCaptureState: CameraCaptureState = .single
    @State private var cameraCaptureisActive = false
    @State private var photoData: [Data] = []
    @State private var contentAlarm: Date? = Date()
    @State private var memo: String? = ""
    @State private var alarmDataisEmpty: Bool? = true
    @State private var alarmID: String? = ""
    
    // 폴더 관련
    @State var chosenFolder: Folder? = nil
    @Query private var folders: [Folder]
    @State private var home: Bool? = false
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .center){
            cameraPreview
                .frame(width: 353, height: 542)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            
            FolderCarouselView(chosenFolder: $chosenFolder)
                .frame(height: 34)
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
                                MakeTodoView(cameraVM: cameraVM, chosenFolder: $chosenFolder, startViewType: .camera, contentAlarm: $contentAlarm, alarmID: $alarmID, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo, home: $home)
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
                .padding(.top)
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
                                MakeTodoView(cameraVM: cameraVM, chosenFolder: $chosenFolder, startViewType: .camera, contentAlarm: $contentAlarm, alarmID: $alarmID, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo, home: $home)
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
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            if home == nil { return }
            if home! == false { return }
            home = false
            dismiss()
        })
        
    }
    
    private var cameraPreview: some View {
        GeometryReader { geo in
            CameraPreview(cameraVM: cameraVM, frame: CGRect(x: 0, y: 0, width: 353, height: 542))
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / self.lastScale
                            self.lastScale = value
                            let newZoomFactor = cameraVM.zoomFactor * delta
                            cameraVM.zoomFactor = newZoomFactor
                        }
                        .onEnded { _ in
                            self.lastScale = 1.0
                        }
                )
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
