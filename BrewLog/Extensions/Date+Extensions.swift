//
//  Date+Extensions.swift
//  BrewLog
//

import Foundation

extension Date {
    /// 格式化为显示日期（如：2月23日）
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: self)
    }

    /// 格式化为完整日期（如：2026年2月23日）
    var fullDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: self)
    }

    /// 格式化为日期时间（如：2月23日 14:30）
    var displayDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 HH:mm"
        return formatter.string(from: self)
    }

    /// 相对时间描述（如：今天、昨天、3天前）
    var relativeDescription: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "今天"
        } else if calendar.isDateInYesterday(self) {
            return "昨天"
        } else {
            let days = calendar.dateComponents([.day], from: self, to: Date()).day ?? 0
            if days < 7 {
                return "\(days)天前"
            } else {
                return displayDate
            }
        }
    }
}
