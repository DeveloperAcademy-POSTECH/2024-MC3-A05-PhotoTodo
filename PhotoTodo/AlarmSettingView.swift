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
    @State private var selectedDays: [String] = []
    let manager = NotificationManager.instance
    
    var body: some View {
        ZStack{
            Color("gray/gray-200")
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
                        let intDays = daysToInt(selectedDays: selectedDays)
                        UserDefaults.standard.set(intDays, forKey: "alarmWeekdays")
                        UserDefaults.standard.set(alarmSet, forKey: "alarmTime")
                        
                        var calendar = Calendar.current
                        let hour = calendar.component(.hour, from: alarmSet)
                        let minute = calendar.component(.minute, from: alarmSet)

                        manager.makeRegularNotification(hour: hour, minute: minute, weekdays: intDays)
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
                        .foregroundStyle(Color("gray/gray-700"))
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
        .onAppear(perform: {
            if let isAlarmDate = UserDefaults.standard.object(forKey: "alarmTime") as? Date {
                alarmSet = isAlarmDate
            }
            
            if let isAlarmDay = UserDefaults.standard.object(forKey: "alarmWeekdays") as? [Int] {
                selectedDays = daysToString(selectedDays: isAlarmDay)
            }
            
        })
    }
    private var dayNames: [String] {
        ["월", "화", "수", "목", "금", "토", "일"]
    }
    
    func daysToInt(selectedDays: [String]) -> [Int] {
        var intDays: [Int] = []
        for day in selectedDays {
            switch day {
            case "일":
                intDays.append(1)
            case "월":
                intDays.append(2)
            case "화":
                intDays.append(3)
            case "수":
                intDays.append(4)
            case "목":
                intDays.append(5)
            case "금":
                intDays.append(6)
            case "토":
                intDays.append(7)
            default:
                continue
            }
        }
        return intDays
    }
    func daysToString (selectedDays: [Int]) -> [String] {
        var stringDays: [String] = []
        for day in selectedDays {
            switch day {
            case 1:
                stringDays.append("일")
            case 2:
                stringDays.append("월")
            case 3:
                stringDays.append("화")
            case 4:
                stringDays.append("수")
            case 5:
                stringDays.append("목")
            case 6:
                stringDays.append("금")
            case 7:
                stringDays.append("토")
            default:
                continue
            }
        }
        return stringDays
    }
    
    private func dayButton(day: String) -> some View {
        Button(action: {
            toggleDaySelection(day)
        }) {
            Text(day)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .foregroundColor(selectedDays.contains(day) ? Color.white : Color("gray/gray-1200"))
                .frame(width: 41, height: 44)
                .background(selectedDays.contains(day) ? Color("AccentColor") : Color.white)
                .cornerRadius(10)
        }
    }
    private func toggleDaySelection(_ day: String) {
        if selectedDays.contains(day) {
            let index = selectedDays.firstIndex(of: day)!
            selectedDays.remove(at: index)
        } else {
            selectedDays.append(day)
        }
    }
}

#Preview {
    AlarmSettingView()
}
