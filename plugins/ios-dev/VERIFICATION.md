# ios-dev v2.0 検証チェックシート

## A. 構造検証（自動）

```bash
# 以下のコマンドで一括チェック可能
cd /path/to/claude-code-plugins/plugins/ios-dev
```

- [x] plugin.json に commands フィールドがない
- [x] commands/ ディレクトリが存在しない
- [x] swift-build-runner.md が存在しない
- [x] ios-build-workflow/ が存在しない
- [x] 全 SKILL.md に有効な YAML フロントマター
- [x] 全 agent .md に有効な YAML フロントマター
- [x] plugin.json の version が 2.0.0
- [x] ワークフロースキルに MCP 検出パターン（XcodeListWindows）が含まれる
- [x] 最適化フラグ（-skipMacroValidation 等）が保持されている

### 自動検証コマンド

```bash
# A1: commands フィールドがないことを確認
grep '"commands"' .claude-plugin/plugin.json || echo "PASS: no commands field"

# A2: commands/ ディレクトリが存在しないことを確認
test -d commands && echo "FAIL: commands dir exists" || echo "PASS: no commands dir"

# A3: swift-build-runner.md が存在しないことを確認
test -f agents/swift-build-runner.md && echo "FAIL: file exists" || echo "PASS: no swift-build-runner"

# A4: ios-build-workflow/ が存在しないことを確認
test -d skills/ios-build-workflow && echo "FAIL: dir exists" || echo "PASS: no ios-build-workflow"

# A5: SKILL.md の YAML フロントマター検証
for f in skills/*/SKILL.md; do
  head -1 "$f" | grep -q "^---" && echo "PASS: $f has frontmatter" || echo "FAIL: $f"
done

# A6: agent .md の YAML フロントマター検証
for f in agents/*.md; do
  head -1 "$f" | grep -q "^---" && echo "PASS: $f has frontmatter" || echo "FAIL: $f"
done

# A7: version が 2.0.0
grep -q '"2.0.0"' .claude-plugin/plugin.json && echo "PASS: version 2.0.0" || echo "FAIL"

# A8: MCP 検出パターン（ワークフロースキルに移動済み）
grep -q "XcodeListWindows" skills/ios-dev-workflow/SKILL.md && echo "PASS: MCP pattern in workflow skill" || echo "FAIL"

# A9: 最適化フラグ
grep -l "skipMacroValidation" agents/*.md | wc -l | grep -q "2" && echo "PASS: optimization flags" || echo "FAIL"
```

---

## B. CLI 動作検証（実プロジェクトで手動）

実際の iOS / SPM プロジェクトディレクトリで検証する。

### B1. ビルド

- [x] iOS プロジェクトで「ビルドして」→ ios-build-runner 起動
- [ ] SPM プロジェクトで「ビルドして」→ ios-build-runner が swift build 実行
- [ ] スキーム指定ビルドが動作する
- [ ] パッケージ解決エラー時にリカバリーする
- [x] サマリーのみ返却（フルログなし）

### B2. テスト

- [x] 「テストして」→ ios-test-runner 起動
- [x] 全テスト実行が動作する
- [ ] 特定テスト実行（-only-testing）が動作する
- [x] 失敗テストの詳細が返却される

### B3. スキル

- [x] ios-diagnostics: CLI フォールバックでエラーチェック動作
- [x] ios-project-info: スキーム一覧が取得できる（ビルド設定含む）
- [x] ios-project-info: シミュレータ一覧が取得できる
- [ ] ios-maintenance: xcodebuild clean が動作する
- [ ] ios-maintenance: DerivedData 削除が動作する

---

## C. MCP 動作検証（Xcode 起動 + MCP 接続）

前提: Xcode が起動済みで、MCP サーバーが接続されていること。

```bash
# MCP サーバーが .mcp.json に登録されていることを確認
grep -q '"xcode"' ~/.mcp.json || grep -q '"xcode"' .mcp.json
```

### C0. MCP 接続

- [x] XcodeListWindows が成功する
- [N/A] ~~サブエージェントから MCP ツールにアクセスできる~~ → プラットフォーム制限で不可と確定（GitHub Issues #13605, #19526）
- [ ] ワークフロースキル（ios-dev-workflow）から MCP ビルドが動作する
- [ ] ワークフロースキル（ios-dev-workflow）から MCP テストが動作する

### C1. MCP ビルド

- [x] BuildProject でビルドが実行される（22.9秒、成功）
- [x] GetBuildLog でログが取得できる（warning 1件検出）

### C2. MCP テスト

- [x] GetTestList でテスト一覧が取得できる（4テスト検出）
- [x] RunAllTests で全テスト実行できる（2 passed / 2 failed）
- [x] RunSomeTests で個別テスト実行できる（実行確認済み）

### C3. MCP 専用機能

- [x] RenderPreview で SwiftUI プレビューが取得できる（EmptyDetailView で検証）
- [x] ExecuteSnippet で Swift コードが実行できる（"Hello from Swift REPL" 出力確認）
- [x] DocumentationSearch で Apple ドキュメントが検索できる（NSAttributedString markdown で検証）
- [x] XcodeListNavigatorIssues でエラー一覧が取得できる（error 2 + warning 1 検出）
- [x] XcodeRefreshCodeIssuesInFile でファイル診断が動作する（PreviewPage.swift で検証）

### C4. フォールバック

- [ ] MCP 未接続時にビルドが CLI で動作する
- [ ] MCP 未接続時にテストが CLI で動作する
- [ ] MCP 未接続時に ios-preview-repl が適切なエラーメッセージを表示する

---

## 検証記録

| 日付 | 検証者 | 段階 | 結果 | 備考 |
|------|--------|------|------|------|
| 2026-02-07 | Claude | A（構造） | 全 PASS | 自動コマンドで一括検証 |
| 2026-02-07 | Claude | C0（MCP 接続） | PASS | XcodeListWindows 成功 |
| 2026-02-07 | Claude | C1（MCP ビルド） | PASS | BuildProject + GetBuildLog 正常動作 |
| 2026-02-07 | Claude | C2（MCP テスト） | PASS | GetTestList + RunAllTests + RunSomeTests 正常動作 |
| 2026-02-07 | Claude | C3（MCP 専用） | PASS | RenderPreview/ExecuteSnippet/DocumentationSearch/Issues 全動作 |
| 2026-02-07 | Claude | B3（スキル CLI） | 部分 PASS | diagnostics/project-info 動作確認、maintenance は未検証 |

### 未検証項目（実運用で追加検証が必要）

- B1: SPM プロジェクトでの swift build / スキーム指定ビルド / パッケージ解決リカバリー
- B2: CLI での -only-testing 個別テスト
- B3: ios-maintenance の clean / DerivedData 削除
- C0: ワークフロースキルからの MCP ビルド / MCP テスト（スキル層移動後の検証）
- C4: MCP 未接続時のフォールバック動作全般
