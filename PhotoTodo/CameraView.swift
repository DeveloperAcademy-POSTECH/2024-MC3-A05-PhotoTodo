//
//  CameraView.swift
//  PhotoTodo
//
//  Revised by Lullu's MacBook on 7/29/24.
//

import SwiftUI
import AVFoundation

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
    
    @State private var cameraVM: CameraViewModel = CameraViewModel()
    @State private var cameraCaptureState: CameraCaptureState = .single
    @State private var cameraCaptureisActive = false
    @State private var photoData: [Data] = []
    @State private var chosenFolder: String = "기본"
    let cameraWidth: CGFloat = 120
    let cameraHeight: CGFloat = 90
    
    var folderList : [String] = ["기본", "공지사항", "강의", "해커톤"]
    
    var body: some View {
        NavigationStack {
            VStack{
                cameraPreview
                
                if cameraCaptureState == .single {
                    ScrollView(.horizontal) {
                        HStack{
                            ForEach(folderList, id: \.self) { name in
                                Text("\(name)")
                                    .background(Color.yellow)
                            }
                        }
                    }
                    Button {
                        cameraVM.takePhoto()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                            photoData = cameraVM.photoData
                            print("여기서 제대로 찍여햐 함 \(photoData)")
                            cameraCaptureisActive.toggle()
                        }
                    } label: {
                        Circle().frame(width: 50, height: 50)
                            .foregroundStyle(Color.black)
                    }
                    .navigationDestination(isPresented: $cameraCaptureisActive) {
                        MakeTodoView(cameraVM: $cameraVM, chosenFolder: $chosenFolder)
                            .toolbar {
                                                Button("Add") {
                                                    
                                                }

                                            }
//                        MakeTodoView()
                    }
                    // MARK: NavigationDestination으로 하면 뒤로가기 시 root로 돌아가는 문제
                    //                    NavigationLink {
                    //                        MakeTodoView(cameraVM: $cameraVM)
                    //                    } label: {
                    //                        Text("넘어가보자")
                    //                    }
                    //
                    //
                    //                    Button {
                    //                        cameraVM.takePhoto()
                    //                        cameraCaptureisActive = true
                    //                    } label: {
                    //                        Circle().frame(width: 50, height: 50)
                    //                            .foregroundStyle(Color.black)
                    //                    }
                    
                } else {
                    
                }
            }
        }
    }
    
    private var cameraPreview: some View {
        GeometryReader { geo in
            CameraPreview(cameraVM: $cameraVM, frame: CGRect(x: 0, y: 0, width: 500, height: 500))
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
    //    @State var path: [String] = []
    //    return CameraView(path: $path)
    CameraView()
}
