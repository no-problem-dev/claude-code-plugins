# アーキテクチャ

## システム構成

```
ios-qa-agent/
├── agents/
│   ├── qa-runner.md (263行)    # テスト実行エンジン
│   └── qa-judge.md (182行)     # 独立判定エンジン
├── skills/
│   ├── ios-qa-workflow/ (324行) # メインオーケストレーター
│   ├── ios-qa-prepare/ (250行)  # テストスイート解析
│   ├── ios-qa-execute/ (173行)  # テスト実行制御
│   ├── ios-qa-report/ (168行)   # レポート生成
│   └── ios-qa-create/ (226行)   # テストケース作成支援
└── docs/
```

## コンポーネント詳細

### サブエージェント

#### qa-runner — テスト実行エンジン

**責務**: アプリを自律操作し、事実を報告する。**判定しない。**

- XcodeBuildMCP の UI Automation ツール（tap, type_text, swipe, snapshot_ui, screenshot）を使用
- observe-think-act ループで自律操作
- App Map の信頼度に基づいて操作方法を自動選択
- Discoveries（確度付き）を報告
- 操作ログはこのエージェント内で完全消費（コンテキスト隔離）

**入力**: テストケース（前提状態 + 操作意図。**期待結果は含まない**）、App Map、制限パラメータ
**出力**: Execution Report（Status, Actions, Final State, Discoveries）

#### qa-judge — 独立判定エンジン

**責務**: runner の報告と期待結果を照合し、判定する。**操作しない。**

- MCP ツールは使用しない
- runner とは独立したコンテキストで動作（確認バイアス排除）
- 3段階判定: Pass / Fail / Inconclusive
- Confidence レベル: high / medium / low
- Key UI Elements の品質チェック

**入力**: テストケースの期待結果 + 補足、runner の Execution Report
**出力**: Judgment（Verdict, Confidence, Item-by-Item Assessment, Evidence, Reasoning）

### スキル

#### ios-qa-workflow — メインオーケストレーター

テスト実行全体を制御する。フェーズスキルに段階的に委譲する。

```
Phase 0:   QA Readiness 検査（条件付き）
Phase 1:   テストスイート解析・実行計画（ios-qa-prepare）
Phase 2:   アプリのビルド & 起動
Phase 3:   テストケース実行ループ（ios-qa-execute）
Phase 3.5: App Map 更新（Discoveries の反映）
Phase 4:   レポート生成（ios-qa-report）
```

**回帰テストモード**: App Map の変更差分を分析し、影響テストを優先実行。
**全体タイムアウト**: デフォルト 900秒（15分）。超過時は残りテストを Skipped。

#### ios-qa-prepare — テストスイート解析

- テストスイート/テストケースの読み込みとパース
- 前提条件プリセットの解決（depends_on の再帰展開）
- 依存関係グラフの構築とトポロジカルソート
- App Map のバージョン判定（format_version < 5 → Phase 0 推奨）
- 回帰テストモード時の App Map 差分分析（Phase 0.5）

#### ios-qa-execute — テスト実行制御

各テストケースを qa-runner → qa-judge のパイプラインで処理する。

- テスト間の状態確認（screenshot で現在画面を確認）
- State transition hints（App Map の Transitions を参照）
- アプリ再起動判断（Fail 後、preconditions 非互換時）
- 独立テストの Fail 後続行（depends_on なしのテストは続行）
- 進捗報告

#### ios-qa-report — レポート生成

- QA レポート（サマリー、Fail/Inconclusive/Pass テスト、次のアクション）
- QA Readiness セクション（Score、改善提案）
- 回帰テストレポート（App Map 差分、影響テスト結果）
- App Map 更新サマリー

#### ios-qa-create — テストケース作成支援

4つのモード:
- **A. 対話的作成**: ユーザーの口頭説明からテストケースを生成
- **B. 画面観察**: 実行中アプリの画面を見てテストケースを提案
- **C. スイートへの追加**: 既存テストスイートに新テストケースを追加
- **D. App Map からの自動生成**: カバレッジ分析で未テスト画面のテストケースを draft 生成

## 実行フロー図

```
ユーザー: 「QA を実行して tests/qa-suite.md」
│
▼ ios-qa-workflow
│
├─ Phase 0: QA Readiness 検査（App Map なし or 古い場合のみ）
│  └─ qa-runner (Full Exploration) → App Map 新規生成
│
├─ Phase 1: 準備 (ios-qa-prepare)
│  ├─ Read(qa-suite.md, TC-*.md, app-map.md)
│  ├─ 前提条件解決、依存関係ソート
│  └─ 実行計画出力
│
├─ Phase 2: アプリ起動
│  └─ ios-dev:xbm-run or build_run_sim
│
├─ Phase 3: テスト実行ループ (ios-qa-execute)
│  │
│  ├─ TC-001:
│  │  ├─ 状態確認 (screenshot)
│  │  ├─ qa-runner (前提+操作意図+App Map) → Execution Report
│  │  │   [snapshot_ui×5, tap×3, screenshot×2 — 内部消費]
│  │  └─ qa-judge (期待結果+Report) → Judgment
│  │
│  ├─ TC-002:
│  │  ├─ 依存チェック (TC-001 Pass?) → 実行 or Skipped
│  │  ├─ 状態遷移 (App Map Transitions 参照)
│  │  ├─ qa-runner → Execution Report
│  │  └─ qa-judge → Judgment
│  │
│  └─ ... (残りのテストケース)
│
├─ Phase 3.5: App Map 更新
│  ├─ 全 Discoveries を集約
│  ├─ [interacted] → 即反映、[observed] → [unverified] で追加
│  ├─ 信頼度変更を適用
│  ├─ Known Issues を追記
│  └─ Write(app-map.md)
│
└─ Phase 4: レポート (ios-qa-report)
   └─ QA Report + QA Readiness + App Map 更新サマリー
```

## データフロー

### テストケースのデータ分離

```
テストケース
├─ 前提状態 ──────────→ qa-runner (操作のガイド)
├─ 操作意図 ──────────→ qa-runner (何をすべきか)
├─ 期待結果 ──────────→ qa-judge (判定の基準) ← runner に渡さない!
└─ 補足 ──────────────→ qa-judge (判定の補足情報)
```

### App Map のデータフロー

```
qa-runner
  │ Discoveries (確度付き)
  ▼
ios-qa-workflow Phase 3.5
  │ マージ・フィルタリング
  ▼
app-map.md (v N+1)
  │ 次回テスト時に Read
  ▼
qa-runner (次回実行)
  └─ 信頼度に基づく操作方法選択
     Known Issues で落とし穴を回避
```

## ios-dev プラグインとの関係

| 項目 | ios-dev | ios-qa-agent |
|------|---------|-------------|
| 目的 | 開発中のビルド・テスト・UI 確認 | 仕様ベースの QA 検証 |
| ビルド | xbm-build | ios-dev:xbm-run に委譲（なければ直接 build_run_sim） |
| UI 操作 | xbm-ui-verify（指示ベース） | qa-runner（意図ベース、自律） |
| 判定 | なし（結果表示のみ） | qa-judge（独立判定） |
| ナレッジ | なし | App Map（自己進化） |

**ソフト依存**: ios-dev があれば活用するが、なくても XcodeBuildMCP さえあれば動作する。
