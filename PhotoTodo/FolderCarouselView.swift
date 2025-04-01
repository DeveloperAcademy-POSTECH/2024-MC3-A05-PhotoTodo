//
//  FolderCarouselView.swift
//  PhotoTodo
//
//  Created by leejina on 7/31/24.
//

import SwiftUI
import SwiftData

struct ListItem: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
}

func changeStringToColor(colorName: String) -> Color {
    switch colorName {
    case "red":
        return Color("folder_color/red")
    case "sky":
        return Color("folder_color/sky")
    case "yellow":
        return Color("folder_color/yellow")
    case "green":
        return Color("folder_color/green")
    case "blue":
        return Color("folder_color/blue")
    case "purple":
        return Color("folder_color/purple")
    default:
        return Color("folder_color/green")
    }
}

struct FolderCarouselView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var chosenFolder: Folder?
    @State private var selectedButtonIndex: Int = 0
    //#if DEBUG
    //    @State private var folders: [Folder] = [
    //        Folder(id: UUID(), name: "하나", color: "green", todos: []),
    //        Folder(id: UUID(), name: "두울", color: "red", todos: []),
    //        Folder(id: UUID(), name: "세에엣", color: "blue", todos: []),
    //        Folder(id: UUID(), name: "넷", color: "purple", todos: []),
    //        Folder(id: UUID(), name: "다아서어엇", color: "green", todos: [])
    //    ]
    //#else
    @Query private var folders: [Folder]
    @Query private var folderOrders: [FolderOrder]
    //#endif
    
    //폴더 추가 시 사용되는 상태들 상태들
    @State var isShowingSheet = false
    @State var folderNameInput = ""
    @State var selectedColor: Color?
    @State var currentScrollPosition: CGFloat = 0
    @State var newFolder: Folder? = nil //"폴더 추가" 선택 시 현재 선택된 폴더와 다른 폴더를 만들기 위해 사용되는 더미 변수. nil값 외에 다른 값으로 두지 말것.
    var folderManager = FolderManager()
    
    var orderedFolder: [Folder] {
        return folderManager.getOrderedFolder(folders, folderOrders)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Array(orderedFolder.enumerated()), id: \.element.id) { index, folder in
                            Button(action: {
                                withAnimation {
                                    selectedButtonIndex = index
                                    // Scroll to the selected button and center it
                                    proxy.scrollTo(index, anchor: .center)
                                }
                                chosenFolder = folder
                            }) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(selectedButtonIndex == index ? changeStringToColor(colorName: folder.color).opacity(0.2) : Color.white)
                                    .frame(width: 82, height: 34)
                                    .overlay(
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5)
                                                .strokeBorder(changeStringToColor(colorName: folder.color), lineWidth: 1)
                                            
                                            Text(folder.name)
                                                .foregroundColor(changeStringToColor(colorName: folder.color))
                                                .bold()
                                        }
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            .id(index)
                        }
                        
                        Button(action: {
                            isShowingSheet.toggle()
                        }, label: {
                            HStack{
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                Text("추가하기")
                            }
                            .foregroundStyle(Color.gray)
                        })
                        
                    }
                    .onAppear(perform: {
                        withAnimation {
                            selectedButtonIndex = 0
                            if let chosenFolder = chosenFolder {
                                for (index, folder) in orderedFolder.enumerated() {
                                    if folder == chosenFolder {
                                        selectedButtonIndex = index
                                        break
                                    }
                                }
                            }
                            proxy.scrollTo(selectedButtonIndex, anchor: .center)
                        }
                    })
                    .frame(minWidth: geometry.size.width)
                    .padding(.horizontal, (geometry.size.width / 2) - 41)
                }
                .padding(.horizontal, 0)
            }
        }
        .frame(height: 34)
        .onAppear {
            folderManager.setDefaultFolder(modelContext, folderOrders, folders)
        }
        .sheet(isPresented: $isShowingSheet, content: {
            FolderEditView(isSheetPresented: $isShowingSheet, folderNameInput: $folderNameInput, selectedColor: $selectedColor, selectedFolder: $newFolder)
                .presentationDetents([.medium, .large])
        })
    }
}

#Preview {
    @Previewable @State var chosenFolder: Folder? = Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
    return FolderCarouselView(chosenFolder: $chosenFolder)
}
