---
description: タスクファイルを起点にレビューを実行する（quality-check を必ず通す）
---

# Review Command

レビュー対象タスク: $ARGUMENTS

## 実行プロセス

1. 指定されたタスクファイルを読み込む
2. `~/.claude/skills/quality-check/SKILL.md` に沿って品質チェックを実施する
3. 必要に応じて `~/.claude/skills/security-check/SKILL.md` を参照する
4. 指摘事項があれば、修正方針と優先度を列挙する
5. 受入条件（チェックリスト）との照合結果を明示する

## レビュールール

- タスクに記載された影響範囲を漏れなく確認する
- 推測で LGTM にしない。根拠（ファイル・行・テスト結果）を添える
- 破壊的変更やセキュリティ影響は必ず明示する
