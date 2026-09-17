# TaskTips Mobile — Agent Guide

## Status
- Flutter 工程（Android 优先）已建立；阶段1（本地闭环）已实现：主题/导航/8 页面、Markdown+front matter 本地存储、今日/列表/搜索/筛选/排序、编辑自动保存、目录标签管理、回收站 30 天。
- 已验证通过的命令（2026-09-16，Flutter 3.47.4）：`flutter analyze`（0 error）、`flutter test`（25 通过）、`flutter build apk --debug`。
- 阶段2（桌面互通）已实现：OpenAPI 生成的 Dart 客户端在 `packages/tasktips_api`（openapi-generator 7.25.0 + build_runner 产物，已 vendored）；登录/设备注册/项目选择、首次接入预览确认、bootstrap/pull/push（幂等 requestId 重试、SHA-256 payload 校验、10MiB 限额）、整对象冲突“保留本机/采用远端”、设备列表、本机同步日志（不含正文/凭据）、自动同步（启动/前台恢复/保存后/60s 前台检查）、token 串行刷新（refresh 入安全存储）、HTTPS 地址校验、Android 备份规则排除 state/。
- 阶段4 P0（桌面数据兼容）已实现：classification.json 对齐桌面 schemaVersion 3（必填 createdAt/updatedAt 以 RFC3339 原文保存、icon/description/orderIndex/isSystem 全字段、未知字段实体级保留、hex 32 色板与语义键迁移、group 空串序列化归一为“其他”、只读保存按原字节写回）；同步引擎 image 对象走二进制路径（不 utf8.decode，防整页 pull 中断）+ image 墓碑删文件、本地新图片文件随 push 上传（超限记 rejected 不重试）；同步健壮性：连接代次（epoch）使 logout/换项目的在飞响应失效、自动同步指数退避（30s~5min，手动同步不受限）、sync-state/index 损坏时暂停自动推送（远端权威副本写回后自动恢复）、401/403/423 解析服务端 ErrorCode 分流并暂停自动提交（submitPaused）、刷新失败清空凭据防“已连接死循环”、push 按 100 条分批幂等提交、payload 限额按 kind（todo 8M / classification、index 5M / image 10M，单项超限不阻断整批）、跨进程 sync.lock 互斥、被拒对象（rejected 记录）本地未变化前不重试、删除 vs 本机编辑冲突标注“远端版本为删除”（接受删除/保留本机）、generation 变化丢弃旧 pendingPush 重新 bootstrap（pull 比对 + syncNow 重试一轮）、bootstrap 仅最终页启用 cursor、resolveKeepLocal 请求入 pendingPush 幂等重试、首次接入完成默认开启自动同步、网络恢复（connectivity_plus none→在线边沿）触发自动同步、sync 页六态（仅本机/待同步/…）与首连“确认并开始同步”、预览随本机变更失效、项目切换入口（beginProjectSwitch）。夹具往返/迁移测试见 test/classification_compat_test.dart。
- 阶段4 批次B（查询层）已实现：customOrder 读取应用（Inbox/All 默认排序置前、筛选/显式排序不用）；tagMode（and/or/exclude，筛选面板三 chip、清除复位）；moveCategory 按“目标深度+子树高度≤3”校验；名称校验对齐桌面（目录 2-50 字符禁 `/\:*?"<>|`、标签 1-20）；目录删除/恢复 cohort 语义（子树+Todo 同批软删除/同批恢复、孤儿子目录保留父引用、恢复同名冲突保留回收站条目、彻底删除连带同批 Todo 只写 todo 墓碑）；categoryId 指向已删/不存在目录按未分类口径；deriveTitle 完整对齐桌面 markdown.ts（链接/图片可见文本、闭合井号、嵌套前缀循环、`<br>` 残留、snake_case、50 行扫描上限）；解析兼容孤立 `\r` 与 priority 0-3 越界拒绝。测试见 test/classification_lifecycle_test.dart、test/query_and_image_test.dart。
- 阶段4 批次D（图片导入）已实现：编辑工具栏“插入本地图片”（image_picker 相册、无 resize 保持原始字节）；魔数白名单 PNG/JPEG/GIF/WebP/BMP 拒 SVG、≤10MiB 按原始字节、`images/<ULID>.<ext>` 原子写、alt 折叠限 60 字符；校验失败保留编辑内容仅提示。
- 阶段3（Android 完善）已实现：文字/链接分享入口（冷/热启动、3 秒重投递去重、引导期间挂起不吞掉）、WorkManager 15 分钟后台周期同步（系统调度，关闭自动同步即取消）、备份规则、release 构建通过（compileSdk 37，receive_sharing_intent 要求）。
- UI 对齐 v0.3 设计稿：今日页搜索入口+焦点联动/空态即将到期入口、列表 result-summary、目录行“N 项未完成”与色板彩色块、回收站计数头+说明卡+空态文案、设置页外观/数据/关于分组（主题 sheet/存储 sheet/关于 sheet/损坏内容只读提示）、编辑页 Offstage 保活（撤销历史/选区/IME 会话保留）、composing 期不落盘、返回先收键盘、截止日期/标签清除入口、跨午夜 30s 检查+时区变化重算今日。
- 命令验证（2026-09-17）：`flutter analyze`（No issues）、`flutter test`（64 通过）、`flutter build apk --debug`、`flutter build apk --release`。
- 审查修复批次（2026-09-18，`flutter analyze` 0 issue、`flutter test` 102 通过）：P0（目录+未分类并集、moveCategory 六校验、色板规范化、围栏搜索保留内容、图片魔数越界守卫）；P1（墓碑先落盘、删除确认文案、image rejected 按哈希、待同步口径、认证终局分流清凭据）；codegen 补丁（SyncChange/PushItemResult 辨别器按契约 const 值解析，regen 后重应用，线格式回归见 test/sync_engine_test.dart）；release 签名支持 keystore.properties（缺失回退 debug）、版本统一 1.0.0、分享 FIFO/冷启动种子、备份排除 FlutterSecureStorage。测试见 test/sync_engine_test.dart（mock 回归网）、test/share_service_test.dart、docs/manual-test-matrix.md（真机矩阵）。
- 阶段4 批次C（查询交互）已实现：customOrder 拖拽写回（仅默认排序+Inbox/All+无筛选启用，过滤不存在 ID 并保留回收站 ID）；标签分组管理（setTagGroup/renameTagGroup/deleteTagGroup，隐式标签转正，GROUP_ORDER 排序+组内使用次数，默认组保护）。
- 阶段4 批次E/F（服务端能力）已实现：设备重命名/撤销（含本机撤销清会话）、修改密码（≥12 字符）、对象/项目历史浏览（信封列表+按需单条正文）、快照列表/创建、恢复发起（快照/时间点二选一+原因 1-512）/轮询/取消；恢复成功后复用既有 generation 链路。网络路径以 docs/manual-test-matrix.md 真机验收为准。

## Source of truth
- `design/android-mobile-ui.html` (badge `v0.3`) is the only approved UI spec. `design/` is reference, never production UI.
- `docs/tasktips-mobile-design.md` is the functional baseline; when the HTML mock and it conflict (e.g. FAB scope), the design doc wins.
- It cites `src/styles/theme.css`, which does not exist yet — treat the HTML `:root` / `:root[data-theme="dark"]` blocks as canonical tokens until then.

## Ecosystem compatibility (do not diverge)
- Data model, Markdown + front-matter format, and sync/tombstone semantics must match sibling `../tasktips/docs/tasktips-design.md` and `../tasktips/docs/tasktips-server-sync-design.md`.
- HTTP contract is sibling `../tasktips-cloud/contracts/openapi.yaml`. Do not hand-write duplicate API models once codegen exists.
- Privacy rule from ecosystem: never log full Todo contents, tokens, passwords, or storage credentials / signed URLs.

## UI contract from the mock
- Android-first Material 3. Light brand `#0078D4`, dark brand `#4A9EFF`; bg/panel/surface/status tokens live in the `:root` blocks. UI copy is `zh-CN`.
- 8 pages defined in the `pages` JS object: `today`, `inbox`, `detail`, `folder`, `trash`, `sync`, `settings`, `onboarding`.
- Nav: bottom 4 tabs (`today` / `inbox` / `folder` / `settings`) + FAB on `today`/`inbox`/`folder` (per `docs/tasktips-mobile-design.md` §2 — the v0.3 HTML `show()` still lacks the folder entry and is outdated); FAB routes to `detail`. Creating from today pre-fills today's due date; from a category/tag list the FAB inherits that category/tag.
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
