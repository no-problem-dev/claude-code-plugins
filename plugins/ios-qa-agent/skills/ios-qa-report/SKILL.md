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

1. [最も重要な修正事項]
2. [次に重要な修正事項]
3. [QA Readiness 改善提案（Priority 順）]
4. [Inconclusive テストの再実行条件]
```

## レポート出力の原則

1. **失敗テストを最初に**: 開発者が最初に見るべき情報
2. **推奨アクションを具体的に**: 「ネットワークエラーハンドリングを確認」ではなく「PlatformLLMClient.swift のエラーハンドリングでタイムアウト時の UI フィードバックが欠けている可能性」
3. **Confidence が low のテスト**: Inconclusive と同等に扱い、手動確認を推奨
4. **成功テストは簡潔に**: ID + タイトル + Confidence のテーブルのみ
5. **QA Readiness 改善提案**: 次回テスト実行時にスコア向上させるための具体的アクション（Priority 1-3 順）
