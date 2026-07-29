---
name: "class-function-annotation"
description: "Adds functional comments to Dart/Flutter classes, fields, properties, and methods. Invoke when user asks to add documentation/comments to classes or methods."
---

# Class Function Annotation

This skill adds comprehensive documentation comments to Dart/Flutter code, following the project's existing comment conventions.

## Scope

- **Classes**: Add class-level documentation explaining purpose, structure, and usage
- **Fields/Properties**: Add comments describing each field's purpose and usage
- **Methods**: Add comments explaining method functionality, parameters, and return values
- **Enums**: Add comments explaining enum values and their meanings

## Comment Style

Follow these conventions when adding comments:

1. Use `///` (triple-slash) for documentation comments
2. Start with a concise description of what the item does
3. Use markdown formatting for better readability (headings, lists, code blocks)
4. Reference related types using `[TypeName]` syntax
5. Keep comments clear and actionable

## Examples

### Class Comment

```dart
/// 分享操作面板，采用底部弹出的两行横向布局。
///
/// 布局结构：
/// - **标题区域**：居中显示分享标题
/// - **第一行**：可配置的三方应用分享入口
/// - **第二行**：自定义操作入口
/// - **取消按钮**：底部独立一行，点击关闭面板
class SHOShareActionSheet extends StatelessWidget {
  // ...
}
```

### Field Comment

```dart
/// 分享面板标题，居中显示在顶部
final String title;

/// 一屏可见的入口数量（默认 5.5，露出半个暗示可滑动）
final double visibleSlots;
```

### Enum Comment

```dart
/// 分享入口类型。
///
/// - [thirdParty]: 三方应用（如微信、微博等）
/// - [custom]: 自定义事件（如复制链接、举报等）
enum SHOShareActionKind { 
  thirdParty, 
  custom 
}
```

## When to Invoke

- User asks to add comments/documentation to a class
- User asks to explain what a class/field/method does
- User requests to add functional annotations
- User wants to improve code documentation

## Workflow

1. Read the target file to understand its structure
2. Identify all classes, fields, properties, and methods that need comments
3. Add comments following the project's conventions
4. Verify with `flutter analyze` if applicable
