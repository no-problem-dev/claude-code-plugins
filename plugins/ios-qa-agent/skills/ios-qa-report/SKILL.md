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

## 次のアクション（優先度順）

1. [最も重要な修正事項]
2. [次に重要な修正事項]
3. [Inconclusive テストの再実行条件]
```

## レポート出力の原則

1. **失敗テストを最初に**: 開発者が最初に見るべき情報
2. **推奨アクションを具体的に**: 「ネットワークエラーハンドリングを確認」ではなく「PlatformLLMClient.swift のエラーハンドリングでタイムアウト時の UI フィードバックが欠けている可能性」
3. **Confidence が low のテスト**: Inconclusive と同等に扱い、手動確認を推奨
4. **成功テストは簡潔に**: ID + タイトル + Confidence のテーブルのみ
