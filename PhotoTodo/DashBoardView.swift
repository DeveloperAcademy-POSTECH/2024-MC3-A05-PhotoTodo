//
//  SwiftUIView.swift
//  test
//
//  Created by 하진주 on 8/2/24.
//

import SwiftUI

struct DashboardView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private var backButton : some View {
        Button(
            action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.backward")    // back button 이미지
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.black)
                    .frame(width: 44, height: 44)
            }
    }
    
    var body: some View {
            ScrollView {
                VStack(spacing : 0){
                    DashboardAccomplishmentTotalView()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 32)
                        .padding(.top, 72)
                    
                    FourLeafCloverCardView()
                        .padding(.top, 132)
                        .padding(.bottom, 20)
                    FootprintCardView()
                        .padding(.bottom, 160)
                    
                    Text("사진을 삭제하는게\n어떻게 환경에\n도움을 줄 수 있나요?")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 57)
                    
                    ScrollView(.horizontal){
                        HStack {
                            Image("environmental_description")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height : 290)
                                .padding(.horizontal, 12)
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding(.bottom, 24)
                    //                .contentMargins(.all, 0)
                    
                }
                .frame(maxWidth: 393, maxHeight: .infinity)
                .background(
                    Image("dashBoardBackground")
                )
            .scrollIndicators(.hidden)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
            
        }
    }
}


private struct DashboardAccomplishmentTotalView: View {
    @AppStorage("deletionCount") var deletionCount: Int = 0
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 8) {
                Text("이번달에 모은 \n네잎클로버")
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .lineSpacing(-8)
                Text("\(deletionCount / 4)개")
                    .font(.title)
                    .bold()
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("이번달에 완료한 \nto do")
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .lineSpacing(-8)
                Text("\(deletionCount)개")
                    .font(.title)
                    .bold()
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("지금까지 줄인 \n디지털 탄소발자국")
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .lineSpacing(-8)
                Text("\(String(format: "%.1f", Float(deletionCount)*(5.4)))g")
                    .font(.title)
                    .bold()
            }
        }
    }
}

private struct FourLeafCloverCardView: View {
    @AppStorage("deletionCount") var deletionCount: Int = 0
    var body: some View {
        VStack(spacing :20) {
            VStack(spacing : 12) {
                Text("이번달에 모은 네잎클로버")
                HStack {
                    Image("fourLeafClover")
                    Text("\(deletionCount / 4)개")
                        .font(.title2)
                        .bold()
                }
            }
            Divider()
                .padding(.horizontal, 28)
            Text("완료함에서 사진 4개가 삭제될 때마다 네잎클로버 한 개를 얻을 수 있어요!")
                .multilineTextAlignment(.center) // 다중 라인 텍스트 정렬
                .lineLimit(nil) // 줄바꿈 무제한
                .padding(.horizontal, 28)
                .font(.callout)
                .foregroundColor(.gray)
        }
        .frame(width: 353, height: 200)
        .background(.white)
        .cornerRadius(20)
    }
}

private struct FootprintCardView: View {
    @AppStorage("deletionCount") var deletionCount: Int = 0
    var body: some View {
        VStack(spacing :20) {
            VStack(spacing : 12) {
                Text("지금까지 줄인 디지털 탄소발자국")
                HStack{
                    Image("footPrint")
                    Text("\(String(format: "%.1 f", Float(deletionCount)*(5.4)))g")
                        .font(.title2)
                        .bold()
                }
            }
            Divider()
                .padding(.horizontal, 28)
            Text("사진(3MB) 한 장을 삭제하면\n탄소 5.4g을 절감할 수 있어요!")
                .multilineTextAlignment(.center) // 다중 라인 텍스트 정렬
                .lineLimit(nil) // 줄바꿈 무제한
                .padding(.horizontal, 28)
                .font(.callout)
                .foregroundColor(.gray)
        }
        .frame(width: 353, height: 200)
        .background(.white)
        .cornerRadius(20)
    }
}

#Preview {
    DashboardView()
}
