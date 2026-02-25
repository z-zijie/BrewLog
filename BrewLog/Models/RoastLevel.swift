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

    /// 颜色表示（使用 Asset Catalog，自动适配深浅模式）
    var color: Color {
        switch self {
        case .light: return .roastLight
        case .mediumLight: return .roastMediumLight
        case .medium: return .roastMedium
        case .mediumDark: return .roastMediumDark
        case .dark: return .roastDark
        }
    }
}
