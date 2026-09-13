#!/usr/bin/env bash
set -u

repo_dir="$1"
failed=0
ok() { printf '  [ok] %s\n' "$1"; }
fail() { printf '  [!!] %s\n' "$1"; failed=1; }

printf 'Syntax checks\n'
if bash -n "$repo_dir/install.sh" "$repo_dir/quickshell/run.sh" "$repo_dir/quickshell/scripts/paths.sh" "$repo_dir/quickshell/scripts/lock-and-suspend.sh" "$repo_dir/quickshell/scripts/clipboard-picker.sh" "$repo_dir/quickshell/scripts/screenshot.sh" "$repo_dir/quickshell/scripts/screen-record.sh"; then ok 'shell scripts'; else fail 'shell script syntax'; fi
if python3 -m py_compile "$repo_dir"/quickshell/scripts/*.py; then ok 'Python scripts'; else fail 'Python script syntax'; fi
if git -C "$repo_dir" diff --check; then ok 'Git whitespace'; else fail 'Git whitespace errors'; fi

exit "$failed"
