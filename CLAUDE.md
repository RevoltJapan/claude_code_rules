# Claude Code Entry Point（グローバル・全社共通）

このディレクトリは `~/.claude/` として clone されるテンプレートリポジトリ本体である。各プロジェクトの `.claude/CLAUDE.md` はリポジトリ固有の前提を書く。

## 読み順（優先順位）

1. `skills/security-check/SKILL.md`
2. `skills/quality-check/SKILL.md`
3. `agents/*`
4. `commands/*`
5. 各プロジェクトの `.claude/project/*`（プロジェクト作業時）

## プロジェクト側での作業

- 実装: `/impl .claude/project/tasks/NNNNN-<slug>.md`
- レビュー: `/review .claude/project/tasks/NNNNN-<slug>.md`
- 反復: `/run .claude/project/tasks/NNNNN-<slug>.md`

## 更新

- `bash ~/.claude/update.sh` で `git pull` により最新化する。
