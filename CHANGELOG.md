# Changelog

## [2.0.0] - 2026-03-28

### Changed

- 共通資産の配布を **コピー方式から `~/.claude/` への git clone 一本**に変更した
- リポジトリ直下を `~/.claude/` の内容と同一にし、`global/` および `project-template/` を廃止した
- 更新用に `update.sh` を追加した
- `setup.sh` は clone と `.gitignore` 生成のみとした
- 任意のチームポリシー文書を `docs/policy/` に移した

## [1.0.0] - 2026-03-28

### Changed

- 初版の運用設計（`global/` + `setup.sh` コピー方式）を記録
