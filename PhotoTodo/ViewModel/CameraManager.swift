//
//  CameraViewModel.swift
//  PhotoTodo
//
//  Created by leejina on 7/30/24.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

///카메라 촬영
//@Observable
class CameraManager: NSObject, ObservableObject {
    
    enum PhotoCaptureState {
        case notStarted
        case prosessing
        case finished(Data)
    }
    
    var session = AVCaptureSession()
    var preview = AVCaptureVideoPreviewLayer()
    var output = AVCapturePhotoOutput()
    
    
    
    @Published var zoomFactor: CGFloat = 1.0 {
            didSet {
                setZoom(zoomFactor)
            }
        }
    
    var cameraVM: CameraViewModel
    
    override init() {
        self.cameraVM = CameraViewModel.shared
    }
    
    private func setZoom(_ zoomFactor: CGFloat) {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = max(1.0, min(zoomFactor, device.activeFormat.videoMaxZoomFactor))
                device.unlockForConfiguration()
            } catch {
                print("Error setting zoom factor: \(error.localizedDescription)")
            }
        }
    
    private(set) var photoCaptureState: PhotoCaptureState = .notStarted
    func requestAccessAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { didAllowAccess in
                self.setup()
            }
        case .authorized:
            setup()
        default:
            print("other state but not used")
        }
    }
    
    private func setup() {
        // 촬영 시마다 사진 데이터 초기화
//        self.photoData = []
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        do {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            session.commitConfiguration()
            
            Task(priority: .background) {
                self.session.startRunning()
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopSession() {
        Task(priority: .background) {
            if session.isRunning {
                session.stopRunning()
            }
        }
    }
    
    //MARK :
    func takePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let error {
            print(error.localizedDescription)
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        self.cameraVM.photoData.append(imageData)
        print(self.self.cameraVM.photoData)
        
        Task(priority: .background) {
            self.session.stopRunning()
        }
    }
}
