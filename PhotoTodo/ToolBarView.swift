//
//  ToolBarView.swift
//  PhotoTodo
//
//  Created by Hyungeol Lee on 8/3/24.
//

import SwiftUI

struct ToolBarView: View {
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State var photoData: [Data] = []
    @State var image = Image(uiImage: UIImage(data: Data()))
    
    var body: some View {
        NavigationView{
            VStack {
                Text("이미지 업로드")
//                Image(uiImage: UIImage(data: Data()))
                image
                    .resizable()
                    .frame(width: 180, height: 200)
                    .scaledToFit()
            }
            .toolbar{
                ToolbarItemGroup(placement: .bottomBar) {
                    //TODO: 업로드 창에서 선택 후 이미지 넣기
                    Button {
                        print("tap first button")
                        showingImagePicker = true
                    } label : {
                        Image(systemName: "photo.on.rectangle")
                    }
                    NavigationLink {
//                        CameraView()
                    }label: {
                        Image(systemName: "camera")
                    }
                }
            }
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
}

#Preview {
    ToolBarView()
    
}
