#!/bin/bash
set -euo pipefail
cd "$REPL_HOME/ai_taro_oppa"
flutter build web --release
