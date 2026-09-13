#!/usr/bin/env bash
set -u

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
failed=0

run_check() {
    if "$@"; then :; else failed=1; fi
}

run_check "$repo_dir/checks/commands.sh" "$repo_dir"
printf '\n'
run_check "$repo_dir/checks/config.sh"
printf '\n'
run_check "$repo_dir/checks/syntax.sh" "$repo_dir"
printf '\n'
run_check "$repo_dir/checks/session.sh"

if [ "$failed" -eq 0 ]; then
    echo 'All checks passed.'
else
    echo 'Some checks failed.'
fi
exit "$failed"
