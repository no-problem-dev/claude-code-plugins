---
name: ios-maintenance
description: iOS ビルドキャッシュクリア・DerivedData 削除・シミュレータ管理。「clean」「DerivedData」「cache」「キャッシュ」「クリーン」「simulator boot」「simulator reset」「シミュレータ起動」「シミュレータリセット」などのキーワードで自動適用。ios-clean の後継。
---

# iOS メンテナンス（ios-clean 後継 + シミュレータ管理）

ビルドキャッシュのクリアとシミュレータの管理。

## ビルドキャッシュクリア

### 基本クリーン
```bash
# プロジェクト検出
WORKSPACE=$(find . -maxdepth 2 -name "*.xcworkspace" -type d | grep -v ".xcodeproj/project.xcworkspace" | head -1)

# xcodebuild clean
xcodebuild clean -workspace "$WORKSPACE" -scheme <scheme> 2>&1 | tail -5
```

### 深いクリーン（DerivedData 削除）
```bash
# プロジェクト固有の DerivedData を特定して削除
# まずプロジェクト名で検索
ls ~/Library/Developer/Xcode/DerivedData/ | grep "<ProjectName>"
rm -rf ~/Library/Developer/Xcode/DerivedData/<ProjectName>-*

# または全 DerivedData を削除（最終手段）
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### SPM キャッシュクリア
```bash
# ローカル .build ディレクトリ
rm -rf .build

# Package.resolved（依存を再解決したい場合）
rm Package.resolved

# グローバル SPM キャッシュ
rm -rf ~/Library/Caches/org.swift.swiftpm
```

## シミュレータ管理

### シミュレータ起動
```bash
# 特定のシミュレータを起動
xcrun simctl boot "iPhone 16 Pro"

# Simulator.app を開く
open -a Simulator
```

### シミュレータ停止
```bash
# 特定のシミュレータ
xcrun simctl shutdown "iPhone 16 Pro"

# 全シミュレータ
xcrun simctl shutdown all
```

### シミュレータリセット
```bash
# 特定のシミュレータのデータをリセット
xcrun simctl erase "iPhone 16 Pro"

# 全シミュレータをリセット
xcrun simctl erase all
```

### シミュレータ一覧
```bash
xcrun simctl list devices available
```

## アプリ操作（シミュレータ上）

### アプリインストール
```bash
xcrun simctl install booted <path-to-.app>
```

### アプリ起動
```bash
xcrun simctl launch booted <bundle-identifier>
```

### スクリーンショット
```bash
xcrun simctl io booted screenshot screenshot.png
```

## 使用タイミング

- ビルドが不安定な時 → 基本クリーン
- キャッシュ起因のエラー / ブランチ切り替え後のエラー → 深いクリーン
- ディスク容量確保 → DerivedData + SPM キャッシュ削除
- シミュレータが応答しない → シミュレータリセット
- 特定の OS バージョンでテストしたい → シミュレータ起動

## 注意事項

- `rm -rf` 系のコマンドは実行前にユーザーに確認すること
- DerivedData 全削除は他の Xcode プロジェクトにも影響する
- シミュレータリセットはアプリデータが全て消える
