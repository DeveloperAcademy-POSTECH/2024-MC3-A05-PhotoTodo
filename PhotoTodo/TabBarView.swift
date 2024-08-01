//
//  TabBarView.swift
//  PhotoTodo
//
//  Created by leejina on 8/2/24.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var isCameraViewActive = false

    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $selectedTab) {
                    ContentView()
                        .tabItem {
                            VStack {
                                Image(systemName: "list.bullet")
                                Text("전체사진")
                            }
                        }
                        .tag(0)

                    TodoView()
                        .tabItem {
                            VStack {
                                Image(systemName: "folder.fill")
                                Text("폴더")
                            }
                        }
                        .tag(1)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        NavigationLink(destination: CameraView(), isActive: $isCameraViewActive) {
                            
                        }

                        Button(action: {
                            isCameraViewActive = true
                        }) {
                            ZStack {
                                Circle()
                                    .foregroundColor(.white)
                                    .frame(width: 70, height: 70)
                                    .shadow(radius: 10)
                                
                                Circle()
                                    .foregroundColor(.green)
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "camera.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 50)
                }
            }
        }
    }}

//struct CustomTabBar: View {
//    @Binding var selectedTab: Int
//
//    var body: some View {
//        HStack {
//            Button(action: {
//                selectedTab = 0
//            }) {
//                VStack {
//                    Image(systemName: "list.bullet")
//                        .foregroundColor(selectedTab == 0 ? .green : .gray)
//                    Text("전체사진")
//                        .foregroundColor(selectedTab == 0 ? .green : .gray)
//                }
//            }
//            .frame(maxWidth: .infinity)
//
//            Spacer()
//
//            Button(action: {
//                selectedTab = 2
//            }) {
//                VStack {
//                    Image(systemName: "folder.fill")
//                        .foregroundColor(selectedTab == 2 ? .green : .gray)
//                    Text("폴더")
//                        .foregroundColor(selectedTab == 2 ? .green : .gray)
//                }
//            }
//            .frame(maxWidth: .infinity)
//        }
//        .frame(height: 50)
//        .background(Color.white.shadow(radius: 2))
//    }
//}

#Preview {
    TabBarView()
}
