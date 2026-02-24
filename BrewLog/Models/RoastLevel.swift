//
//  RoastLevel.swift
//  BrewLog
//

import SwiftUI

/// 烘焙程度
enum RoastLevel: String, Codable, CaseIterable, Identifiable {
    case light = "Light"
    case mediumLight = "Medium Light"
    case medium = "Medium"
    case mediumDark = "Medium Dark"
    case dark = "Dark"

    var id: String { rawValue }

    /// 中文显示名称
    var displayName: String {
        switch self {
        case .light: return "浅烘"
        case .mediumLight: return "中浅烘"
        case .medium: return "中烘"
        case .mediumDark: return "中深烘"
        case .dark: return "深烘"
        }
    }

    /// 推荐萃取温度范围 (°C)
    var recommendedTempRange: ClosedRange<Int> {
        switch self {
        case .light: return 90...95
        case .mediumLight: return 88...93
        case .medium: return 86...91
        case .mediumDark: return 84...89
        case .dark: return 82...87
        }
    }

    /// 颜色表示
    var color: Color {
        switch self {
        case .light: return Color(red: 0.76, green: 0.60, blue: 0.42)
        case .mediumLight: return Color(red: 0.65, green: 0.49, blue: 0.35)
        case .medium: return Color(red: 0.55, green: 0.40, blue: 0.28)
        case .mediumDark: return Color(red: 0.45, green: 0.32, blue: 0.22)
        case .dark: return Color(red: 0.30, green: 0.20, blue: 0.15)
        }
    }
}
