//
//  MilkType.swift
//  BrewLog
//

import Foundation

/// 牛奶类型枚举
enum MilkType: String, Codable, CaseIterable, Identifiable {
    case whole = "全脂牛奶"
    case skim = "脱脂牛奶"
    case oat = "燕麦奶"
    case almond = "杏仁奶"
    case soy = "豆奶"
    case coconut = "椰奶"

    var id: String { rawValue }
}
