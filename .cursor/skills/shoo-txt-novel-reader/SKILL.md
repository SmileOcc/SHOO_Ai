---
name: shoo-txt-novel-reader
description: >-
  Implements and extends SHOO's local TXT novel reader and bookshelf module
  (download → chapter index cache → lazy pagination → progress → shelf).
  Use when the user asks to build, fix, or extend TXT novel reading, 小说阅读器,
  书架, 章节分页, 阅读进度, 百宝箱下载阅读, or features under lib/features/toolbox/.
---

# SHOO TXT Novel Reader & Bookshelf

Self-contained module under `lib/features/toolbox/`. Identity is always **`SHODownloadTask.id`**.

## When to Read More

| Need | File |
|------|------|
| Full file map & data flow | [reference.md](reference.md) |
| Parser/pagination internals | `lib/features/toolbox/domain/hos_txt_novel_parser.dart` |
| Reader UI & UX rules | `lib/features/toolbox/presentation/hos_txt_reader_page.dart` |

## Module Map (quick)

```
lib/features/toolbox/
├── domain/     hos_txt_novel_models.dart, hos_txt_novel_parser.dart, hos_bookshelf_entry.dart
├── data/       bookshelf/progress/download storage, chapter index cache, reading_storage_keys
├── presentation/
│   hos_txt_reader_page.dart      # main reader UI
│   hos_txt_reader_session.dart   # lazy chapter + flat page list
│   hos_bookshelf_controller.dart # Riverpod shelf providers
│   hos_download_controller.dart  # downloads + cascade delete
│   hos_download_preview_helper.dart  # .txt → reader routing
└── router.dart   # /toolbox, /toolbox/downloads, /toolbox/reader
```

**App wiring:** `lib/app/router/hos_routes.dart`, `lib/features/profile/router.dart` (`/profile/bookshelf`), `hos_profile_discovery_section.dart` (小说阅读 entry).

## Architecture Invariants

1. **Never load full novel into memory** — stream chapter scan; lazy load chapters into `SHOTxtReaderSession.flatPages`.
2. **Three persistence surfaces:**
   - Prefs: bookshelf (`novel_bookshelf_v1`), downloads (`download_tasks_v1`), progress (`txt_reader_progress_{taskId}`)
   - Documents: `Documents/shoo_downloads/*.txt`
   - App Support: `txt_chapter_index_cache/` (invalidated by size+mtime)
3. **Repaginate on layout / font / theme** — `LayoutBuilder` signature change → `_repaginate()`; restore chapter+page via session.
4. **Conditional progress writes** — do not persist if user only opened at ch0/p0 without navigation or settings change (see below).
5. **All user strings** — `txtReader*` / `bookshelf*` keys in **both** `app_en.arb` and `app_zh.arb`.

## Data Flow

```
Download completed .txt
  → handleDownloadTaskTap → SHOTxtReaderPage.open → /toolbox/reader?taskId=
  → SHOTxtReaderRoutePage resolves task from downloadTasksProvider
  → scanChapterMetasWithCache → SHOTxtReaderSession.openAtChapter
  → PageView horizontal paging + prefetch adjacent chapters
  → persist progress on navigate / settings / pop
```

Bookshelf stores `{ taskId, addedAt }` only; list joins `bookshelfEntriesProvider` + `downloadTasksProvider`.

## Critical Gotchas (do not regress)

### Progress save gate (`_shouldPersistProgress`)

Save only when **any** of:
- `_hasUserNavigated` (page change, chapter jump, cross-chapter swipe)
- `_settingsChanged` (font/theme)
- `_restoredFromProgress` (meaningful saved position)
- current `chapterIndex > 0 || pageIndexInChapter > 0`

Bookshelf subtitle treats ch0/p0 as **unread** (`_hasMeaningfulProgress`).

### Pagination alignment

- Shared `TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: false)`.
- First page: title in `RichText`; body pagination uses reduced `firstPageMaxHeight`.
- `_paginationHeightBonus` (2 line-heights) compensates padding — revisit if changing `_readerPadding`.

### Session prepend/append

- `tryPrependPreviousChapter` shifts indices — always `_syncPageController` after prepend.
- `tryAppendNextChapter` returns first flat index of new chapter.
- `jumpToChapter` to unloaded chapter clears `flatPages` — show chapter transition mask.

### Chapter slider

- `onChanged` → preview chapter title only (`_sliderPreviewChapterIndex`).
- `onChangeEnd` → `_jumpToChapter` (never jump on every tick).

### Cross-chapter page swipe

- `_goPrevPage` at index 0 → `_goPrevPageAcrossChapter` (prepend + animate).
- `_goNextPage` at last flat index → `_goNextPageAcrossChapter` (append or jump).

### Delete cascade

`deleteTask` must remove: task list entry, local file, bookshelf entry, reader progress.

### Prefs clear preservation

`SHOReadingStorageKeys.preserveOnPreferencesClear` — bookshelf, download tasks, progress prefix survive `SHOLocalStorage.clear()`.

## Riverpod Providers

| Provider | File |
|----------|------|
| `downloadTasksProvider` | `hos_download_controller.dart` |
| `bookshelfEntriesProvider` | `hos_bookshelf_controller.dart` |
| `bookshelfListItemsProvider` | derived join |
| `txtReaderProgressStorageProvider` | `hos_txt_reader_progress_storage.dart` |

Reader bookshelf button: `ref.watch(bookshelfEntriesProvider)` — never cache shelf state in local `setState` only.

## Routes

| Constant | Path |
|----------|------|
| `SHOAppRoutes.profileBookshelf` | `/profile/bookshelf` |
| `SHOAppRoutes.toolboxReader` | `/toolbox/reader?taskId=` |
| `SHOAppRoutes.toolboxReaderFor(id)` | helper |

Use `parentNavigatorKey: rootKey` for full-screen over tab shell. Navigate: `context.push(SHOAppRoutes.toolboxReaderFor(task.id))`.

## Reader UX Contract

- Content area: top = safe + 52px nav; bottom = safe only (toolbar overlays).
- Tap zones: left 33% prev, right 67% next, center toggle chrome; chrome hides on swipe/tap.
- Catalog drawer 72% width; scrim opacity follows `_catalogController.value`.
- Chrome slide animations via `_chromeController`.
- Failed load: message + **Retry** button re-runs `_bootstrap()`.

## How to Extend

### New reader setting (e.g. line spacing)

1. Add field to `SHOTxtReaderProgress` + `fromJson` default in `hos_txt_novel_models.dart`.
2. Wire UI in `hos_txt_reader_page.dart`; call `_markSettingsChanged()` + `_repaginate()` if layout-affecting.
3. Add l10n to both ARB files.
4. If new prefs key → add to `SHOReadingStorageKeys` preserve list if user-facing data.

### New entry point

- Profile: `_ServiceItem` in `hos_profile_discovery_section.dart`.
- Toolbox: `_ToolboxMenuItem` in `hos_toolbox_page.dart`.

### New route

1. `hos_routes.dart` constant (+ helper if query/path param).
2. Register in `toolbox/router.dart` or `profile/router.dart`.
3. `context.push(...)`.

### Tests (preferred targets)

```bash
flutter test test/hos_txt_novel_parser_test.dart test/hos_reading_storage_keys_test.dart
```

- Parser: `isChapterHeadingLine`, `paginateChapterContent` — pure Dart.
- Storage: `SHOReadingStorageKeys.preserveOnPreferencesClear`.
- Session: temp file + fake pagination params (good gap for new tests).

## Implementation Checklist

Copy when building or auditing a change:

```
- [ ] Keys off taskId; download task exists before opening reader route
- [ ] Chapter scan uses cache (size+mtime); no full-file read for index
- [ ] Lazy session: only loaded chapters in flatPages
- [ ] Repaginate on layout/font/theme; position restored
- [ ] Progress gate respected; bookshelf unread not polluted
- [ ] Slider uses onChangeEnd; cross-chapter swipe symmetric
- [ ] deleteTask cascades shelf + progress + file
- [ ] l10n en + zh; flutter gen-l10n if ARB changed
- [ ] Tests updated for parser/storage changes
```

## Dev & QA

```bash
cd SHOO
flutter pub get
flutter analyze
flutter test test/hos_txt_novel_parser_test.dart test/hos_reading_storage_keys_test.dart
flutter run
```

**Manual path:** 百宝箱 → 文件下载 → add `.txt` → complete → open reader → 加入书架 → 我的/小说阅读 → verify progress → rotate device → verify repagination → delete download → verify shelf orphan cleanup.

**After reader/theme changes:** Hot Restart (not just hot reload).

## Naming Conventions

- Classes: `SHO*` prefix.
- Files: `hos_*` prefix (matches SHOO codebase).
- Prefer `SHOReadingStorageKeys` over hardcoded pref key strings.
