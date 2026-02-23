# 技术架构

> BrewLog 架构设计与项目结构

---

## 架构模式

采用 **MVVM + Services** 架构，针对 SwiftUI + SwiftData 进行优化。

### 架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                          Views                                   │
│                        (SwiftUI)                                 │
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │  List    │  │  Detail  │  │  New     │  │Settings  │        │
│  │  Views   │  │  Views   │  │  Views   │  │  Views   │        │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘        │
│       │             │             │             │                │
│  ┌────┴─────────────┴─────────────┴─────────────┴────┐         │
│  │              Components (可复用 UI 组件)           │         │
│  │   StarRating / ParameterField / ScoreRing / ...   │         │
│  └────────────────────────────────────────────────────┘         │
└──────────────────────────────┬──────────────────────────────────┘
                               │
              @Query / @Environment / @Binding
                               │
┌──────────────────────────────┴──────────────────────────────────┐
│                         Services                                  │
│                    (业务逻辑层)                                   │
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  BrewAnalyzer   │  │ UserPreferences │  │  DataExporter   │  │
│  │  (参数分析)      │  │  (用户偏好)      │  │  (数据导出)     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                   │
└──────────────────────────────┬──────────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────────┐
│                          Models                                   │
│                       (SwiftData)                                 │
│                                                                   │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────────┐ │
│  │ BrewRecord  │  │    Enums     │  │     分析结果存储        │ │
│  │ (冲煮记录)   │  │ (枚举类型)    │  │ (JSON in BrewRecord)   │ │
│  └─────────────┘  └──────────────┘  └─────────────────────────┘ │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

### 层级职责

| 层级 | 职责 | 依赖 |
|------|------|------|
| **Views** | UI 展示、用户交互 | Services, Models |
| **Services** | 业务逻辑、分析算法 | Models |
| **Models** | 数据定义、持久化 | 无 |

---

## 技术栈

| 层级 | 技术 | 版本要求 | 说明 |
|------|------|----------|------|
| UI | SwiftUI | iOS 15+ | 声明式界面 |
| 数据持久化 | SwiftData | iOS 17+ | 本地存储 |
| 用户偏好 | UserDefaults | iOS 15+ | 简单设置 |
| 语言 | Swift | 5.9 | - |
| 最低版本 | iOS | 17.0 | SwiftData 要求 |

> **注意**: SwiftData 需要 iOS 17.0+，如需支持 iOS 15-16，需改用 CoreData。

---

## 目录结构

```
BrewLog/
│
├── App/
│   ├── BrewLogApp.swift              # App 入口，SwiftData 配置
│   └── ContentView.swift             # TabView 主框架
│
├── Models/
│   ├── BrewRecord.swift              # 冲煮记录 (@Model)
│   ├── BrewMethod.swift              # 冲煮方式枚举
│   ├── RoastLevel.swift              # 烘焙程度枚举
│   ├── HeatLevel.swift               # 火力枚举
│   └── BrewAnalysis.swift            # 分析结果 (Codable struct)
│
├── Services/
│   ├── BrewAnalyzer.swift            # 参数分析引擎
│   │   ├── analyze(_:)               # 完整分析
│   │   ├── quickInsight(_:)          # 快速洞察
│   │   └── 规则实现...
│   │
│   └── UserPreferences.swift         # 用户偏好管理
│       ├── defaultMethod             # 默认冲煮方式
│       ├── lastUsedParams            # 上次使用的参数
│       └── analysisEnabled           # 是否启用分析
│
├── ViewModels/
│   └── (可选，复杂场景使用)
│
├── Views/
│   ├── List/
│   │   ├── RecordListView.swift          # 记录列表
│   │   └── RecordRowView.swift           # 列表行
│   │
│   ├── Detail/
│   │   ├── RecordDetailView.swift        # 记录详情
│   │   └── AnalysisSection.swift         # AI 分析区块
│   │
│   ├── NewRecord/
│   │   ├── NewRecordView.swift           # 新建记录主视图
│   │   ├── MethodPickerView.swift        # 方式选择
│   │   ├── EspressoFormView.swift        # 意式表单
│   │   ├── PourOverFormView.swift        # 手冲表单
│   │   ├── MokaPotFormView.swift         # 摩卡壶表单
│   │   └── CommonFormView.swift          # 通用表单
│   │
│   ├── Settings/
│   │   └── SettingsView.swift            # 设置页
│   │
│   └── Components/
│       ├── StarRating.swift              # 评分组件
│       ├── ParameterField.swift          # 参数输入
│       ├── MethodBadge.swift             # 方式标签
│       ├── AnalysisCard.swift            # 分析弹窗卡片
│       ├── ScoreRing.swift               # 圆形评分
│       ├── FlavorMeter.swift             # 风味指标条
│       └── ParameterScoreRow.swift       # 参数评分行
│
├── Extensions/
│   ├── Color+Theme.swift                 # 主题颜色
│   ├── Date+Extensions.swift             # 日期格式化
│   └── Double+Extensions.swift           # 数字格式化
│
├── Resources/
│   └── Assets.xcassets                   # 图片资源
│       ├── AppIcon.appiconset
│       └── AccentColor.colorset
│
└── docs/                                  # 设计文档
    ├── README.md                          # 文档索引
    ├── overview.md                        # 项目概述
    ├── architecture.md                    # 技术架构 (本文档)
    ├── data-model.md                      # 数据模型
    ├── services.md                        # 服务层设计
    ├── views.md                           # 视图设计
    ├── ui-ux.md                           # UI/UX 规范
    ├── features.md                        # 功能列表
    ├── ai-analysis.md                     # AI 分析设计
    ├── roadmap.md                         # 开发路线图
    └── development.md                     # 开发计划
```

---

## 数据流设计

### 读取流程

```
┌─────────────┐      @Query       ┌─────────────┐
│   View      │ ───────────────>  │ SwiftData   │
│             │                    │ Container   │
└─────────────┘                    └─────────────┘
```

### 写入流程

```
┌─────────────┐  modelContext   ┌─────────────┐
│   View      │ ──────────────> │ SwiftData   │
│             │   .insert()     │ Container   │
└─────────────┘                 └─────────────┘
```

### 分析流程

```
┌─────────────┐                  ┌─────────────┐
│ 保存记录    │                  │             │
│             │                  │             │
└──────┬──────┘                  │             │
       │                         │             │
       ▼                         │             │
┌─────────────┐  analyze(_:)  ┌──┴────────────┤
│ BrewAnalyzer│ ────────────> │ BrewAnalysis  │
│   (Service) │               │   (Result)    │
└─────────────┘               └───────────────┘
       │                             │
       │  存储到 BrewRecord          │
       │  .analysisJSON              │
       ▼                             │
┌─────────────┐                      │
│ SwiftData   │ <────────────────────┘
└─────────────┘
```

---

## 依赖关系

```
                    ┌─────────────┐
                    │    Views    │
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
           ▼               ▼               ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │ Components  │ │  Services   │ │   Models    │
    └─────────────┘ └──────┬──────┘ └─────────────┘
                          │
                          ▼
                   ┌─────────────┐
                   │   Models    │
                   └─────────────┘
```

### 依赖规则

1. **Views** 可以依赖 Components、Services、Models
2. **Services** 只能依赖 Models
3. **Components** 不依赖业务逻辑，只依赖 Extensions
4. **Models** 完全独立，无外部依赖
5. **Extensions** 完全独立

---

## SwiftData 配置

### 模型容器

```swift
// BrewLogApp.swift
@main
struct BrewLogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: BrewRecord.self)
    }
}
```

### 模型定义

```swift
// BrewRecord.swift
@Model
final class BrewRecord {
    @Attribute(.unique) var id: UUID
    var method: BrewMethod
    var date: Date

    // ... 其他字段 ...

    // AI 分析结果 (JSON 存储)
    var analysisJSON: Data?

    // 计算属性：解析分析结果
    var analysis: BrewAnalysis? {
        get {
            guard let data = analysisJSON else { return nil }
            return try? JSONDecoder().decode(BrewAnalysis.self, from: data)
        }
        set {
            analysisJSON = try? JSONEncoder().encode(newValue)
        }
    }
}
```

---

## 用户偏好设计

使用 `@AppStorage` 存储简单用户偏好：

```swift
// UserPreferences.swift
struct UserPreferences {
    // 默认冲煮方式
    @AppStorage("defaultMethod") var defaultMethod: BrewMethod = .pourOver

    // 是否启用 AI 分析
    @AppStorage("analysisEnabled") var analysisEnabled: Bool = true

    // 是否在保存后显示分析弹窗
    @AppStorage("showAnalysisAfterSave") var showAnalysisAfterSave: Bool = true

    // 上次使用的参数 (按方式存储)
    @AppStorage("lastEspressoDose") var lastEspressoDose: Double = 18.0
    @AppStorage("lastPourOverDose") var lastPourOverDose: Double = 15.0
    // ...
}
```

---

## 错误处理

### 错误类型定义

```swift
// Models/BrewLogError.swift
enum BrewLogError: LocalizedError {
    case analysisFailed
    case dataCorrupted
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .analysisFailed:
            return "分析失败，请重试"
        case .dataCorrupted:
            return "数据损坏，请联系支持"
        case .exportFailed:
            return "导出失败，请重试"
        }
    }
}
```

### 错误处理策略

| 场景 | 处理方式 |
|------|----------|
| 分析失败 | 静默失败，不阻塞保存 |
| 数据解析失败 | 返回 nil，显示默认值 |
| 导出失败 | 显示错误提示，允许重试 |

---

## 性能考虑

### 列表性能

- 使用 `@Query` 自动懒加载
- 列表项高度固定 (72pt)
- 避免在列表项中执行复杂计算

### 分析性能

- 分析在保存时异步执行
- 结果缓存到 `analysisJSON`，避免重复计算
- 快速洞察 (< 10ms) vs 完整分析 (< 100ms)

### 内存管理

- 分析结果使用值类型 (struct)
- 大列表使用 `LazyVStack`
- 图片资源使用 Asset Catalog 压缩

---

## 安全考虑

### 数据安全

- 本地数据存储在 App Sandbox
- 无网络传输，数据不离开设备
- 未来 iCloud 同步使用系统加密

### 输入验证

- 数值范围限制 (如温度 0-100°C)
- 文本长度限制
- 避免 SQL 注入 (SwiftData 自动处理)

---

## 可扩展性

### 未来扩展点

| 扩展方向 | 设计预留 |
|----------|----------|
| 云端 AI | Service 协议化，可替换实现 |
| 多设备同步 | SwiftData + iCloud |
| 咖啡豆管理 | 预留 CoffeeBean 模型接口 |
| 配方模板 | 预留 Recipe 模型接口 |
| Widget | 数据层独立，可复用 |

### 服务层协议化

```swift
// Services/BrewAnalyzing.swift
protocol BrewAnalyzing {
    func analyze(_ record: BrewRecord) -> BrewAnalysis
    func quickInsight(_ record: BrewRecord) -> QuickInsight
}

// 本地实现
class LocalBrewAnalyzer: BrewAnalyzing { ... }

// 未来云端实现
class CloudBrewAnalyzer: BrewAnalyzing { ... }
```

---

*文档版本: 2.0*
*最后更新: 2025-02-21*
