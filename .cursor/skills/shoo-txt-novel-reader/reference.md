# SHOO TXT Novel Reader — Reference

## File Index

### Domain (`lib/features/toolbox/domain/`)

| File | Contents |
|------|----------|
| `hos_txt_novel_models.dart` | `SHONovelChapterMeta`, `SHONovelPage`, `SHOTxtReaderProgress`, `SHOTxtReaderLoadPhase` |
| `hos_txt_novel_parser.dart` | `decodeTxtBytes`, `scanChapterMetas`, `readChapterContent`, `paginateChapterContent`, `buildPagesForChapter`, `measureTextBlockHeight` |
| `hos_bookshelf_entry.dart` | `SHOBookshelfEntry` JSON model |
| `hos_download_task.dart` | `SHODownloadTask`, status enum, `isTxtNovelFile`, preview helpers |

### Data (`lib/features/toolbox/data/`)

| File | Contents |
|------|----------|
| `hos_reading_storage_keys.dart` | `bookshelf`, `downloadTasks`, `progressPrefix`, `preserveOnPreferencesClear()` |
| `hos_bookshelf_storage.dart` | `novel_bookshelf_v1` JSON list; `removeByTaskId()` |
| `hos_txt_reader_progress_storage.dart` | Per-task progress read/write/remove |
| `hos_txt_chapter_index_cache.dart` | `scanChapterMetasWithCache()` — disk cache under Application Support |
| `hos_download_storage.dart` | `download_tasks_v1` task list |
| `hos_download_paths.dart` | `Documents/shoo_downloads/`, `resolveExistingFilePath`, `reconcileTask` |
| `hos_download_engine.dart` | Dio queue, pause/resume, 2 concurrent |

### Presentation (`lib/features/toolbox/presentation/`)

| File | Contents |
|------|----------|
| `hos_txt_reader_page.dart` | Reader UI: chrome, catalog, settings, PageView, masks, bookshelf toggle |
| `hos_txt_reader_session.dart` | `openAtChapter`, `jumpToChapter`, prepend/append, `repaginateAllLoaded` |
| `hos_txt_reader_pagination.dart` | Width/height/styles bundle for parser |
| `hos_txt_reader_theme.dart` | Sepia/light/dark presets, ARGB persistence |
| `hos_txt_reader_route_page.dart` | Query `taskId` → lookup → `SHOTxtReaderPage` or missing task |
| `hos_bookshelf_list_page.dart` | Shelf list, swipe delete, orphan cleanup banner |
| `hos_bookshelf_controller.dart` | `bookshelfEntriesProvider`, `bookshelfListItemsProvider`, `removeOrphans()` |
| `hos_download_controller.dart` | `downloadTasksProvider`, `deleteTask` cascade |
| `hos_download_preview_helper.dart` | `handleDownloadTaskTap` — routes `.txt` to reader |
| `hos_download_list_page.dart` | Download manager UI |
| `hos_toolbox_page.dart` | 阅读 → 我的书架; 工具 → 文件下载 |

### Integration

| File | Role |
|------|------|
| `lib/app/router/hos_routes.dart` | Route constants |
| `lib/features/toolbox/router.dart` | Toolbox sub-routes |
| `lib/features/profile/router.dart` | `/profile/bookshelf` |
| `lib/features/profile/presentation/hos_profile_discovery_section.dart` | 小说阅读 entry |
| `lib/core/storage/hos_local_storage.dart` | Preserves reading keys on `clear()` |
| `lib/core/cache/hos_cache_cleanup_service.dart` | Excludes reading keys from misc cache bytes |

## Chapter Heading Regex

Matches: `第N章`, `Chapter N`, `【标题】`, 序章/楔子/番外/终章/后记, etc. See `_chapterHeadingPattern` in `hos_txt_novel_parser.dart`.

## l10n Keys

### Profile & Toolbox
- `profileServiceNovelReading`
- `toolboxGroupReading`, `toolboxBookshelf`, `toolboxFileDownload`

### Reader (`txtReader*`)
- Loading: `txtReaderParsingChapters`, `txtReaderPaginating`, `txtReaderLoadFailed`, `txtReaderRetry`, `txtReaderTaskMissing`
- Chrome: `txtReaderAddBookshelf`, `txtReaderRemoveBookshelf`, `txtReaderRemovedBookshelf`, `txtReaderChapters`, `txtReaderPrevChapter`, `txtReaderNextChapter`
- Settings: `txtReaderFontSize`, `txtReaderBackground`, `txtReaderFontColor`, `txtReaderNight`, `txtReaderSettingsLabel`
- Progress display: `txtReaderPageProgress`, `txtReaderChapterPageProgress`

### Bookshelf (`bookshelf*`)
- `bookshelfTitle`, `bookshelfEmpty`, `bookshelfUnread`, `bookshelfReadingProgress`
- `bookshelfNotCompleted`, `bookshelfFileMissing`, `bookshelfUnknownTitle`
- `bookshelfRemoveAction`, `bookshelfRemoveConfirmTitle`, `bookshelfRemoveConfirmMessage`
- `bookshelfCleanupOrphansTitle`, `bookshelfCleanupOrphansMessage`, `bookshelfCleanupOrphansAction`

## Session State Machine (simplified)

```
openAtChapter(ch, page)
  → load chapter → paginate → set flatPages + currentFlatIndex

page change at chapter boundary
  → tryAppendNextChapter / tryPrependPreviousChapter

jumpToChapter(ch)
  → if chapter in flatPages: reposition index
  → else: clear flatPages, load single chapter, show mask

repaginateAllLoaded
  → reload each loaded chapter with new pagination → restore ch+page
```

## Audit Fixes Already Landed (regression guard)

| Issue | Fix location |
|-------|--------------|
| Slider fires continuous jump | `onChangeEnd` only in `_buildBottomChrome` |
| Last page can't swipe to next chapter | `_goNextPageAcrossChapter` |
| Bootstrap paginate before layout | `_scheduleLayoutRepaginate` in `LayoutBuilder` |
| A-/A+ broken for non-preset sizes | `_stepFontSize(±2)` 14–28 |
| Shelf state stale after external delete | `ref.watch(bookshelfEntriesProvider)` |
| No remove-from-shelf in reader | `_onBookshelfAction` with confirm |
| deleteTask orphan shelf/progress | cascade in `hos_download_controller.dart` |
| clear() wipes reading data | `SHOReadingStorageKeys` in `hos_local_storage.dart` |
| Open+exit marks as read | `_shouldPersistProgress` gate |
| No retry on load fail | `txtReaderRetry` button in `_buildLoadingBody` |
| Reader not in go_router | `/toolbox/reader?taskId=` route |
| No toolbox shelf entry | `hos_toolbox_page.dart` reading group |
| No tests | `test/hos_txt_novel_parser_test.dart`, `test/hos_reading_storage_keys_test.dart` |

## Known Duplication

`hos_download_storage.dart` hardcodes `'download_tasks_v1'` — value matches `SHOReadingStorageKeys.downloadTasks` but not imported. Prefer central constant when touching that file.
