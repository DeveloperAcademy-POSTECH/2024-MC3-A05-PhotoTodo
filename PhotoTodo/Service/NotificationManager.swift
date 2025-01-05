//
//  UserNotification.swift
//  PhotoTodo
//
//  Created by leejina on 8/12/24.
//
import SwiftUI
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    var notiID: [String] = []
    
    /// 제일 처음에 알림 설정을 하기 위한 함수 -> 앱이 열릴 때나 button 클릭시에 함수 호출 되도록!
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { suceess, error in
            if let error {
                print("ERROR: \(error)")
            } else {
                print("SUCCESS")
            }
        }
    }
    
    func makeRegularNotification(hour: Int, minute: Int, weekdays: [Int]) {
        
        if let isAlarmNotiID = UserDefaults.standard.object(forKey: "notiID") as? [String] {
            for noti in isAlarmNotiID {
                self.deleteNotification(withID: noti)
            }
        }
        
            let content = UNMutableNotificationContent()
            content.title = "미완료된 TODO를 확인해보세요!"
            content.body = "아직 확인하지 못한 TODO가 검토를 기다리고 있어요!"
            content.sound = UNNotificationSound.default
            
            for weekday in weekdays {
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.weekday = weekday // 1: Sunday, 2: Monday, ..., 7: Saturday
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                let id  = UUID().uuidString
                self.notiID.append(id)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                let center = UNUserNotificationCenter.current()
                center.add(request) { error in
                    if let error = error {
                        print("Error: \(error)")
                    } else {
                        print("Weekly notification scheduled for weekday: \(weekday)")
                    }
                }
            }
        UserDefaults.standard.set(notiID, forKey: "notiID")
        }
    func makeTodoNotification(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> String {
        let content = UNMutableNotificationContent()
        content.title = "미완료된 TODO를 확인해보세요!"
        content.body = "[중요]오늘 꼭 확인해야 하는 TODO가 있어요!"
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
                dateComponents.calendar = Calendar.current
                dateComponents.year = year
                dateComponents.month = month
                dateComponents.day = day
                dateComponents.hour = hour
                dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let id  = UUID().uuidString
            self.notiID.append(id)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    print("\(id) Notification scheduled for \(year)-\(month)-\(day)-\(hour)-\(minute)")
                }
            }
        return id
    }
    
    func deleteNotification(withID: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [withID])
        print("\(withID)")
    }
}

