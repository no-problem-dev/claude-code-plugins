---
name: ios-qa-report
description: QA テスト結果を集約し、構造化レポートを生成するフェーズスキル。失敗テストの分析と次のアクション提案を含む。「QA レポート」「テスト結果」「QA 結果」などのキーワードで自動適用。
---

# QA レポート生成

## レポートフォーマット

```markdown
# QA Report: [スイート名]

**実行日時**: YYYY-MM-DD HH:MM
**アプリ**: [scheme]
**シミュレータ**: [simulator]
**実行環境**: [iOS version]
**実行モード**: [通常 / 回帰テスト]

## 回帰テスト結果（回帰テストモード時のみ）

### App Map 差分サマリー
- **前回バージョン**: A.B.C
- **今回バージョン**: C.D.E
- **新規画面**: N 件
- **変更画面**: N 件
- **削除画面**: N 件
- **遷移変更**: N 件

### 影響テストケース実行結果
| TC-ID | 影響種別 | 結果 | Confidence | 実行時間 | 備考 |
|-------|---------|------|-----------|--------|------|
| TC-001 | precondition 変更 | Pass | high | 45s | home 画面要素が [HIGH]→[MED] に低下。タップ成功 |
| TC-002 | 操作意図 変更 | Fail | high | 38s | settings への遷移が削除され、テスト失敗 |
| TC-003 | 新規画面 | Pass | medium | 52s | session_history 画面が新規追加。初回確認成功 |

### 影響テストケースの成功率
- **Pass**: M 件
- **Fail**: N 件
- **Inconclusive**: K 件
- **成功率**: M / (M + N + K) %

### 推奨アクション

#### 1. 失敗した影響テストケース（優先対応）
- **TC-002**: settings への遷移が削除されたため、テストケースの操作意図を修正するか、テストケースを削除してください

#### 2. 新規テストケースの追加
- **session_history 画面**: 新規追加画面。既存テストでカバー予定でない場合、新規テストケース TC-AUTO-001 の実装を検討してください

#### 3. 削除対象のテストケース
- **deprecated_feature 画面が削除**: 関連テストケースを `skip: true` に設定してください

## App Map 更新

- **Updated**: yes/no
- **New Screens**: N
- **New Transitions**: M
- **New Elements**: K
- **Version**: X.Y.Z
- **Format Version**: 4
- **QA Readiness Score**: X (0-100)
- **QA Readiness Level**: Low / Conditional / High
- **Last Updated**: YYYY-MM-DD HH:MM
- **Last Verified**: YYYY-MM-DD HH:MM

## サマリー

| 結果 | 件数 |
|------|------|
| Pass | N |
| Fail | N |
| Inconclusive | N |
| Skipped | N |
| **合計** | **N** |

**成功率**: X% (Pass / (Pass + Fail + Inconclusive))
**信頼度**: N/M テストで high confidence

## QA Readiness

- **Score**: X/100
- **Level**: Low / Conditional / High
- **主な課題**: [要素識別性、操作可能性、状態観測性のいずれが弱いか]

## 重大な問題（Fail テスト）

### [TC-ID]: [title]
- **Verdict**: Fail
- **Confidence**: [level]
- **問題**: [Issues]
- **根拠**: [Evidence Summary]
- **推奨アクション**: [具体的な修正方針]

## 要確認（Inconclusive テスト）

### [TC-ID]: [title]
- **Verdict**: Inconclusive
- **理由**: [Issues]
- **推奨**: [手動確認 or パラメータ調整]

## 成功テスト

| ID | タイトル | Confidence |
|----|---------|------------|
| TC-XXX | ... | high/medium/low |

## スキップされたテスト

| ID | タイトル | 理由 |
|----|---------|------|
| TC-XXX | ... | 依存先 TC-YYY が失敗 |

## QA Readiness 改善提案

テストスイート実行時に以下の形式で具体的な改善提案を含める:

### Priority 1: 要素識別性の改善（Accessibility Identifiers）

- [画面名] の [要素名]:
  - 現状: tap(label:) 失敗、座標タップ必須
  - 提案: `accessibilityIdentifier: "square.and.pencil"` を Button に追加
  - 効果: [LOW] → [HIGH] に昇格。タップ成功率 向上

### Priority 2: 操作可能性の改善

- [画面名] の [要素名]:
  - 現状: タップしても目に見える変化がない
  - 提案: ボタン有効/無効の UI フィードバック、またはローディング表示を追加
  - 効果: QA テストの検証確度向上

### Priority 3: 状態観測性の改善

- [画面名] の [状態]:
  - 現状: snapshot_ui では検出できない（例：非表示エラーメッセージ）
  - 提案: エラー状態を視覚的に表現（画面遷移、アラート表示等）
  - 効果: QA テストの自動判定が可能に

## 次のアクション（優先度順）

### 通常テスト時
1. [最も重要な修正事項]
2. [次に重要な修正事項]
3. [QA Readiness 改善提案（Priority 順）]
4. [Inconclusive テストの再実行条件]

### 回帰テスト時（回帰テストモードの場合）
1. **影響テストケースの Fail 項目**: 修正 + 再実行が必須
   - アプリの UI 構造変更が既存テストと非互換
   - テストケースの更新または削除が必要

2. **削除画面の関連テストケース**: 削除 or 無効化
   - App Map で削除された画面に依存するテストケースをスキップに設定

3. **新規画面の新規テストケース**: 作成推奨
   - App Map で追加された画面に対するテストケースを作成

4. **変更画面の信頼度低下対応**: テストケース見直し
   - 要素の信頼度が [HIGH] → [MED]/[LOW] に低下した場合
   - テストケースの期待結果や操作方法を見直し
```

## レポート出力の原則

1. **失敗テストを最初に**: 開発者が最初に見るべき情報
2. **推奨アクションを具体的に**: 「ネットワークエラーハンドリングを確認」ではなく「PlatformLLMClient.swift のエラーハンドリングでタイムアウト時の UI フィードバックが欠けている可能性」
3. **Confidence が low のテスト**: Inconclusive と同等に扱い、手動確認を推奨
4. **成功テストは簡潔に**: ID + タイトル + Confidence のテーブルのみ
5. **QA Readiness 改善提案**: 次回テスト実行時にスコア向上させるための具体的アクション（Priority 1-3 順）
