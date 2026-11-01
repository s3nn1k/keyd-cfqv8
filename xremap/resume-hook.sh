#!/usr/bin/env bash
set -euo pipefail

[[ "${1:-}" == post ]] || exit 0

runuser -u __USER__ -- systemctl --user restart xremap.service
