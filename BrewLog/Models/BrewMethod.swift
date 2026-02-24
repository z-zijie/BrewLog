//
//  BrewMethod.swift
//  BrewLog
//

import SwiftUI

/// 冲煮方式
enum BrewMethod: String, Codable, CaseIterable, Identifiable {
    case espresso = "Espresso"
    case pourOver = "Pour Over"
    case mokaPot = "Moka Pot"

    var id: String { rawValue }

    /// 中文显示名称
    var displayName: String {
        switch self {
        case .espresso: return "意式浓缩"
        case .pourOver: return "手冲咖啡"
        case .mokaPot: return "摩卡壶"
        }
    }

    /// SF Symbol 图标名称
    var iconName: String {
        switch self {
        case .espresso: return "cup.and.saucer.fill"
        case .pourOver: return "drop.fill"
        case .mokaPot: return "flame.fill"
        }
    }

    /// 主题色
    var themeColor: Color {
        switch self {
        case .espresso: return .coffee
        case .pourOver: return .coffeeLight
        case .mokaPot: return .brown
        }
    }

    /// 别名
    var color: Color { themeColor }
}
