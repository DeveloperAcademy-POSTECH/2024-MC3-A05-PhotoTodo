//
//  AlarmSettingViewModel.swift
//  PhotoTodo
//
//  Created by leejina on 1/3/25.
//
import Foundation

@Observable
class AlarmSettingViewModel {
    var notificationManage: NotificationManager
    
    init() {
        self.notificationManage = .shared
    }
    
    var selectedDays: [String] = []
    private var alarmSet: Date = Date()
    var dayNames: [String] {
        ["월", "화", "수", "목", "금", "토", "일"]
    }
    
    func saveAlarmSetting() {
        let intDays = daysToInt(selectedDays: selectedDays)
        UserDefaults.standard.set(intDays, forKey: "alarmWeekdays")
        UserDefaults.standard.set(alarmSet, forKey: "alarmTime")
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: alarmSet)
        let minute = calendar.component(.minute, from: alarmSet)

        notificationManage.makeRegularNotification(hour: hour, minute: minute, weekdays: intDays)
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

    func toggleDaySelection(_ day: String) {
        if selectedDays.contains(day) {
            let index = selectedDays.firstIndex(of: day)!
            selectedDays.remove(at: index)
        } else {
            selectedDays.append(day)
        }
    }
    
}
