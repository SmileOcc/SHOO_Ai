---
name: new-project
description: >-
  Scaffolds a production-ready Flutter e-commerce app from the SHOO reference
  (Phase 0 + 0.5 + Phase 2: search, reviews, logistics). Use when bootstrapping
  a new Flutter e-commerce project, copying SHOO infrastructure, 一键搭建基建,
  new_project skill, or setting up Clean Architecture + Riverpod + go_router + Mock API.
---

# New Project — Flutter E-Commerce Infrastructure (SHOO)

个人级完整 Skill：`~/.cursor/skills/new-project/`（跨项目可用）。

## 快速触发

> 用 **new-project** skill 搭建 Flutter 电商基建，项目名 `{Name}`

或：

> 按 SHOO 模板复制基建，org `com.{brand}`，包名 `{pkg}`

## 文档

| 资源 | 路径 |
|------|------|
| 完整 Skill 步骤 | `~/.cursor/skills/new-project/SKILL.md` |
| SHOO 文件索引 | `~/.cursor/skills/new-project/reference.md` |
| 技术方案 | [docs/Flutter电商项目基建技术方案.md](../../docs/Flutter电商项目基建技术方案.md) |
| 参考实现 | 本仓库 `lib/` + `assets/mock/` |

## 当前 SHOO 基建范围（v0.2）

| 阶段 | 内容 |
|------|------|
| Phase 0 | 四 Tab + Shein 风格 Token + 17+ 组件 + Mock 首页 |
| Phase 0.5 | AppConfig / Session / MockRouteRegistry / i18n / 暗黑 / 离线条 |
| Phase 2 | 搜索、商品详情、评价、订单列表、物流轨迹 |
| 未含 | Phase 1 购物车结算、Phase 3 优惠券售后 |

## 验收

```bash
flutter analyze   # 0 error
flutter test
flutter run
```

Agent 执行时请读取 `~/.cursor/skills/new-project/SKILL.md` 中的完整 Checklist。
