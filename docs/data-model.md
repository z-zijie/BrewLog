# 数据模型

> BrewLog 数据结构设计

---

## 模型概览

```
┌─────────────────────────────────────────────────────────┐
│                      Models                              │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  SwiftData Models (@Model)                              │
│  ┌─────────────────────────────────────────────────┐   │
│  │                 BrewRecord                       │   │
│  │              (冲煮记录 - 核心模型)                │   │
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  值类型 (Codable Structs)                               │
│  ┌──────────────────┐  ┌──────────────────┐            │
│  │   BrewAnalysis   │  │  ComparisonData  │            │
│  │    (分析结果)     │  │    (对比数据)     │            │
│  └──────────────────┘  └──────────────────┘            │
│                                                          │
│  枚举 (String, Codable)                                 │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐          │
│  │ BrewMethod │ │ RoastLevel │ │ HeatLevel  │          │
│  │ (冲煮方式)  │ │ (烘焙程度)  │ │  (火力)    │          │
│  └────────────┘ └────────────┘ └────────────┘          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 枚举类型

### BrewMethod (冲煮方式)

```swift
enum BrewMethod: String, CaseIterable, Codable, Identifiable {
    case espresso = "意式浓缩"
    case pourOver = "手冲咖啡"
    case mokaPot = "摩卡壶"

    var id: String { rawValue }

    /// SF Symbol 图标名
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
        case .espresso: return .espresso
        case .pourOver: return .pourOver
        case .mokaPot: return .mokaPot
        }
    }
}
```

### RoastLevel (烘焙程度)

```swift
enum RoastLevel: String, CaseIterable, Codable, Identifiable {
    case light = "浅烘"
    case mediumLight = "中浅"
    case medium = "中烘"
    case mediumDark = "中深"
    case dark = "深烘"

    var id: String { rawValue }

    /// 推荐水温范围 (°C)
    var recommendedTempRange: ClosedRange<Double> {
        switch self {
        case .light: return 93...96
        case .mediumLight: return 91...95
        case .medium: return 90...94
        case .mediumDark: return 88...92
        case .dark: return 86...90
        }
    }
}
```

### HeatLevel (火力)

```swift
enum HeatLevel: String, CaseIterable, Codable, Identifiable {
    case low = "小火"
    case medium = "中火"
    case high = "大火"

    var id: String { rawValue }

    /// SF Symbol 图标名
    var iconName: String {
        switch self {
        case .low: return "flame"
        case .medium: return "flame.fill"
        case .high: return "flame.circle.fill"
        }
    }
}
```

---

## 核心模型

### BrewRecord

冲煮记录的核心数据模型，使用 SwiftData 持久化。

```swift
import Foundation
import SwiftData

@Model
final class BrewRecord {

    // MARK: - 基本信息

    @Attribute(.unique) var id: UUID
    var method: BrewMethod
    var date: Date

    // MARK: - 通用参数

    var grindSize: String           // 研磨度描述
    var coffeeBean: String          // 咖啡豆名称/品牌
    var roastLevel: RoastLevel      // 烘焙程度
    var roastDate: Date?            // 烘焙日期
    var rating: Int                 // 评分 (1-5)
    var notes: String               // 心得笔记

    // MARK: - 意式浓缩参数 (espresso)

    var espressoDose: Double?       // 粉量 (g)
    var espressoYield: Double?      // 萃取量 (ml)
    var espressoTime: Int?          // 萃取时间 (s)
    var espressoTemp: Double?       // 水温 (°C)
    var espressoPressure: Double?   // 压力 (bar)

    // MARK: - 手冲参数 (pourOver)

    var pourOverDose: Double?       // 粉量 (g)
    var pourOverWater: Double?      // 总水量 (ml)
    var pourOverTemp: Double?       // 水温 (°C)
    var pourOverBloomTime: Int?     // 闷蒸时间 (s)
    var pourOverTime: Int?          // 冲煮时间 (s)
    var pourOverPours: Int?         // 注水次数

    // MARK: - 摩卡壶参数 (mokaPot)

    var mokaDose: Double?           // 粉量 (g)
    var mokaWater: Double?          // 水量 (ml)
    var mokaHeat: HeatLevel?        // 火力
    var mokaTime: Int?              // 时间 (s)

    // MARK: - AI 分析结果 (JSON 存储)

    var analysisJSON: Data?
    var analyzedAt: Date?

    // MARK: - 计算属性

    /// 解析/设置分析结果
    var analysis: BrewAnalysis? {
        get {
            guard let data = analysisJSON else { return nil }
            return try? JSONDecoder().decode(BrewAnalysis.self, from: data)
        }
        set {
            analysisJSON = try? JSONEncoder().encode(newValue)
            analyzedAt = newValue != nil ? Date() : nil
        }
    }

    /// 参数摘要 (用于列表显示)
    var parameterSummary: String {
        switch method {
        case .espresso:
            let parts = [espressoDose, espressoYield, espressoTime]
                .compactMap { $0 }
                .map { "\($0)" }
            return parts.isEmpty ? "" : parts.joined(separator: " / ")
        case .pourOver:
            let parts = [pourOverDose, pourOverWater]
                .compactMap { $0 }
                .map { "\($0)" }
            return parts.isEmpty ? "" : parts.joined(separator: "g / ") + "ml"
        case .mokaPot:
            let parts = [mokaDose, mokaWater]
                .compactMap { $0 }
                .map { "\($0)" }
            return parts.isEmpty ? "" : parts.joined(separator: " / ")
        }
    }

    // MARK: - 初始化

    init(method: BrewMethod) {
        self.id = UUID()
        self.method = method
        self.date = Date()
        self.grindSize = ""
        self.coffeeBean = ""
        self.roastLevel = .medium
        self.rating = 3
        self.notes = ""
    }
}
```

---

## 分析结果模型

### BrewAnalysis

AI 分析结果，以 Codable struct 存储，通过 JSON 序列化存入 BrewRecord。

```swift
import Foundation

/// 冲煮分析结果
struct BrewAnalysis: Codable, Equatable {

    /// 综合评分 (0-100)
    let overallScore: Int

    /// 评分等级
    var scoreLevel: ScoreLevel {
        switch overallScore {
        case 85...100: return .excellent
        case 70...84: return .good
        case 55...69: return .fair
        default: return .needsWork
        }
    }

    /// 各参数评分
    let parameterScores: [ParameterScore]

    /// 改进建议
    let suggestions: [Suggestion]

    /// 风味预测
    let flavorProfile: FlavorProfile

    /// 对比数据 (可选)
    let comparison: ComparisonData?

    /// 分析时间
    let analyzedAt: Date
}

/// 评分等级
enum ScoreLevel: String, Codable {
    case excellent = "优秀"
    case good = "良好"
    case fair = "一般"
    case needsWork = "需改进"

    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .orange
        case .fair: return .yellow
        case .needsWork: return .red
        }
    }
}
```

### ParameterScore

单个参数的评分。

```swift
/// 参数评分
struct ParameterScore: Codable, Equatable, Identifiable {
    let id: UUID
    let name: String           // 参数名称
    let displayName: String    // 显示名称
    let value: String          // 实际值 (格式化后)
    let score: Int             // 评分 (0-100)
    let status: ScoreStatus

    init(id: UUID = UUID(), name: String, displayName: String,
         value: String, score: Int, status: ScoreStatus) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.value = value
        self.score = score
        self.status = status
    }
}

/// 评分状态
enum ScoreStatus: String, Codable {
    case excellent = "excellent"   // 85-100
    case good = "good"             // 70-84
    case needsWork = "needsWork"   // 0-69

    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .orange
        case .needsWork: return .red
        }
    }
}
```

### Suggestion

改进建议。

```swift
/// 改进建议
struct Suggestion: Codable, Equatable, Identifiable {
    let id: UUID
    let title: String          // 建议标题
    let description: String    // 详细说明
    let priority: Priority     // 优先级
    let relatedParameter: String?  // 关联的参数名

    init(id: UUID = UUID(), title: String, description: String,
         priority: Priority, relatedParameter: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.relatedParameter = relatedParameter
    }
}

/// 建议优先级
enum Priority: String, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
}
```

### FlavorProfile

风味预测。

```swift
/// 风味轮廓
struct FlavorProfile: Codable, Equatable {
    let acidity: FlavorLevel      // 酸度
    let sweetness: FlavorLevel    // 甜度
    let bitterness: FlavorLevel   // 苦味
    let body: FlavorLevel         // 醇厚度

    /// 转换为数组 (用于图表展示)
    var asArray: [(name: String, level: FlavorLevel)] {
        [
            ("酸", acidity),
            ("甜", sweetness),
            ("苦", bitterness),
            ("醇", body)
        ]
    }
}

/// 风味强度等级
enum FlavorLevel: Int, Codable, CaseIterable {
    case low = 1          // 偏低
    case mediumLow = 2    // 中偏低
    case medium = 3       // 中等
    case mediumHigh = 4   // 中偏高
    case high = 5         // 明亮/强烈

    var displayText: String {
        switch self {
        case .low: return "偏低"
        case .mediumLow: return "中偏低"
        case .medium: return "中等"
        case .mediumHigh: return "中偏高"
        case .high: return "明亮"
        }
    }
}
```

### ComparisonData

历史对比数据。

```swift
/// 对比数据
struct ComparisonData: Codable, Equatable {
    let userAverageScore: Int     // 用户平均分
    let userBestScore: Int        // 用户最佳分
    let totalRecords: Int         // 记录总数

    /// 与平均分对比
    var vsAverage: Int {
        // 当前记录分 - 平均分 (由外部计算时传入)
        // 这里存储的是参考数据
        return 0 // 占位，实际由分析引擎计算
    }
}
```

### QuickInsight

快速洞察 (用于保存后弹窗)。

```swift
/// 快速洞察
struct QuickInsight: Codable, Equatable {
    let summary: String              // 一句话摘要
    let topSuggestion: String?       // 最重要的建议
    let overallScore: Int            // 综合评分
    let scoreLevel: ScoreLevel       // 评分等级
}
```

---

## 模型关系图

```
┌─────────────────────────────────────────────────────────────┐
│                        BrewRecord                            │
│                     (@Model, SwiftData)                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  id: UUID                                                    │
│  method: BrewMethod ──────────────────┐                     │
│  date: Date                            │                     │
│  ...                                   │                     │
│                                        │                     │
│  analysisJSON: Data?                   │                     │
│       │                                │                     │
│       │ JSON Encode/Decode             │                     │
│       ▼                                │                     │
│  ┌─────────────────┐                   │                     │
│  │  BrewAnalysis   │                   │                     │
│  │  (Codable)      │                   │                     │
│  ├─────────────────┤                   │                     │
│  │ overallScore    │                   │                     │
│  │ parameterScores │──> [ParameterScore]                    │
│  │ suggestions     │──> [Suggestion]                        │
│  │ flavorProfile   │──> FlavorProfile                       │
│  │ comparison      │──> ComparisonData?                     │
│  └─────────────────┘                   │                     │
│                                        │                     │
└────────────────────────────────────────┼─────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────┐
│                       枚举类型                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  BrewMethod          RoastLevel         HeatLevel           │
│  ├── espresso        ├── light          ├── low             │
│  ├── pourOver        ├── mediumLight    ├── medium          │
│  └── mokaPot         ├── medium         └── high            │
│                      ├── mediumDark                          │
│                      └── dark                                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 存储策略

### SwiftData 存储

| 数据 | 存储方式 | 说明 |
|------|----------|------|
| BrewRecord | SwiftData | 核心数据，自动持久化 |
| 枚举值 | Raw Value | 以 String 存储 |

### JSON 存储

| 数据 | 存储位置 | 说明 |
|------|----------|------|
| BrewAnalysis | BrewRecord.analysisJSON | 复杂结构，JSON 序列化 |
| 参数历史 | UserDefaults | @AppStorage |

### 不存储的数据

| 数据 | 原因 |
|------|------|
| QuickInsight | 从 BrewAnalysis 实时计算 |
| ScoreLevel | 从 overallScore 实时计算 |

---

## 数据迁移

### 版本迁移策略

```swift
// 未来如需修改模型，使用 VersionedSchema
// V1: 初始版本
// V2: 添加 analysisJSON 字段
// V3: 添加新字段...

// 当前使用默认迁移
.modelContainer(for: BrewRecord.self)
```

---

## 查询示例

### 基础查询

```swift
// 查询所有记录，按日期倒序
@Query(sort: \BrewRecord.date, order: .reverse)
private var records: [BrewRecord]

// 筛选特定方式
var espressoRecords: [BrewRecord] {
    records.filter { $0.method == .espresso }
}

// 筛选高评分记录
var highRatedRecords: [BrewRecord] {
    records.filter { $0.rating >= 4 }
}
```

### 统计查询

```swift
// 获取所有意式浓缩记录
func fetchEspressoRecords(context: ModelContext) -> [BrewRecord] {
    let descriptor = FetchDescriptor<BrewRecord>(
        predicate: #Predicate { $0.method == .espresso }
    )
    return try? context.fetch(descriptor) ?? []
}

// 计算平均评分
func averageRating(records: [BrewRecord]) -> Double {
    guard !records.isEmpty else { return 0 }
    return Double(records.reduce(0) { $0 + $1.rating }) / Double(records.count)
}
```

---

*文档版本: 2.0*
*最后更新: 2025-02-21*
