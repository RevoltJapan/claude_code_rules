# Skills

このディレクトリは `~/.claude/skills/` にコピーではなく **リポジトリ全体が `~/.claude/` として clone される**ため、`~/.claude/skills/` と同一の内容になる。

## v1 で最低限用意するスキル

| ディレクトリ | 目的 |
| --- | --- |
| `quality-check` | 未使用コード・到達不能分岐・後方互換の残骸の排除、受入条件の充足、テスト・静的解析 |
| `security-check` | 機密・秘密情報の混入防止、危険な実装パターンの検出 |
| `doc-sync` | README / 設計 / テストなどドキュメントの実装同期 |

## その他のスキル

- `code-review` — レビュー時の包括チェック
- `git-workflow` — コミット・ブランチ・PR の型
- `changelog-generator` — CHANGELOG 整備
- `dependency-audit` — 依存関係の監査
- `api-compatibility` — API 互換性
- `test-runner` / `test-fixing` — テスト実行と修正支援

## 構造

各スキルは `skill-name/SKILL.md` を持つ。

## 変更手順

1. 本リポジトリで編集し PR をマージする
2. 各開発者に `bash ~/.claude/update.sh` を周知する
