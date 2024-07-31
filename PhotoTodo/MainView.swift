//
//  MainView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI

struct MainView: View {
    @State private var showCamera: Bool = false
    @State var path: [String] = []
    var body: some View {
        
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            NavigationLink {
                CameraView()
            } label: {
                Text("카메라 실행")
            }
        }
        
//        NavigationStack(path: $path) {
//            Button(action: {
//                self.path.append("cameraView")
//            }, label: {
//                Text("카메라 촬영")
//            })
//            .navigationDestination(for: String.self) { value in
//                CameraView(path: $path)
//            }
//        }
    }
}

#Preview {
    MainView()
}
