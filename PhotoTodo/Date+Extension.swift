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

func dayOfYear(from date: Date) -> Int {
    let calendar = Calendar.current
    return calendar.ordinality(of: .day, in: .year, for: date) ?? 0
}
          
func daysPassedSinceJanuaryFirst2024(from date: Date) -> Int {
  return dayOfYear(from : date) + (extractYear(from : date)-2024)*365
}

func extractYear(from date: Date) -> Int {
  let calendar = Calendar.current
  let year = calendar.component(.year, from: date)
  return year
}
