---
name: flutter-ecommerce-scaffold
description: >-
  Scaffolds a production-ready Flutter e-commerce app foundation (Clean Architecture,
  Riverpod, go_router, Dio Mock, freezed, Session, i18n, dark mode, validators).
  Use when the user asks to scaffold/init/bootstrap a Flutter e-commerce project,
  set up SHOO-style infrastructure, Phase 0/0.5 foundation, or 一键搭建 Flutter 电商框架.
---

# Flutter E-Commerce Scaffold (SHOO Project Copy)

个人级完整 Skill 位于 `~/.cursor/skills/flutter-ecommerce-scaffold/`（跨项目可用）。

## 快速触发

> 用 **flutter-ecommerce-scaffold** skill 搭建 Flutter 电商基建，项目名 `{Name}`

## 文档

| 资源 | 路径 |
|------|------|
| 完整技术方案 | [docs/Flutter电商项目基建技术方案.md](../../docs/Flutter电商项目基建技术方案.md) |
| 参考实现源码 | 本仓库 `lib/` |
| Skill 详细步骤 | `~/.cursor/skills/flutter-ecommerce-scaffold/SKILL.md` |
| 文件模板 | `~/.cursor/skills/flutter-ecommerce-scaffold/reference.md` |

## 执行摘要

**Phase 0**：flutter create → 目录分层 → Token/主题 → go_router 四 Tab → Dio Mock → 组件库 → 首页 Mock

**Phase 0.5**：AppConfig → freezed → Session(authTokenProvider 解耦) → MockRouteRegistry → 路由守卫 → Validators → i18n → 暗黑模式 → 离线条 → AppLogger

**验收**：`flutter analyze` (0 error) + `flutter test` + `flutter run`

Agent 执行时请读取 `~/.cursor/skills/flutter-ecommerce-scaffold/SKILL.md` 中的完整 Checklist。
