# AI 分析功能设计

> 智能分析冲泡参数，提供改进建议与风味预测

---

## 功能概述

### 核心价值

帮助用户理解冲泡参数与咖啡品质的关系，通过智能分析：
- 评估参数组合的合理性
- 提供具体的改进建议
- 预测可能的风味表现
- 对比历史记录，发现优化方向

### 设计原则

| 原则 | 说明 |
|------|------|
| 即时反馈 | 保存记录后立即获得分析结果 |
| 可选深入 | 可快速浏览，也可查看详细分析 |
| 可操作性 | 建议具体、可直接执行 |
| 渐进增强 | 本地规则引擎为基础，可扩展云端 AI |

---

## 用户流程

### 整体流程

```
┌─────────────────────────────────────────────────────────┐
│                      新建记录流程                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   填写参数  →  点击保存  →  保存成功  →  弹出分析卡片   │
│                                  │                      │
│                                  ↓                      │
│                         ┌──────────────────┐           │
│                         │  ✓ 保存成功      │           │
│                         │                  │           │
│                         │  AI 发现：       │           │
│                         │  萃取时间偏短，  │           │
│                         │  建议延长至28s   │           │
│                         │                  │           │
│                         │  [查看详情] [关闭]│           │
│                         └──────────────────┘           │
│                                                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                      详情页查看                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   记录详情页底部新增 "AI 分析" Section                  │
│   点击可展开/收起分析内容                               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 交互流程

```
1. 用户填写参数 → 点击保存
        ↓
2. 数据保存到 SwiftData
        ↓
3. 触发分析引擎计算
        ↓
4. 弹出底部分析卡片 (可选关闭)
        ↓
5. 用户可选择:
   - "知道了" → 关闭，回到列表
   - "查看详情" → 跳转到该记录详情页
        ↓
6. 之后可随时在详情页查看分析
```

---

## UI 设计

### 1. 保存成功后的分析弹窗

```
┌─────────────────────────────────────────┐
│                                         │
│              ✓ 保存成功                 │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │  💡 AI 分析                     │   │  标题: .headline, #6F4E37
│  │                                 │   │
│  │  你的萃取时间(23s)略短于理想    │   │  内容: .body, #3E2723
│  │  范围(25-30s)，可能导致萃取     │   │
│  │  不足。                         │   │
│  │                                 │   │
│  │  建议尝试：                     │   │
│  │  • 延长萃取时间至 28s           │   │  建议项: 左侧圆点
│  │  • 或调细研磨度 0.5 档          │   │
│  │                                 │   │
│  │  预测风味：                     │   │
│  │  酸度明亮 ⬤ 甜感中等 ◯ 苦味偏低 ◯│   │  风味指标
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│     [查看完整分析]      [知道了]        │  两个按钮
│                                         │
└─────────────────────────────────────────┘
```

**弹窗规格**:

| 属性 | 值 |
|------|-----|
| 宽度 | 屏幕宽度 - 32pt (左右各 16pt 边距) |
| 圆角 | 16pt |
| 背景 | #FFFFFF |
| 遮罩 | rgba(0,0,0,0.4) |
| 动画 | 从底部滑入，0.3s spring |

### 2. 详情页分析卡片

```
├─────────────────────────────────────────┤
│  AI 分析                      [重新分析]│  Section Header
├─────────────────────────────────────────┤
│                                         │
│  综合评分                               │
│  ┌─────────────────────────────────┐   │
│  │         📊 78 分                │   │  圆形进度指示器
│  │       良好 · 有提升空间          │   │  直径 80pt
│  └─────────────────────────────────┘   │
│                                         │
│  参数评估                               │
│  ┌─────────────────────────────────┐   │
│  │ 萃取比例   ████████░░   1:2.0   │   │  进度条
│  │ 萃取时间   ██████░░░░   23s     │   │  绿=优 黄=可 红=差
│  │ 水温       ████████░░   93°C    │   │
│  │ 研磨度     ███████░░░   中细    │   │
│  └─────────────────────────────────┘   │
│                                         │
│  💡 改进建议                            │
│  ┌─────────────────────────────────┐   │
│  │ 1. 萃取时间偏短                 │   │
│  │    尝试延长至 27-30 秒          │   │
│  │                                 │   │
│  │ 2. 可以尝试提高水温 1-2°C       │   │
│  │    有助于提升甜感               │   │
│  └─────────────────────────────────┘   │
│                                         │
│  🎯 风味预测                            │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │  酸   ████████░░  明亮          │   │  横向指标条
│  │  甜   ██████░░░░  中等          │   │
│  │  苦   ████░░░░░░  偏低          │   │
│  │  醇   ███████░░░  中等          │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  📈 与你的记录对比                      │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │  本次记录     ●──────────       │   │  对比图
│  │  你 的平均    ───●───────       │   │
│  │  最佳记录     ─────────●        │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

### 3. 组件规格

**评分等级颜色**:

| 等级 | 分数范围 | 颜色 | 说明 |
|------|----------|------|------|
| 优秀 | 85-100 | #34C759 (绿) | 参数组合极佳 |
| 良好 | 70-84 | #FF9500 (橙) | 有提升空间 |
| 需改进 | 0-69 | #FF3B30 (红) | 建议调整 |

**风味指标条**:

| 属性 | 值 |
|------|-----|
| 高度 | 8pt |
| 圆角 | 4pt |
| 背景 | #E5E5EA |
| 填充 | 根据等级着色 |
| 间距 | 12pt |

---

## 数据模型

### 分析结果模型

```swift
// 分析结果
struct BrewAnalysis {
    let overallScore: Int              // 综合评分 0-100
    let parameterScores: [ParameterScore]
    let suggestions: [Suggestion]
    let flavorProfile: FlavorProfile
    let comparison: ComparisonData?
    let analyzedAt: Date
}

// 参数评分
struct ParameterScore {
    let name: String                   // 参数名
    let value: String                  // 实际值
    let score: Int                     // 评分 0-100
    let status: ScoreStatus            // 评分状态
}

enum ScoreStatus {
    case excellent                     // 优秀 (85-100)
    case good                          // 良好 (70-84)
    case needsWork                     // 需改进 (0-69)
}

// 改进建议
struct Suggestion {
    let title: String                  // 建议标题
    let description: String            // 详细说明
    let priority: Priority             // 优先级
}

enum Priority {
    case high                          // 高优先级
    case medium                        // 中优先级
    case low                           // 低优先级
}

// 风味预测
struct FlavorProfile {
    let acidity: FlavorLevel           // 酸度
    let sweetness: FlavorLevel         // 甜度
    let bitterness: FlavorLevel        // 苦味
    let body: FlavorLevel              // 醇厚度
}

enum FlavorLevel: Int {
    case low = 1                       // 偏低
    case mediumLow = 2                 // 中偏低
    case medium = 3                    // 中等
    case mediumHigh = 4                // 中偏高
    case high = 5                      // 明亮/强烈
}

// 对比数据
struct ComparisonData {
    let userAverage: Int               // 用户平均分
    let userBest: Int                  // 用户最佳分
    let overallAverage: Int?           // 全局平均分 (可选)
}
```

### 模型扩展

在 `BrewRecord` 中添加分析结果关联：

```swift
@Model
class BrewRecord {
    // ... 现有字段 ...

    // AI 分析结果 (可选，按需生成)
    var analysis: BrewAnalysis?
    var analyzedAt: Date?
}
```

---

## 分析规则

### 意式浓缩 (Espresso)

#### 萃取比例 (粉量:萃取量)

```
理想范围: 1:1.5 ~ 1:2.5
最佳值: 1:2.0

评分逻辑:
  - 1:2.0 ± 0.1 → 100分 (优秀)
  - 1:2.0 ± 0.2 → 85分 (良好)
  - 每偏离 0.1 → -10分
  - 低于 1:1.5 或高于 1:3.0 → 50分以下

建议生成:
  - < 1:1.5: "萃取量偏低，可能口感过于浓郁，尝试增加萃取量"
  - > 1:2.5: "萃取量偏高，可能口感稀薄，尝试减少萃取量"
```

#### 萃取时间

```
理想范围: 25s ~ 30s

评分逻辑:
  - 25-30s → 100分
  - 22-24s 或 31-33s → 80分
  - < 20s 或 > 35s → 50分以下
  - 中间值线性插值

建议生成:
  - < 22s: "萃取时间偏短，可能导致萃取不足，酸味突出"
  - > 32s: "萃取时间偏长，可能导致过度萃取，苦味增加"
```

#### 水温

```
理想范围: 根据烘焙度调整
  - 浅烘: 93-96°C
  - 中烘: 90-94°C
  - 深烘: 88-92°C

评分逻辑:
  - 在理想范围内 → 100分
  - 偏离 ±2°C → 80分
  - 偏离 ±4°C → 60分

建议生成:
  - 过高: "水温偏高，可能增加苦味和涩感"
  - 过低: "水温偏低，可能导致萃取不足，酸味尖锐"
```

#### 压力

```
理想范围: 8 ~ 9 bar

评分逻辑:
  - 8-9 bar → 100分
  - 7-8 或 9-10 bar → 85分
  - < 7 或 > 10 bar → 60分
```

### 手冲 (Pour Over)

#### 粉水比

```
理想范围: 1:14 ~ 1:17
最佳值: 1:15

评分逻辑:
  - 1:15 ± 1 → 100分
  - 1:15 ± 2 → 80分
  - 每偏离 1 → -10分

建议生成:
  - < 1:13: "粉水比偏高，咖啡可能过于浓郁"
  - > 1:18: "粉水比偏低，咖啡可能过于稀释"
```

#### 萃取时间

```
理想范围: 根据粉量调整
  - 15g 粉: 2:00 ~ 2:45
  - 18g 粉: 2:15 ~ 3:00
  - 20g 粉: 2:30 ~ 3:30

评分逻辑:
  - 在理想范围内 → 100分
  - 偏离 ±15s → 80分
  - 偏离 ±30s → 60分
```

#### 水温

```
理想范围: 根据烘焙度调整
  - 浅烘: 91-94°C
  - 中烘: 88-92°C
  - 深烘: 85-90°C
```

#### 闷蒸时间

```
理想范围: 20s ~ 45s

评分逻辑:
  - 20-45s → 100分
  - < 20s 或 > 60s → 70分
```

### 摩卡壶 (Moka Pot)

#### 粉水比

```
理想范围: 1:8 ~ 1:12

评分逻辑:
  - 1:10 ± 1 → 100分
  - 每偏离 1 → -10分
```

#### 火力控制

```
理想: 中低火

评分逻辑:
  - low → 100分
  - medium → 80分
  - high → 50分

建议生成:
  - high: "火力过大，容易过度萃取产生焦苦味"
```

#### 萃取时间

```
理想范围: 3:00 ~ 5:00

评分逻辑:
  - 3:00-5:00 → 100分
  - < 2:30 或 > 6:00 → 60分
```

---

## 风味预测算法

### 预测逻辑

基于参数组合预测风味轮廓：

```swift
func predictFlavor(record: BrewRecord) -> FlavorProfile {
    var acidity = FlavorLevel.medium
    var sweetness = FlavorLevel.medium
    var bitterness = FlavorLevel.medium
    var body = FlavorLevel.medium

    // 根据烘焙度调整基准
    switch record.roastLevel {
    case .light:
        acidity = .high
        sweetness = .mediumLow
        bitterness = .low
    case .medium:
        acidity = .mediumHigh
        sweetness = .medium
        bitterness = .mediumLow
    case .dark:
        acidity = .low
        sweetness = .mediumLow
        bitterness = .mediumHigh
    }

    // 根据萃取程度调整
    let extractionLevel = calculateExtractionLevel(record)

    if extractionLevel > 1.0 {  // 过度萃取
        bitterness = increase(bitterness)
        acidity = decrease(acidity)
    } else if extractionLevel < 0.8 {  // 萃取不足
        acidity = increase(acidity)
        sweetness = decrease(sweetness)
    }

    // 水温影响
    if record.temperature > 94 {
        bitterness = increase(bitterness)
        body = increase(body)
    } else if record.temperature < 88 {
        acidity = increase(acidity)
    }

    return FlavorProfile(
        acidity: acidity,
        sweetness: sweetness,
        bitterness: bitterness,
        body: body
    )
}
```

---

## 文件结构

```
BrewLog/
├── Services/
│   └── BrewAnalyzer.swift          // 分析引擎
│       ├── analyze(record:)        // 主分析函数
│       ├── calculateScore()        // 评分计算
│       ├── generateSuggestions()   // 建议生成
│       └── predictFlavor()         // 风味预测
│
├── Models/
│   ├── BrewRecord.swift            // (扩展) 添加 analysis 字段
│   └── BrewAnalysis.swift          // 分析结果模型
│
├── Views/
│   ├── Components/
│   │   ├── AnalysisCard.swift      // 保存后弹出的分析卡片
│   │   ├── ScoreRing.swift         // 圆形评分指示器
│   │   ├── FlavorMeter.swift       // 风味指标条
│   │   ├── ParameterScoreRow.swift // 参数评分行
│   │   └── ComparisonChart.swift   // 对比图表
│   │
│   └── Detail/
│       └── AnalysisSection.swift   // 详情页分析区块
│
└── Extensions/
    └── BrewAnalysis+Preview.swift  // 预览数据
```

---

## 技术实现

### 分析引擎接口

```swift
protocol BrewAnalyzing {
    func analyze(_ record: BrewRecord) -> BrewAnalysis
    func quickInsight(_ record: BrewRecord) -> QuickInsight
}

struct QuickInsight {
    let summary: String           // 一句话摘要
    let topSuggestion: String?    // 最重要建议
}

class BrewAnalyzer: BrewAnalyzing {
    func analyze(_ record: BrewRecord) -> BrewAnalysis {
        let scores = calculateParameterScores(record)
        let overallScore = calculateOverallScore(from: scores)
        let suggestions = generateSuggestions(record, scores)
        let flavor = predictFlavor(record)

        return BrewAnalysis(
            overallScore: overallScore,
            parameterScores: scores,
            suggestions: suggestions,
            flavorProfile: flavor,
            comparison: nil,  // 首次分析无对比数据
            analyzedAt: Date()
        )
    }

    func quickInsight(_ record: BrewRecord) -> QuickInsight {
        // 快速分析，用于弹窗预览
        let analysis = analyze(record)

        let summary: String
        if analysis.overallScore >= 85 {
            summary = "参数组合很棒！继续保持"
        } else if analysis.overallScore >= 70 {
            summary = "整体不错，还有些提升空间"
        } else {
            summary = "建议调整参数以获得更好口感"
        }

        return QuickInsight(
            summary: summary,
            topSuggestion: analysis.suggestions.first?.description
        )
    }
}
```

### 触发时机

```swift
// NewRecordView.swift
private func saveRecord() {
    modelContext.insert(record)

    // 保存后触发分析
    let analyzer = BrewAnalyzer()
    record.analysis = analyzer.analyze(record)
    record.analyzedAt = Date()

    try? modelContext.save()

    // 显示分析弹窗
    showAnalysisSheet = true
}
```

---

## 未来扩展

### 云端 AI 增强

```
Phase 2: 云端 AI 集成

1. 保留本地规则引擎作为基础分析
2. 可选调用云端 AI 进行深度分析:
   - 基于大量数据的个性化建议
   - 更精准的风味预测
   - 咖啡豆推荐

API 设计:
   POST /api/analyze
   Request: { record: BrewRecord, userHistory: [BrewRecord] }
   Response: { analysis: BrewAnalysis, confidence: Float }
```

### 学习用户偏好

```
Phase 3: 个性化学习

1. 记录用户对建议的反馈 (采纳/忽略)
2. 学习用户口味偏好
3. 生成个性化评分标准
4. 推荐适合用户口感的参数组合
```

---

## 实现计划

| 阶段 | 内容 | 版本 |
|------|------|------|
| 1 | 数据模型 + 本地分析引擎 | v1.1 |
| 2 | 保存后弹窗 + 详情页卡片 | v1.1 |
| 3 | 风味预测可视化 | v1.1 |
| 4 | 历史对比功能 | v1.5 |
| 5 | 云端 AI 集成 | v1.5 |

> 详细实现任务见 [roadmap.md](./roadmap.md)

---

*文档版本: 1.1*
*最后更新: 2025-02-21*
