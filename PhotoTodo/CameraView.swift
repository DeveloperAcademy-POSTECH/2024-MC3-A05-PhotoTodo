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
    
    @StateObject private var cameraVM: CameraViewModel = CameraViewModel()
    @State private var cameraCaptureState: CameraCaptureState = .single
    @State private var cameraCaptureisActive = false
    @State private var photoData: [Data] = []
    @State private var chosenFolder: String = "기본"
    let cameraWidth: CGFloat = 120
    let cameraHeight: CGFloat = 90
    @State private var folderScrollPaddingSize = UIScreen.main.bounds.size.width / 2 - 40
    
    var folderList : [(String,Color)] = [("기본",Color.red), ("공지사항",Color.blue),( "강의",Color.green), ("해커톤",Color.yellow)]
    var colors: [Color] = [.red, .green, .blue, .yellow, .pink, .black, .cyan]
    
    var body: some View {
        
        
        VStack(alignment: .center){
                cameraPreview
                    .frame(width: 350, height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            
            if cameraCaptureState == .single {
                FolderCarouselView()
                    .frame(height: 80)
                    .padding(.top)
                
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
            } else {
                
            }
        }
        
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
    //    @State var path: [String] = []
    //    return CameraView(path: $path)
    CameraView()
}


//https://prod.velog.io/@realhsb/iOS17-SwiftUI-Carousel
