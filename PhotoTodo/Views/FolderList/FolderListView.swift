

//
//  FolderListView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 7/29/24.
//

import SwiftUI
import SwiftData

enum TodoGridViewType {
    case singleFolder
    case main
    case doneList
}

struct FolderListView: View {
    
    // 환경변수
    @Environment(\.modelContext) private var modelContext
    @AppStorage("defaultFolderID") private var defaultFolderID: String?
    
    // SwiftData 쿼리
    @Query private var folders: [Folder]
    
    // 뷰 관련 변수
    @State private var folderListViewModel: FolderListViewModel = .init()
    @State private var editMode: EditMode = .inactive
    @State var isShowingSheet = false
    @State var folderNameInput = ""
    @State var selectedColor: Color?
    private var basicViewType: TodoGridViewType = .singleFolder
    private var doneListViewType: TodoGridViewType = .doneList
    
    
    var body: some View {
            List {
                //기본 폴더(인덱스 0에 있음) → 삭제 불가능하게 만들기 위해 따로 뺌
                NavigationLink{
                    TodoGridView(currentFolder: folders.count > 0 ? folders.first(where: {$0.id.uuidString == defaultFolderID}) : nil, viewType: basicViewType)
                } label : {
                    FolderRow(folder: folders.count > 0 ? folders.first(where: {$0.id.uuidString == defaultFolderID}) : nil, viewType: basicViewType)
                }

                
                //기본 폴더를 제외하고는 모두 삭제 가능
                ForEach(folders.filter({$0.id.uuidString != defaultFolderID})) { folder in
                    NavigationLink {
                        TodoGridView(currentFolder: folder, viewType: basicViewType)
                    } label: {
                        FolderRow(folder: folder, viewType: basicViewType)
                    }
                }
                .onDelete { offsets in
                    self.folderListViewModel.deleteItems(offsets: offsets, modelContext: self.modelContext, folders: self.folders)
                }
                //TODO: 옵션을 줘서 완료된 것(되지 않은 것)만 필터링해서 보여주기
                //리스트 뷰의 마지막에는 완료함이 위치함
                NavigationLink {
                    TodoGridView(viewType: .doneList)
                } label : {
                    FolderRow(folder: nil, viewType: doneListViewType)
                }
            }
            .onAppear {
                if defaultFolderID != nil {
                    return
                }
                defaultFolderID = folders.first(where: {$0.name == "기본"})?.id.uuidString
            }

            .scrollContentBackground(.hidden)
            //            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("폴더")
            .toolbar {
                ToolbarItem {
                    if editMode == .inactive {
                        Button {
                            isShowingSheet.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .frame(width: 38)
                }
            }
            .sheet(isPresented: $isShowingSheet, content: {
                FolderEditView(isSheetPresented: $isShowingSheet, folderNameInput: $folderNameInput, selectedColor: $selectedColor)
                    .presentationDetents([.medium, .large])
            })
            .environment(\.editMode, $editMode)
    }
}


private struct FolderRow: View {
    @State var folder: Folder?
    @State var viewType: TodoGridViewType
    
    var body: some View{
        HStack{
            Image(systemName: "folder.fill")
                .foregroundStyle(viewType == .singleFolder ? changeStringToColor(colorName: folder != nil ? folder!.color : "folder-color/green" ) : Color("gray/gray-800"))
            Text(folder != nil ? folder!.name : viewType == .singleFolder ? "" : "완료함")
            Spacer()
        }
    }
}


#Preview {
    FolderListView()
        .modelContainer(for: Folder.self, inMemory: true)
}

