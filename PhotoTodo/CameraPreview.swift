//
//  CameraPreview.swift
//  PhotoTodo
//
//  Created by leejina on 7/30/24.
//

import AVFoundation
import SwiftUI

struct CameraPreview: UIViewRepresentable {
    
    @State var cameraManager: CameraManager
    let frame: CGRect
    
    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: frame)
        
        cameraManager.preview = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        cameraManager.preview.frame = frame
        cameraManager.preview.borderColor = UIColor.blue.cgColor
        print("카메라 만들 때 뷰 크기 가로: \(frame.width), 세로: \(frame.height)")
        cameraManager.preview.videoGravity = .resizeAspectFill
        
        cameraManager.preview.cornerRadius = 25
        cameraManager.preview.masksToBounds = true
        
        view.layer.addSublayer(cameraManager.preview)
        return view
    }
    
    ///UIViewRepresentable를 사용하기 위한 필수요소, but 구현 시 사용 안함
    func updateUIView(_ uiView: UIViewType, context: Context) {
        cameraManager.preview.frame = frame
        cameraManager.preview.borderColor = UIColor.blue.cgColor
        cameraManager.preview.videoGravity = .resizeAspectFill
        
        cameraManager.preview.cornerRadius = 25
        cameraManager.preview.masksToBounds = true
        
        print("카메라 업데이드 후 뷰 크기 가로: \(frame.width), 세로: \(frame.height)")
        print("뷰 업데이트됨")
    }
}

#Preview {
    CameraPreview(
        cameraManager: CameraManager(),
        frame: CGRect(x: 0, y: 0, width: 350, height: 400)
    )
}
