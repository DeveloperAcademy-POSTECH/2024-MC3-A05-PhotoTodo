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
class CameraViewModel: ObservableObject {
    
    static let shared = CameraViewModel()
    
    var photoData: [Data] = []
    
}
