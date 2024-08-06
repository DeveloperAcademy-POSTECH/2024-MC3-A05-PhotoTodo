//
//  AlarmSettingView.swift
//  PhotoTodo
//
//  Created by Sunyoung Jeon  on 8/6/24.
//

import SwiftUI

struct AlarmSettingView: View {
    @Environment(\.presentationMode) var presentation
    @State private var alarmSet = Date()
    @State private var selectedDays: Set<String> = []
    
    var body: some View {
        ZStack{
            Color("gray-200")
                .ignoresSafeArea()
            
            VStack{
                HStack{
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }){
                        Text("취소")
                    }
                    Spacer()
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }){
                        Text("저장").bold()
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 11, trailing: 20))
                
                VStack(alignment: .leading){
                    Text("정기 알람 설정")
                        .font(.title2.bold())
                        .padding(.bottom, 3)
                    Text("지정한 요일과 시간에 알림을 보내드립니다.")
                        .font(.footnote)
                        .foregroundStyle(Color("gray-700"))
                }
                
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .padding(EdgeInsets(top: 8, leading: 20, bottom: 11, trailing: 20))
                HStack {
                    Spacer()
                    ForEach(dayNames, id: \.self) { day in
                        dayButton(day: day)
                    Spacer()
                    }
                    
                }
                DatePicker("Please enter a date", selection: $alarmSet,
                           displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.03), radius: 20, x: 0, y: 5)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
            }
        }
    }
    private var dayNames: [String] {
        ["월", "화", "수", "목", "금", "토", "일"]
    }
    
    private func dayButton(day: String) -> some View {
        Button(action: {
            toggleDaySelection(day)
        }) {
            Text(day)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .foregroundColor(selectedDays.contains(day) ? Color.white : Color("gray-1200"))
                .frame(width: 41, height: 44)
                .background(selectedDays.contains(day) ? Color("AccentColor") : Color.white)
                .cornerRadius(10)
            
            
            
        }
    }
    private func toggleDaySelection(_ day: String) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}

#Preview {
    AlarmSettingView()
}