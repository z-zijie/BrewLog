# Apple 设计规范合规报告

> 基于 Apple Human Interface Guidelines 和 App Store Review Guidelines

---

## 一、Apple Human Interface Guidelines 核心规范

### 1. 设计三大原则

| 原则 | 说明 | 当前设计 | 状态 |
|------|------|----------|------|
| **Clarity (清晰)** | 文字清晰、图标精确、功能明确 | ✅ 符合 | ✅ |
| **Deference (顺从)** | UI 服务于内容，不喧宾夺主 | ✅ 符合 | ✅ |
| **Depth (深度)** | 层次分明，有视觉层级 | ✅ 符合 | ✅ |

### 2. 布局规范

#### 2.1 安全区域 (Safe Area)

```
必须尊重的安全区域:
├── 顶部: 状态栏 + 导航栏
├── 底部: Home Indicator (有 Home 键) 或 Home Indicator Bar (全面屏)
├── 左侧: 无特殊要求
└── 右侧: 无特殊要求

全面屏 iPhone 顶部安全区域高度:
├── iPhone X-14: 44pt (状态栏) + 44pt (导航栏) = 88pt
├── iPhone 14 Pro+: 动态岛 + 导航栏 ≈ 91pt
└── 底部安全区域: 34pt
```

**当前设计状态**: ✅ 使用 SwiftUI 自动处理

**代码要求**:
```swift
// SwiftUI 自动处理安全区域
NavigationStack {
    List { ... }
}
// 无需手动处理，系统自动适配
```

#### 2.2 响应式布局

```
必须支持的设备尺寸:
├── iPhone SE (3rd): 375 × 667 pt
├── iPhone 14: 390 × 844 pt
├── iPhone 14 Plus: 428 × 926 pt
├── iPhone 14 Pro: 393 × 852 pt
├── iPhone 14 Pro Max: 430 × 932 pt
└── iPad: 各种尺寸
```

**当前设计状态**: ✅ 使用 SwiftUI 自适应布局

**代码要求**:
```swift
// 不要硬编码尺寸
// ❌ 错误
.frame(width: 375, height: 100)

// ✅ 正确
.frame(maxWidth: .infinity)
.padding()
```

#### 2.3 触控目标

```
Apple 强制要求:
- 最小触控区域: 44 × 44 pt
- 控件间距: 至少 8pt
- 不要放置在屏幕边缘 44pt 范围内的重要交互
```

**当前设计问题**:

| 组件 | 当前设计 | 要求 | 状态 | 修改方案 |
|------|----------|------|------|----------|
| 评分星星 | 28pt 显示 | 44pt 点击区域 | ❌ | 增加透明点击区域 |
| Tab 图标 | 系统默认 | 44pt | ✅ | - |
| 列表项 | 72pt 高 | 44pt | ✅ | - |
| 按钮 | 50pt 高 | 44pt | ✅ | - |
| 表单行 | 44pt 高 | 44pt | ✅ | - |

**修改代码**:
```swift
// ❌ 当前设计
Image(systemName: "star.fill")
    .font(.system(size: 28))  // 显示 28pt，点击区域也是 28pt

// ✅ 修改后
Image(systemName: "star.fill")
    .font(.system(size: 28))           // 显示 28pt
    .frame(width: 44, height: 44)      // 点击区域 44pt
    .contentShape(Rectangle())          // 整个 frame 可点击
```

### 3. 导航规范

#### 3.1 Tab Bar 规范

```
Apple HIG 要求:
├── Tab 数量: 3-5 个（最多 5 个）
├── Tab 位置: 始终在屏幕底部
├── Tab 内容: 只放主要导航目的地，不放操作按钮
├── 图标: 使用 SF Symbols
└── 选中状态: 系统自动处理（使用 tint color）
```

**❌ 当前设计问题**:

```
当前 Tab 结构:
Tab 1: 记录 (导航目的地) ✅
Tab 2: 新建 (操作按钮) ❌ 不符合规范
Tab 3: 设置 (导航目的地) ✅
```

**Apple 指出**: Tab Bar 应该用于导航，而不是操作。创建新内容是操作，不是导航目的地。

**✅ 修改方案 A（推荐）**:

```
修改后 Tab 结构:
Tab 1: 记录 ✅
Tab 2: 设置 ✅

新建入口: 列表页导航栏右上角 [+] 按钮
```

**✅ 修改方案 B（未来扩展）**:

```
v1.4+ 版本 Tab 结构:
Tab 1: 记录 ✅
Tab 2: 洞察 (统计页面) ✅
Tab 3: 设置 ✅

新建入口: 列表页导航栏右上角 [+] 按钮
```

**修改代码**:
```swift
// ❌ 当前设计
TabView {
    RecordListView()
        .tabItem { Label("记录", systemImage: "list.bullet") }

    NewRecordView()  // ❌ 不应该作为 Tab
        .tabItem { Label("新建", systemImage: "plus.circle") }

    SettingsView()
        .tabItem { Label("设置", systemImage: "gearshape") }
}

// ✅ 修改后
TabView {
    RecordListView()  // 包含导航栏 [+] 按钮
        .tabItem { Label("记录", systemImage: "list.bullet") }

    SettingsView()
        .tabItem { Label("设置", systemImage: "gearshape") }
}

// RecordListView 中添加新建按钮
NavigationStack {
    List { ... }
    .navigationTitle("BrewLog")
    .toolbar {
        ToolbarItem(placement: .primaryAction) {
            Button(action: { showNewRecord = true }) {
                Image(systemName: "plus")
            }
        }
    }
    .sheet(isPresented: $showNewRecord) {
        NewRecordView()
    }
}
```

#### 3.2 Navigation Bar 规范

```
Apple HIG 要求:
├── 位置: 始终在顶部
├── 标题: 大标题或小标题，居中显示
├── 返回按钮: 左侧，可显示前页标题
├── 操作按钮: 右侧，使用 SF Symbols
├── 编辑按钮: 系统标准 EditButton
└── 颜色: 使用系统颜色或品牌色
```

**当前设计状态**: ✅ 基本符合

**代码要求**:
```swift
// ✅ 正确实现
NavigationStack {
    List { ... }
    .navigationTitle("BrewLog")  // 大标题
    .toolbar {
        ToolbarItem(placement: .primaryAction) {
            Button(action: { }) {
                Image(systemName: "plus")
            }
        }
    }
}

// 详情页
NavigationStack {
    Form { ... }
    .navigationTitle("记录详情")  // 小标题
    .navigationBarTitleDisplayMode(.inline)
}
```

#### 3.3 页面转场

```
Apple 标准转场:
├── push/pop: 右滑进入，右滑返回
├── modal: 底部滑入，下滑关闭
├── sheet: 底部滑入（可设置高度）
└── fullScreenCover: 全屏覆盖
```

**当前设计状态**: ✅ 使用 SwiftUI 默认转场

**代码要求**:
```swift
// 列表跳转详情 - push
NavigationLink(value: record) {
    RecordRowView(record: record)
}
.navigationDestination(for: BrewRecord.self) { record in
    RecordDetailView(record: record)
}

// 新建记录 - sheet
.sheet(isPresented: $showNewRecord) {
    NewRecordView()
}
```

### 4. 颜色规范

#### 4.1 系统颜色

```
Apple 提供的系统语义颜色:
├── .primary      : 主文字颜色（自动适配深浅模式）
├── .secondary    : 次要文字颜色
├── .accentColor  : 强调色（系统默认蓝色）
├── .background   : 背景色
├── .systemBackground: 系统背景
└── 系统功能色:
    ├── .systemRed   : 错误/删除
    ├── .systemGreen : 成功
    ├── .systemOrange: 警告
    ├── .systemBlue  : 链接/操作
    └── .systemGray  : 禁用
```

**当前设计问题**:

| 项目 | 当前 | 问题 |
|------|------|------|
| 主色 | #6F4E37 硬编码 | 需要适配深浅模式 |
| 背景 | #FAF8F5 硬编码 | 深色模式需要不同值 |
| 评分星星 | #FFD700 / #E5E5EA | 需要使用系统颜色 |

**✅ 修改方案**:

```swift
// ❌ 当前设计 - 硬编码颜色
extension Color {
    static let coffee = Color(hex: "6F4E37")
    static let cream = Color(hex: "FAF8F5")
}

// ✅ 修改后 - 使用 Asset Catalog

// 步骤 1: 在 Assets.xcassets 中创建 Color Set
// Coffee.colorset/
//   ├── Any Appearance: #6F4E37
//   └── Dark Appearance: #C68B59 (浅一点，深色模式更易读)

// 步骤 2: 代码中使用
extension Color {
    static let coffee = Color("Coffee")  // 自动适配深浅模式
    static let coffeeLight = Color("CoffeeLight")
    static let cream = Color("Cream")
}

// 步骤 3: 评分星星使用系统颜色
Image(systemName: "star.fill")
    .foregroundColor(.systemYellow)  // 系统黄色，自动适配

Image(systemName: "star")
    .foregroundColor(.secondary)  // 系统次要颜色
```

#### 4.2 深色模式要求

```
Apple 强制要求:
- 必须支持深色模式
- 不能只在 App 内切换（应该跟随系统）
- 所有颜色必须在两种模式下都清晰可读
```

**当前设计**: 已规划，需要完善

**颜色对照表**:

| 用途 | 浅色模式 | 深色模式 | 对比度检查 |
|------|----------|----------|------------|
| 主色 | #6F4E37 | #C68B59 | ✅ |
| 背景 | #FAF8F5 | #1C1C1E | ✅ |
| 卡片背景 | #FFFFFF | #2C2C2E | ✅ |
| 主文字 | #1C1C1E | #FFFFFF | ✅ 15:1 |
| 次要文字 | #8E8E93 | #8E8E93 | ✅ |
| 分割线 | #C6C6C8 | #38383A | ✅ |

#### 4.3 对比度要求

```
WCAG 2.0 要求（Apple 遵循）:
├── 正文文字: 对比度 ≥ 4.5:1
├── 大标题: 对比度 ≥ 3:1
├── 图标: 对比度 ≥ 3:1
└── 禁用状态: 无强制要求
```

**验证方法**: 使用 [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

### 5. 字体规范

#### 5.1 系统字体

```
Apple 系统字体:
├── SF Pro: 主要字体
├── SF Pro Display: 大标题
├── SF Pro Text: 正文
├── SF Mono: 等宽字体（代码/数字）
└── New York: 衬线字体（可选）
```

**当前设计状态**: ✅ 使用 SwiftUI 系统字体

#### 5.2 动态类型 (Dynamic Type)

```
Apple 强制要求:
- 必须支持用户字体大小设置
- 使用语义字体 (.body, .headline 等)
- 不要使用固定字号
```

**代码要求**:
```swift
// ❌ 错误 - 固定字号
Text("标题")
    .font(.system(size: 20))

// ✅ 正确 - 语义字体
Text("标题")
    .font(.headline)  // 自动适配用户设置

// ✅ 可接受 - 需要特定样式时
Text("标题")
    .font(.system(.headline, design: .default))
```

#### 5.3 字体层级

```
SwiftUI 语义字体:
├── .largeTitle: 34pt
├── .title: 28pt
├── .title2: 22pt
├── .title3: 20pt
├── .headline: 17pt semibold
├── .body: 17pt
├── .callout: 16pt
├── .subheadline: 15pt
├── .footnote: 13pt
├── .caption: 12pt
└── .caption2: 11pt
```

**当前设计对照**:

| 用途 | 当前设计 | 修改后 |
|------|----------|--------|
| 列表标题 | .headline | ✅ 保持 |
| 列表副标题 | .subheadline | ✅ 保持 |
| 列表时间 | .caption | ✅ 保持 |
| 详情标题 | .title2 | ✅ 保持 |
| 表单标签 | .body | ✅ 保持 |

### 6. 列表规范

#### 6.1 List 样式

```
Apple 提供的 List 样式:
├── .automatic: 系统默认（推荐）
├── .plain: 无分组样式
├── .inset: 带边距
├── .insetGrouped: 分组带边距（iOS 14+，推荐）
└── .grouped: 分组无边距
```

**代码要求**:
```swift
// ✅ 推荐样式
List {
    Section("今天") {
        ForEach(todayRecords) { record in
            RecordRowView(record: record)
        }
    }
}
.listStyle(.insetGrouped)  // iOS 标准 grouped 样式
```

#### 6.2 列表交互

```
标准手势:
├── 点击: 进入详情
├── 左滑: 显示删除按钮
├── 右滑: 自定义操作（可选）
├── 长按: 上下文菜单
└── 下拉: 刷新（可选）
```

**当前设计状态**: ✅ 基本符合

**代码要求**:
```swift
List {
    ForEach(records) { record in
        NavigationLink(value: record) {
            RecordRowView(record: record)
        }
    }
    .onDelete(perform: deleteRecords)  // 左滑删除
    .contextMenu {  // 长按菜单
        Button(role: .destructive) {
            // 删除
        } label: {
            Label("删除", systemImage: "trash")
        }
    }
}
.refreshable {  // 下拉刷新
    // 刷新逻辑
}
```

#### 6.3 删除确认

```
Apple 推荐方式:
- 方案 A: 撤销机制（推荐，更符合 iOS 风格）
- 方案 B: 确认对话框
```

**当前设计**: ✅ 已规划撤销机制

**代码要求**:
```swift
// ✅ 推荐方案 - 撤销机制
@State private var deletedRecord: BrewRecord?
@State private var showUndo = false

func delete(_ record: BrewRecord) {
    deletedRecord = record
    modelContext.delete(record)
    showUndo = true

    // 3 秒后确认删除
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        if showUndo {
            showUndo = false
            deletedRecord = nil
        }
    }
}

// 撤销提示
.overlay(alignment: .bottom) {
    if showUndo {
        HStack {
            Text("已删除")
            Spacer()
            Button("撤销") {
                // 恢复记录
                if let record = deletedRecord {
                    modelContext.insert(record)
                }
                showUndo = false
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(10)
        .padding()
    }
}
```

### 7. 表单规范

#### 7.1 Form 样式

```
Apple 标准 Form:
├── 使用 Form 而不是 ScrollView + VStack
├── 使用 Section 分组
├── 使用系统标准控件
└── 避免过度自定义
```

**当前设计状态**: ✅ 基本符合

**代码要求**:
```swift
// ✅ 标准表单结构
Form {
    Section("冲煮方式") {
        Picker("方式", selection: $method) {
            ForEach(BrewMethod.allCases) { method in
                Text(method.rawValue).tag(method)
            }
        }
        .pickerStyle(.segmented)
    }

    Section("参数") {
        // 使用 LabeledContent 或 HStack
        LabeledContent("粉量") {
            HStack {
                TextField("", value: $dose, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                Text("g")
            }
        }
    }
}
```

#### 7.2 键盘处理

```
Apple 要求:
- 键盘不能遮挡输入框
- 点击空白区域收起键盘
- 提供完成按钮
```

**代码要求**:
```swift
// ✅ 键盘处理
Form { ... }
    .scrollDismissesKeyboard(.interactively)  // 滚动时收起键盘
    .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("完成") {
                focusedField = nil  // 收起键盘
            }
        }
    }
```

### 8. 按钮规范

#### 8.1 按钮样式

```
SwiftUI 按钮样式:
├── .borderedProminent: 主要按钮（填充背景）
├── .bordered: 次要按钮（边框）
├── .borderless: 无边框
└── .plain: 纯文本
```

**代码要求**:
```swift
// ✅ 保存按钮
Button("保存") {
    saveRecord()
}
.buttonStyle(.borderedProminent)

// ✅ 取消按钮
Button("取消") {
    dismiss()
}
.buttonStyle(.bordered)

// ✅ 删除按钮
Button(role: .destructive, "删除") {
    deleteRecord()
}
```

#### 8.2 按钮位置

```
导航栏按钮位置:
├── .confirmationAction: 右侧确认操作（保存、完成）
├── .cancellationAction: 左侧取消操作
├── .primaryAction: 右侧主要操作（新建）
├── .secondaryAction: 次要操作
└── .destructiveAction: 破坏性操作（删除）
```

**代码要求**:
```swift
.toolbar {
    ToolbarItem(placement: .cancellationAction) {
        Button("取消") { dismiss() }
    }

    ToolbarItem(placement: .confirmationAction) {
        Button("保存") { saveRecord() }
    }
}
```

### 9. 动画规范

#### 9.1 动画时长

```
Apple 建议时长:
├── 微交互: 0.1-0.2s
├── 标准过渡: 0.2-0.35s
├── 复杂动画: 0.35-0.5s
└── 弹簧动画: 系统默认参数
```

**当前设计状态**: ✅ 符合

#### 9.2 动画原则

```
Apple 动画原则:
├── 有意义: 动画服务于功能
├── 自然: 遵循物理规律
├── 一致: 全局风格统一
├── 可中断: 用户操作优先
└── 克制: 不要过度使用
```

**代码要求**:
```swift
// ✅ 标准动画
withAnimation(.spring()) {
    // 状态变化
}

// ✅ 系统默认转场
NavigationLink(value: item) {
    // 自动使用系统转场
}

// ❌ 避免自定义复杂转场
// 除非有充分理由
```

### 10. 无障碍规范

#### 10.1 VoiceOver

```
Apple 要求:
- 所有交互元素必须有 accessibility label
- 使用标准的 accessibility traits
- 提供有意义的 hint
```

**代码要求**:
```swift
// ✅ 评分组件
HStack {
    ForEach(1...5, id: \.self) { star in
        Image(systemName: star <= rating ? "star.fill" : "star")
            .accessibilityLabel(star <= rating ? "\(star) 星，已选中" : "\(star) 星")
            .accessibilityHint("双击设置评分")
            .onTapGesture { rating = star }
    }
}
.accessibilityElement(children: .combine)
.accessibilityLabel("评分：\(rating) 星")
.accessibilityAdjustableAction { direction in
    switch direction {
    case .increment: rating = min(5, rating + 1)
    case .decrement: rating = max(1, rating - 1)
    @unknown default: break
    }
}

// ✅ 列表项
RecordRowView(record: record)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(record.method.rawValue)，\(record.coffeeBean)，\(record.rating) 星")
```

#### 10.2 动态字体

```
要求: 所有文字必须支持用户字体大小设置
```

**代码要求**:
```swift
// ✅ 使用语义字体
Text("标题")
    .font(.headline)  // 自动支持动态字体

// ❌ 避免固定字号
Text("标题")
    .font(.system(size: 17))  // 不支持动态字体
```

#### 10.3 减少动效

```
要求: 尊重用户"减少动效"设置
```

**代码要求**:
```swift
// ✅ 检查用户设置
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    SomeView()
        .animation(reduceMotion ? .none : .default, value: someState)
}
```

### 11. SF Symbols 规范

#### 11.1 图标使用

```
Apple 要求:
- 使用 SF Symbols 作为系统图标
- 不要修改 SF Symbols 的外观
- 保持图标一致性
```

**当前设计检查**:

| 用途 | 图标 | 状态 |
|------|------|------|
| 意式浓缩 | cup.and.saucer.fill | ✅ |
| 手冲 | drop.fill | ✅ |
| 摩卡壶 | flame.fill | ✅ |
| 列表 Tab | list.bullet | ✅ |
| 设置 Tab | gearshape | ✅ |
| 新建按钮 | plus | ✅ |
| 删除 | trash | ✅ |
| 编辑 | pencil | ✅ |
| 返回 | chevron.left | ✅ 系统自动 |

#### 11.2 图标大小

```
SF Symbols 标准尺寸:
├── .small: 小图标
├── .medium: 中等（默认）
├── .large: 大图标
└── 自定义: .font(.system(size: XX))
```

---

## 二、App Store 审核规范

### 1. 必须避免的问题

| 问题 | 说明 | 检查方法 |
|------|------|----------|
| 崩溃 | App 任何情况下不能崩溃 | 真机充分测试 |
| Bug | 功能性错误 | 测试所有功能 |
| 私有 API | 只能使用公开 API | 代码审查 |
| 占位内容 | 不能有测试文本 | 搜索 "test", "TODO", "lorem" |
| 提及竞品 | 不能提 Android 等 | 检查所有文案 |
| Beta 标识 | 不能有测试版标识 | 检查文案 |

### 2. 元数据要求

#### 2.1 App 名称

```
要求:
├── 长度: ≤ 30 字符
├── 不能包含价格
├── 不能包含 "Beta", "Test" 等字样
└── 与设备上显示一致
```

**当前**: "BrewLog" ✅

#### 2.2 副标题

```
要求:
├── 长度: ≤ 30 字符
├── 简短描述 App 功能
└── 不要重复 App 名称
```

**建议**: "咖啡冲泡参数记录"

#### 2.3 描述

```
要求:
├── 准确描述功能
├── 不能有虚假宣传
└── 不能有未实现的功能
```

#### 2.4 截图

```
要求:
├── 必须有 6.5" iPhone 截图
├── 必须有 5.5" iPhone 截图
├── 截图必须来自真实 App
├── 不能有模拟内容
└── 不能有设备边框
```

**尺寸**:
| 设备 | 尺寸 |
|------|------|
| 6.5" (iPhone 14 Pro Max) | 1288 × 2778 |
| 5.5" (iPhone 8 Plus) | 1242 × 2208 |

### 3. 隐私要求

#### 3.1 隐私政策

```
上架必须:
├── 提供隐私政策 URL
├── 说明收集什么数据
├── 说明数据用途
└── 说明数据存储
```

**BrewLog 隐私政策要点**:
```
- 本地存储，不收集用户数据
- 不需要网络权限
- 不需要登录
- 数据仅存储在用户设备
```

#### 3.2 权限请求

```
要求:
- 使用系统权限前必须解释原因
- 在 Info.plist 中添加使用说明
```

**BrewLog 需要的权限**:
| 权限 | 用途 | Info.plist Key |
|------|------|----------------|
| 无 | 本地 App，不需要特殊权限 | - |

### 4. 年龄分级

```
BrewLog 预估:
├── 无暴力内容
├── 无成人内容
├── 无赌博
├── 无社交功能
└── 预估评级: 4+ (无年龄限制)
```

---

## 三、当前设计修改清单

### P0 - 必须修改

| # | 问题 | 修改方案 | 涉及文件 |
|---|------|----------|----------|
| 1 | 评分星星点击区域太小 | 增加 44pt 点击区域 | views.md, ui-ux.md |
| 2 | Tab Bar 有「新建」操作 | 移除，改为导航栏按钮 | views.md |

### P1 - 强烈建议修改

| # | 问题 | 修改方案 | 涉及文件 |
|---|------|----------|----------|
| 3 | 颜色硬编码 | 使用 Asset Catalog | ui-ux.md |
| 4 | 深色模式配色不完整 | 完善配色方案 | ui-ux.md |
| 5 | 无障碍标签缺失 | 添加 VoiceOver 支持 | ui-ux.md |

### P2 - 建议优化

| # | 问题 | 修改方案 | 涉及文件 |
|---|------|----------|----------|
| 6 | 表单样式可更原生 | 使用 LabeledContent | views.md |
| 7 | 键盘处理不完整 | 添加完成按钮 | views.md |

---

## 四、详细修改方案

### 修改 1: Tab 结构调整

**之前**:
```
TabView
├── Tab 1: 记录
├── Tab 2: 新建
└── Tab 3: 设置
```

**之后**:
```
TabView
├── Tab 1: 记录（含导航栏 [+] 按钮）
└── Tab 2: 设置
```

**代码**:
```swift
// ContentView.swift
struct ContentView: View {
    var body: some View {
        TabView {
            RecordListView()
                .tabItem {
                    Label("记录", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
        .tint(.coffee)
    }
}

// RecordListView.swift
struct RecordListView: View {
    @State private var showNewRecord = false

    var body: some View {
        NavigationStack {
            List { ... }
            .navigationTitle("BrewLog")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewRecord = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewRecord) {
                NewRecordView()
            }
        }
    }
}
```

### 修改 2: 评分组件触控区域

**之前**:
```swift
Image(systemName: "star.fill")
    .font(.system(size: 28))
    .foregroundColor(.yellow)
```

**之后**:
```swift
Image(systemName: "star.fill")
    .font(.system(size: 28))
    .foregroundColor(.systemYellow)
    .frame(width: 44, height: 44)
    .contentShape(Rectangle())
```

### 修改 3: 颜色系统

**之前**:
```swift
extension Color {
    static let coffee = Color(hex: "6F4E37")
}
```

**之后**:
```swift
// 在 Assets.xcassets 中创建 Color Set
// Coffee.colorset:
//   - Any: #6F4E37
//   - Dark: #C68B59

extension Color {
    static let coffee = Color("Coffee")
    static let coffeeLight = Color("CoffeeLight")
    static let cream = Color("Cream")
}
```

### 修改 4: 无障碍支持

```swift
// 评分组件
HStack {
    ForEach(1...5, id: \.self) { star in
        Image(systemName: star <= rating ? "star.fill" : "star")
            .font(.system(size: 28))
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .foregroundColor(star <= rating ? .systemYellow : .secondary)
            .onTapGesture { rating = star }
    }
}
.accessibilityElement(children: .combine)
.accessibilityLabel("评分：\(rating) 星")
.accessibilityAdjustableAction { direction in
    switch direction {
    case .increment: rating = min(5, rating + 1)
    case .decrement: rating = max(1, rating - 1)
    @unknown default: break
    }
}
```

---

## 五、检查清单

### 开发阶段检查

```
每完成一个功能:
□ 使用语义字体
□ 触控区域 ≥ 44pt
□ 颜色使用 Asset Catalog
□ VoiceOver 可用
□ 深色模式正常
```

### 提交前检查

```
□ 无崩溃
□ 无 Bug
□ 无占位文本
□ 无 "Beta" 字样
□ 隐私政策已准备
□ 截图已准备
□ 元数据已填写
□ 真机测试通过
```

---

*文档版本: 1.0*
*创建日期: 2025-02-22*
