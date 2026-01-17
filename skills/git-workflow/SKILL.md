---
name: git-workflow
description: |
  Git操作の標準化を強制するスキル。
  コミットメッセージ、ブランチ命名規則、PRの説明、マージ戦略などを統一し、
  チーム全体で一貫したGitワークフローを維持します。

  <example>
  Context: コミット作成時またはPR作成時
  user: "この変更をコミットして"
  assistant: "git-workflowスキルを適用して、コミットメッセージの形式、ブランチ名、変更内容を確認します。"
  <commentary>
  Gitワークフローの標準化により、履歴の可読性と追跡性が向上します。
  </commentary>
  </example>
---

# Git Workflow Skill

Git操作の標準化を強制するスキルです。
コミットメッセージ、ブランチ命名規則、PRの説明、マージ戦略などを統一し、チーム全体で一貫したGitワークフローを維持します。

## 使用タイミング

- コミット作成時
- ブランチ作成時
- プルリクエスト作成時
- マージ前

## チェック項目

### 1. コミットメッセージ

- [ ] コミットメッセージが規約に従っているか（Conventional Commits推奨）
- [ ] コミットメッセージが英語で記述されているか（必須）
- [ ] コミットメッセージが明確で理解しやすいか
- [ ] コミットメッセージに変更の理由が含まれているか（必要に応じて）
- [ ] 1つのコミットが1つの論理的な変更を表しているか（atomic commits）
- [ ] コミットメッセージに機密情報が含まれていないか

#### コミットメッセージ形式（推奨: Conventional Commits）

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type例**:
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント変更
- `style`: コードスタイル変更（フォーマット等）
- `refactor`: リファクタリング
- `test`: テスト追加・変更
- `chore`: ビルドプロセスやツールの変更
- `perf`: パフォーマンス改善
- `ci`: CI設定変更

**例**:
```
feat(auth): Add multi-factor authentication

Implement TOTP-based multi-factor authentication for user authentication.
Enhance security and improve account protection.

Closes #123
```

#### コミットメッセージの言語ルール

**必須**: コミットメッセージは英語で記述する必要があります。

**理由**:
- 国際的な開発チームでの可読性向上
- オープンソースプロジェクトへの貢献時の標準
- ツールやCI/CDシステムとの互換性
- 履歴検索の一貫性

**例外**:
- プロジェクト固有の用語やドメイン固有の概念は、適切な英語表現を使用する
- 技術的な制約により英語での表現が困難な場合は、簡潔な英語とコメントで補足する

**チェック項目**:
- [ ] コミットメッセージのsubject（タイトル）が英語か
- [ ] コミットメッセージのbody（本文）が英語か（存在する場合）
- [ ] 技術用語が適切な英語で表現されているか
- [ ] 文法エラーがないか（基本的な文法チェック）

### 2. ブランチ命名規則

- [ ] ブランチ名が規約に従っているか
- [ ] ブランチ名が英語で記述されているか（必須）
- [ ] ブランチ名が意味を持っているか（機能名、チケット番号等）
- [ ] ブランチ名に機密情報が含まれていないか

#### ブランチ命名規則（推奨）

```
<type>/<ticket-number>-<short-description>
```

**Type例**:
- `feature/`: 新機能
- `fix/`: バグ修正
- `hotfix/`: 緊急修正
- `refactor/`: リファクタリング
- `docs/`: ドキュメント

**例**:
```
feature/123-user-authentication
fix/456-login-error
hotfix/789-security-patch
```

### 3. プルリクエスト

- [ ] PRのタイトルが英語で記述されているか（必須）
- [ ] PRのタイトルが明確で、変更内容を要約しているか
- [ ] PRの説明が英語で記述されているか（必須、プロジェクト固有の要件がある場合は例外可）
- [ ] PRの説明に以下が含まれているか：
  - 変更の目的・背景
  - 変更内容の概要
  - テスト方法
  - スクリーンショット（UI変更時）
  - 関連チケット番号
- [ ] 破壊的変更がある場合は明記されているか
- [ ] レビュアーが指定されているか
- [ ] ラベルが適切に設定されているか

#### PRテンプレート（推奨）

**注意**: PRの説明は英語で記述してください。

```markdown
## Purpose
<!-- Why is this change needed? -->

## Changes
<!-- What was changed? -->

## Testing
<!-- How was this tested? Test procedures -->

## Screenshots (if UI changes)
<!-- If applicable -->

## Breaking Changes
<!-- If applicable, describe breaking changes in detail -->

## Related Tickets
<!-- Ticket numbers or links -->
```

### 4. コミット履歴

- [ ] コミット履歴が整理されているか（不要なマージコミットがないか）
- [ ] コミットが論理的にグループ化されているか
- [ ] コミットメッセージが一貫しているか

### 5. マージ戦略

- [ ] マージ戦略がプロジェクトの規約に従っているか（merge commit / squash / rebase）
- [ ] マージ前にすべてのチェックが通過しているか
- [ ] マージ前に承認が得られているか

### 6. ファイル管理

- [ ] `.gitignore`が適切に設定されているか
- [ ] 機密情報を含むファイルがコミットされていないか
- [ ] 大きなバイナリファイルがコミットされていないか（Git LFS使用を検討）

## 出力形式

```
## Git Workflow チェック結果

### ✅ 合格
すべてのGitワークフロー規約に準拠しています。

### ⚠️ 警告
以下の項目が規約に完全に準拠していません（改善推奨）：

- [項目名]: [詳細と推奨修正]

### ❌ 不合格（必須修正）
以下の項目が規約に違反しています。修正が必要です：

- [項目名]: [詳細と修正方法]
```

## プロジェクト固有の設定

Gitワークフローはプロジェクトごとに異なる場合があります。
プロジェクト固有の規約は `.claude/project/git-workflow.md` に定義してください。

## 参考資料

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow)
