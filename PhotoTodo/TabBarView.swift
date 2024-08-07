//
//  TabBarView.swift
//  PhotoTodo
//
//  Created by leejina on 8/2/24.
//
import SwiftUI
 
enum page {
    case main
    case folder
}
 
struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var isCameraViewActive = false
    @State private var path: NavigationPath = NavigationPath()
    @State private var page: page = .main
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack{
                VStack{
                    if page == .main {
                        MainView()
                    } else if page == .folder {
                        FolderListView()
                    }
                    HStack {
                        
                        Button {
                            page = .main
                        } label: {
                            VStack{
                                Image(page == .main ? "allTodo.fill" : "allTodo")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                Text("전체투두")
                                    .font(.system(size: 12))
                                    .padding(.top, 2)
                                    .bold()
                            }
                        }
                        .foregroundStyle(page == .main ? Color("gray/gray-700") : Color("gray/gray-500"))
                        
                        NavigationLink(value: "camera") {
                            ZStack{
                                Circle()
                                    .frame(width: 70, height: 70)
                                    .foregroundStyle(Color.white)
                                    .shadow(color: .lightGray, radius: 10)
                                
                                Image("cloverCamera.fill")
                                    .resizable()
                                    .frame(width: 40, height: 32)
                                    .foregroundStyle(Color.green)
                            }
                        }.navigationDestination(for: String.self) { value in
                            CameraView()
                        }
                        .padding(.horizontal, 55)
                        
                        Button {
                            page = .folder
                        } label: {
                            VStack{
                                Image(systemName: page == .folder ? "folder.fill" : "folder")
                                    .resizable()
                                    .frame(width: 25, height: 20)
                                Text("폴더")
                                    .font(.system(size: 12))
                                    .padding(.top, 2)
                                    .bold()
                            }
                        }
                        .foregroundStyle(page == .folder ? Color("gray/gray-700") : Color("gray/gray-500"))
                    }
                }
 
//                NavigationLink(value: "camera") {
////                    ZStack{
//                        Circle()
//                            .frame(width: 80, height: 80)
//                            .foregroundStyle(Color.white)
//                            .shadow(color: .lightGray, radius: 10)
//
////                        Image(systemName: "camera.fill")
////                            .resizable()
////                            .frame(width: 48, height: 35)
////                            .foregroundStyle(Color.green)
////                    }
//                }
////                .navigationDestination(for: String.self) { value in
////                    CameraView()
////                }
//                .offset(y: 290)
            }
        }
        .navigationDestination(for: String.self) { value in
            CameraView()
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
 
 
//import SwiftUI
//
//enum page {
//    case main
//    case folder
//    case camera
//}
//
//struct TabBarView: View {
//    @State private var selectedTab = 0
//    @State private var isCameraViewActive = false
//    @State private var path: [page] = []
//    @State private var page: page = .main
//
//    var body: some View {
//        NavigationStack(path: $path) {
//            ZStack{
//                VStack{
//                    if page == .main {
//                        MainView()
//                    } else if page == .folder {
//                        FolderListView()
//                    }
//                    HStack {
//
//                        Button {
//                            page = .main
//                        } label: {
//                            Text("메인뷰")
//                        }
//
//
//                        NavigationLink(value: "camera") {
//                            ZStack{
//                                Circle()
//                                    .frame(width: 80, height: 80)
//                                    .foregroundStyle(Color.white)
//                                    .shadow(color: .lightGray, radius: 10)
//
//                                Image(systemName: "camera.fill")
//                                    .resizable()
//                                    .frame(width: 48, height: 35)
//                                    .foregroundStyle(Color.green)
//                            }
//                        }.navigationDestination(for: String.self) { value in
//                            CameraView()
//                        }
//
//                        Spacer()
//                        Button {
//                            page = .folder
//                        } label: {
//                            Text("폴더뷰")
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//
////                NavigationLink(value: "camera") {
////                    ZStack{
////                        Circle()
////                            .frame(width: 80, height: 80)
////                            .foregroundStyle(Color.white)
////                            .shadow(color: .lightGray, radius: 10)
////
////                        Image(systemName: "camera.fill")
////                            .resizable()
////                            .frame(width: 48, height: 35)
////                            .foregroundStyle(Color.green)
////                    }
////                }.navigationDestination(for: String.self) { value in
////                    CameraView()
////                }
////                .offset(y: 290)
//            }
//            .navigationDestination(for: String.self) { value in
//                CameraView()
//            }
//        }
//    }
//}
////struct CustomTabBar: View {
////    @Binding var selectedTab: Int
////
////    var body: some View {
////        HStack {
////            Button(action: {
////                selectedTab = 0
////            }) {
////                VStack {
////                    Image(systemName: "list.bullet")
////                        .foregroundColor(selectedTab == 0 ? .green : .gray)
////                    Text("전체사진")
////                        .foregroundColor(selectedTab == 0 ? .green : .gray)
////                }
////            }
////            .frame(maxWidth: .infinity)
////
////            Spacer()
////
////            Button(action: {
////                selectedTab = 2
////            }) {
////                VStack {
////                    Image(systemName: "folder.fill")
////                        .foregroundColor(selectedTab == 2 ? .green : .gray)
////                    Text("폴더")
////                        .foregroundColor(selectedTab == 2 ? .green : .gray)
////                }
////            }
////            .frame(maxWidth: .infinity)
////        }
////        .frame(height: 50)
////        .background(Color.white.shadow(radius: 2))
////    }
////}
//
//#Preview {
//    TabBarView()
//}
