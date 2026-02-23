# 开发计划

> BrewLog 开发环境与阶段任务

---

## 开发环境

| 项目 | 要求 |
|------|------|
| 开发机 | Mac (Apple Silicon 推荐) |
| 系统 | macOS Sonoma+ |
| IDE | Xcode 15+ |
| iOS 版本 | iOS 17.0+ (SwiftData 要求) |
| 测试设备 | iPhone |

---

## 开发阶段

### 阶段一：项目搭建 (v0.1-v0.2)

**目标**: 创建可运行的项目骨架

**任务清单**:

- [ ] 创建 Xcode 项目
  - [ ] 选择 App 模板
  - [ ] 命名为 BrewLog
  - [ ] 选择 SwiftUI + SwiftData

- [ ] 配置项目
  - [ ] 设置 Bundle Identifier
  - [ ] 配置最低 iOS 17.0
  - [ ] 添加 App 图标

- [ ] 创建目录结构
  - [ ] App/
  - [ ] Models/
  - [ ] Services/
  - [ ] Views/
  - [ ] Components/
  - [ ] Extensions/

- [ ] 创建数据模型
  - [ ] BrewMethod.swift
  - [ ] RoastLevel.swift
  - [ ] HeatLevel.swift
  - [ ] BrewRecord.swift

**完成标志**: 项目可编译运行

---

### 阶段二：列表功能 (v0.3)

**目标**: 显示记录列表

**任务清单**:

- [ ] 创建 ContentView
  - [ ] TabView 框架
  - [ ] 三个 Tab 配置

- [ ] 创建 RecordListView
  - [ ] List 基础结构
  - [ ] @Query 获取数据
  - [ ] 按日期分组

- [ ] 创建 RecordRowView
  - [ ] 显示冲煮方式
  - [ ] 显示咖啡豆名称
  - [ ] 显示评分
  - [ ] 显示参数摘要

**完成标志**: 列表可显示、可删除

---

### 阶段三：新建功能 (v0.4)

**目标**: 创建新记录

**任务清单**:

- [ ] 创建 NewRecordView
  - [ ] Form 表单结构
  - [ ] 冲煮方式选择器

- [ ] 创建参数表单组件
  - [ ] EspressoFormView
  - [ ] PourOverFormView
  - [ ] MokaPotFormView
  - [ ] CommonFormView

- [ ] 创建输入组件
  - [ ] ParameterField
  - [ ] StarRating

- [ ] 实现保存功能
  - [ ] 数据验证
  - [ ] 插入 SwiftData

**完成标志**: 可创建新记录

---

### 阶段四：详情功能 (v0.5-v0.6)

**目标**: 查看、编辑、删除记录

**任务清单**:

- [ ] 创建 RecordDetailView
  - [ ] 显示完整参数
  - [ ] 显示评分
  - [ ] 显示笔记

- [ ] 实现编辑功能
  - [ ] 复用表单组件
  - [ ] 更新数据

- [ ] 实现删除功能
  - [ ] 删除按钮
  - [ ] 确认对话框
  - [ ] 返回列表

**完成标志**: 可查看、编辑、删除

---

### 阶段五：优化完善 (v0.7-v0.9)

**目标**: 美化界面、优化体验

**任务清单**:

- [ ] UI 美化
  - [ ] 应用主题色
  - [ ] 添加图标
  - [ ] 调整间距

- [ ] 交互优化
  - [ ] 添加动画
  - [ ] 键盘处理
  - [ ] 保存成功提示

- [ ] 设置页面
  - [ ] 关于信息
  - [ ] 数据管理

- [ ] 完整参数支持
  - [ ] 三种方式完整表单
  - [ ] 参数动态切换

**完成标志**: App 可正常使用

---

### 阶段六：正式发布 (v1.0)

**目标**: 可发布的版本

**任务清单**:

- [ ] 真机测试
  - [ ] 连接 iPhone
  - [ ] 功能验证
  - [ ] 性能检查

- [ ] 问题修复
  - [ ] 记录问题
  - [ ] 逐一修复

- [ ] 最终打磨
  - [ ] UI 细节
  - [ ] 文案检查
  - [ ] 图标完善

**完成标志**: 可提交 App Store

---

## 文件创建顺序

```
Phase 1: 基础
├── Models/
│   ├── BrewMethod.swift
│   ├── RoastLevel.swift
│   ├── HeatLevel.swift
│   └── BrewRecord.swift
└── App/
    └── BrewLogApp.swift (修改)

Phase 2: 扩展
├── Extensions/
│   ├── Color+Theme.swift
│   └── Date+Extensions.swift
└── Components/
    ├── StarRating.swift
    └── ParameterField.swift

Phase 3: 视图
├── Views/
│   ├── ContentView.swift
│   ├── RecordListView.swift
│   ├── RecordRowView.swift
│   ├── NewRecordView.swift
│   ├── RecordDetailView.swift
│   └── SettingsView.swift
└── Components/
    └── MethodBadge.swift

Phase 4: 表单
└── Views/NewRecord/
    ├── MethodPickerView.swift
    ├── EspressoFormView.swift
    ├── PourOverFormView.swift
    ├── MokaPotFormView.swift
    └── CommonFormView.swift

Phase 5: AI 分析 (v1.1)
├── Models/
│   └── BrewAnalysis.swift
├── Services/
│   ├── BrewAnalyzer.swift
│   └── UserPreferences.swift
└── Components/
    ├── AnalysisCard.swift
    ├── ScoreRing.swift
    ├── FlavorMeter.swift
    └── ParameterScoreRow.swift
```

---

## 测试检查点

### 功能测试

| 功能 | 测试项 | 通过标准 |
|------|--------|----------|
| 列表 | 显示记录 | 正确显示 |
| 列表 | 删除记录 | 删除成功 |
| 列表 | 分组显示 | 按日期分组 |
| 新建 | 选择方式 | 切换正常 |
| 新建 | 填写参数 | 保存成功 |
| 详情 | 显示信息 | 完整显示 |
| 详情 | 编辑保存 | 更新成功 |
| 详情 | 删除确认 | 删除成功 |
| 分析 | 评分计算 | 分数合理 |
| 分析 | 建议生成 | 建议相关 |

### 兼容性测试

- [ ] iPhone SE (小屏)
- [ ] iPhone 15 (标准)
- [ ] iPhone 15 Pro Max (大屏)
- [ ] 深色模式
- [ ] 动态字体

---

## 参考资源

### 官方文档

- [SwiftUI 官方教程](https://developer.apple.com/tutorials/swiftui)
- [SwiftData 文档](https://developer.apple.com/documentation/swiftdata)

### 设计参考

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

---

*文档版本: 2.0*
*最后更新: 2025-02-21*
