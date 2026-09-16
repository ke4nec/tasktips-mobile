# TaskTips Mobile — Agent Guide

## Status
- Flutter 工程（Android 优先）已建立；阶段1（本地闭环）已实现：主题/导航/8 页面、Markdown+front matter 本地存储、今日/列表/搜索/筛选/排序、编辑自动保存、目录标签管理、回收站 30 天。
- 已验证通过的命令（2026-09-16，Flutter 3.47.4）：`flutter analyze`（0 error）、`flutter test`（25 通过）、`flutter build apk --debug`。
- 阶段2（同步）/阶段3（分享、无障碍、发布检查）未实现；同步页当前为占位。

## Source of truth
- `design/android-mobile-ui.html` (badge `v0.2`) is the only approved UI spec. `design/` is reference, never production UI.
- It cites `src/styles/theme.css`, which does not exist yet — treat the HTML `:root` / `:root[data-theme="dark"]` blocks as canonical tokens until then.

## Ecosystem compatibility (do not diverge)
- Data model, Markdown + front-matter format, and sync/tombstone semantics must match sibling `../tasktips/docs/tasktips-design.md` and `../tasktips/docs/tasktips-server-sync-design.md`.
- HTTP contract is sibling `../tasktips-cloud/contracts/openapi.yaml`. Do not hand-write duplicate API models once codegen exists.
- Privacy rule from ecosystem: never log full Todo contents, tokens, passwords, or storage credentials / signed URLs.

## UI contract from the mock
- Android-first Material 3. Light brand `#0078D4`, dark brand `#4A9EFF`; bg/panel/surface/status tokens live in the `:root` blocks. UI copy is `zh-CN`.
- 8 pages defined in the `pages` JS object: `today`, `inbox`, `detail`, `folder`, `trash`, `sync`, `settings`, `onboarding`.
- Nav: bottom 4 tabs (`today` / `inbox` / `folder` / `settings`) + FAB visible only on `today`/`inbox`/`folder` (see `show()`); FAB routes to `detail`.
- Touch/a11y: 48dp min-height on primary actions (`.action`, `.filter`, `.seg`, bottom nav); keep light/dark parity via tokens; preserve the `prefers-reduced-motion` guard.
- Theme has 3 modes (light / dark / system, default `system` via `applyTheme()`); do not hardcode a single theme.
- Pinned behaviors: local-first Markdown autosave; trash auto-clean 30d, restore keeps folder/tags/desktop position; sync shows 3-device model with upload/download log.

## Data rules (shared with desktop, do not diverge)
- Title derives from the first non-empty Markdown line (strip markers, max 80 chars, written back to the title field).
- Physical delete (expiry / purge / empty trash) removes the Markdown file and creates a tombstone in the sync index.
- Window/desktop position, transparency, pinning are local-only UI state — never inside synced Markdown.

## Desktop behaviors that do NOT transfer to Android
- No tray residency, no 380×300 floating note windows, no transparency/snapping multi-window lifecycle. Do not copy `src-tauri/src/platform/` window code patterns.

## Workflow
- Commit format: `<type>(<scope>): <中文描述>` — type is `feat|fix|docs|refactor|test|build|chore`, scope in parens names the area, description in Chinese, no trailing period. Example: `feat(sync): 添加后台同步任务`.
- This differs from sibling repos (English summaries); this repo uses Chinese descriptions.
