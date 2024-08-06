//
//  Date+Extension.swift
//  PhotoTodo
//
//  Created by leejina on 8/6/24.
//

import Foundation

extension Date {
    func makeAlarmDate(alarmData: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd a hh:mm"
        return formatter.string(from: alarmData)
    }
}
