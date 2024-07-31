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
    
    enum SwipeHVDirection: String {
        case left, right, up, down, none
    }

    func detectDirection(value: DragGesture.Value) -> SwipeHVDirection {
    if value.startLocation.x < value.location.x - 24 {
                return .left
              }
              if value.startLocation.x > value.location.x + 24 {
                return .right
              }
              if value.startLocation.y < value.location.y - 24 {
                return .down
              }
              if value.startLocation.y > value.location.y + 24 {
                return .up
              }
      return .none
      }
    
    var body: some View {
        
        VStack(alignment: .center){
                cameraPreview
                    .frame(width: 350, height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .border(Color.black)
                    .padding(.top, -50)
            
            if cameraCaptureState == .single {
                ScrollViewReader { value in
                    ScrollView(.horizontal) {
                        HStack{
                            ForEach(0..<folderList.count, id: \.self) { index in
                                Button(action: {
                                    value.scrollTo(index+1)
                                    folderScrollPaddingSize -= 60
                                }, label: {
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5)
                                            .frame(width: 80, height: 30)
                                            .foregroundStyle(folderList[index].1)
                                        
                                        Text("\(folderList[index].0)")
                                            .foregroundStyle(Color.white)
                                            .bold()
                                    }
                                })
                                .id(index)
                            }
                        }
                        .gesture(
                            DragGesture()
                                    .onEnded { value in
                                    print("value ",value.translation.width)
                                      let direction = self.detectDirection(value: value)
                                      if direction == .left {
                                        print("왼쪽 드레그됨")
                                      }
                                    }
                        )
                    }
                }
                .padding(.leading, folderScrollPaddingSize)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                VStack {
                    Button {
                        cameraVM.takePhoto()
                        cameraCaptureisActive.toggle()
                    } label: {
                        Circle().frame(width: 80, height: 80)
                            .foregroundStyle(Color.black)
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
