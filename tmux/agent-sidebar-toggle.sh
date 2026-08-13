#!/usr/bin/env bash
#
# Real open/close toggle for the tmux-agent-status sidebar.
#
# Upstream's sidebar-toggle.sh only ever opens or focuses the pane -- its own
# comment says so: "Sidebar visible in current window - focus it (don't kill)".
# No plugin option changes that, so wrap it: close the pane when it is already
# showing, otherwise hand off to upstream to create it.

set -u

PLUGIN_TOGGLE="${HOME}/.tmux/plugins/tmux-agent-status/scripts/sidebar-toggle.sh"
SIDEBAR_TITLE="agent-sidebar"

# Scoped to the current window, matching upstream. Tab-delimited because pane
# titles routinely contain spaces, which would break whitespace field splitting.
pane=$(tmux list-panes -F $'#{pane_id}\t#{pane_title}' 2>/dev/null |
	awk -F'\t' -v title="$SIDEBAR_TITLE" '$2 == title { print $1; exit }')

if [ -n "$pane" ]; then
	tmux kill-pane -t "$pane"
	exit 0
fi

if [ ! -x "$PLUGIN_TOGGLE" ]; then
	tmux display-message "agent-sidebar: $PLUGIN_TOGGLE not found"
	exit 1
fi

exec "$PLUGIN_TOGGLE" "$@"
