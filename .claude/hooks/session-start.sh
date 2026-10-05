#!/bin/bash
# Sets up Flutter + Linux desktop tooling in Claude Code cloud sessions so that
# `flutter analyze`, `flutter test` and `flutter build linux` work.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

FLUTTER_VERSION="3.44.8"
FLUTTER_DIR="/opt/flutter"
SQLITE_TARBALL="/opt/sqlite-src/sqlite-amalgamation.tar.gz"

# 1. Flutter SDK (same version used locally).
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  curl -sSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ -C /opt
fi
git config --global --add safe.directory "$FLUTTER_DIR" || true
export PATH="$FLUTTER_DIR/bin:$PATH"
flutter --disable-analytics >/dev/null 2>&1 || true
echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\"" >> "${CLAUDE_ENV_FILE:-/dev/null}"

# 2. Linux desktop build deps + virtual display for screenshots.
if ! command -v ninja >/dev/null || ! command -v Xvfb >/dev/null || ! command -v xdg-user-dir >/dev/null; then
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev \
    libsqlite3-dev xvfb x11-utils imagemagick xdg-user-dirs >/dev/null
fi

# 3. Documents dir (path_provider needs it; the app stores its DB there).
mkdir -p "$HOME/Documents"
xdg-user-dirs-update >/dev/null 2>&1 || true

# 4. Dart/Flutter packages.
cd "$CLAUDE_PROJECT_DIR"
flutter pub get >/dev/null

# 5. sqlite.org is blocked by the network policy, so sqlite3_flutter_libs
#    cannot download its source during `flutter build linux`. Use the same
#    amalgamation shipped in the better-sqlite3 npm package instead.
if [ ! -f "$SQLITE_TARBALL" ]; then
  tmp=$(mktemp -d)
  (cd "$tmp" && npm pack better-sqlite3 >/dev/null 2>&1 && tar xzf better-sqlite3-*.tgz)
  mkdir -p /opt/sqlite-src/sqlite-amalgamation
  cp "$tmp"/package/deps/sqlite3/sqlite3.{c,h} "$tmp"/package/deps/sqlite3/sqlite3ext.h /opt/sqlite-src/sqlite-amalgamation/
  tar czf "$SQLITE_TARBALL" -C /opt/sqlite-src sqlite-amalgamation
  rm -rf "$tmp"
fi
for f in "$HOME"/.pub-cache/hosted/pub.dev/sqlite3_flutter_libs-*/linux/CMakeLists.txt; do
  [ -f "$f" ] && sed -i -E "s#URL https://(www\.)?sqlite\.org/[^ )]*#URL file://$SQLITE_TARBALL#" "$f"
done
