#!/bin/bash

# -----------------------------------------------------------------------------
# 名前: launch-raycast-aerospace-alt-tab-extension.sh
# 概要: AeroSpaceのワークスペース履歴を読み込み、指定インデックス(mod計算付き)の
#       ワークスペースを選択状態でRaycast拡張機能を起動します。
#       エラー時はmacOSの通知センターに表示します(無音)。
# -----------------------------------------------------------------------------

# 引数: selected-index (数値)
SELECTED_INDEX=$1

# ワークスペース履歴ファイルのパス
HISTORY_FILE="/tmp/aerospace_workspace_history"

# エラー通知関数
# メッセージを受け取り、通知を表示してスクリプトを終了します
notify_error() {
    local message="$1"
    # コンソールにも出力
    echo "Error: $message" >&2
    # macOS通知 (タイトル: AeroSpace Switcher, 音なし)
    osascript -e "display notification \"$message\" with title \"AeroSpace Switcher\""
    exit 1
}

# --- 引数チェック ---
if [ -z "$SELECTED_INDEX" ]; then
    notify_error "引数 'selected-index' が指定されていません。"
fi

# --- ファイル存在チェック ---
if [ ! -f "$HISTORY_FILE" ]; then
    notify_error "履歴ファイルが見つかりません: $HISTORY_FILE"
fi

# --- JSON構築とエンコード (jq) ---
# jqコマンドが失敗した場合(終了コードが0以外)は通知を出します
ENCODED_CONTEXT=$(/usr/bin/jq -R -s -r --argjson idx "$SELECTED_INDEX" '
  split("\n") | map(select(length > 0)) as $ws_list |
  ($ws_list | length) as $len |
  {
    "workspaces": $ws_list,
    "selected-workspace": (if $len > 0 then $ws_list[$idx % $len] else "" end)
  } | tostring | @uri
' "$HISTORY_FILE")

if [ $? -ne 0 ]; then
    notify_error "JSONデータの生成に失敗しました (jq error)。"
fi

# --- URLの生成と実行 ---
BASE_URL="raycast://extensions/gaishi/aerospace-workspace-switcher/switch-workspace-recent"
FULL_URL="${BASE_URL}?launchContext=${ENCODED_CONTEXT}"

# openコマンドの実行結果もチェック
if ! open "$FULL_URL"; then
    notify_error "Raycastの起動に失敗しました。"
fi
