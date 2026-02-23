# BrewLog 设计文档

> 咖啡冲煮参数记录 App - 完整设计文档

---

## 文档导航

### 项目概述

| 文档 | 说明 |
|------|------|
| [overview.md](./overview.md) | 项目背景、目标、定位 |

### 架构设计

| 文档 | 说明 |
|------|------|
| [architecture.md](./architecture.md) | 技术架构、目录结构、数据流 |
| [data-model.md](./data-model.md) | 数据模型、枚举、存储策略 |
| [services.md](./services.md) | 服务层设计、分析引擎、用户偏好 |

### 功能设计

| 文档 | 说明 |
|------|------|
| [features.md](./features.md) | 功能列表、版本规划 |
| [ai-analysis.md](./ai-analysis.md) | AI 分析功能详细设计 |
| [views.md](./views.md) | 视图层次、页面设计 |

### UI/UX 设计

| 文档 | 说明 |
|------|------|
| [ui-ux.md](./ui-ux.md) | 设计规范、交互设计、动画（遵循 Apple HIG） |
| [apple-guidelines-compliance.md](./apple-guidelines-compliance.md) | **Apple HIG 合规报告** |

### 开发计划

| 文档 | 说明 |
|------|------|
| [workflow.md](./workflow.md) | **版本规范、迭代流程、发布指南** |
| [roadmap.md](./roadmap.md) | 版本路线图、迭代计划 |
| [development.md](./development.md) | 开发环境、阶段任务 |
| [future-ideas.md](./future-ideas.md) | **未来探索：备选功能池** |

---

## 快速开始

### 新人上手顺序

```
1. overview.md     → 了解项目是什么
2. features.md     → 了解要做什么功能
3. architecture.md → 了解技术架构
4. data-model.md   → 了解数据结构
5. roadmap.md      → 了解开发计划
```

### 开发者快速索引

| 需求 | 查看文档 |
|------|----------|
| 创建新 View | [views.md](./views.md) + [ui-ux.md](./ui-ux.md) |
| 修改数据模型 | [data-model.md](./data-model.md) |
| 添加分析规则 | [services.md](./services.md) + [ai-analysis.md](./ai-analysis.md) |
| 了解版本规划 | [features.md](./features.md) + [roadmap.md](./roadmap.md) |

---

## 版本规划总览

| 版本 | 主题 | 核心功能 | 状态 |
|------|------|----------|------|
| **v1.0** | MVP | 记录的增删改查 | 规划中 |
| **v1.1** | AI 分析 | 参数评分与建议 | 规划中 |
| **v1.2** | 搜索筛选 | 快速查找记录 | 规划中 |
| **v1.3** | 数据管理 | 导出与备份 | 规划中 |
| **v1.4** | 数据统计 | 可视化分析 | 规划中 |
| **v2.0** | 云同步 | iCloud 多设备 | 规划中 |

---

## 技术栈

| 层级 | 技术 |
|------|------|
| UI | SwiftUI |
| 数据 | SwiftData |
| 语言 | Swift 5.9 |
| 最低版本 | iOS 17.0 |

---

## 文档版本

- 文档版本: 3.0
- 最后更新: 2025-02-22
- 遵循: Apple Human Interface Guidelines
