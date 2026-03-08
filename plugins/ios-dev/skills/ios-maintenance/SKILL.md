---
name: ios-maintenance
description: iOS ビルドキャッシュクリア・シミュレータ管理を XcodeBuildMCP 経由で実行。「clean」「DerivedData」「cache」「キャッシュ」「クリーン」「simulator boot」「simulator reset」「シミュレータ起動」「シミュレータリセット」などのキーワードで自動適用。
---

# iOS メンテナンス（XcodeBuildMCP）

ビルドキャッシュのクリアとシミュレータの管理。
軽量操作のためメインコンテキストで直接 MCP ツールを呼び出す。

## ビルドクリーン

### XcodeBuildMCP でクリーン
```
ToolSearch("select:mcp__XcodeBuildMCP__clean")
clean(scheme: "<scheme>")
```

### DerivedData 削除（XcodeBuildMCP 外）
XcodeBuildMCP では DerivedData 直接削除は未サポート。Bash で実行:
```bash
# プロジェクト固有
ls ~/Library/Developer/Xcode/DerivedData/ | grep "<ProjectName>"
rm -rf ~/Library/Developer/Xcode/DerivedData/<ProjectName>-*

# 全削除（確認後のみ）
rm -rf ~/Library/Developer/Xcode/DerivedData
```

## シミュレータ管理

### シミュレータ一覧
```
ToolSearch("select:mcp__XcodeBuildMCP__list_sims")
list_sims()
```

### シミュレータ起動
```
ToolSearch("select:mcp__XcodeBuildMCP__boot_sim,mcp__XcodeBuildMCP__open_sim")
boot_sim(simulator_name: "iPhone 16 Pro")
open_sim()
```

### シミュレータリセット
```
ToolSearch("select:mcp__XcodeBuildMCP__erase_sims")
erase_sims(simulator_name: "iPhone 16 Pro")
```

## 注意事項

- `rm -rf` 系のコマンドは実行前にユーザーに確認すること
- DerivedData 全削除は他プロジェクトにも影響する
- シミュレータリセットはアプリデータが全て消える
- simulator-management ワークフローの有効化が必要な操作がある
