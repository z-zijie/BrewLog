# BrewLog 开发路线图

> 小步快跑，频繁迭代，逐步优化

---

## 迭代策略

**核心原则**：
- 每个版本只做一件事
- 先跑通，再优化
- 快速验证，及时修复

---

## 版本规划总览

| 版本 | 目标 | 预计时间 |
|------|------|----------|
| v0.1 | 项目搭建 | 0.5 天 |
| v0.2 | 数据模型 | 0.5 天 |
| v0.3 | 列表展示 | 0.5 天 |
| v0.4 | 新建记录 | 1 天 |
| v0.5 | 详情查看 | 0.5 天 |
| v0.6 | 编辑删除 | 0.5 天 |
| v0.7 | UI 美化 | 0.5 天 |
| v0.8 | 优化打磨 | 0.5 天 |
| v0.9 | 真机测试 | 0.5 天 |
| v1.0 | 正式发布 | - |

---

## v0.1 项目搭建

**目标**: 创建可运行的空项目

**任务清单**:

```
1. 创建 Xcode 项目
   - [ ] 选择 App 模板
   - [ ] Product Name: BrewLog
   - [ ] Interface: SwiftUI
   - [ ] Storage: SwiftData
   - [ ] Language: Swift

2. 基础配置
   - [ ] Bundle Identifier: com.yourname.brewlog
   - [ ] Minimum iOS: 15.0
   - [ ] 配置 App Icon (可选)

3. 创建文件夹结构
   - [ ] Models/
   - [ ] Views/
   - [ ] Components/
   - [ ] Extensions/

4. 创建占位文件
   - [ ] Models/.gitkeep
   - [ ] Views/.gitkeep
   - [ ] Components/.gitkeep
   - [ ] Extensions/.gitkeep
```

**验收标准**:
- 项目可编译
- 模拟器可运行
- 显示空白界面

**不做的**:
- 暂不创建数据模型
- 暂不写业务代码

---

## v0.2 数据模型

**目标**: 定义核心数据结构

**前置依赖**: v0.1 完成

**任务清单**:

```
1. 创建枚举
   - [ ] Models/BrewMethod.swift
   - [ ] Models/RoastLevel.swift
   - [ ] Models/HeatLevel.swift

2. 创建主模型
   - [ ] Models/BrewRecord.swift
   - [ ] 配置 SwiftData @Model
   - [ ] 定义所有字段

3. 配置 SwiftData
   - [ ] 修改 BrewLogApp.swift
   - [ ] 添加 .modelContainer

4. 验证模型
   - [ ] 编译通过
   - [ ] 无运行时错误
```

**代码检查点**:

```swift
// BrewLogApp.swift 应该包含
.modelContainer(for: BrewRecord.self)
```

**验收标准**:
- 所有文件编译通过
- App 可启动
- 控制台无错误

**不做的**:
- 暂不创建界面
- 暂不处理数据

---

## v0.3 列表展示

**目标**: 显示记录列表（空状态）

**前置依赖**: v0.2 完成

**任务清单**:

```
1. 创建 ContentView
   - [ ] Views/ContentView.swift
   - [ ] TabView 结构
   - [ ] 第一个 Tab: 记录

2. 创建 RecordListView
   - [ ] Views/RecordListView.swift
   - [ ] List 基础结构
   - [ ] @Query 查询数据
   - [ ] 空状态提示

3. 连接导航
   - [ ] NavigationStack
   - [ ] navigationTitle
```

**代码检查点**:

```swift
// RecordListView 核心代码
@Query(sort: \BrewRecord.date, order: .reverse)
private var records: [BrewRecord]

var body: some View {
    NavigationStack {
        List {
            if records.isEmpty {
                Text("还没有记录")
            } else {
                ForEach(records) { record in
                    Text(record.method.rawValue)
                }
            }
        }
        .navigationTitle("BrewLog")
    }
}
```

**验收标准**:
- 列表页显示
- 空状态提示可见
- Tab 切换正常

**不做的**:
- 暂不美化列表项
- 暂不添加新建功能

---

## v0.4 新建记录 (基础版)

**目标**: 能够创建最简单的记录

**前置依赖**: v0.3 完成

**任务清单**:

```
1. 创建 NewRecordView
   - [ ] Views/NewRecordView.swift
   - [ ] 第二个 Tab
   - [ ] Form 表单

2. 实现最小表单
   - [ ] 冲煮方式选择 (Picker)
   - [ ] 咖啡豆名称 (TextField)
   - [ ] 评分 (Stepper)
   - [ ] 保存按钮

3. 实现保存
   - [ ] modelContext.insert()
   - [ ] 自动返回列表
```

**代码检查点**:

```swift
// NewRecordView 核心代码
@Environment(\.modelContext) private var modelContext

@State private var method: BrewMethod = .pourOver
@State private var coffeeBean: String = ""
@State private var rating: Int = 3

private func save() {
    let record = BrewRecord(method: method)
    record.coffeeBean = coffeeBean
    record.rating = rating
    modelContext.insert(record)
}
```

**验收标准**:
- 可选择冲煮方式
- 可输入咖啡豆名称
- 点击保存后列表显示新记录

**不做的**:
- 暂不支持其他参数
- 暂不做数据验证
- 暂不美化界面

---

## v0.5 详情查看

**目标**: 点击记录可查看详情

**前置依赖**: v0.4 完成

**任务清单**:

```
1. 创建 RecordDetailView
   - [ ] Views/RecordDetailView.swift
   - [ ] 显示基本信息
   - [ ] 显示冲煮方式

2. 实现导航跳转
   - [ ] RecordListView 添加 NavigationLink
   - [ ] 传递 BrewRecord

3. 布局优化
   - [ ] 使用 Form 显示
   - [ ] 分组展示信息
```

**代码检查点**:

```swift
// RecordListView 导航
NavigationLink(value: record) {
    Text(record.coffeeBean)
}
.navigationDestination(for: BrewRecord.self) { record in
    RecordDetailView(record: record)
}
```

**验收标准**:
- 点击记录跳转到详情
- 详情显示基本信息
- 返回按钮正常

**不做的**:
- 暂不支持编辑
- 暂不支持删除

---

## v0.6 编辑和删除

**目标**: 可修改和删除已有记录

**前置依赖**: v0.5 完成

**任务清单**:

```
1. 实现编辑功能
   - [ ] RecordDetailView 添加 EditButton
   - [ ] 或跳转到编辑页面
   - [ ] 保存修改

2. 实现删除功能
   - [ ] 添加删除按钮
   - [ ] 确认对话框
   - [ ] modelContext.delete()
   - [ ] 返回列表

3. 列表滑动删除
   - [ ] List .onDelete()
```

**代码检查点**:

```swift
// 删除功能
func deleteRecord() {
    modelContext.delete(record)
    dismiss()
}

// 列表滑动删除
.onDelete { indexSet in
    for index in indexSet {
        modelContext.delete(records[index])
    }
}
```

**验收标准**:
- 可编辑记录并保存
- 可删除单条记录
- 列表滑动删除正常

**不做的**:
- 暂不优化交互体验
- 暂不添加撤销功能

---

## v0.7 UI 美化

**目标**: 让界面好看一些

**前置依赖**: v0.6 完成

**任务清单**:

```
1. 主题配色
   - [ ] Extensions/Color+Theme.swift
   - [ ] 咖啡色系定义
   - [ ] 应用到全局

2. 列表项美化
   - [ ] Views/RecordRowView.swift
   - [ ] 显示冲煮方式图标
   - [ ] 显示评分星星
   - [ ] 显示参数摘要

3. 评分组件
   - [ ] Components/StarRating.swift
   - [ ] 可点击星星
   - [ ] 动画效果

4. 详情页美化
   - [ ] 分组样式
   - [ ] 图标装饰
```

**代码检查点**:

```swift
// 主题色
extension Color {
    static let coffee = Color(hex: "6F4E37")
    static let caramel = Color(hex: "C68B59")
}

// 应用主题
.tint(.coffee)
```

**验收标准**:
- 整体风格统一
- 列表项信息清晰
- 评分组件可用

**不做的**:
- 暂不添加动画
- 暂不做深色模式适配

---

## v0.8 完整参数

**目标**: 支持所有冲煮参数

**前置依赖**: v0.7 完成

**任务清单**:

```
1. 意式浓缩表单
   - [ ] Components/EspressoForm.swift
   - [ ] 研磨度、粉量、萃取量
   - [ ] 时间、水温、压力

2. 手冲表单
   - [ ] Components/PourOverForm.swift
   - [ ] 研磨度、粉量、水量
   - [ ] 水温、闷蒸、时间、注水次数

3. 摩卡壶表单
   - [ ] Components/MokaPotForm.swift
   - [ ] 研磨度、粉量、水量
   - [ ] 火力、时间

4. 通用表单
   - [ ] Components/CommonForm.swift
   - [ ] 咖啡豆、烘焙程度
   - [ ] 烘焙日期、笔记

5. 动态表单切换
   - [ ] 根据冲煮方式显示对应表单
```

**验收标准**:
- 三种方式各有专属表单
- 参数保存正确
- 详情显示完整

---

## v0.9 优化打磨

**目标**: 提升用户体验

**前置依赖**: v0.8 完成

**任务清单**:

```
1. 交互优化
   - [ ] 键盘自动收起
   - [ ] 表单滚动优化
   - [ ] 保存成功提示

2. 数据验证
   - [ ] 必填项检查
   - [ ] 数值范围限制
   - [ ] 错误提示

3. 设置页面
   - [ ] Views/SettingsView.swift
   - [ ] 关于信息
   - [ ] 版本号显示

4. 空状态优化
   - [ ] 更友好的提示
   - [ ] 引导创建记录
```

**验收标准**:
- 交互流畅
- 无明显 bug
- 用户体验良好

---

## v1.0 正式发布

**目标**: 可日常使用的版本

**前置依赖**: v0.9 完成

**任务清单**:

```
1. 真机测试
   - [ ] 连接 iPhone
   - [ ] 安装测试
   - [ ] 功能验证
   - [ ] 性能检查

2. 问题修复
   - [ ] 记录发现的问题
   - [ ] 逐一修复

3. 最终打磨
   - [ ] UI 细节
   - [ ] 文案检查
   - [ ] 图标完善

4. 使用文档
   - [ ] 更新 README
   - [ ] 添加使用说明
```

**验收标准**:
- 真机运行正常
- 核心功能可用
- 无崩溃问题

---

## 后续版本

> 版本规划与 [features.md](./features.md) 保持一致

### v1.1 AI 分析 (本地)

**目标**: 添加智能参数分析功能

**前置依赖**: v1.0 完成

**任务清单**:

```
1. 数据模型
   - [ ] Models/BrewAnalysis.swift
   - [ ] 扩展 BrewRecord 添加 analysisJSON 字段

2. 分析引擎
   - [ ] Services/BrewAnalyzer.swift
   - [ ] 实现意式浓缩分析规则
   - [ ] 实现手冲分析规则
   - [ ] 实现摩卡壶分析规则
   - [ ] 风味预测算法

3. 保存后弹窗
   - [ ] Components/AnalysisCard.swift
   - [ ] 底部弹出样式
   - [ ] 快速洞察展示

4. 详情页分析卡片
   - [ ] Components/ScoreRing.swift
   - [ ] Components/FlavorMeter.swift
   - [ ] Components/ParameterScoreRow.swift
   - [ ] Views/Detail/AnalysisSection.swift

5. 集成
   - [ ] NewRecordView 保存后触发分析
   - [ ] RecordDetailView 展示分析结果
```

**验收标准**:
- 保存记录后弹出分析卡片
- 详情页显示完整分析
- 评分和建议合理

> 详细设计见 [ai-analysis.md](./ai-analysis.md) 和 [services.md](./services.md)

---

### v1.2 搜索筛选

- 搜索咖啡豆名称
- 按冲煮方式筛选
- 按日期范围筛选
- 按评分筛选

---

### v1.3 数据管理

- 导出 CSV
- 导出 JSON
- 数据备份

---

### v1.4 数据统计

- 冲煮次数统计
- 评分分布
- 常用参数分析
- 图表可视化

---

### v1.5 AI 分析增强

- 历史记录对比
- 个性化建议学习
- 云端 AI 集成 (可选)

---

### v2.0 云同步

- iCloud 集成
- 多设备同步
- Widget 支持

---

## 迭代检查清单

每个版本完成后检查：

```
[ ] 代码编译通过
[ ] 模拟器运行正常
[ ] 功能验收通过
[ ] 无新增警告
[ ] Git 提交记录清晰
```

---

## 开发日志模板

```markdown
## [版本号] - 日期

### 完成的
- 任务 1
- 任务 2

### 遇到的问题
- 问题描述 + 解决方案

### 下一步
- 下个版本目标
```

---

*文档版本: 1.1*
*最后更新: 2025-02-21*
