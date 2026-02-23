# 视图设计

> BrewLog 界面设计与组件（遵循 Apple HIG）

---

## 界面结构

### 导航结构

```
TabView（符合 Apple HIG - Tab 只用于导航，不用于操作）
├── Tab 1: 记录列表（含导航栏 [+] 按钮）
└── Tab 2: 设置
```

> ⚠️ **Apple HIG 要求**: Tab Bar 只放导航目的地，不放操作按钮。"新建"是操作，不是导航目的地。

### 页面流程

```
┌─────────────┐     ┌─────────────┐
│  记录列表   │ ──> │  记录详情   │
└─────────────┘     └─────────────┘
       │
       │ [+] 导航栏按钮
       ▼
┌─────────────┐
│  新建记录   │  (Sheet 弹出)
└─────────────┘
```

---

## 页面设计

### 1. ContentView (主页面)

TabView 框架，包含两个 Tab。

```swift
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
        .tint(.coffee)  // 使用 Asset Catalog 中的颜色
    }
}
```

---

### 2. RecordListView (记录列表)

显示所有冲煮记录，包含新建按钮。

**布局**:

```
┌────────────────────────────────┐
│  BrewLog              [+]      │  NavigationBar（含新建按钮）
├────────────────────────────────┤
│  [全部 ▼] [今天 ▼]             │  筛选器
├────────────────────────────────┤
│  今天                          │  Section Header
│  ┌──────────────────────────┐  │
│  │ ☕ 意式浓缩               │  │
│  │ 耶加雪菲 · 4★            │  │
│  │ 18g / 36ml / 27s        │  │
│  └──────────────────────────┘  │
│  ┌──────────────────────────┐  │
│  │ 💧 手冲                   │  │
│  │ 肯尼亚 · 5★              │  │
│  │ 15g / 225ml / 2:30      │  │
│  └──────────────────────────┘  │
├────────────────────────────────┤
│  昨天                          │
│  ...                           │
└────────────────────────────────┘
```

**代码框架**:

```swift
struct RecordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BrewRecord.date, order: .reverse)
    private var records: [BrewRecord]

    @State private var searchText = ""
    @State private var selectedMethod: BrewMethod?
    @State private var showNewRecord = false  // 控制 Sheet 显示
    @State private var deletedRecord: BrewRecord?  // 撤销机制
    @State private var showUndo = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedRecords.keys.sorted().reversed(), id: \.self) { date in
                    Section(header: Text(date.formatted(date: .abbreviated, time: .omitted))) {
                        ForEach(groupedRecords[date]!) { record in
                            NavigationLink(value: record) {
                                RecordRowView(record: record)
                            }
                        }
                        .onDelete(perform: deleteRecords)
                    }
                }
            }
            .listStyle(.insetGrouped)  // Apple 标准 grouped 样式
            .navigationTitle("BrewLog")
            .searchable(text: $searchText)
            .toolbar {
                // ✅ Apple HIG: 新建按钮放在导航栏
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewRecord = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("新建记录")
                    .accessibilityHint("点击创建新的冲煮记录")
                }
            }
            .sheet(isPresented: $showNewRecord) {
                NewRecordView()
            }
            .overlay(alignment: .bottom) {
                // 撤销提示（Apple 推荐方式）
                if showUndo {
                    undoToast
                }
            }
        }
    }

    private var undoToast: some View {
        HStack {
            Text("已删除")
            Spacer()
            Button("撤销") {
                if let record = deletedRecord {
                    modelContext.insert(record)
                }
                showUndo = false
                deletedRecord = nil
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(10)
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func deleteRecords(offsets: IndexSet) {
        for index in offsets {
            deletedRecord = groupedRecords[currentSection]![index]
            modelContext.delete(groupedRecords[currentSection]![index])
        }
        showUndo = true

        // 3 秒后确认删除
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if showUndo {
                showUndo = false
                deletedRecord = nil
            }
        }
    }
}
```

---

### 3. RecordRowView (列表行)

单条记录的展示组件。

**布局**:

```
┌────────────────────────────────┐
│ [图标] 意式浓缩                │
│        耶加雪菲 · ★★★★☆       │
│        18g · 36ml · 27s        │
└────────────────────────────────┘
高度: 72pt（符合 Apple 44pt 最小触控要求）
```

**代码框架**:

```swift
struct RecordRowView: View {
    let record: BrewRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: record.method.icon)
                Text(record.method.rawValue)
                    .font(.headline)
                Spacer()
                Text(record.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(record.coffeeBean)
                .font(.subheadline)

            StarRating(rating: record.rating, isEditable: false)

            Text(parameterSummary)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        // ✅ VoiceOver 支持
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.method.rawValue)，\(record.coffeeBean)，\(record.rating) 星")
    }
}
```

---

### 4. RecordDetailView (记录详情)

显示单条记录的完整信息。

**布局**:

```
┌────────────────────────────────┐
│  < 返回              编辑      │
├────────────────────────────────┤
│  意式浓缩                      │
│  2025年2月21日 15:30          │
│  ★★★★☆                       │
├────────────────────────────────┤
│  参数                          │
│  ────────────────────          │
│  研磨度    3.5                 │
│  粉量      18 g                │
│  萃取量    36 ml               │
│  时间      27 秒               │
│  水温      93 °C               │
│  压力      9 bar               │
├────────────────────────────────┤
│  咖啡豆                        │
│  ────────────────────          │
│  名称      耶加雪菲            │
│  烘焙      中浅烘              │
├────────────────────────────────┤
│  笔记                          │
│  ────────────────────          │
│  酸度明亮，花香突出...         │
└────────────────────────────────┘
```

**代码框架**:

```swift
struct RecordDetailView: View {
    let record: BrewRecord

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.method.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(record.date.formatted())
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    StarRating(rating: record.rating, isEditable: false)
                }
                .padding(.vertical, 8)
            }

            Section("参数") {
                // ✅ 使用 LabeledContent（iOS 16+）
                LabeledContent("研磨度") {
                    Text(record.grindSize ?? "-")
                }

                switch record.method {
                case .espresso:
                    LabeledContent("粉量") { Text("\(record.espressoDose ?? 0) g") }
                    LabeledContent("萃取量") { Text("\(record.espressoYield ?? 0) ml") }
                    LabeledContent("时间") { Text("\(record.espressoTime ?? 0) 秒") }
                    LabeledContent("水温") { Text("\(record.espressoTemp ?? 0) °C") }
                    LabeledContent("压力") { Text("\(record.espressoPressure ?? 0) bar") }
                case .pourOver:
                    LabeledContent("粉量") { Text("\(record.pourOverDose ?? 0) g") }
                    LabeledContent("水量") { Text("\(record.pourOverWater ?? 0) ml") }
                    LabeledContent("水温") { Text("\(record.pourOverTemp ?? 0) °C") }
                    LabeledContent("闷蒸") { Text("\(record.pourOverBloomTime ?? 0) 秒") }
                    LabeledContent("注水次数") { Text("\(record.pourOverPours ?? 0) 次") }
                case .mokaPot:
                    LabeledContent("粉量") { Text("\(record.mokaDose ?? 0) g") }
                    LabeledContent("水量") { Text("\(record.mokaWater ?? 0) ml") }
                    LabeledContent("火力") { Text(record.mokaHeat?.rawValue ?? "-") }
                    LabeledContent("时间") { Text("\(record.mokaTime ?? 0) 秒") }
                }
            }

            Section("咖啡豆") {
                LabeledContent("名称") { Text(record.coffeeBean) }
                LabeledContent("烘焙") { Text(record.roastLevel?.rawValue ?? "-") }
            }

            if let notes = record.notes, !notes.isEmpty {
                Section("笔记") {
                    Text(notes)
                }
            }
        }
        .formStyle(.insetGrouped)
        .navigationTitle("记录详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("编辑") {
                    // 编辑逻辑
                }
            }
        }
    }
}
```

---

### 5. NewRecordView (新建记录)

创建新的冲煮记录，以 Sheet 形式弹出。

**布局**:

```
┌────────────────────────────────┐
│  取消        新建       保存   │
├────────────────────────────────┤
│  冲煮方式                      │
│  ┌─────┬─────┬─────┐          │
│  │ 意式│ 手冲│ 摩卡│          │
│  └─────┴─────┴─────┘          │
├────────────────────────────────┤
│  参数                          │
│  研磨度    [__________]        │
│  粉量      [_____] g           │
│  萃取量    [_____] ml          │
│  ...                           │
├────────────────────────────────┤
│  咖啡豆                        │
│  名称      [__________]        │
│  烘焙      [中烘 ▼]            │
├────────────────────────────────┤
│  评分                          │
│  ★★★☆☆                       │
├────────────────────────────────┤
│  笔记                          │
│  [________________]            │
│  [________________]            │
├────────────────────────────────┤
│           [完成]               │  键盘工具栏
└────────────────────────────────┘
```

**代码框架**:

```swift
struct NewRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMethod: BrewMethod = .pourOver
    @State private var record: BrewRecord
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case coffeeBean, notes, dose, yield, time
    }

    var body: some View {
        NavigationStack {
            Form {
                // 冲煮方式选择
                Section("冲煮方式") {
                    Picker("方式", selection: $selectedMethod) {
                        ForEach(BrewMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 根据方式显示对应参数表单
                switch selectedMethod {
                case .espresso:
                    EspressoFormSection(record: $record)
                case .pourOver:
                    PourOverFormSection(record: $record)
                case .mokaPot:
                    MokaPotFormSection(record: $record)
                }

                // 通用参数
                CommonFormSection(record: $record)
            }
            .formStyle(.insetGrouped)
            .navigationTitle("新建记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(!isValid)
                }

                // ✅ 键盘工具栏 - 完成按钮
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完成") {
                        focusedField = nil
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)  // ✅ 滚动时收起键盘
        }
    }

    private func saveRecord() {
        modelContext.insert(record)
        dismiss()
    }
}
```

---

### 6. SettingsView (设置)

App 设置页面。

**布局**:

```
┌────────────────────────────────┐
│  设置                          │
├────────────────────────────────┤
│  关于                          │
│  ────────────────────          │
│  版本      1.0.0               │
│  作者      Your Name           │
├────────────────────────────────┤
│  数据                          │
│  ────────────────────          │
│  导出数据    >                 │
│  清除数据    >                 │
└────────────────────────────────┘
```

**代码框架**:

```swift
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("关于") {
                    LabeledContent("版本") {
                        Text("1.0.0")
                    }

                    LabeledContent("作者") {
                        Text("Your Name")
                    }
                }

                Section("数据") {
                    Button {
                        // 导出逻辑
                    } label: {
                        Label("导出数据", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        // 清除数据逻辑
                    } label: {
                        Label("清除数据", systemImage: "trash")
                    }
                }
            }
            .formStyle(.insetGrouped)
            .navigationTitle("设置")
        }
    }
}
```

---

## 组件设计

### 1. StarRating (评分组件)

**Apple HIG 要求**: 触控区域必须 ≥ 44pt

```swift
struct StarRating: View {
    @Binding var rating: Int
    var isEditable: Bool = true

    // ✅ VoiceOver 支持
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    // ✅ 显示大小 28pt
                    .font(.system(size: 28))
                    // ✅ 点击区域 44pt（Apple HIG 要求）
                    .frame(width: 44, height: 44)
                    // ✅ 整个 frame 可点击
                    .contentShape(Rectangle())
                    // ✅ 使用系统颜色，自动适配深浅模式
                    .foregroundColor(star <= rating ? .systemYellow : .secondary)
                    .onTapGesture {
                        guard isEditable else { return }
                        withAnimation(reduceMotion ? .none : .spring(response: 0.2)) {
                            rating = star
                        }
                        // 触觉反馈
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
            }
        }
        // ✅ VoiceOver 支持
        .accessibilityElement(children: .combine)
        .accessibilityLabel("评分：\(rating) 星")
        .accessibilityHint(isEditable ? "双击调整评分" : "")
        .accessibilityAdjustableAction { direction in
            guard isEditable else { return }
            switch direction {
            case .increment:
                rating = min(5, rating + 1)
            case .decrement:
                rating = max(1, rating - 1)
            @unknown default:
                break
            }
        }
    }
}
```

**触控区域说明**:

```
┌──────────────────────────────────────────┐
│                                          │
│     ┌──────┐ ┌──────┐ ┌──────┐ ...      │
│     │  ★   │ │  ★   │ │  ★   │          │
│     │ 28pt │ │ 28pt │ │ 28pt │          │
│     └──────┘ └──────┘ └──────┘          │
│      44pt    44pt    44pt                │
│                                          │
│  显示: 28pt（视觉效果）                   │
│  触控: 44pt（Apple HIG 最小要求）         │
└──────────────────────────────────────────┘
```

### 2. ParameterField (参数输入)

```swift
struct ParameterField: View {
    let title: String
    let unit: String
    @Binding var value: Double

    var body: some View {
        // ✅ 使用 LabeledContent（iOS 16+ 原生样式）
        LabeledContent(title) {
            HStack(spacing: 4) {
                TextField("", value: $value, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                Text(unit)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

### 3. MethodBadge (方式标签)

```swift
struct MethodBadge: View {
    let method: BrewMethod

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: method.icon)
            Text(method.rawValue)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(method.color.opacity(0.2))
        .foregroundColor(method.color)
        .cornerRadius(6)  // Apple 推荐的小圆角
        // ✅ VoiceOver
        .accessibilityLabel(method.rawValue)
    }
}
```

---

## 颜色系统（使用 Asset Catalog）

> ⚠️ **Apple HIG 要求**: 使用 Asset Catalog 定义颜色，自动适配深浅模式

### Asset Catalog 配置

在 `Assets.xcassets` 中创建以下 Color Set：

**Coffee.colorset**:
- Any Appearance: `#6F4E37`
- Dark Appearance: `#C68B59`

**CoffeeLight.colorset**:
- Any Appearance: `#C68B59`
- Dark Appearance: `#D4A574`

**Cream.colorset**:
- Any Appearance: `#FAF8F5`
- Dark Appearance: `#1C1C1E`

### 代码使用

```swift
extension Color {
    // ✅ 从 Asset Catalog 加载，自动适配深浅模式
    static let coffee = Color("Coffee")
    static let coffeeLight = Color("CoffeeLight")
    static let coffeeDark = Color("CoffeeDark")
    static let cream = Color("Cream")
}
```

### 颜色对照表

| 用途 | 浅色模式 | 深色模式 | 对比度 |
|------|----------|----------|--------|
| 主色 | #6F4E37 | #C68B59 | ✅ |
| 背景 | #FAF8F5 | #1C1C1E | ✅ |
| 卡片 | #FFFFFF | #2C2C2E | ✅ |
| 主文字 | #1C1C1E | #FFFFFF | ✅ 15:1 |
| 次要文字 | #8E8E93 | #8E8E93 | ✅ |

---

## 检查清单

### 开发阶段

- [ ] 触控区域 ≥ 44pt
- [ ] 使用语义字体（.headline, .body 等）
- [ ] 颜色使用 Asset Catalog
- [ ] VoiceOver 标签完整
- [ ] 深色模式正常显示
- [ ] 键盘不遮挡输入框

### 提交前

- [ ] 无崩溃、无 Bug
- [ ] 无占位文本
- [ ] 真机测试通过
- [ ] 所有交互有反馈

---

*文档版本: 2.0*
*最后更新: 2025-02-22*
*遵循: Apple Human Interface Guidelines*
