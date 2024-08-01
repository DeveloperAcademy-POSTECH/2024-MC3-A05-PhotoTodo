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
        
        // NavigationStack은 root에 하나만 두면 됨 안에서 전부 사용 가능
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            NavigationLink {
                CameraView()
                    .toolbar {
                        Button("폴더설정") {
                            
                        }
                        
                    }
            } label: {
                Text("카메라 실행")
            }
            
        }
    }
}

#Preview {
    MainView()
}
