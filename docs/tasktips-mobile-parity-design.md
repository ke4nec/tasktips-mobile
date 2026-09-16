# TaskTips 移动端桌面功能对齐设计（阶段4）

> 状态：设计稿，待实现。基于 2026-09-16 对桌面端 `../tasktips`（代码为准）、云端契约 `../tasktips-cloud/contracts/openapi.yaml` 与本仓库现状的逐项核对。阶段1–3 已交付；本文定义阶段4「桌面功能对齐」的范围、精确格式与验收。
>
> 前置事项：工作区尚有 v0.3 设计稿 UI 改动未提交，且 `test/app_smoke_test.dart` 期望文案（「开始使用」）落后于实际（「开始记录」）；开工前先修复该测试并提交 v0.3 基线。

## 1. 范围与优先级

按风险与价值分四批，编号供任务引用：

| 批次 | 内容 | 理由 |
|---|---|---|
| **P0 兼容修复** | classification.json 序列化不兼容（§2.1）；pull 遇 image 对象崩溃（§2.2） | 不修复则与桌面互通会损坏数据或中断同步，优先于一切新功能 |
| **P1 补齐首版设计缺口** | 图片导入与图片同步（§3）；目录移动校验（§4.4） | 首版设计（tasktips-mobile-design.md §3、§4.1、§4.2）已承诺但未实现 |
| **P2 桌面已有功能** | 自定义排序（§4.1）；标签筛选 and/or/exclude（§4.2）；标签分组管理（§4.3） | 首版设计明确「后续增加」，现按桌面语义补齐 |
| **P3 服务端能力** | 设备管理、认证失效分流、修改密码（§5.1）；对象历史、快照与恢复（§5.2/§5.3） | 契约与生成客户端零缺口，全部是 `lib/` 层工作 |

**非目标**（明确不做，防止范围蔓延）：

- 云盘目录同步（桌面 FolderProvider 交换目录）——按用户决定不需要。
- 通知提醒、重复任务、任务级置顶/归档——桌面端设计亦为非目标。
- 块级混合渲染编辑器（Milkdown 形态）、命令面板、多语言。
- 忘记密码/自助注册——云端契约不存在对应端点（邀请制账号）。
- 本地备份与导出、跨账号/项目切换——沿用首版设计 §6 待确认状态，本文不替用户决定。

## 2. P0 数据兼容修复

### 2.1 classification.json 序列化对齐

现状五处不兼容（`lib/domain/classification.dart`）：

| # | 移动端现状 | 桌面端要求 | 后果 |
|---|---|---|---|
| 1 | 写 `schemaVersion: 1` | 当前为 **3**（`classification_store.rs:106-113` 含 1→2→3 迁移，仅接受 ≤3） | 桌面可读但走旧迁移路径 |
| 2 | Category/Tag 无 `createdAt`/`updatedAt` | 两者为**必填**（`domain/classification.rs:63-64`，无 serde default） | **桌面解析移动端文件直接失败**，进恢复流程 |
| 3 | `fromJson` 丢弃未知字段（icon/description/orderIndex/isSystem） | 桌面始终写这些字段 | 移动端读后保存即**静默丢数据** |
| 4 | 颜色写语义键 `'blue'/'green'`…（`folder_page.dart:377-379`） | 32 色 hex 色板（`COLOR_PALETTE`，`#8a8a8a`…），color 为必填字符串 | 桌面渲染移动端颜色为无效值 |
| 5 | Tag.group 缺省空串 `''` | 持久化值归一为 `"其他"`（`DEFAULT_TAG_GROUP`） | 值语义可兼容但非逐字节一致 |

修复方案：

- `Category`/`Tag` 增加 `createdAt`/`updatedAt`（必填，新建实体取当前 UTC）、`icon`/`description`（默认空串）、Category 另加 `orderIndex`（默认 0）；`toJson` 写 `schemaVersion: 3`。
- 读取时保留未知字段（在实体上加 `extra` map 原样写回，做法对齐 Todo 的 `extraFrontMatter`），保证「移动端只读不写」往返不丢字节。
- 颜色改为桌面 32 色 hex 色板；旧语义键按下表映射迁移（`blue→#4a9eff`、`green→#6ccb5f`、`orange→#fb923c`、`purple→#a78bfa`、`red→#f97066`、`gray→#8a8a8a`），`null` 保持不写或写默认色均可（桌面缺省会取 `#8a8a8a`），选定「始终写 hex」以对齐桌面序列化。
- `group` 空串在序列化层归一写 `"其他"`，内存中允许空串表示默认组。
- 解析旧 schemaVersion 1/2 文件时补默认值升级，不视为损坏。

验收：用桌面端生成的 classification.json 作为夹具——移动端读入后不改任何内容再保存，与原文件逐字节等价（未知字段、时间戳、色板全保留）；移动端新建目录/标签后，桌面端可正常解析并渲染颜色。

### 2.2 同步引擎二进制对象防御与 image 同步接入

现状：`sync_engine.dart:461` `_writeRemoteObject` 在 switch 之前执行 `utf8.decode(bytes)`；pull 流中出现 `kind == "image"` 的对象（桌面端上传图片必然产生）会抛 `FormatException` 中断整页 pull，同步卡死。

修复：image 对象走独立二进制路径——pull 时校验哈希后直接把字节写入 `content/tips/images/<objectId>.<ext>`（不做文本解码）；push、冲突与墓碑语义见 §3.3。若阶段4分批交付，本条最小防御（跳过 image 变更并推进 cursor、日志记录）不得晚于 P1 图片导入上线。

## 3. P1 图片导入与图片同步

首版设计已定义（tasktips-mobile-design.md §3「编辑与保存」、§4.1、§4.2 步骤3），本节补齐实现细节，全部对齐桌面端 `image_store.rs` 与设计 §7.6。

### 3.1 导入

- 入口：编辑页工具栏图片按钮（现占位行为替换）。调起系统图片选择器（推荐 Android Photo Picker，`image_picker`；选型确认见 §9）；不申请相机与广义存储权限。
- 校验：**魔数白名单**，不信任文件名与 MIME——PNG `89 50 4E 47`；JPEG `FF D8 FF`；GIF `GIF87a`/`GIF89a`；WebP `RIFF….WEBP`（bytes[8..12]）；BMP `BM`；**SVG 拒绝**。大小 ≤ **10 MiB**（10×1024×1024，按原始字节计），超限保留编辑并提示原因，禁止截断。
- 落盘：复制到 `content/tips/images/<ULID>.<ext>`（ext 取 png/jpg/gif/webp/bmp），临时文件 + rename 原子写；**绝不使用用户原始文件名**。
- 插入：光标处插入 `![alt](images/<ulid>.<ext>)`；alt 取原始文件名去扩展名、折叠空白、限 60 字符（超出加 `…`）。
- 渲染：沿用现有 `_ImagePlaceholder` 占位卡片（桌面端编辑器同样不加载图片内容，保持一致）；预览不自动加载网络图片的规则不变。
- 删除：删除 Markdown 引用或 Todo **不清理** images/ 孤儿文件（桌面明确延后清理策略）。

### 3.2 同步

图片是独立二进制同步对象（kind `image`，id = 文件主名 ULID）：

- **push**：本地新增图片文件后，对象内容 = 原始字节，contentHash 按实际字节 SHA-256；`putPayload` 上传后随正常 push 流程提交对象版本；10 MiB 限额与共享领域约束一致，超限保留本地并提示。
- **pull**：收到 image 变更按 §2.2 二进制路径写文件；image 墓碑 = 删除本地文件（桌面当前无清理来源，语义预留）。
- 冲突：图片冲突保留双方文件（整对象「保留本机/采用远端」，与现有一致）。
- 图片引用（`images/...` 相对路径）随 Todo 正文同步，不做路径改写。

验收：手机导入图片 → 桌面端 pull 后占位可见且 payload 可取；桌面端导入 → 手机 pull 不中断、文件落盘；10 MiB 边界与 SVG 拒绝有测试。

## 4. P2 列表与分类功能

### 4.1 自定义排序（customOrder）

桌面语义（`index.rs`、`todo_service.rs`，设计 `custom-order-design.md`）：

- index.json 的 `customOrder` 仅含 `inbox`/`all` 两个视图键，值为 ULID 数组；目录视图无自定义顺序。
- **仅默认排序时生效**：`query.sort.is_none()` 才应用；用户显式选择任何排序键即绕过。
- 应用算法：命中的 ID 按数组顺序在前，未命中者按默认复合排序（未完成→过期→优先级降序→截止升序→更新降序）稳定追加在后；数组中不存在的 ID 自然跳过。
- 写回：全量覆盖该视图数组，先过滤掉当前不存在的 ID；软删除（回收站中）的 ID 保留。

移动端方案：

- `runQuery` 增加可选参数 `customOrder`（由调用方从 `model.index` 取 `customOrder['inbox'|'all']`），条件 `q.defaultSort && view ∈ {inbox, all}` 时按上述稳定算法套用。
- UI：`ReorderableListView` 长按拖动。启用条件：默认排序 + 视图为 inbox/all + **无搜索与筛选**（`hasActiveFilter` 为 false 时才允许拖动）。桌面代码实际允许筛选态拖拽并整组覆盖写回（`ListWindow.vue:512-516`），会丢失旧顺序——移动端按桌面**设计文档**语义禁用，此差异记录为已知分歧。
- 写回：拖动结束把当前视图完整 ID 列表（含回收站中的既有 ID 原位保留）写回 `customOrder[view]` 并原子保存 index.json；index 本身已是同步对象，冲突走现有整对象流程。
- 已知差异记录：桌面 `lastFullScan` 字段实现为 `lastScanAt`，移动端 `IndexData` 已按代码命名。

### 4.2 标签筛选模式（tagMode）

桌面语义（`domain/query.rs:295-312`、`FilterBar.vue`）：

- `TagFilterMode = "and" | "or" | "exclude"`，缺省 and；标签为空时任何模式恒命中；标签名匹配做 Unicode 小写折叠。
- and=全部命中（∀）、or=任一命中（∃）、exclude=无一命中（¬∃）。

移动端方案：

- `TodoQuery` 增加 `tagMode`（枚举，默认 `and`）；`runQuery` 第 93-99 行的 AND 判断改为按模式三分支。
- UI：筛选面板标签区增加模式选择（三个 chip 或下拉：`全部包含 / 任一包含 / 均不包含`）；未选标签时禁用。`清除筛选` 同时复位 tagMode。
- tagMode 只存在于查询内存态，不落盘、不进任何同步对象。

### 4.3 标签分组管理

桌面语义（`domain/classification.rs`、`classification_service.rs`）：

- 分组不是实体，只是 Tag.group 字符串的聚合；默认组 `"其他"`；组名 trim 后非空、≤20 字符；空白归「其他」。
- 组排序：`["优先级","状态","属性","其他"]` 固定在前（`GROUP_ORDER`），自定义组随后，组内按使用次数降序、次数同则名称。
- 重命名组：默认组不可改；把组内全部活跃标签 group 批量改为新名（共用同一 updatedAt）；改名到已存在组被拒绝（提示「分组名称已存在: X；如需合并请删除原分组」）。
- 删除组：组内活跃标签回到「其他」，不删标签。
- 设置单标签分组：隐式标签（仅出现在 Todo 上、未注册实体）先「转正」注册为实体再入组。

移动端方案：

- `AppModel` 增加 `setTagGroup` / `renameTagGroup` / `deleteTagGroup`，规则与文案照抄桌面；`tagsByGroup` 排序对齐 GROUP_ORDER（系统组不存在时顺序仍按该表，缺组跳过）。
- UI（folder 页标签 tab）：标签长按/菜单增加「设置分组」（弹层选现有组或新建）；组标题右侧菜单「重命名分组 / 删除分组」，删除确认文案注明「组内标签将移入"其他"」；分组标题常显，「其他」组空也保留。
- 依赖 §2.1 的 group 归一（空串↔「其他」）先落地。

### 4.4 目录移动校验补齐

现状（`app_model.dart:325-339` `moveCategory`）：已有自移/移入子孙拦截与 parentId 写入；缺三条规则。对齐桌面 `move_category` 六条校验：

1. `id == "uncategorized"` 保留 ID 拒绝（移动端当前未生成该 ID，防御性拦截）。
2. `newParent == id` → 「不能把目录移动到自己下面」。
3. 新父是自身或子孙 → 「不能把目录移动到自己的子目录下」。
4. **深度上限按「父级层级 + 被移动子树高度 ≤ 3」**（现实现 `depthOf(id)+1>3` 只算了单节点层级，三层子树移到二级目录下会误放行）。
5. 移动后同层重名校验（大小写折叠，排除自身）→ 「同级已存在同名目录」（新建路径已有此文案，复用）。
6. 只改 `parentId` + `updatedAt`，子目录不级联，不触碰 index.json。

## 5. P3 服务端能力

契约与生成客户端（`packages/tasktips_api`）已全覆盖所需端点：`revokeDevice`、`updateDevice`、`changePassword`、`listProjectHistory`、`listObjectHistory`、`listSnapshots`、`createSnapshot`、`createRestore`、`getRestore`、`cancelRestore` 均已生成，无需重新 codegen。以下全部是 `lib/` 层工作。

### 5.1 设备管理、认证失效分流与修改密码

**设备列表增强**（sync 页设备卡片）：

- 列表项菜单：「重命名」（`updateDevice`，displayName 1-128）与「撤销此设备」（`revokeDevice`，二次确认，文案说明撤销立即生效且不可恢复）。
- 撤销**本机**设备：确认弹层必须说明后果——本机凭据立即失效、需要重新登录；revoke 成功后立即清空本机会话（等同退出登录），不再发起同步。
- 撤销其他设备：刷新列表即可；不把「最近活动」解释为在线状态（沿用现文案规则）。

**认证失效分流**（`sync_engine.dart` 现状：401 → 尝试刷新 → 失败原样上抛，仅按 HTTP 状态码给文案；刷新 token 仍留在安全存储，重启后回到「已连接但一直失败」循环）：

- 解析 401/403 响应体 `ErrorResponse.code`，区分三态：
  - `DEVICE_REVOKED` → 停止同步、清空凭据、状态转 `disconnected`，提示「此设备已被撤销，请重新登录」；
  - `ACCOUNT_DISABLED` → 停止同步、清凭据，提示「账号已被禁用」；
  - `AUTHENTICATION_REQUIRED`（刷新失败/凭据无效）→ 清凭据转 `disconnected`，提示重新登录。
- 刷新失败分支必须调 `session.clear()`，不得让失效凭据在下次启动时被 `loadState` 重新判为已连接。
- 403 文案不再笼统猜测「设备可能已被撤销」，以错误码为准。

**修改密码**（设置页账号区或同步页，二选一，实现时按 UI 稿空间定）：

- 表单：当前密码 + 新密码（≥12 字符，契约 `PasswordChangeRequest`）；成功 204 后提示「其他设备需重新登录」（服务端会撤销该账号全部 refresh token），本机走一次刷新或要求重新登录。
- 登出（`logout`）已实现，不再重复。

### 5.2 对象历史浏览

- 入口：同步页「历史」二级页；对象级历史另从详情页菜单「查看历史」进入（`listObjectHistory`）。
- 列表仅展示信封字段：时间、kind、id、revision、baseRevision、contentHash 前 8 位、deviceId、changeSequence；支持 kind 筛选与 `afterSequence` 分页（limit 200，`hasMore` 续拉）。墓碑行标注「此版本为删除」。
- **查看正文按需 `getPayload` 单条**（服务端设计 §11.5 明确禁止因浏览历史批量下载 payload）；正文展示为只读，不提供从历史直接恢复单对象（恢复一律走 §5.3 整项目流程，与桌面对齐）。

### 5.3 快照与恢复

- 快照列表（`listSnapshots`：generation、changeSequence、status、createdBy、createdAt）+ 「立即创建快照」（`createSnapshot`，423 维护中/503 存储不可用按现状文案处理）。
- 发起恢复（`createRestore`，202 返回 `RestoreJob`）两种模式：按快照 / 按 `targetChangeSequence` 时间点；`reason` 必填（trim 后 1-512 字符，写入永久审计，表单需说明）。
- 任务页轮询 `getRestore` 至终态（queued→running→succeeded/failed/cancelled）；期间提供 `cancelRestore`（同样需 reason）。
- **恢复成功后服务端 generation+1**：复用现有 `GENERATION_MISMATCH`(409) → 暂停提交 → 重新 bootstrap → 预览确认 的既有链路（sync_engine 409 分支已实现，验证衔接即可）；409 并发恢复冲突按提示重试。
- UI 放同步页「高级」折叠区，入口文案明确「恢复会影响项目内所有设备」。

## 6. 编辑器小项

- **撤销/重做**：桌面仅为 Milkdown history 插件的会话级历史（不持久化、关窗即清）。移动端对齐：编辑会话内提供撤销/重做（`TextField` + `UndoHistory` 或自维护快照栈），离开编辑页清空；不写入 Markdown、不跨会话。
- **代码块工具栏按钮**：核对结论——桌面工具栏实际只有粗体/斜体/删除线/两类列表 5 个按钮，**没有代码块按钮**；移动端现有按钮集已超出桌面。此项不是对齐缺口，不做（避免移动端单方面偏离）。

## 7. 交付顺序

每批独立可发布，完成即更新 AGENTS.md「Status」并记录 `flutter analyze` / `flutter test` / `flutter build apk` 结果：

1. **前置**：修 smoke 测试文案 → 提交 v0.3 UI 基线。
2. **批次A（P0）**：§2.1 classification 序列化 + §2.2 image 二进制路径。用桌面序列化夹具加共享测试。
3. **批次B（查询层）**：§4.2 tagMode + §4.1 customOrder 读取应用（不含拖拽 UI）+ §4.4 移动校验。纯 `domain/` 逻辑，测试优先。
4. **批次C（交互层）**：§4.1 拖拽 UI + §4.3 标签分组管理。
5. **批次D（图片）**：§3 导入 + 同步。
6. **批次E（认证与设备）**：§5.1。
7. **批次F（历史/快照/恢复）**：§5.2 + §5.3。

## 8. 验收用例（节选关键场景）

| 场景 | 必须满足的结果 |
|---|---|
| 桌面生成 classification.json → 手机只读保存 → 桌面再读 | 逐字节等价，未知字段、时间戳、hex 色板不丢失；桌面无解析错误 |
| 桌面上传含图片的项目 → 手机 bootstrap/pull | 同步不中断；images/ 文件落盘；正文引用保持相对路径 |
| 手机导入 PNG/JPEG/GIF/WebP/BMP 与 SVG、>10MiB 文件 | 白名单通过并插入引用；SVG 与超限被拒且不产生半写文件 |
| 手机在 Inbox 默认排序拖动 → 桌面打开 | 桌面显示相同顺序；选择任何显式排序后两侧均回退默认规则 |
| 手机在筛选/搜索态、显式排序态 | 拖动手柄不可用；不写 customOrder |
| 标签选 `甲+乙` 三种模式 | and=同时含两者；or=含其一；exclude=两者皆无；清除筛选复位 |
| 三级子树拖入二级目录、目标层有同名 | 均被拦截，文案与桌面一致 |
| 重命名/删除分组、隐式标签入组 | 组内标签随组更新；删组标签回「其他」；隐式标签转正为实体 |
| 撤销本机设备、撤销其他设备、改密码 | 本机立即断开并清凭据；其他设备下次请求收到 DEVICE_REVOKED 分流提示；改密后其他设备需重新登录 |
| 浏览 1000 条历史 | 只发起信封请求；点开单条才取一次 payload |
| 发起快照恢复成功 | 轮询至 succeeded；本地自动走 generation 变化 → bootstrap 预览确认；旧 cursor 失效不误推送 |

## 9. 待确认事项

- **图片选择器选型**：Android Photo Picker（`image_picker`，无权限、仅相册）vs SAF 文件选择器（`file_picker`，可选下载目录中的图片）。默认按 Photo Picker 设计。
- **32 色板 UI**：设计稿 v0.3 目录/标签颜色弹层仍是 6 个语义色，需设计稿更新为 hex 色板呈现（分批可行：先底层格式对齐，UI 色板展示沿用现有 6 色但值改为 hex 映射）。
- **拖拽禁用条件**：本文按桌面设计文档「有筛选时禁用」；桌面代码现状允许筛选态拖拽并整组覆盖。若要完全复刻桌面行为需反向上游确认，默认不复刻。
- **修改密码入口位置**（设置页 vs 同步页）待 UI 稿补充后定。
