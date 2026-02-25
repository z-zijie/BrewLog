//
//  BrewRecord.swift
//  BrewLog
//

import Foundation
import SwiftData

/// 冲煮记录数据模型
@Model
final class BrewRecord {
    // MARK: - 基础信息
    var id: UUID
    var method: BrewMethod
    var date: Date
    var rating: Int // 1-5
    var notes: String

    // MARK: - 咖啡豆信息
    var coffeeBean: String // 咖啡豆名称
    var roastLevel: RoastLevel
    var roastDate: Date?
    var grindSize: Double? // 研磨度 (0-12)

    // MARK: - Espresso 参数
    var espressoDose: Double? // 粉量 (g)
    var espressoYield: Double? // 液重 (g)
    var espressoTime: Int? // 萃取时间 (秒)
    var espressoTemp: Double? // 水温 (°C)
    var espressoPressure: Double? // 压力 (bar)

    // MARK: - Pour Over 参数
    var pourOverDose: Double? // 粉量 (g)
    var pourOverWater: Double? // 注水量 (g)
    var pourOverTemp: Double? // 水温 (°C)
    var pourOverBloomTime: Int? // 闷蒸时间 (秒)
    var pourOverTime: Int? // 总时间 (秒)
    var pourOverPours: Int? // 注水次数

    // MARK: - Moka Pot 参数
    var mokaDose: Double? // 粉量 (g)
    var mokaWater: Double? // 水量 (ml)
    var mokaHeat: HeatLevel? // 火力
    var mokaTime: Int? // 时间 (秒)

    // MARK: - 后处理参数
    var drinkType: DrinkType? // 饮品类型
    var milkType: MilkType? // 牛奶类型
    var milkAmount: Int? // 牛奶量 (ml)
    var isIced: Bool = false // 是否冰饮

    // MARK: - AI 分析结果
    var analysisJSON: String?
    var analyzedAt: Date?

    // MARK: - 初始化
    init(
        method: BrewMethod,
        date: Date = Date(),
        rating: Int = 0,
        notes: String = "",
        coffeeBean: String = "",
        roastLevel: RoastLevel = .medium,
        roastDate: Date? = nil,
        grindSize: Double? = nil
    ) {
        self.id = UUID()
        self.method = method
        self.date = date
        self.rating = rating
        self.notes = notes
        self.coffeeBean = coffeeBean
        self.roastLevel = roastLevel
        self.roastDate = roastDate
        self.grindSize = grindSize
    }
}

// MARK: - 参数摘要
extension BrewRecord {
    /// 获取参数摘要文本
    var parameterSummary: String {
        switch method {
        case .espresso:
            let parts: [String] = [
                espressoDose.map { "\($0)g" },
                espressoYield.map { "\($0)g out" },
                espressoTime.map { "\($0)s" }
            ].compactMap { $0 }
            return parts.isEmpty ? "未记录参数" : parts.joined(separator: " · ")

        case .pourOver:
            let parts: [String] = [
                pourOverDose.map { "\($0)g" },
                pourOverWater.map { "\($0)ml" },
                pourOverTime.map { "\($0)s" }
            ].compactMap { $0 }
            return parts.isEmpty ? "未记录参数" : parts.joined(separator: " · ")

        case .mokaPot:
            let parts: [String] = [
                mokaDose.map { "\($0)g" },
                mokaWater.map { "\($0)ml" },
                mokaHeat?.displayName
            ].compactMap { $0 }
            return parts.isEmpty ? "未记录参数" : parts.joined(separator: " · ")
        }
    }
}
