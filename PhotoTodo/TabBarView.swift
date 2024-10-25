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
    @Query private var todos: [Todo]
    @State private var navigationisActive: Bool = false
    let manager = NotificationManager.instance
    @State var isCameraSheetOn: Bool = false
    // 온보딩뷰
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("onboarding") var isOnboarindViewActive: Bool = true
    @AppStorage("deletionCount") var deletionCount: Int = 0
    
    var body: some View {
        NavigationStack/*(path: $path)*/ {
            ZStack{
                Color("gray/gray-200").ignoresSafeArea()
                VStack{
                    if page == .main {
                        MainView()
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

