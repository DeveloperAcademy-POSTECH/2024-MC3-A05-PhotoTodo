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
        cameraManager.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraManager.preview)
        return view
    }
    
    ///UIViewRepresentable를 사용하기 위한 필수요소, but 구현 시 사용 안함
    func updateUIView(_ uiView: UIViewType, context: Context) {
        cameraManager.preview.frame = frame
        print("뷰 업데이트됨")
    }
}
