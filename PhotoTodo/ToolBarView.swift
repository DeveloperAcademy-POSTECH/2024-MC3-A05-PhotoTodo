//
//  ToolBarView.swift
//  PhotoTodo
//
//  Created by Hyungeol Lee on 8/3/24.
//

import SwiftUI

struct ToolBarView: View {
    @State var photoData: [Data] = []
    
    var body: some View {
        NavigationView{
            VStack {
                Text("이미지 업로드")
                Image(uiImage: UIImage(data: Data()))
            }
            .toolbar{
                ToolbarItemGroup(placement: .bottomBar) {
                    //TODO: 업로드 창에서 선택 후 이미지 넣기
                    Button {
                        print("tap first button")
                    } label : {
                        Image(systemName: "photo.on.rectangle")
                    }
                    NavigationLink {
                        CameraView()
                    }label: {
                        Image(systemName: "camera")
                    }
                }
            }
        }
    }
}

#Preview {
    ToolBarView()
    
}
