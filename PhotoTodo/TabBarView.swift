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

struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var isCameraViewActive = false
    //    @State private var path: NavigationPath = NavigationPath()
    @State private var page: page = .main
    @AppStorage("hasBeenLaunched") private var hasBeenLaunched = false
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [Folder]
    @Query private var folderOrders: [FolderOrder]
    @Query private var todos: [Todo]
    @State private var navigationisActive: Bool = false
    let manager = NotificationManager.instance
    @State var isCameraSheetOn: Bool = false
    // 온보딩뷰
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("onboarding") var isOnboarindViewActive: Bool = true
    @AppStorage("deletionCount") var deletionCount: Int = 0
    
    var folderManager = FolderManager()
    
    var body: some View {
        
            ZStack(alignment: .bottom) {
                
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        ZStack{
                            Color("gray/gray-200").ignoresSafeArea(.all, edges: .top)
                            MainView()
                        }
                    }
                    .tag(0)
                    
                    CameraView(isCameraSheetOn: $isCameraSheetOn)
                        .tag(1)
                    
                    NavigationStack {
                        ZStack{
                            Color("gray/gray-200").ignoresSafeArea(.all, edges: .top)
                            FolderListView()
                        }
                    }
                    .tag(2)
                }
                .onAppear {
                    UITabBar.appearance().isHidden = true
                }
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 0) {
                        HStack {
                            Button {
                                selectedTab = 0
                                page = .main
                            } label: {
                                VStack(spacing: 0) {
                                    VStack{
                                        Image(page == .main ? "allTodo.fill" : "allTodo")
                                            .font(.system(size: 24))
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                    }
                                    .frame(width: 44, height: 44)
                                    Text("전체투두")
                                        .font(.system(size: 12))
                                        .bold()
                                }
                                .frame(height: 60)
                            }
                            .foregroundStyle(page == .main ? Color("gray/gray-700") : Color("gray/gray-500"))
                            
                            Spacer()
                            
                            Button {
                                selectedTab = 2
                                page = .folder
                            } label: {
                                VStack(spacing: 0) {
                                    VStack {
                                        Image(systemName: page == .folder ? "folder.fill" : "folder")
                                            .font(.system(size: 24))
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    .frame(width: 44, height: 44)
                                    Text("폴더")
                                        .font(.system(size: 12))
                                        .bold()
                                }
                                .frame(height: 60)
                            }
                            .foregroundStyle(page == .folder ? Color("gray/gray-700") : Color("gray/gray-500"))
                        }
                        .padding(.horizontal, 42)
                        .padding(.bottom, 23)
                    }
                    .background(Color.white)
                }
                
                HStack {
                    NavigationLink  {
//                        selectedTab = 1
                        CameraView(isCameraSheetOn: $isCameraSheetOn)
                    } label:  {
                        ZStack{
                            Circle()
                                .frame(width: 78, height: 78)
                                .foregroundStyle(Color.white)
                                .shadow(color: .lightGray, radius: 10)
                            VStack {
                                Image("cloverCamera.fill")
                                    .font(.system(size: 40))
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundStyle(Color("green/green-400"))
                            }
                            .frame(width: 48, height: 48)
                        }
                    }
                    //                        .navigationDestination(for: String.self) { value in
                    //                            CameraView()
                    //                        }
                    .offset(y: -42)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .ignoresSafeArea(.keyboard)
        
        .fullScreenCover(isPresented: $isOnboarindViewActive) {
            OnboardingView()
        }
        .onAppear {
#if DEBUG
            self.isOnboarindViewActive = false
#endif
            //MARK: 30일 초과한 아이템을 지움
            removeTodoItemsPastDueDate()
            
            //MARK: 최초 1회 실행된 적이 있을 시
            if hasBeenLaunched {
                return
            }
            
            //MARK: 최초 1회 실행된 적 없을 시 세팅 작업 실행
            let defaultFolder = Folder(
                id: UUID(),
                name: "기본",
                color: "green",
                todos: []
            )
            modelContext.insert(defaultFolder)
            hasBeenLaunched = true
            
            manager.requestAuthorization()
            
            //MARK: 폴더 순서 정렬 관련 안정화 코드
            folderManager.setFolderOrder(folders, folderOrders, modelContext)
        }
    }
    
    private func removeTodoItemsPastDueDate() -> Void {
        let todoItemsPastDueDate: [Todo] = todos.filter{
            isPastDueDate(todo: $0)
        }
        
        for todo in todoItemsPastDueDate {
            if let todo = todos.first(where: { $0.id == todo.id }) {
                modelContext.delete(todo)
                deletionCount += 1
            }
        }
    }
    
    func isPastDueDate(todo: Todo) -> Bool {
        if 30 < daysPassedSinceJanuaryFirst2024(from : Date())-daysPassedSinceJanuaryFirst2024(from : todo.isDoneAt ?? Date()) {
            return true
        }
        return false
    }
}

#Preview {
    TabBarView()
}

