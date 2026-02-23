# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BrewLog is an iOS app for recording coffee brewing parameters. It helps coffee enthusiasts track their brewing experiments for Espresso, Pour Over, and Moka Pot methods.

## Tech Stack

| Item | Technology |
|------|------------|
| Platform | iOS 17.0+ |
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Data Storage | SwiftData |
| Architecture | MVVM + Services |
| IDE | Xcode 15+ |

## Development Commands

This is an Xcode-based iOS project. Use Xcode for building, running, and testing.

- **Build**: `Cmd+B` in Xcode
- **Run**: `Cmd+R` in Xcode (select simulator or device first)
- **Test**: `Cmd+U` in Xcode
- **Clean**: `Cmd+Shift+K` in Xcode

## CLI Preferences

When working with Git/GitHub operations, prefer `gh` (GitHub CLI) commands over `git` commands:

- Use `gh` for PR operations, issue management, repo info
- Use `git` only when `gh` doesn't support the operation

---

## ⚠️ Apple 规范要求（必须遵循）

> 在本项目的任何操作中，都必须遵循 Apple 的规范。详见 `docs/apple-guidelines-compliance.md`

### Apple Human Interface Guidelines (HIG)

#### 1. 设计原则

| 原则 | 要求 |
|------|------|
| Clarity（清晰） | 文字清晰、图标精确、功能明确 |
| Deference（顺从） | UI 服务于内容，不喧宾夺主 |
| Depth（深度） | 层次分明，有视觉层级 |

#### 2. 布局规范

| 规范 | 要求 |
|------|------|
| 安全区域 | 使用 SwiftUI 自动处理，不要手动覆盖 |
| 响应式布局 | 不要硬编码尺寸，使用 `.frame(maxWidth: .infinity)` |
| **触控目标** | **最小 44 × 44 pt（强制要求）** |
| 控件间距 | 至少 8pt |

#### 3. 导航规范

| 规范 | 要求 |
|------|------|
| Tab Bar | 只放导航目的地，**不放操作按钮**（如"新建"） |
| Tab 数量 | 3-5 个（最多 5 个） |
| 图标 | 使用 SF Symbols |
| Navigation Bar | 操作按钮放右侧（`.primaryAction`） |

#### 4. 颜色规范

| 规范 | 要求 |
|------|------|
| 颜色定义 | **必须使用 Asset Catalog**（自动适配深浅模式） |
| 系统颜色 | 使用 `.primary`, `.secondary`, `.systemYellow` 等 |
| 对比度 | 正文 ≥ 4.5:1，大标题 ≥ 3:1 |
| 深色模式 | **必须支持**，跟随系统设置 |

```swift
// ✅ 正确 - Asset Catalog
static let coffee = Color("Coffee")

// ❌ 错误 - 硬编码
static let coffee = Color(hex: "6F4E37")
```

#### 5. 字体规范

| 规范 | 要求 |
|------|------|
| 字体 | 使用语义字体（`.headline`, `.body`, `.caption`） |
| 动态类型 | **必须支持**用户字体大小设置 |

```swift
// ✅ 正确 - 语义字体
.font(.headline)

// ❌ 错误 - 固定字号
.font(.system(size: 17))
```

#### 6. 无障碍规范

| 规范 | 要求 |
|------|------|
| VoiceOver | 所有交互元素必须有 `accessibilityLabel` |
| 减少动效 | 检查 `@Environment(\.accessibilityReduceMotion)` |

```swift
// ✅ VoiceOver 支持
.accessibilityLabel("评分：\(rating) 星")
.accessibilityHint("双击调整评分")

// ✅ 减少动效
@Environment(\.accessibilityReduceMotion) var reduceMotion
.animation(reduceMotion ? .none : .spring(), value: state)
```

### App Store Review Guidelines

#### 提交前检查

| 检查项 | 要求 |
|--------|------|
| 崩溃 | App 任何情况下不能崩溃 |
| Bug | 功能性错误必须修复 |
| 私有 API | 只能使用公开 API |
| 占位内容 | 不能有测试文本（搜索 "test", "TODO", "lorem"） |
| Beta 标识 | 不能有 "Beta", "Test" 等字样 |

#### 元数据要求

| 项目 | 要求 |
|------|------|
| App 名称 | ≤ 30 字符，不能包含价格 |
| 副标题 | ≤ 30 字符 |
| 隐私政策 | **必须提供 URL** |
| 截图 | 6.5" 和 5.5" iPhone，来自真实 App |

---

## 代码规范（遵循 Apple HIG）

### 触控区域

```swift
// ✅ 显示 28pt，触控 44pt
Image(systemName: "star.fill")
    .font(.system(size: 28))
    .frame(width: 44, height: 44)
    .contentShape(Rectangle())
```

### Tab 结构

```swift
// ✅ 正确 - Tab 只用于导航
TabView {
    RecordListView()  // 含导航栏 [+] 按钮
        .tabItem { Label("记录", systemImage: "list.bullet") }
    SettingsView()
        .tabItem { Label("设置", systemImage: "gearshape") }
}

// ❌ 错误 - Tab 包含操作按钮
TabView {
    RecordListView()
    NewRecordView()  // "新建"是操作，不是导航
    SettingsView()
}
```

### 键盘处理

```swift
// ✅ 键盘工具栏
.toolbar {
    ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button("完成") { focusedField = nil }
    }
}
.scrollDismissesKeyboard(.interactively)
```

### 删除交互

```swift
// ✅ 撤销机制（Apple 推荐方式）
@State private var deletedRecord: BrewRecord?
@State private var showUndo = false

func delete(_ record: BrewRecord) {
    deletedRecord = record
    modelContext.delete(record)
    showUndo = true
    // 3 秒后确认删除
}
```

---

## Project Structure

```
BrewLog/
├── App/
│   ├── BrewLogApp.swift          # App entry point, SwiftData configuration
│   └── ContentView.swift         # TabView main frame
├── Models/
│   ├── BrewRecord.swift          # Core data model (@Model)
│   ├── BrewMethod.swift          # Brewing method enum
│   ├── RoastLevel.swift          # Roast level enum
│   └── HeatLevel.swift           # Heat level enum
├── Views/
│   ├── List/                     # RecordListView, RecordRowView
│   ├── Detail/                   # RecordDetailView
│   ├── NewRecord/                # NewRecordView, form components
│   └── Settings/                 # SettingsView
├── Components/                   # Reusable UI components
│   ├── StarRating.swift
│   ├── ParameterField.swift
│   └── MethodBadge.swift
├── Services/                     # Business logic layer
│   ├── BrewAnalyzer.swift        # Brewing parameter analysis
│   └── UserPreferences.swift     # User settings
├── Extensions/
│   ├── Color+Theme.swift         # Coffee color theme (Asset Catalog)
│   └── Date+Extensions.swift
└── Resources/
    └── Assets.xcassets           # Colors, Images (含深浅模式配色)
```

## Architecture

MVVM + Services pattern with SwiftData for persistence:

- **View**: SwiftUI views, use `@Query` for data fetching
- **ViewModel**: Optional for simple scenarios; SwiftUI's state management often suffices
- **Model**: SwiftData `@Model` classes
- **Services**: Business logic (BrewAnalyzer, UserPreferences)

### Data Flow

- **Read**: `@Query` property wrapper fetches data from SwiftData
- **Write**: `modelContext.insert(record)` to save
- **Delete**: `modelContext.delete(record)` to remove

### SwiftData Configuration

```swift
// In BrewLogApp.swift
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

## Core Data Model

The `BrewRecord` model uses a single-table design with optional fields for each brewing method:

- **Common fields**: method, date, grindSize, coffeeBean, roastLevel, rating, notes
- **Espresso fields**: espressoDose, espressoYield, espressoTime, espressoTemp, espressoPressure
- **Pour Over fields**: pourOverDose, pourOverWater, pourOverTemp, pourOverBloomTime, pourOverTime, pourOverPours
- **Moka Pot fields**: mokaDose, mokaWater, mokaHeat, mokaTime
- **AI Analysis**: analysisJSON (Codable BrewAnalysis)

## Theme Colors (Asset Catalog)

在 `Assets.xcassets` 中定义，自动适配深浅模式：

| 颜色 | 浅色模式 | 深色模式 |
|------|----------|----------|
| Coffee | #6F4E37 | #C68B59 |
| CoffeeLight | #C68B59 | #D4A574 |
| Cream | #FAF8F5 | #1C1C1E |

```swift
// 使用 Asset Catalog 颜色
extension Color {
    static let coffee = Color("Coffee")
    static let coffeeLight = Color("CoffeeLight")
    static let cream = Color("Cream")
}
```

## Brewing Methods

1. **Espresso (意式浓缩)**: High pressure, fast extraction. Key params: dose, yield, time, temp, pressure
2. **Pour Over (手冲咖啡)**: Gravity filtration. Key params: dose, water, temp, bloom time, pour count
3. **Moka Pot (摩卡壶)**: Steam pressure. Key params: dose, water, heat level, time

## Documentation

Detailed design docs in `docs/`:
- `architecture.md` - Technical architecture details
- `data-model.md` - Complete data model specification
- `views.md` - View hierarchy and components (遵循 Apple HIG)
- `ui-ux.md` - Design guidelines and animations (遵循 Apple HIG)
- `apple-guidelines-compliance.md` - **Apple HIG 合规报告**
- `roadmap.md` - Version-by-version development plan
- `development.md` - Development phase breakdown
- `workflow.md` - Version management and release process

---

## 开发检查清单

### 每次代码提交前

- [ ] 触控区域 ≥ 44pt
- [ ] 使用语义字体（`.headline`, `.body` 等）
- [ ] 颜色使用 Asset Catalog
- [ ] VoiceOver 标签完整
- [ ] 深色模式正常显示
- [ ] 动画尊重 `accessibilityReduceMotion`

### App Store 提交前

- [ ] 无崩溃、无 Bug
- [ ] 无占位文本（"test", "TODO"）
- [ ] 真机测试通过
- [ ] 隐私政策 URL 已准备
- [ ] 截图已准备（6.5" 和 5.5"）
