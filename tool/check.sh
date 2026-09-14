#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
npm --prefix functions run lint
npm --prefix functions run build
python3 -m json.tool firebase.json >/dev/null
python3 -m json.tool firestore.indexes.json >/dev/null
git diff --check
