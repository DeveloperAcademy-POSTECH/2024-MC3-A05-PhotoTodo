//
//  CameraView.swift
//  PhotoTodo
//
//  Revised by Lullu's MacBook on 7/29/24.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    @State private var cameraVM: CameraViewModel = CameraViewModel()
    
    let cameraWidth: CGFloat = 120
    let cameraHeight: CGFloat = 90
    
    var body: some View {
        VStack{
            cameraPreview
            
            Button(action: {
                
            }, label: {
                Text("캡쳐하기")
            })
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
                    cameraVM.stop()
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    CameraView()
}
