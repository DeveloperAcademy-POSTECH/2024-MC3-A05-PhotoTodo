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
    @State private var cameraVM = CameraViewModel.shared
    @State private var cameraManager = CameraManager()
    @State private var cameraCaptureState: CameraCaptureState = .single
    @State private var cameraCaptureisActive = false
    @State private var contentAlarm: Date? = Date()
    @State private var memo: String? = ""
    @State private var alarmDataisEmpty: Bool? = true
    @State private var alarmID: String? = ""
    
    // 폴더 관련
    @State var chosenFolder: Folder? = nil
    @Query private var folders: [Folder]
    @State private var lastScale: CGFloat = 1.0
    
    //이미지 추가 관련
    @Binding var isCameraSheetOn: Bool
    @Binding var home: Bool?
    
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            cameraPreview
                .padding(.top, isCameraSheetOn ? 36 : 6)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                if !isCameraSheetOn {
                    FolderCarouselView(chosenFolder: $chosenFolder)
                }
            }
            .padding(.top, 24)
            
            VStack(spacing: 0) {
                if cameraCaptureState == .single {
                    HStack(alignment: .center) {
                        ZStack{
                            VStack {
                                Button {
                                    cameraManager.takePhoto()
                                    cameraCaptureisActive.toggle()
                                    isCameraSheetOn = false
                                    home = false
                                } label: {
                                    ZStack{
                                        Circle().frame(width: 78, height: 78)
                                            .foregroundStyle(Color("green/green-400"))
                                        Circle().frame(width: 62, height: 62)
                                            .foregroundStyle(Color("green/green-400"))
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: 3)// 테두리 색상과 두께
                                            )
                                    }
                                }
                                .navigationDestination(isPresented: $cameraCaptureisActive) {
                                    MakeTodoView(chosenFolder: $chosenFolder, startViewType: .camera, contentAlarm: $contentAlarm, alarmID: $alarmID, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo, home: $home)
                                }
                            }
                        }
                    }
                } else {
                    HStack(alignment: .center) {
                        ZStack{
                            VStack {
                                Button {
                                    cameraManager.takePhoto()
                                    cameraCaptureisActive.toggle()
                                    isCameraSheetOn = false
                                } label: {
                                    ZStack{
                                        Circle().frame(width: 78, height: 78)
                                            .foregroundStyle(Color("green/green-400"))
                                        Circle().frame(width: 62, height: 62)
                                            .foregroundStyle(Color("green/green-400"))
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: 3)// 테두리 색상과 두께
                                            )
                                    }
                                }
                                .navigationDestination(isPresented: $cameraCaptureisActive) {
                                    MakeTodoView(chosenFolder: $chosenFolder, startViewType: .camera, contentAlarm: $contentAlarm, alarmID: $alarmID, alarmDataisEmpty: $alarmDataisEmpty, memo: $memo, home: $home)
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
            .padding(.bottom, 10)
            .padding(.top, 30)
        }

        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            if isCameraSheetOn == false {
                cameraVM.photoData = []
            }
            // true일 때는 photoData를 그대로 보존함
            // 네비게이션 되돌아가는 로직
            // onAppear 시 home이 true일 때는 메인 화면으로 바로 돌아감
            if home == nil { return }
            if home! == false { return }
            dismiss()
        })
        
        .task(id: cameraCaptureisActive) {
            // onAppear 이후에 수행됨
            // onAppear 시 home이 false여서 메인화면으로 바로 돌아가지 않더라도,
            // 카메라 뷰에서 '뒤로'버튼을 눌렀을 때 home이 참값을 가지고 있어야, 탭바가 원래되로 돌아오기 때문에 다시 home을 참값으로 바꿔주는 작업이 필요함
            if !cameraCaptureisActive {
                // 카메라를 촬영해서(cameraCaptureisActive가 true임) makeTodoView로 들어가는 경우,
                // button 내부의 액션 클로저에서 home값을 false로 다시 바꿔놓는데,
                // task는 makeTodoView로 들어간 이후에 실행되므로,
                // home을 true로 다시 바꿔놓으면 뒤로가기 했을 때 위의 onAppear에 의해 메인으로 바로 돌아가게 됨
                // 이런 이유로 카메라를 촬영해서 들어가는 경우에는 이 처리를 수행하지 않도록 해둠
                home = true
            }
        }
    }
    
    private var cameraPreview: some View {
        GeometryReader { geo in
            CameraPreview(cameraManager: cameraManager, frame: CGRect(x: 0, y: 0, width: geo.size.width, height: UIScreen.main.bounds.size.height * 0.6))
                .frame(width: geo.size.width, height: UIScreen.main.bounds.size.height * 0.6)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / self.lastScale
                            self.lastScale = value
                            let newZoomFactor = cameraManager.zoomFactor * delta
                            cameraManager.zoomFactor = newZoomFactor
                        }
                        .onEnded { _ in
                            self.lastScale = 1.0
                        }
                )
                .onAppear(){
                    cameraManager.requestAccessAndSetup()
                }
                .onDisappear() {
                    cameraManager.stopSession()
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    @Previewable @State var isCameraSheetOn = false
    @Previewable @State var home: Bool? = false
    CameraView(isCameraSheetOn: $isCameraSheetOn, home: $home)
}
