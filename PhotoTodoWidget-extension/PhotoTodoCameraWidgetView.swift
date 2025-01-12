//
//  PhotoTodoCameraWidgetView.swift
//  PhotoTodoWidget-extensionExtension
//
//  Created by Lyosha's MacBook   on 9/2/24.
//

import SwiftUI
import WidgetKit

struct PhotoTodoCameraWidgetView: View {
    
    var entry: PhotoTodoProvider.Entry
    var body: some View {
            VStack{
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(Color.white)
                    .shadow(color: .gray.opacity(0.4), radius: 4)
                    .overlay(
                        Image("cloverCamera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color.green)
                    )
                Text("투두 촬영하기")
                             .font(.system(size: 14, weight: .bold))
                             .foregroundStyle(Color.black)
                             .padding(.top, 4)
            }
            .containerBackground(for: .widget) {
                           Color("gray-200")
                       }

            .widgetURL(URL(string: "openCamera"))
    }
}

//#Preview {
//    PhotoTodoCameraWidgetView()
//}
