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
    @State private var isCameraViewNavigate = false
    @State private var home: Bool? = false
    
    @State private var page: page = .main
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [Folder]
    @Query private var folderOrders: [FolderOrder]
    @Query private var todos: [Todo]
    @State private var navigationisActive: Bool = false
    let manager = NotificationManager.instance
    @State var isCameraSheetOn: Bool = false
    // 온보딩뷰
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("hasBeenLaunched") private var hasBeenLaunched = false
    @AppStorage("onboarding") var isOnboarindViewActive: Bool = true
    @AppStorage("deletionCount") var deletionCount: Int = 0
    
    @State var recentlySeenFolder: Folder? = nil
    @AppStorage("defaultFolderID") private var defaultFolderID: String?
    
    var folderManager = FolderManager()
    @State var recentTag: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack{ // 메모리에 적재되어 네비게이션 되고 있는 뷰들을 탭바로 관리함
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        ZStack{
                            Color("gray/gray-200").ignoresSafeArea(.all, edges: .top)
                            MainView()
                        }
                    }
                    .tag(0)
                    
                    NavigationStack {
                        VStack {
                            EmptyView()
                        }
                        .animation(.easeInOut, value: isCameraViewActive)
                        .navigationDestination(isPresented: $isCameraViewNavigate){
                            CameraView(chosenFolder: recentlySeenFolder, isCameraSheetOn: $isCameraSheetOn, home: $home)
                        }
                    }
                    .tag(1)
                    
                    NavigationStack {
                        ZStack{
                            Color("gray/gray-200").ignoresSafeArea(.all, edges: .top)
                            FolderListView(recentlySeenFolder: $recentlySeenFolder)
                        }
                    }
                    .tag(2)
                }
                .onChange(of: isCameraViewNavigate) { newValue in
                    if newValue == false && home == true {
                        isCameraViewActive = false
                        home = false
                        selectedTab = recentTag
                    }
                }
                .onAppear {
                    UITabBar.appearance().isHidden = true
                }
            }
            .animation(.easeInOut, value: isCameraViewActive)
            
            VStack(spacing: 0) { // 커스텀 탭바 뷰
                Spacer()
                HStack(spacing: 0) {
                    HStack {
                        Button { // 전체 투두 탭
                            selectedTab = 0
                            recentTag = 0
                            recentlySeenFolder = folders.count > 0 ? folders.first(where: {$0.id.uuidString == defaultFolderID}) : nil
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
                        
                        Button { //폴더뷰 탭
                            selectedTab = 2
                            recentTag = 2
                            page = .folder
                            recentlySeenFolder = folders.count > 0 ? folders.first(where: {$0.id.uuidString == defaultFolderID}) : nil
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
            .animation(.easeInOut, value: isCameraViewActive)
            .opacity(isCameraViewActive ? 0 : 1)
            
            HStack { //탭바의 카메라 버튼
                Button  {
                    selectedTab = 1
                    isCameraViewActive = true
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        isCameraViewNavigate = true
                    }
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
                .offset(y: -42)
            }
            .opacity(isCameraViewActive ? 0 : 1)
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
            
            if hasBeenLaunched {
                //포토투두 앱 내부에서만 쓰이는 AppStorage에서 앱 그룹의 유저디폴트 값으로 기본 폴더 생성을 여부를 판단하고자 심어놓은 코드
                let defaults = UserDefaults(suiteName: "group.PhotoTodo-com.2024-MC3-A05-team5.PhotoTodo")
                if defaults?.bool(forKey: "hasBeenLaunched") == false {
                    defaults?.set(true, forKey: "hasBeenLaunched")
                }
                return
            }
            
            folderManager.setDefaultFolder(modelContext, folderOrders, folders)
            hasBeenLaunched = true
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

