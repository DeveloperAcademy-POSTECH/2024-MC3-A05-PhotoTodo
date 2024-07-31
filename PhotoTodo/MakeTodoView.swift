//
//  MakeTodoView.swift
//  PhotoTodo
//
//  Created by leejina on 7/31/24.
//

import SwiftUI
import UIKit

struct MakeTodoView: View {
    
    @ObservedObject var cameraVM: CameraViewModel
    @Binding var chosenFolder: String
    @State private var wakeUp = Date()
//    @ObservedObject private var cameraVM: CameraViewModel = CameraViewModel()
//    @State var data = CameraViewModel().photoData
    
    var body: some View {
        
            VStack{
                HStack{
                    Image(systemName: "folder")
                        .resizable()
                        .frame(width: 15, height: 15)
                    Text("\(chosenFolder)")
                }
                if cameraVM.photoData.isEmpty {
                    // MARK: 스켈레톤 넣고 싶은데 문제 있는지 확인
                    /// https://github.com/CSolanaM/SkeletonUI
                    Text("없음")
                    Text("1. \(cameraVM.photoData)")
                } else {
                    Image(uiImage: UIImage(data: cameraVM.photoData.first!)!)
                        .resizable()
                        .frame(width: 300, height: 500)
                }
                
                Button(action: {
                    
                }, label: {
                    HStack{
                        Image(systemName: "alarm")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("알람설정")
                        
                        DatePicker(
                              "Select Date",
                              selection: $wakeUp,
                              displayedComponents: [.date, .hourAndMinute]
                            )
                        .labelsHidden()
                        .padding(.horizontal, 20)
                        .datePickerStyle(.compact)
                    }
                })
                Button(action: {
                    
                }, label: {
                    HStack{
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("메모작성")
                    }
                })
                
            }
        
    }
}

//#Preview {
//    @State var cameraVM = CameraViewModel()
//    @State var chosenFolder = "기본"
//    return MakeTodoView(cameraVM: cameraVM, chosenFolder: $chosenFolder)
//    
////    MakeTodoView()
//}
