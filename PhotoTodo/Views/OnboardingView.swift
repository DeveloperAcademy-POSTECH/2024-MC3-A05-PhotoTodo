//
//  OnboardingView.swift
//  PhotoTodo
//
//  Created by leejina on 10/23/24.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedItem = 0
    var indexList: [Int] = [1,2,3,4]
    
    
    var body: some View {
        ZStack{
            VStack{
                TabView(selection: $selectedItem) {
                    
                    ForEach(indexList.indices, id: \.self) { index in
                        Image("onboarding\(indexList[selectedItem])")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .onChange(of: selectedItem) {
                    print("\(selectedItem)")
                }
                .padding(.bottom)
                
                Button {
                    if selectedItem == 3 {
                        dismiss()
                    }
                    if 0..<3 ~= selectedItem {
                        selectedItem += 1
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(selectedItem == 3 ? "green/green-500" : "green/green-300"))
                        .frame(width: 353, height: 60)
                        .overlay {
                            Text(selectedItem == 3 ? "시작하기" : "다음")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 20))
                                .bold()
                        }
                }
                .padding(.bottom)

            }
            .padding(.top, 30)
        }
    }
}

#Preview {
    OnboardingView()
}
