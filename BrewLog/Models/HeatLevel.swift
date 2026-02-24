//
//  HeatLevel.swift
//  BrewLog
//

import SwiftUI

/// 火力大小（摩卡壶用）
enum HeatLevel: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }

    /// 中文显示名称
    var displayName: String {
        switch self {
        case .low: return "小火"
        case .medium: return "中火"
        case .high: return "大火"
        }
    }

    /// SF Symbol 图标
    var iconName: String {
        switch self {
        case .low: return "flame"
        case .medium: return "flame.fill"
        case .high: return "flame.circle.fill"
        }
    }

    /// 颜色
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}
