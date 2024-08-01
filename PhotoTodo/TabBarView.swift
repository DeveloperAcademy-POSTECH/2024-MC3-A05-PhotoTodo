//
//  TabBarView.swift
//  PhotoTodo
//
//  Created by leejina on 8/2/24.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 1

        var body: some View {
            ZStack {
                TabView(selection: $selectedTab) {
                    TodoView()
                        .tabItem {
                            Image(systemName: "list.bullet")
                            Text("전체사진")
                        }
                        .tag(0)


                    FolderListView()
                        .tabItem {
                            Image(systemName: "folder.fill")
                            Text("폴더")
                        }
                        .tag(1)
                }

                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        Button(action: {
                            
                        }) {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 50)

//                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        }
}

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
