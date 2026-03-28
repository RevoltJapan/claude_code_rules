#!/bin/bash
set -e

# ~/.claude/ にリポジトリを clone（すでに存在する場合はスキップ）
if [ ! -d "$HOME/.claude/.git" ]; then
  git clone git@github.com:revolt-inc/revolt-claude-template.git ~/.claude
fi

# Claude Code が書き込むファイルを git 追跡から除外
cat > ~/.claude/.gitignore << 'EOF'
# Claude Code が自動生成するファイル
settings.local.json
*.log
.cache/
EOF

echo "セットアップ完了。"
