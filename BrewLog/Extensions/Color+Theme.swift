//
//  Color+Theme.swift
//  BrewLog
//
//  咖啡主题颜色扩展
//  注意：Asset Catalog 中的颜色会自动生成 Color 扩展
//  此文件仅保留语义化别名和文档用途
//

import SwiftUI

// MARK: - 基础主题色别名
// Asset Catalog 会自动生成 Color.coffee, Color.coffeeLight, Color.cream 等
// 这里提供额外的文档说明

/*
 颜色定义在 Assets.xcassets 中：

 | 颜色名 | 用途 | 浅色模式 | 深色模式 |
 |--------|------|----------|----------|
 | Coffee | 主色 | #6F4E37 | #C68B59 |
 | CoffeeLight | 浅色主色 | #C68B59 | #D4A574 |
 | Cream | 背景色 | #FAF8F5 | #1C1C1E |
 | StarFill | 星星填充 | #FFD700 | #FFD700 |
 | RoastLight | 浅烘 | #C2996B | #D4A574 |
 | RoastMediumLight | 中浅烘 | #A67D5B | #B8916A |
 | RoastMedium | 中烘 | #8B5A2B | #A67D5B |
 | RoastMediumDark | 中深烘 | #6B4423 | #8B5A2B |
 | RoastDark | 深烘 | #4A2C17 | #6B4423 |

 使用方式：
 - Color.coffee
 - Color.starFill
 - Color.roastLight
 等
 */
