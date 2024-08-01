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
    
    static let preview: [ListItem] = [
        .init(title: "기본", color: .red),
        .init(title: "공지사항", color: .blue),
        .init(title: "강의자료", color: .green),
        .init(title: "MC3", color: .yellow),
        .init(title: "해커톤", color: .gray),
        .init(title: "기본", color: .red),
        .init(title: "공지사항", color: .blue),
        .init(title: "강의자료", color: .green),
        .init(title: "MC3", color: .yellow),
        .init(title: "해커톤", color: .gray),
    ]
}

struct FolderCarouselView: View {
    
    @State private var selectedFolder: ListItem = ListItem.preview.first!
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: UIScreen.main.bounds.size.width / 2 - 55, height: 30)
                        .foregroundColor(Color.white)
                    
                    ForEach(ListItem.preview) { item in
                        Button(action: {
                            selectedFolder = item
                            print("\(selectedFolder)")
                        }, label: {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: 82, height: 34)
                                .foregroundColor(item.id == selectedFolder.id ? item.color.opacity(0.2) : Color.white)
                                .overlay {
                                    Text(item.title)
                                        .foregroundColor(item.color)
                                        .bold()
                                }
                        })
                    }
                    Button(action: {
                        
                    }, label: {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 82, height: 34)
                            .foregroundColor(Color.white)
                            .overlay {
                                HStack{
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color.gray)
                                    Text("추가하기")
                                        .foregroundColor(Color.gray)
                                        .bold()
                                }
                            }
                    })
                    .padding(.leading, 5)
                }
                .padding(.horizontal, 5)
                
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    FolderCarouselView()
}
