#!/bin/bash
#set -x

# 引数チェック
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <workspace_directory>"
  exit 1
fi

WORKSPACE_DIR=$1

# LANG 環境変数の言語指定部分を取得 (デフォルトは "ja_JP")
default_lang=$(echo "$LANG" | sed -E 's/\..*//' | grep -E '^[a-zA-Z]+(-[a-zA-Z]+)?$' || echo "ja_JP")

# ワークスペースの .vscode/settings.json のパス
VSCODE_SETTINGS="$WORKSPACE_DIR/.vscode/settings.json"

# グローバル settings.json のパス
GLOBAL_SETTINGS="$HOME/.config/Code/User/settings.json"

# ファイルが存在し files.encoding 項目が存在するかチェックする関数
get_files_encoding() {
  local settings_file=$1
  if [ -f "$settings_file" ]; then
    encoding=$(jq -r '."files.encoding"' "$settings_file" 2>/dev/null)
    if [ "$encoding" != "" ]; then
      echo "$default_lang.$encoding"
      return 0
    fi
  fi
  return 1
}

# 優先順位に従って files.encoding の値を取得
if get_files_encoding "$VSCODE_SETTINGS"; then
  exit 0
elif get_files_encoding "$GLOBAL_SETTINGS"; then
  exit 0
else
  echo "$default_lang.utf8"
fi
