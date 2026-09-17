# TaskTips Mobile — Agent Guide

## Status
- Flutter 工程（Android 优先）已建立；阶段1（本地闭环）已实现：主题/导航/8 页面、Markdown+front matter 本地存储、今日/列表/搜索/筛选/排序、编辑自动保存、目录标签管理、回收站 30 天。
- 已验证通过的命令（2026-09-16，Flutter 3.47.4）：`flutter analyze`（0 error）、`flutter test`（25 通过）、`flutter build apk --debug`。
- 阶段2（桌面互通）已实现：OpenAPI 生成的 Dart 客户端在 `packages/tasktips_api`（openapi-generator 7.25.0 + build_runner 产物，已 vendored）；登录/设备注册/项目选择、首次接入预览确认、bootstrap/pull/push（幂等 requestId 重试、SHA-256 payload 校验、10MiB 限额）、整对象冲突“保留本机/采用远端”、设备列表、本机同步日志（不含正文/凭据）、自动同步（启动/前台恢复/保存后/60s 前台检查）、token 串行刷新（refresh 入安全存储）、HTTPS 地址校验、Android 备份规则排除 state/。
- 阶段4 P0（桌面数据兼容）已实现：classification.json 对齐桌面 schemaVersion 3（必填 createdAt/updatedAt 以 RFC3339 原文保存、icon/description/orderIndex/isSystem 全字段、未知字段实体级保留、hex 32 色板与语义键迁移、group 空串序列化归一为“其他”、只读保存按原字节写回）；同步引擎 image 对象走二进制路径（不 utf8.decode，防整页 pull 中断）+ image 墓碑删文件、本地新图片文件随 push 上传（10MiB 限额、超限记 rejected 不重试）；同步健壮性：连接代次（epoch）使 logout/换项目的在飞响应失效、自动同步指数退避（30s~5min，手动同步不受限）、sync-state/index 损坏时暂停自动推送（远端权威副本写回后自动恢复）、401/403/423 解析服务端 ErrorCode 分流并暂停自动提交（submitPaused）、push 按 100 条分批幂等提交、跨进程 sync.lock 互斥、被拒对象（rejected 记录）本地未变化前不重试、删除 vs 本机编辑冲突标注“远端版本为删除”（接受删除/保留本机）、generation 回退中止 pull 重新 bootstrap、首次接入完成默认开启自动同步。夹具往返/迁移测试见 test/classification_compat_test.dart。阶段4 其余批次（tagMode、customOrder、标签分组、图片导入、认证分流、历史/快照）按 docs/tasktips-mobile-parity-design.md 顺序待实现。
- 阶段3（Android 完善）已实现：文字/链接分享入口（冷/热启动、3 秒重投递去重、引导期间挂起不吞掉）、WorkManager 15 分钟后台周期同步（系统调度，关闭自动同步即取消）、备份规则、release 构建通过（compileSdk 37，receive_sharing_intent 要求）。
- 命令验证（2026-09-16）：`flutter analyze`（0 error/warning）、`flutter test`（30 通过）、`flutter build apk --debug`、`flutter build apk --release`。

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
- Nav: bottom 4 tabs (`today` / `inbox` / `folder` / `settings`) + FAB visible only on `today`/`inbox` (HTML `show()` L1807); FAB routes to `detail`.
- Touch/a11y: 48dp min-height on primary actions (`.action`, `.filter`, `.seg`, bottom nav); keep light/dark parity via tokens; preserve the `prefers-reduced-motion` guard.
- Theme has 3 modes (light / dark / system, default `system` via `applyTheme()`); do not hardcode a single theme.
- Pinned behaviors: local-first Markdown autosave; trash auto-clean 30d, restore keeps folder/tags/desktop position; sync shows 3-device model with upload/download log.

## Data rules (shared with desktop, do not diverge)
- Title derives from the first non-empty Markdown line (strip markers, max 80 chars, written back to the title field).
- Physical delete (expiry / purge / empty trash) removes the Markdown file and creates a tombstone in the sync index.
- Window/desktop position, transparency, pinning are local-only UI state — never inside synced Markdown.

## Desktop behaviors that do NOT transfer to Android
- No tray residency, no 380×300 floating note windows, no transparency/snapping multi-window lifecycle. Do not copy `src-tauri/src/platform/` window code patterns.

## CI
- 本地模拟：`act push -j check`（nektos/act + catthehacker/ubuntu:act-latest 镜像）已验证通过；build 作业含 Android SDK 缺失时自助安装步骤，但本机透明代理环境下 Java sdkmanager 拉取清单会失败（curl 正常），完整 build 需在 GitHub runner 或直连网络验证。

- `.github/workflows/android-build.yml`：PR/push 跑 `flutter analyze` + `flutter test`；push 构建仅 arm64-v8a release APK；`v*` 标签发布到 GitHub Release（APK 当前为 debug 签名，正式签名策略属待确认事项）。pub/Gradle 缓存按锁文件键恢复；artifacts 保留 1 天且 cleanup 作业在发布后立即删除。

## Workflow
- Commit format: `<type>(<scope>): <中文描述>` — type is `feat|fix|docs|refactor|test|build|chore`, scope in parens names the area, description in Chinese, no trailing period. Example: `feat(sync): 添加后台同步任务`.
- This differs from sibling repos (English summaries); this repo uses Chinese descriptions.
