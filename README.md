# TaskTips Mobile

本地优先的 Android 待办工具：随手记录、聚焦今日任务、与桌面端（[tasktips](../tasktips)）通过自建云（[tasktips-cloud](../tasktips-cloud)）接续编辑。

## 功能概览

- **本地闭环**（无需登录即可使用）：Markdown + YAML front matter 编辑（预览切换、自动保存）、今日/列表/搜索/筛选/排序、三级目录与标签（分组、自定义颜色）、回收站 30 天保留、本地备份导出/恢复（SAF zip）。
- **桌面互通**：登录/设备注册/项目选择、首次接入预览确认、bootstrap/pull/push 增量同步（revision CAS、requestId 幂等重试、SHA-256 校验）、整对象冲突“保留本机/采用远端”、多设备管理、对象历史、快照与恢复。
- **Android 集成**：文字/链接分享入口、WorkManager 15 分钟后台周期同步、网络恢复自动同步、明暗主题。

数据格式与同步语义与桌面端逐字段对齐（classification.json schemaVersion 3、index.json 规范形态、todo 墓碑 90 天保留），详见 [docs/tasktips-mobile-design.md](docs/tasktips-mobile-design.md) 与 [docs/tasktips-mobile-parity-design.md](docs/tasktips-mobile-parity-design.md)。

## 开发

要求 Flutter 3.47.x / Dart ≥3.13 / JDK 17 / Android SDK 37（minSdk 24——Flutter 3.47 工具强制将 <24 的硬编码 minSdk 迁移为 24，Android 6.0 基线不可维持）。

```bash
flutter pub get
dart pub get --directory=packages/tasktips_api
flutter analyze
flutter test
flutter build apk --debug   # 或 --release（签名见下）
```

- UI 唯一批准稿：`design/android-mobile-ui.html`（v0.3）；业务行为以 `docs/tasktips-mobile-design.md` 为准。
- HTTP 客户端由 `../tasktips-cloud/contracts/openapi.yaml` 生成，vendored 于 `packages/tasktips_api`（regen 后需重应用辨别器补丁，以及 `PayloadsApi.putPayload` 使用调用方 `contentType` 的补丁；回归见 `test/sync_engine_test.dart`、`test/sync_regression_test.dart`）。
- 真机验收矩阵：`docs/manual-test-matrix.md`。性能基准：`integration_test/benchmark_test.dart`（1000 条数据集）。
- 约定与状态记录见 [AGENTS.md](AGENTS.md)；提交格式 `<type>(<scope>): <中文描述>`。

## 发布

- applicationId `dev.tasktips.tasktips`，版本随 `pubspec.yaml`（1.0.0+1）。
- 正式签名：复制 `android/keystore.properties.example` 为 `android/keystore.properties` 并填写 keystore 路径与密码；缺失时回退 debug 签名，仅供内部测试。
- CI（`.github/workflows/android-build.yml`）：push/PR 跑 analyze + test；push 构建仅 arm64-v8a release APK；`v*` 标签发布到 GitHub Release。

## 隐私

本地优先：不登录不上传任何内容。连接同步后，正文经服务端传输；凭据只存系统安全存储；设备身份/同步基线/待提交请求排除在系统云备份与设备迁移之外（`backup_rules.xml` / `data_extraction_rules.xml`）；日志不记录正文与凭据。
