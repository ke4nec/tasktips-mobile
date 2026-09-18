# 发布签名密钥管理

## 现状

- keystore：`android/release.keystore`（PKCS12，alias `tasktips`，RSA 2048，有效期 10000 天，生成于 2026-09-18）
- 证书 SHA-256：`C0:8D:B3:0E:2C:99:E7:FA:2B:C1:00:F2:E0:BA:EB:13:63:5A:A6:FC:19:3C:A2:04:14:CF:BE:96:F2:16:9F:2B`
- 口令：`android/keystore.properties`（store 与 key 同一个随机口令；该文件不入库）

## 为什么必须固定签名

Android 覆盖安装要求新旧版本同一 `applicationId` 使用同一密钥签名。历史上 CI 缺
`keystore.properties` 时回退 debug 签名，而 GitHub 托管 runner 每次构建重新生成
debug.keystore，导致 v0.0.3 及之前的 APK 彼此签名不同，升级安装均被拒。自 v0.0.4
起所有发布 APK 使用上述固定证书；**丢失该 keystore 将无法向已装用户推送更新**
（只能换 applicationId 重新上架），务必备份。

## 备份（生成后立即做）

1. 备份 `android/release.keystore` 文件本身；
2. 备份口令（见 `android/keystore.properties`，或密码管理器）；
3. 备份 GitHub Secrets 的原始材料：`base64 -w0 android/release.keystore` 的输出
   （即 `KEYSTORE_BASE64`）。

建议 keystore 文件 + 口令分开存放（如密码管理器存口令、离线介质存文件），至少
保持两份独立拷贝。

## CI Secrets

| Secret | 内容 |
| --- | --- |
| `KEYSTORE_BASE64` | `base64 -w0 android/release.keystore` 输出 |
| `KEYSTORE_PASSWORD` | store/key 口令（同一值） |

CI（`.github/workflows/android-build.yml` 的 build 作业）在构建前解码生成
`android/release.keystore` 与 `android/keystore.properties`；Secrets 缺失时构建直接
失败，不会静默回退 debug 签名。

更新 Secrets（口令轮换/keystore 更换）：

```bash
base64 -w0 android/release.keystore | gh secret set KEYSTORE_BASE64 -R ke4nec/tasktips-mobile
grep '^storePassword=' android/keystore.properties | cut -d= -f2 | gh secret set KEYSTORE_PASSWORD -R ke4nec/tasktips-mobile
```

## 灾难恢复：keystore 丢失

无法用新 keystore 对旧包名发更新。两个选择：

1. 找回备份（推荐）；
2. 生成新 keystore（下方命令）并**同时更换 `applicationId`**，作为全新应用发布，
   老应用发最后一个版本引导导出/同步数据后迁移。

## 再生成（仅新应用或换包名时使用，勿覆盖现有 keystore）

```bash
PASS=$(openssl rand -hex 20)
keytool -genkeypair -v \
  -keystore android/release.keystore \
  -alias tasktips -keyalg RSA -keysize 2048 -validity 10000 \
  -storetype PKCS12 -storepass "$PASS" -keypass "$PASS" \
  -dname "CN=TaskTips Mobile, OU=TaskTips Mobile, O=TaskTips, C=CN"
printf 'storeFile=../release.keystore\nstorePassword=%s\nkeyAlias=tasktips\nkeyPassword=%s\n' "$PASS" "$PASS" > android/keystore.properties
chmod 600 android/keystore.properties
```

生成后按上文更新备份与 Secrets。

## 本地验证签名

```bash
flutter build apk --release --target-platform android-arm64 --split-per-abi
"$HOME/Android/Sdk/build-tools/36.0.0/apksigner" verify --print-certs \
  build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

输出的 `SHA-256 digest` 应与上文证书指纹一致。
