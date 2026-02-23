# UI/UX 设计规范

> 遵循 Apple Human Interface Guidelines

---

## Apple HIG 设计原则

### 三大核心原则

| 原则 | 英文 | 说明 | 我们的设计 |
|------|------|------|------------|
| 清晰 | Clarity | 文字清晰、图标精确、功能明确 | ✅ 语义字体、SF Symbols |
| 顺从 | Deference | UI 服务于内容，不喧宾夺主 | ✅ 简洁界面、内容优先 |
| 深度 | Depth | 层次分明，有视觉层级 | ✅ 合理的层级结构 |

### 六大交互原则

1. **审美完整性** - 视觉设计与应用功能一致
2. **一致性** - 遵循系统和应用内的标准
3. **直接操控** - 用户直接控制屏幕内容
4. **反馈** - 每个操作都有即时反馈
5. **隐喻** - 当虚拟对象模仿现实时学习更容易
6. **用户控制** - 用户控制设备，而不是应用控制

---

## 布局规范

### 安全区域 (Safe Area)

```
必须尊重的安全区域:
├── 顶部: 状态栏 + 导航栏
├── 底部: Home Indicator (全面屏 34pt)
└── SwiftUI 自动处理

全面屏 iPhone 顶部安全区域:
├── iPhone X-14: 44pt (状态栏) + 44pt (导航栏) = 88pt
├── iPhone 14 Pro+: 动态岛 + 导航栏 ≈ 91pt
└── 底部安全区域: 34pt
```

**代码**:
```swift
// ✅ SwiftUI 自动处理安全区域
NavigationStack {
    List { ... }
}
// 无需手动处理
```

### 响应式布局

```
必须支持的设备尺寸:
├── iPhone SE (3rd): 375 × 667 pt
├── iPhone 14: 390 × 844 pt
├── iPhone 14 Plus: 428 × 926 pt
├── iPhone 14 Pro: 393 × 852 pt
└── iPhone 14 Pro Max: 430 × 932 pt
```

**代码**:
```swift
// ❌ 错误 - 硬编码尺寸
.frame(width: 375, height: 100)

// ✅ 正确 - 自适应布局
.frame(maxWidth: .infinity)
.padding()
```

### 触控目标

```
Apple 强制要求:
├── 最小触控区域: 44 × 44 pt
├── 控件间距: 至少 8pt
└── 不要在屏幕边缘 44pt 范围内放置重要交互
```

**组件触控检查**:

| 组件 | 显示大小 | 触控区域 | 状态 |
|------|----------|----------|------|
| 评分星星 | 28pt | 44pt | ✅ |
| Tab 图标 | 系统默认 | 44pt | ✅ |
| 列表项 | 72pt 高 | 72pt | ✅ |
| 按钮 | 50pt 高 | 50pt | ✅ |
| 表单行 | 44pt 高 | 44pt | ✅ |

---

## 导航规范

### Tab Bar 规范

```
Apple HIG 要求:
├── Tab 数量: 3-5 个（最多 5 个）
├── Tab 位置: 始终在屏幕底部
├── Tab 内容: 只放主要导航目的地，不放操作按钮
├── 图标: 使用 SF Symbols
└── 选中状态: 系统自动处理（使用 tint color）
```

**✅ 正确的 Tab 结构**:
```
TabView
├── Tab 1: 记录（导航目的地）
└── Tab 2: 设置（导航目的地）

新建入口: 列表页导航栏右上角 [+] 按钮
```

**❌ 错误示例**:
```
TabView
├── Tab 1: 记录
├── Tab 2: 新建  ← 不符合规范，"新建"是操作不是导航
└── Tab 3: 设置
```

### Navigation Bar 规范

```
位置与内容:
├── 位置: 始终在顶部
├── 标题: 大标题或小标题，居中显示
├── 返回按钮: 左侧，可显示前页标题
├── 操作按钮: 右侧，使用 SF Symbols
└── 颜色: 使用系统颜色或品牌色
```

**Toolbar 位置常量**:

| Placement | 用途 | 示例 |
|-----------|------|------|
| `.cancellationAction` | 左侧取消 | 取消按钮 |
| `.confirmationAction` | 右侧确认 | 保存按钮 |
| `.primaryAction` | 右侧主要操作 | 新建、编辑 |
| `.destructiveAction` | 破坏性操作 | 删除 |

### 页面转场

```
Apple 标准转场:
├── push/pop: 右滑进入，右滑返回（NavigationLink）
├── sheet: 底部滑入，下滑关闭
└── fullScreenCover: 全屏覆盖
```

---

## 交互设计

### 1. 新建记录流程

**设计目标**: 3 秒内开始填写，10 秒内完成保存

**交互流程**:

```
点击 [+] → Sheet 弹出 → 参数表单 → 保存
   │           │            │        │
   │           0.3s        自动      0.2s
   │           spring      聚焦      动画
```

### 2. 列表交互

**手势支持**:

| 手势 | 操作 | 动画 |
|------|------|------|
| 点击 | 进入详情 | 系统默认 push |
| 左滑 | 显示删除 | 按钮渐显 |
| 长按 | 快捷菜单 | 系统菜单 |
| 下拉 | 刷新列表 | 系统动画 |

### 3. 评分交互

**设计要求**:
- 单手操作
- 触控区域 44pt
- 即时视觉反馈
- 触觉反馈（Haptic）

```swift
// ✅ 完整的评分交互
Image(systemName: "star.fill")
    .font(.system(size: 28))         // 显示 28pt
    .frame(width: 44, height: 44)    // 触控 44pt
    .contentShape(Rectangle())        // 整个区域可点击
    .onTapGesture {
        withAnimation(.spring(response: 0.2)) {
            rating = star
        }
        // 触觉反馈
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
```

### 4. 表单交互

**输入优化**:

| 字段类型 | 优化方式 |
|----------|----------|
| 数字 | `.keyboardType(.decimalPad)` |
| 文本 | 自动大写 |
| 选项 | `.pickerStyle(.segmented)` |
| 日期 | `DatePicker` |

**键盘处理**:

```swift
// ✅ 键盘工具栏
.toolbar {
    ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button("完成") {
            focusedField = nil
        }
    }
}
// ✅ 滚动时收起键盘
.scrollDismissesKeyboard(.interactively)
```

### 5. 删除交互

**Apple 推荐方式**: 撤销机制

```swift
// ✅ 撤销机制（比弹窗确认更符合 iOS 风格）
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
```

---

## 动画设计

### 动画原则

- **自然**: 遵循物理规律
- **有意义**: 动画服务于功能
- **一致性**: 全局动画风格统一
- **可中断**: 用户操作优先
- **尊重用户设置**: 检查 `accessibilityReduceMotion`

### 动画时长

| 类型 | 时长 | 曲线 |
|------|------|------|
| 微交互 | 0.1-0.2s | easeOut |
| 标准过渡 | 0.2-0.35s | spring |
| 复杂动画 | 0.35-0.5s | spring |

### 代码规范

```swift
// ✅ 检查减少动效设置
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    SomeView()
        .animation(reduceMotion ? .none : .spring(), value: someState)
}

// ✅ 使用系统默认转场
NavigationLink(value: item) {
    // 自动使用系统转场
}

// ❌ 避免自定义复杂转场（除非有充分理由）
```

---

## 视觉设计

### 配色系统（Asset Catalog）

> ⚠️ **使用 Asset Catalog 定义颜色，自动适配深浅模式**

**Color Set 配置**:

| 颜色名称 | 浅色模式 | 深色模式 |
|----------|----------|----------|
| Coffee | #6F4E37 | #C68B59 |
| CoffeeLight | #C68B59 | #D4A574 |
| CoffeeDark | #3E2723 | #8B6914 |
| Cream | #FAF8F5 | #1C1C1E |

**系统语义颜色**:

| 颜色 | 用途 |
|------|------|
| `.primary` | 主文字（自动适配） |
| `.secondary` | 次要文字 |
| `.systemYellow` | 评分星星（选中） |
| `.systemRed` | 删除/错误 |
| `.systemGreen` | 成功 |
| `.background` | 背景 |
| `.regularMaterial` | 毛玻璃效果 |

### 字体规范

**使用语义字体**（支持动态类型）:

```swift
// ✅ 正确 - 语义字体
Text("标题").font(.headline)
Text("正文").font(.body)
Text("说明").font(.caption)

// ❌ 避免 - 固定字号（不支持动态字体）
Text("标题").font(.system(size: 17))
```

**字体层级**:

| 样式 | 大小 | 用途 |
|------|------|------|
| .largeTitle | 34pt | 大标题 |
| .title2 | 22pt | 详情页标题 |
| .headline | 17pt semibold | 列表标题 |
| .body | 17pt | 正文 |
| .subheadline | 15pt | 副标题 |
| .caption | 12pt | 辅助信息 |

### 间距系统

```swift
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
```

### 圆角规范

| 元素 | 圆角 |
|------|------|
| 卡片 | 12pt |
| 按钮 | 10pt |
| 输入框 | 8pt |
| 标签 | 6pt |

---

## 组件规范

### 1. 列表项

```
┌─────────────────────────────────────┐
│                                     │
│  ☕  意式浓缩           15:30  >    │
│      耶加雪菲                       │
│      ★★★★☆  ·  18g / 36ml / 27s    │
│                                     │
└─────────────────────────────────────┘
  高度: 72pt (≥ 44pt 触控要求 ✅)
  内边距: 16pt
  使用 .insetGrouped 样式
```

### 2. 按钮

**主按钮**:
```swift
Button("保存") { save() }
    .buttonStyle(.borderedProminent)
    .tint(.coffee)
```

**次要按钮**:
```swift
Button("取消") { dismiss() }
    .buttonStyle(.bordered)
```

**删除按钮**:
```swift
Button(role: .destructive, "删除") { delete() }
```

### 3. 表单字段

```swift
// ✅ 使用 LabeledContent（iOS 16+）
LabeledContent("粉量") {
    HStack {
        TextField("", value: $dose, format: .number)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
        Text("g")
            .foregroundColor(.secondary)
    }
}
```

### 4. 评分组件

```
★★★★☆

星星显示: 28pt
触控区域: 44pt (Apple HIG ✅)
间距: 4pt
选中: .systemYellow
未选中: .secondary
```

---

## 深色模式

### 适配策略

```swift
// ✅ 使用语义颜色
.foregroundColor(.primary)      // 主文字
.foregroundColor(.secondary)    // 次要文字
.background(.background)        // 背景

// ✅ 使用 Asset Catalog 颜色
.foregroundColor(.coffee)       // 自动适配深浅模式
```

### 配色对照表

| 用途 | 浅色模式 | 深色模式 | 对比度 |
|------|----------|----------|--------|
| 背景 | #FAF8F5 | #1C1C1E | - |
| 卡片 | #FFFFFF | #2C2C2E | - |
| 主色 | #6F4E37 | #C68B59 | ✅ |
| 主文字 | #1C1C1E | #FFFFFF | ✅ 15:1 |
| 次要文字 | #8E8E93 | #8E8E93 | ✅ |

### 对比度要求

```
WCAG 2.0 要求（Apple 遵循）:
├── 正文文字: 对比度 ≥ 4.5:1
├── 大标题: 对比度 ≥ 3:1
└── 图标: 对比度 ≥ 3:1
```

---

## 无障碍设计

### VoiceOver

```swift
// ✅ 评分组件
.accessibilityElement(children: .combine)
.accessibilityLabel("评分：\(rating) 星")
.accessibilityHint("双击调整评分")
.accessibilityAdjustableAction { direction in
    switch direction {
    case .increment: rating = min(5, rating + 1)
    case .decrement: rating = max(1, rating - 1)
    @unknown default: break
    }
}

// ✅ 列表项
.accessibilityElement(children: .combine)
.accessibilityLabel("\(method)，\(coffeeBean)，\(rating) 星")

// ✅ 按钮
.accessibilityLabel("新建记录")
.accessibilityHint("点击创建新的冲煮记录")
```

### 动态字体

```swift
// ✅ 使用语义字体，自动支持动态字体
.font(.headline)
.font(.body)
.font(.caption)

// ❌ 避免固定字号
.font(.system(size: 17))
```

### 减少动效

```swift
// ✅ 尊重用户"减少动效"设置
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    SomeView()
        .animation(reduceMotion ? .none : .spring(), value: someState)
}
```

---

## SF Symbols 使用

### 图标规范

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

### 图标大小

```swift
// 使用语义尺寸
.imageScale(.small)
.imageScale(.medium)
.imageScale(.large)

// 或自定义
.font(.system(size: 20))
```

---

## 交互细节清单

### 必须有

- [x] 触控区域 ≥ 44pt
- [x] 使用语义字体
- [x] 颜色使用 Asset Catalog
- [x] VoiceOver 标签完整
- [x] 深色模式适配
- [x] 键盘工具栏有"完成"按钮
- [x] 删除使用撤销机制
- [x] 动画尊重"减少动效"设置
- [x] Tab Bar 只用于导航

### 检查方法

```swift
// 开发时检查触控区域
.onAppear {
    // 确保所有可点击元素 ≥ 44pt
}
```

---

## App Store 审核注意事项

### 必须避免

| 问题 | 检查方法 |
|------|----------|
| 崩溃 | 真机充分测试 |
| Bug | 测试所有功能 |
| 私有 API | 代码审查 |
| 占位内容 | 搜索 "test", "TODO" |
| Beta 标识 | 检查所有文案 |

### 元数据要求

- App 名称: ≤ 30 字符
- 副标题: ≤ 30 字符
- 隐私政策: 必须提供 URL
- 截图: 6.5" 和 5.5" iPhone

---

*文档版本: 2.0*
*最后更新: 2025-02-22*
*遵循: Apple Human Interface Guidelines*
