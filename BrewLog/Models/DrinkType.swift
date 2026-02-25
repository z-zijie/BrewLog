//
//  DrinkType.swift
//  BrewLog
//

import Foundation

/// 饮品类型枚举
enum DrinkType: String, Codable, CaseIterable, Identifiable {
    // 黑咖
    case espresso = "浓缩"
    case americano = "美式"
    case pourOver = "手冲"
    case moka = "摩卡壶"

    // 奶咖
    case latte = "拿铁"
    case cappuccino = "卡布奇诺"
    case flatWhite = "Flat White"
    case cortado = "Cortado"
    case macchiato = "玛奇朵"
    case mocha = "摩卡"

    // 其他
    case iced = "冰咖啡"
    case custom = "自定义"

    var id: String { rawValue }

    /// 是否为奶咖饮品
    var isMilkDrink: Bool {
        [.latte, .cappuccino, .flatWhite, .cortado, .macchiato, .mocha].contains(self)
    }

    /// 是否需要显示冰块选项
    var supportsIced: Bool {
        true // 所有饮品都可以做冰的
    }
}
