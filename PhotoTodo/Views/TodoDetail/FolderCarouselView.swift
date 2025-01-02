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
    @Binding var chosenFolder: Folder?
    @State private var selectedButtonIndex: Int = 0
    @Query private var folders: [Folder]
    
    //폴더 추가 시 사용되는 상태들 상태들
    @State var isShowingSheet = false
    @State var folderNameInput = ""
    @State var selectedColor: Color?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Array(folders.enumerated()), id: \.element.id) { index, folder in
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
                                                            .stroke(changeStringToColor(colorName: folder.color), lineWidth: 4)
                                                        Text(folder.name)
                                                            .foregroundColor(changeStringToColor(colorName: folder.color))
                                                            .bold()
                                                    }
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            .onAppear(perform: {
                                withAnimation {
                                    selectedButtonIndex = 0
                                    proxy.scrollTo(0, anchor: .center)
                                }
                            })
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
                    .frame(minWidth: geometry.size.width)
                    .padding(.horizontal, (geometry.size.width - 40) / 2)
                }
            }
        }
        .frame(height: 34)
        .padding(.top)
        .sheet(isPresented: $isShowingSheet, content: {
            FolderEditView(isSheetPresented: $isShowingSheet, folderNameInput: $folderNameInput, selectedColor: $selectedColor)
                .presentationDetents([.medium, .large])
        })
    }
}

#Preview {
    @Previewable @State var chosenFolder: Folder? = Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
    return FolderCarouselView(chosenFolder: $chosenFolder)
}
