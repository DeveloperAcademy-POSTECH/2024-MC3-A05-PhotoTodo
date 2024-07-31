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
    ]
}

struct FolderCarouselView: View {
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(ListItem.preview) { item in
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 90, height: 30)
                            .foregroundStyle(item.color)
                            .overlay {
                                Text(item.title)
                                    .foregroundStyle(Color.white)
                                    .bold()
                            }
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .scrollTransition(.interactive, axis: .horizontal) { effect, phase in
                                effect
                                    .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                    .offset(x: offset(for: phase))
                        
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        }
        
    }
    
    func offset(for phase: ScrollTransitionPhase) -> Double {
        switch phase {
        case .topLeading:
            300
        case .identity:
            0
        case .bottomTrailing:
            -300
        }
    }
}

#Preview {
    FolderCarouselView()
}
