//
//  TabBarView.swift
//  PhotoTodo
//
//  Created by leejina on 8/2/24.
//
import SwiftUI
import SwiftData

enum page {
    case main
    case folder
}

struct MainTabView: View {
    
    // 환경변수
    @AppStorage("hasBeenLaunched") private var hasBeenLaunched = false // 최초 런치 시
    @AppStorage("onboarding") var isOnboarindViewActive: Bool = true // 최초 온보딩 시(런치했지만 온보딩을 확인하지 않을 수도 있음)
    @AppStorage("deletionCount") var deletionCount: Int = 0
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    //SwiftData 쿼리
    @Query private var folders: [Folder]
    @Query private var todos: [Todo]
    
    // 뷰 내부 변수
    @State private var page: page = .main
    @State private var mainTabViewModel: MainTabViewModel = .init()
    @State private var selectedTab = 0
    @State private var isCameraViewActive = false
    @State private var navigationisActive: Bool = false
    @State var isCameraSheetOn: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color("gray/gray-200").ignoresSafeArea()
                VStack{
                    if page == .main {
                        MasterTodoView()
                    } else if page == .folder {
                        FolderListView()
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            page = .main
                        } label: {
                            VStack{
                                Image(page == .main ? "allTodo.fill" : "allTodo")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("전체투두")
                                    .font(.system(size: 12))
                                    .padding(.top, 2)
                                    .bold()
                            }
                        }
                        .foregroundStyle(page == .main ? Color("gray/gray-700") : Color("gray/gray-500"))
                        
                        
                        NavigationLink  {
                            CameraView(isCameraSheetOn: $isCameraSheetOn)
                        } label:  {
                            ZStack{
                                Circle()
                                    .frame(width: 70, height: 70)
                                    .foregroundStyle(Color.white)
                                    .shadow(color: .lightGray, radius: 10)
                                
                                Image("cloverCamera.fill")
                                    .resizable()
                                    .frame(width: 40, height: 30)
                                    .foregroundStyle(Color.green)
                            }
                        }
                        //                        .navigationDestination(for: String.self) { value in
                        //                            CameraView()
                        //                        }
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
                        Spacer()
                    }.background(Color(.white))
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .fullScreenCover(isPresented: $isOnboarindViewActive) {
            OnboardingView()
        }
        .onAppear {
            //MARK: 30일 초과한 아이템을 지움
            self.deletionCount = mainTabViewModel.removeTodoItemsPastDueDate(todos: self.todos, modelContext: self.modelContext, deletionCount: self.deletionCount)
            
            //MARK: 최초 1회 실행된 적이 있을 시
            if hasBeenLaunched {
                return
            }
            
            //MARK: 최초 1회 실행된 적 없을 시 세팅 작업 실행
            mainTabViewModel.MakeDefaultFolder(modelContext: self.modelContext)
            hasBeenLaunched = true
            
            mainTabViewModel.activateNotificationRequestAuthorization()
        }
    }
}

#Preview {
    MainTabView()
}

