---
description: CHANGELOGの「未リリース」セクションに変更を追加
allowed-tools: Read, Write, Edit, Glob
argument-hint: <category> <description> (例: 追加 "新機能の説明")
---

# CHANGELOG追加コマンド

CHANGELOGの「未リリース」セクションに変更エントリを追加します。

## 引数

$ARGUMENTS の形式: `<category> <description>`

### カテゴリ一覧
- `追加` / `added` - 新機能
- `変更` / `changed` - 既存機能の変更
- `非推奨` / `deprecated` - 将来削除予定の機能
- `削除` / `removed` - 削除された機能
- `修正` / `fixed` - バグ修正
- `セキュリティ` / `security` - セキュリティ関連

## 実行手順

1. **引数を解析**: カテゴリと説明を分離
2. **CHANGELOG.mdを読み込み**
3. **「未リリース」セクションを探す**
4. **該当カテゴリのサブセクションを探す/作成**
5. **エントリを追加**
6. **ファイルを保存**

## 出力例

```
✅ CHANGELOGにエントリを追加しました

カテゴリ: 追加
内容: - **API**: POST /api/v1/users エンドポイントを追加

現在の「未リリース」セクション:
## [未リリース]

### 追加
- **API**: POST /api/v1/users エンドポイントを追加
```

## ベストプラクティス

説明には以下を含めることを推奨:
- **プラットフォーム/コンポーネント**: `**Backend**:`, `**iOS**:`, `**API**:`
- **具体的な内容**: 何が変わったか
- **ユーザー価値**: なぜ重要か（必要に応じて）
