//
//  CameraPreview.swift
//  PhotoTodo
//
//  Created by leejina on 7/30/24.
//

import AVFoundation
import SwiftUI

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var cameraVM: CameraViewModel
    let frame: CGRect
    
    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: frame)
        cameraVM.preview = AVCaptureVideoPreviewLayer(session: cameraVM.session)
        cameraVM.preview.frame = frame
        cameraVM.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraVM.preview)
        return view
    }
    
    ///UIViewRepresentable를 사용하기 위한 필수요소, but 구현 시 사용 안함
    func updateUIView(_ uiView: UIViewType, context: Context) {
        cameraVM.preview.frame = frame
    }
}
