#!/bin/bash
# Cloudflare Pages build script for posai-flutter-dashboard.
#
# In Cloudflare Pages → Settings → Environment Variables, set ONE variable:
#   DART_DEFINES_JSON = {"SUPABASE_URL":"...","SUPABASE_PUBLISHABLE_KEY":"...","API_BASE_URL":"..."}
#
# To add a new dart-define param, just update the JSON value in Cloudflare dashboard.
# This script never needs to change.
#
# Cloudflare build command (set once, never touch again):
#   bash scripts/build.sh
#
# Local usage:
#   bash scripts/build.sh
#   (reads dart_defines.json directly if DART_DEFINES_JSON is not set)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DART_DEFINES_FILE="$PROJECT_ROOT/dart_defines.json"

cd "$PROJECT_ROOT"

# ---------------------------------------------------------------------------
# 1. Install Flutter (if not already available)
# ---------------------------------------------------------------------------
if ! command -v flutter &> /dev/null; then
  echo "📦 Flutter not found — installing stable..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
fi

export PATH="$PATH:$HOME/flutter/bin"
echo "✅ Flutter: $(flutter --version | head -1)"

# ---------------------------------------------------------------------------
# 2. Precache web artifacts & fetch dependencies
# ---------------------------------------------------------------------------
echo "⚙️  Precaching Flutter web..."
flutter precache --web

echo "📥 Fetching pub dependencies..."
flutter pub get

# ---------------------------------------------------------------------------
# 3. Resolve dart_defines.json
# ---------------------------------------------------------------------------
if [ -n "${DART_DEFINES_JSON:-}" ]; then
  echo "✅ Writing dart_defines.json from DART_DEFINES_JSON environment variable..."
  echo "$DART_DEFINES_JSON" > "$DART_DEFINES_FILE"
else
  if [ -f "$DART_DEFINES_FILE" ]; then
    echo "⚠️  DART_DEFINES_JSON not set — using existing dart_defines.json (local dev mode)"
  else
    echo "❌ Neither DART_DEFINES_JSON env var nor dart_defines.json found. Aborting."
    exit 1
  fi
fi

echo "📄 dart_defines.json:"
cat "$DART_DEFINES_FILE"
echo ""

# ---------------------------------------------------------------------------
# 4. Flutter web build
# ---------------------------------------------------------------------------
echo "🔨 Building Flutter web..."
flutter build web \
  --release \
  --base-href=/ \
  --dart-define-from-file="$DART_DEFINES_FILE"

echo "✅ Build complete → build/web"
