# 服务层设计

> BrewLog 业务逻辑层设计

---

## 概述

服务层负责处理业务逻辑，位于 Views 和 Models 之间。主要职责：

- 参数分析计算
- 用户偏好管理
- 数据导入导出
- 业务规则封装

---

## 服务架构

```
┌─────────────────────────────────────────────────────────────┐
│                         Views                                │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                        Services                              │
│                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │  BrewAnalyzer   │  │ UserPreferences │                  │
│  │  (参数分析)      │  │  (用户偏好)      │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │  DataExporter   │  │  RecordStats    │                  │
│  │  (数据导出)      │  │  (记录统计)      │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                              │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                         Models                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 1. BrewAnalyzer (参数分析服务)

### 职责

- 根据冲煮参数计算评分
- 生成改进建议
- 预测风味轮廓
- 对比历史记录

### 接口定义

```swift
// Services/BrewAnalyzer.swift

/// 分析服务协议 (支持未来云端实现替换)
protocol BrewAnalyzing {
    /// 完整分析
    func analyze(_ record: BrewRecord, history: [BrewRecord]?) -> BrewAnalysis

    /// 快速洞察 (用于保存后弹窗)
    func quickInsight(_ record: BrewRecord) -> QuickInsight

    /// 重新分析
    func reanalyze(_ record: BrewRecord, history: [BrewRecord]?) -> BrewAnalysis
}

/// 本地分析引擎
final class BrewAnalyzer: BrewAnalyzing {

    // MARK: - 单例

    static let shared = BrewAnalyzer()

    private init() {}

    // MARK: - 公开方法

    func analyze(_ record: BrewRecord, history: [BrewRecord]? = nil) -> BrewAnalysis {
        let scores = calculateParameterScores(record)
        let overallScore = calculateOverallScore(scores)
        let suggestions = generateSuggestions(record, scores)
        let flavor = predictFlavor(record)
        let comparison = calculateComparison(record, history: history)

        return BrewAnalysis(
            overallScore: overallScore,
            parameterScores: scores,
            suggestions: suggestions,
            flavorProfile: flavor,
            comparison: comparison,
            analyzedAt: Date()
        )
    }

    func quickInsight(_ record: BrewRecord) -> QuickInsight {
        let analysis = analyze(record)

        let summary: String
        switch analysis.scoreLevel {
        case .excellent:
            summary = "参数组合很棒！继续保持"
        case .good:
            summary = "整体不错，还有些提升空间"
        case .fair:
            summary = "参数有改进空间"
        case .needsWork:
            summary = "建议调整参数以获得更好口感"
        }

        return QuickInsight(
            summary: summary,
            topSuggestion: analysis.suggestions.first?.description,
            overallScore: analysis.overallScore,
            scoreLevel: analysis.scoreLevel
        )
    }

    func reanalyze(_ record: BrewRecord, history: [BrewRecord]?) -> BrewAnalysis {
        return analyze(record, history: history)
    }

    // MARK: - 私有方法 (详见分析规则部分)
}
```

### 分析规则

#### 意式浓缩规则

```swift
extension BrewAnalyzer {

    // MARK: - 意式浓缩分析

    func analyzeEspresso(_ record: BrewRecord) -> [ParameterScore] {
        var scores: [ParameterScore] = []

        // 1. 萃取比例 (粉量:萃取量)
        if let dose = record.espressoDose, let yield = record.espressoYield {
            let ratio = yield / dose
            scores.append(scoreExtractionRatio(ratio, dose: dose, yield: yield))
        }

        // 2. 萃取时间
        if let time = record.espressoTime {
            scores.append(scoreExtractionTime(time))
        }

        // 3. 水温
        if let temp = record.espressoTemp {
            scores.append(scoreTemperature(temp, roastLevel: record.roastLevel))
        }

        // 4. 压力
        if let pressure = record.espressoPressure {
            scores.append(scorePressure(pressure))
        }

        return scores
    }

    /// 评分: 萃取比例 (理想 1:1.5 ~ 1:2.5)
    private func scoreExtractionRatio(_ ratio: Double, dose: Double, yield: Double) -> ParameterScore {
        let score: Int
        let status: ScoreStatus

        switch ratio {
        case 1.8...2.2:
            score = 100
            status = .excellent
        case 1.5...1.8, 2.2...2.5:
            score = 85
            status = .good
        case 1.3...1.5, 2.5...3.0:
            score = 70
            status = .good
        default:
            score = 50
            status = .needsWork
        }

        return ParameterScore(
            name: "extractionRatio",
            displayName: "萃取比例",
            value: String(format: "1:%.1f", ratio),
            score: score,
            status: status
        )
    }

    /// 评分: 萃取时间 (理想 25-30s)
    private func scoreExtractionTime(_ time: Int) -> ParameterScore {
        let score: Int
        let status: ScoreStatus

        switch time {
        case 25...30:
            score = 100
            status = .excellent
        case 22...24, 31...33:
            score = 80
            status = .good
        case 18...21, 34...40:
            score = 60
            status = .needsWork
        default:
            score = 40
            status = .needsWork
        }

        return ParameterScore(
            name: "extractionTime",
            displayName: "萃取时间",
            value: "\(time)s",
            score: score,
            status: status
        )
    }

    /// 评分: 水温 (根据烘焙度调整理想范围)
    private func scoreTemperature(_ temp: Double, roastLevel: RoastLevel) -> ParameterScore {
        let range = roastLevel.recommendedTempRange
        let score: Int
        let status: ScoreStatus

        if range.contains(temp) {
            score = 100
            status = .excellent
        } else if temp >= range.lowerBound - 2 && temp <= range.upperBound + 2 {
            score = 80
            status = .good
        } else {
            score = 50
            status = .needsWork
        }

        return ParameterScore(
            name: "temperature",
            displayName: "水温",
            value: String(format: "%.0f°C", temp),
            score: score,
            status: status
        )
    }

    /// 评分: 压力 (理想 8-9 bar)
    private func scorePressure(_ pressure: Double) -> ParameterScore {
        let score: Int
        let status: ScoreStatus

        switch pressure {
        case 8...9:
            score = 100
            status = .excellent
        case 7...8, 9...10:
            score = 85
            status = .good
        case 6...7, 10...11:
            score = 60
            status = .needsWork
        default:
            score = 40
            status = .needsWork
        }

        return ParameterScore(
            name: "pressure",
            displayName: "压力",
            value: String(format: "%.0f bar", pressure),
            score: score,
            status: status
        )
    }
}
```

#### 手冲规则

```swift
extension BrewAnalyzer {

    // MARK: - 手冲分析

    func analyzePourOver(_ record: BrewRecord) -> [ParameterScore] {
        var scores: [ParameterScore] = []

        // 1. 粉水比
        if let dose = record.pourOverDose, let water = record.pourOverWater {
            let ratio = water / dose
            scores.append(scorePourOverRatio(ratio, dose: dose, water: water))
        }

        // 2. 萃取时间
        if let time = record.pourOverTime {
            scores.append(scorePourOverTime(time, dose: record.pourOverDose))
        }

        // 3. 水温
        if let temp = record.pourOverTemp {
            scores.append(scoreTemperature(temp, roastLevel: record.roastLevel))
        }

        // 4. 闷蒸时间
        if let bloomTime = record.pourOverBloomTime {
            scores.append(scoreBloomTime(bloomTime))
        }

        return scores
    }

    /// 评分: 粉水比 (理想 1:14 ~ 1:17)
    private func scorePourOverRatio(_ ratio: Double, dose: Double, water: Double) -> ParameterScore {
        let score: Int
        let status: ScoreStatus

        switch ratio {
        case 14...17:
            score = 100
            status = .excellent
        case 13...14, 17...18:
            score = 85
            status = .good
        case 12...13, 18...20:
            score = 70
            status = .good
        default:
            score = 50
            status = .needsWork
        }

        return ParameterScore(
            name: "waterRatio",
            displayName: "粉水比",
            value: String(format: "1:%.0f", ratio),
            score: score,
            status: status
        )
    }

    /// 评分: 手冲时间 (根据粉量调整)
    private func scorePourOverTime(_ time: Int, dose: Double?) -> ParameterScore {
        let idealRange: ClosedRange<Int>

        switch dose {
        case ..<15:
            idealRange = 90...150      // 1:30 - 2:30
        case 15...18:
            idealRange = 120...180     // 2:00 - 3:00
        case 18...:
            idealRange = 150...210     // 2:30 - 3:30
        default:
            idealRange = 120...180
        }

        let score: Int
        let status: ScoreStatus

        if idealRange.contains(time) {
            score = 100
            status = .excellent
        } else if time >= idealRange.lowerBound - 15 && time <= idealRange.upperBound + 15 {
            score = 80
            status = .good
        } else {
            score = 60
            status = .needsWork
        }

        return ParameterScore(
            name: "brewTime",
            displayName: "冲煮时间",
            value: formatTime(time),
            score: score,
            status: status
        )
    }

    /// 评分: 闷蒸时间 (理想 20-45s)
    private func scoreBloomTime(_ time: Int) -> ParameterScore {
        let score: Int
        let status: ScoreStatus

        switch time {
        case 20...45:
            score = 100
            status = .excellent
        case 15...20, 45...60:
            score = 80
            status = .good
        default:
            score = 60
            status = .needsWork
        }

        return ParameterScore(
            name: "bloomTime",
            displayName: "闷蒸时间",
            value: "\(time)s",
            score: score,
            status: status
        )
    }
}
```

#### 摩卡壶规则

```swift
extension BrewAnalyzer {

    // MARK: - 摩卡壶分析

    func analyzeMokaPot(_ record: BrewRecord) -> [ParameterScore] {
        var scores: [ParameterScore] = []

        // 1. 粉水比
        if let dose = record.mokaDose, let water = record.mokaWater {
            let ratio = water / dose
            scores.append(scoreMokaRatio(ratio))
        }

        // 2. 火力
        if let heat = record.mokaHeat {
            scores.append(scoreHeatLevel(heat))
        }

        // 3. 时间
        if let time = record.mokaTime {
            scores.append(scoreMokaTime(time))
        }

        return scores
    }

    /// 评分: 摩卡壶粉水比 (理想 1:8 ~ 1:12)
    private func scoreMokaRatio(_ ratio: Double) -> ParameterScore {
        let score: Int
        let status: ScoreStatus

        switch ratio {
        case 8...12:
            score = 100
            status = .excellent
        case 6...8, 12...15:
            score = 80
            status = .good
        default:
            score = 60
            status = .needsWork
        }

        return ParameterScore(
            name: "waterRatio",
            displayName: "粉水比",
            value: String(format: "1:%.0f", ratio),
            score: score,
            status: status
        )
    }

    /// 评分: 火力 (小/中火最佳)
    private func scoreHeatLevel(_ heat: HeatLevel) -> ParameterScore {
        let (score, status): (Int, ScoreStatus) = switch heat {
        case .low:
            (100, .excellent)
        case .medium:
            (80, .good)
        case .high:
            (50, .needsWork)
        }

        return ParameterScore(
            name: "heatLevel",
            displayName: "火力",
            value: heat.rawValue,
            score: score,
            status: status
        )
    }

    /// 评分: 摩卡壶时间 (理想 3-5 分钟)
    private func scoreMokaTime(_ time: Int) -> ParameterScore {
        let score: Int
        let status: ScoreStatus

        switch time {
        case 180...300:  // 3:00 - 5:00
            score = 100
            status = .excellent
        case 150...180, 300...360:
            score = 80
            status = .good
        default:
            score = 60
            status = .needsWork
        }

        return ParameterScore(
            name: "brewTime",
            displayName: "萃取时间",
            value: formatTime(time),
            score: score,
            status: status
        )
    }
}
```

### 建议生成

```swift
extension BrewAnalyzer {

    // MARK: - 建议生成

    func generateSuggestions(_ record: BrewRecord, _ scores: [ParameterScore]) -> [Suggestion] {
        var suggestions: [Suggestion] = []

        // 遍历低分项，生成针对性建议
        for score in scores where score.status == .needsWork {
            if let suggestion = suggestionForParameter(score, record: record) {
                suggestions.append(suggestion)
            }
        }

        // 补充优化建议 (针对 good 状态的参数)
        for score in scores where score.status == .good {
            if let suggestion = optimizationSuggestion(score, record: record) {
                suggestions.append(suggestion)
            }
        }

        // 按优先级排序，最多返回 3 条
        return suggestions.sorted { $0.priority.rawValue > $1.priority.rawValue }
                          .prefix(3)
                          .map { $0 }
    }

    private func suggestionForParameter(_ score: ParameterScore, record: BrewRecord) -> Suggestion? {
        switch score.name {
        case "extractionRatio":
            return extractionRatioSuggestion(record)
        case "extractionTime":
            return extractionTimeSuggestion(record)
        case "temperature":
            return temperatureSuggestion(record)
        case "pressure":
            return Suggestion(
                title: "调整压力",
                description: "建议将压力调整到 8-9 bar 范围",
                priority: .high,
                relatedParameter: "pressure"
            )
        case "waterRatio":
            return waterRatioSuggestion(record)
        case "bloomTime":
            return Suggestion(
                title: "优化闷蒸",
                description: "建议闷蒸时间控制在 20-45 秒",
                priority: .medium,
                relatedParameter: "bloomTime"
            )
        case "heatLevel":
            return Suggestion(
                title: "降低火力",
                description: "大火容易导致过度萃取和焦苦味，建议使用小火",
                priority: .high,
                relatedParameter: "heatLevel"
            )
        default:
            return nil
        }
    }

    private func extractionRatioSuggestion(_ record: BrewRecord) -> Suggestion? {
        guard let dose = record.espressoDose, let yield = record.espressoYield else { return nil }
        let ratio = yield / dose

        if ratio < 1.5 {
            return Suggestion(
                title: "增加萃取量",
                description: "萃取比例偏低 (\(String(format: "1:%.1f", ratio)))，建议增加到 1:2.0 左右",
                priority: .high,
                relatedParameter: "extractionRatio"
            )
        } else if ratio > 2.5 {
            return Suggestion(
                title: "减少萃取量",
                description: "萃取比例偏高 (\(String(format: "1:%.1f", ratio)))，可能导致口感稀薄",
                priority: .high,
                relatedParameter: "extractionRatio"
            )
        }
        return nil
    }

    // ... 其他建议生成方法
}
```

### 风味预测

```swift
extension BrewAnalyzer {

    // MARK: - 风味预测

    func predictFlavor(_ record: BrewRecord) -> FlavorProfile {
        // 基于烘焙度的基准
        var acidity: FlavorLevel = .medium
        var sweetness: FlavorLevel = .medium
        var bitterness: FlavorLevel = .medium
        var body: FlavorLevel = .medium

        // 根据烘焙度调整
        switch record.roastLevel {
        case .light:
            acidity = .high
            sweetness = .mediumLow
            bitterness = .low
            body = .mediumLow
        case .mediumLight:
            acidity = .mediumHigh
            sweetness = .medium
            bitterness = .mediumLow
            body = .medium
        case .medium:
            acidity = .medium
            sweetness = .medium
            bitterness = .medium
            body = .medium
        case .mediumDark:
            acidity = .mediumLow
            sweetness = .mediumLow
            bitterness = .mediumHigh
            body = .mediumHigh
        case .dark:
            acidity = .low
            sweetness = .low
            bitterness = .high
            body = .high
        }

        // 根据萃取程度微调
        let extractionScore = calculateExtractionLevel(record)

        if extractionScore > 1.1 {  // 过度萃取
            bitterness = increment(bitterness)
            acidity = decrement(acidity)
            sweetness = decrement(sweetness)
        } else if extractionScore < 0.9 {  // 萃取不足
            acidity = increment(acidity)
            sweetness = decrement(sweetness)
        }

        return FlavorProfile(
            acidity: acidity,
            sweetness: sweetness,
            bitterness: bitterness,
            body: body
        )
    }

    private func calculateExtractionLevel(_ record: BrewRecord) -> Double {
        // 简化的萃取程度计算
        // 返回 >1.0 表示过度萃取，<1.0 表示萃取不足
        switch record.method {
        case .espresso:
            return calculateEspressoExtraction(record)
        case .pourOver:
            return calculatePourOverExtraction(record)
        case .mokaPot:
            return calculateMokaExtraction(record)
        }
    }

    private func increment(_ level: FlavorLevel) -> FlavorLevel {
        FlavorLevel(rawValue: min(level.rawValue + 1, 5)) ?? level
    }

    private func decrement(_ level: FlavorLevel) -> FlavorLevel {
        FlavorLevel(rawValue: max(level.rawValue - 1, 1)) ?? level
    }
}
```

---

## 2. UserPreferences (用户偏好服务)

### 职责

- 管理用户设置
- 记住上次使用的参数
- 存储分析开关

### 实现

```swift
// Services/UserPreferences.swift

import SwiftUI

/// 用户偏好管理
final class UserPreferences: ObservableObject {

    // MARK: - 单例

    static let shared = UserPreferences()

    // MARK: - 分析设置

    @AppStorage("analysisEnabled")
    var analysisEnabled: Bool = true

    @AppStorage("showAnalysisAfterSave")
    var showAnalysisAfterSave: Bool = true

    // MARK: - 默认值

    @AppStorage("defaultMethod")
    var defaultMethodRaw: String = BrewMethod.pourOver.rawValue

    var defaultMethod: BrewMethod {
        get { BrewMethod(rawValue: defaultMethodRaw) ?? .pourOver }
        set { defaultMethodRaw = newValue.rawValue }
    }

    // MARK: - 上次使用的参数

    // 意式浓缩
    @AppStorage("lastEspressoDose") var lastEspressoDose: Double = 18.0
    @AppStorage("lastEspressoYield") var lastEspressoYield: Double = 36.0
    @AppStorage("lastEspressoTemp") var lastEspressoTemp: Double = 93.0
    @AppStorage("lastEspressoTime") var lastEspressoTime: Int = 27

    // 手冲
    @AppStorage("lastPourOverDose") var lastPourOverDose: Double = 15.0
    @AppStorage("lastPourOverWater") var lastPourOverWater: Double = 225.0
    @AppStorage("lastPourOverTemp") var lastPourOverTemp: Double = 91.0
    @AppStorage("lastPourOverBloomTime") var lastPourOverBloomTime: Int = 30

    // 摩卡壶
    @AppStorage("lastMokaDose") var lastMokaDose: Double = 20.0
    @AppStorage("lastMokaWater") var lastMokaWater: Double = 200.0

    // MARK: - 方法

    /// 保存记录参数为默认值
    func saveAsDefaults(_ record: BrewRecord) {
        switch record.method {
        case .espresso:
            if let dose = record.espressoDose { lastEspressoDose = dose }
            if let yield = record.espressoYield { lastEspressoYield = yield }
            if let temp = record.espressoTemp { lastEspressoTemp = temp }
            if let time = record.espressoTime { lastEspressoTime = time }
        case .pourOver:
            if let dose = record.pourOverDose { lastPourOverDose = dose }
            if let water = record.pourOverWater { lastPourOverWater = water }
            if let temp = record.pourOverTemp { lastPourOverTemp = temp }
            if let bloom = record.pourOverBloomTime { lastPourOverBloomTime = bloom }
        case .mokaPot:
            if let dose = record.mokaDose { lastMokaDose = dose }
            if let water = record.mokaWater { lastMokaWater = water }
        }
    }

    /// 应用默认参数到记录
    func applyDefaults(to record: BrewRecord) {
        switch record.method {
        case .espresso:
            record.espressoDose = lastEspressoDose
            record.espressoYield = lastEspressoYield
            record.espressoTemp = lastEspressoTemp
            record.espressoTime = lastEspressoTime
        case .pourOver:
            record.pourOverDose = lastPourOverDose
            record.pourOverWater = lastPourOverWater
            record.pourOverTemp = lastPourOverTemp
            record.pourOverBloomTime = lastPourOverBloomTime
        case .mokaPot:
            record.mokaDose = lastMokaDose
            record.mokaWater = lastMokaWater
        }
    }
}
```

---

## 3. DataExporter (数据导出服务)

### 职责

- 导出 CSV
- 导出 JSON
- 分享数据

### 接口

```swift
// Services/DataExporter.swift

protocol DataExporting {
    func exportToCSV(_ records: [BrewRecord]) -> URL?
    func exportToJSON(_ records: [BrewRecord]) -> URL?
}

final class DataExporter: DataExporting {

    static let shared = DataExporter()

    func exportToCSV(_ records: [BrewRecord]) -> URL? {
        // 实现 CSV 导出
        let csv = CSVBuilder()
        csv.addHeader([...])

        for record in records {
            csv.addRow([...])
        }

        return csv.saveToTempFile()
    }

    func exportToJSON(_ records: [BrewRecord]) -> URL? {
        // 实现 JSON 导出
        let data = try? JSONEncoder().encode(records)
        // 保存到临时文件
        // ...
    }
}
```

---

## 4. RecordStats (记录统计服务)

### 职责

- 计算统计数据
- 生成报告

### 接口

```swift
// Services/RecordStats.swift

struct RecordStatistics {
    let totalRecords: Int
    let averageRating: Double
    let methodDistribution: [BrewMethod: Int]
    let topCoffeeBeans: [(String, Int)]
    let averageScore: Double?
}

final class RecordStats {

    static let shared = RecordStats()

    func calculate(from records: [BrewRecord]) -> RecordStatistics {
        // 计算统计数据
        // ...
    }
}
```

---

## 依赖注入

### 环境对象方式

```swift
// App 入口注册
@main
struct BrewLogApp: App {
    @StateObject private var preferences = UserPreferences.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(preferences)
        }
    }
}

// View 中使用
struct NewRecordView: View {
    @EnvironmentObject var preferences: UserPreferences

    var body: some View {
        // 使用 preferences
    }
}
```

### 单例方式

```swift
// 直接使用单例
let analysis = BrewAnalyzer.shared.analyze(record)
```

---

*文档版本: 1.0*
*最后更新: 2025-02-21*
