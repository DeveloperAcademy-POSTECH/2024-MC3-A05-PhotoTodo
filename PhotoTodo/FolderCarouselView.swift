//
//  FolderCarouselView.swift
//  PhotoTodo
//
//  Created by leejina on 7/31/24.
//

import SwiftUI

struct ListItem: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
}

import SwiftUI
import SwiftData

struct FolderCarouselView: View {
    @State private var selectedButtonIndex: Int = 0
    @Query private var folders: [Folder]
    @State private var listItems: [ListItem] = []
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Array(listItems.enumerated()), id: \.element.id) { index, item in
                            Button(action: {
                                withAnimation {
                                    selectedButtonIndex = index
                                    // Scroll to the selected button and center it
                                    proxy.scrollTo(index, anchor: .center)
                                }
                            }) {
                                RoundedRectangle(cornerRadius: 5)
                                                .fill(selectedButtonIndex == index ? item.color.opacity(0.2) : Color.white)
                                                .frame(width: 82, height: 34)
                                                .overlay(
                                                    ZStack{
                                                        RoundedRectangle(cornerRadius: 5)
                                                            .stroke(item.color, lineWidth: 4)
                                                        Text(item.title)
                                                            .foregroundColor(item.color)
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
        .onAppear {
            listItems.append(ListItem(title: "기본폴더", color: Color.red))
            listItems.append(ListItem(title: "아카데미", color: Color.blue))
            listItems.append(ListItem(title: "해커톤", color: Color.green))
            listItems.append(ListItem(title: "공지사항", color: Color.yellow))
        }
    }
}


//struct FolderCarouselView: View {
//    
//    @State private var selectedFolder: ListItem = ListItem.preview.first!
//    
//    var body: some View {
//        GeometryReader { proxy in
//            ScrollView(.horizontal) {
//                HStack {
//                    RoundedRectangle(cornerRadius: 5)
//                        .frame(width: UIScreen.main.bounds.size.width / 2 - 55, height: 30)
//                        .foregroundColor(Color.white)
//                    
//                    ForEach(ListItem.preview) { item in
//                        Button(action: {
//                            selectedFolder = item
//                            print("\(selectedFolder)")
//                        }, label: {
//                            RoundedRectangle(cornerRadius: 5)
//                                .frame(width: 82, height: 34)
//                                .foregroundColor(item.id == selectedFolder.id ? item.color.opacity(0.2) : Color.white)
//                                .overlay {
//                                    Text(item.title)
//                                        .foregroundColor(item.color)
//                                        .bold()
//                                }
//                        })
//                    }
//                    Button(action: {
//                        
//                    }, label: {
//                        RoundedRectangle(cornerRadius: 5)
//                            .frame(width: 82, height: 34)
//                            .foregroundColor(Color.white)
//                            .overlay {
//                                HStack{
//                                    Image(systemName: "plus")
//                                        .resizable()
//                                        .frame(width: 15, height: 15)
//                                        .foregroundStyle(Color.gray)
//                                    Text("추가하기")
//                                        .foregroundColor(Color.gray)
//                                        .bold()
//                                }
//                            }
//                    })
//                    .padding(.leading, 5)
//                }
//                .padding(.horizontal, 5)
//                
//            }
//            .scrollIndicators(.hidden)
//        }
//    }
//}

#Preview {
    FolderCarouselView()
}
