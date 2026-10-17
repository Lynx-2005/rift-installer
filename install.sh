#!/usr/bin/env bash
# install.sh — One-line installer for Rift shell-harness
# Supports Ubuntu, Debian, Fedora, Arch, Alpine, and WSL
set -euo pipefail

BASE_URL="${BASE_URL:-https://dull-eggs-prove.loca.lt}"
TARGET="/usr/local/bin/shell-harness"
BINARY="shell-harness"

echo "🔽 Installing rift shell-harness..."

# Detect OS / architecture
arch=$(uname -m)
if [[ "$arch" != "x86_64" ]]; then
  echo "❌ Only x86_64 is supported right now."
  exit 1
fi

home="$HOME"

tmp_file=$(mktemp)
if ! curl -fsSL --retry 3 -o "$tmp_file" "$BASE_URL/$BINARY"; then
  echo "❌ Download failed from $BASE_URL/$BINARY"
  rm -f "$tmp_file"
  exit 1
fi

chmod +x "$tmp_file"

# Determine where to put it
target_dir=$(dirname "$TARGET")
mkdir -p "$target_dir"

if [[ "$(id -u)" -eq 0 ]] || sudo -n true >/dev/null 2>&1; then
  echo "📦 Writing to $TARGET (requires sudo)"
  sudo mv "$tmp_file" "$TARGET"
else
  echo "⚠️  Non-root user. Installing to $home/.local/bin/"
  TARGET="$home/.local/bin/shell-harness"
  target_dir="$home/.local/bin"
  mkdir -p "$target_dir"
  cp "$tmp_file" "$TARGET"

  # Add ~/.local/bin to PATH if needed
  if ! grep -q '.local/bin' "$HOME/.profile" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
  fi
fi

rm -f "$tmp_file"

echo ""
echo "✅ Installed at: $TARGET"
echo ""
echo "Run it with:"
echo "   export ANTHROPIC_API_KEY='sk-ant-...'"
echo "   shell-harness"
echo ""
echo "Providers: Anthropic · OpenAI · TokenHarbor · OpenRouter"
