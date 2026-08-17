#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build-openrec.sh  —  Build OpenRec as a plain .app on Apple Silicon
# Naga Codex · https://github.com/Nagacash/openrec
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

step()  { echo -e "\n${BOLD}▸ $1${NC}"; }
ok()    { echo -e "  ${GREEN}✓ $1${NC}"; }
warn()  { echo -e "  ${YELLOW}⚠ $1${NC}"; }
abort() { echo -e "\n${RED}✗ $1${NC}\n"; exit 1; }

echo -e "\n${BOLD}╔══════════════════════════════════════╗"
echo -e "║   OpenRec build — Apple Silicon     ║"
echo -e "╚══════════════════════════════════════╝${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# 1. PREREQUISITE CHECKS
# ─────────────────────────────────────────────────────────────────────────────
step "Checking prerequisites"

# macOS version
MACOS_MAJOR=$(sw_vers -productVersion | cut -d. -f1)
if [[ "$MACOS_MAJOR" -lt 13 ]]; then
  abort "macOS 13 (Ventura) or later required. You have $(sw_vers -productVersion)."
fi
ok "macOS $(sw_vers -productVersion)"

# Xcode CLI tools
if ! xcode-select -p &>/dev/null; then
  abort "Xcode Command Line Tools not found. Run: xcode-select --install"
fi
ok "Xcode CLI tools: $(xcode-select -p)"

# Node version
REQUIRED_NODE="22.22.1"
if ! command -v node &>/dev/null; then
  abort "Node.js not found. Install via nvm: https://github.com/nvm-sh/nvm\n  nvm install 22.22.1 && nvm use 22.22.1"
fi
NODE_VER=$(node -v | tr -d 'v')
if [[ "$NODE_VER" != "$REQUIRED_NODE" ]]; then
  warn "Node $NODE_VER found — project requires $REQUIRED_NODE exactly."
  warn "If the build fails, run: nvm install $REQUIRED_NODE && nvm use $REQUIRED_NODE"
else
  ok "Node $NODE_VER"
fi

# npm version
REQUIRED_NPM="10.9.4"
NPM_VER=$(npm -v)
if [[ "$NPM_VER" != "$REQUIRED_NPM" ]]; then
  warn "npm $NPM_VER found — project requires $REQUIRED_NPM. Run: npm install -g npm@$REQUIRED_NPM"
else
  ok "npm $NPM_VER"
fi

# Rust
if ! command -v cargo &>/dev/null; then
  abort "Rust not found. Install via: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
fi
ok "Rust $(rustc --version)"

# aarch64-apple-darwin target
if ! rustup target list --installed | grep -q "aarch64-apple-darwin"; then
  step "Adding Rust target aarch64-apple-darwin"
  rustup target add aarch64-apple-darwin
fi
ok "Rust target aarch64-apple-darwin"

# LLVM (needed by bindgen for Rust compositor)
if ! command -v clang &>/dev/null; then
  abort "clang not found. Install LLVM via Homebrew: brew install llvm\n  Then add to PATH: export PATH=\"/opt/homebrew/opt/llvm/bin:\$PATH\""
fi
ok "clang $(clang --version | head -1)"

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# 2. INSTALL JS DEPENDENCIES
# ─────────────────────────────────────────────────────────────────────────────
step "Installing npm dependencies (npm ci)"
npm ci
ok "Dependencies installed"

# ─────────────────────────────────────────────────────────────────────────────
# 3. BUILD SCREENCAPTUREKIT HELPER  (Swift/Obj-C native capture binary)
# ─────────────────────────────────────────────────────────────────────────────
step "Building ScreenCaptureKit helper (Swift)"
npm run build:native:mac
ok "ScreenCaptureKit helper built"

# ─────────────────────────────────────────────────────────────────────────────
# 4. BUILD RUST COMPOSITOR  (wgpu/Metal N-API addon)
# ─────────────────────────────────────────────────────────────────────────────
step "Building Rust compositor addon (this takes ~10–15 min on first run)"
npm run build:native:compositor:mac
ok "Rust compositor built"

# ─────────────────────────────────────────────────────────────────────────────
# 5. FETCH FFMPEG BINARIES
# ─────────────────────────────────────────────────────────────────────────────
step "Fetching vendored FFmpeg binaries (macOS)"
npm run fetch:ffmpeg:mac
ok "FFmpeg ready"

# ─────────────────────────────────────────────────────────────────────────────
# 6. BUILD WHISPER-STT-SERVER  (captions / transcription)
# ─────────────────────────────────────────────────────────────────────────────
step "Building whisper-stt-server for captions"
npm run build:whisper-binaries
ok "whisper-stt-server built"

# ─────────────────────────────────────────────────────────────────────────────
# 7. COMPILE TYPESCRIPT + VITE
# ─────────────────────────────────────────────────────────────────────────────
step "Compiling TypeScript and bundling frontend (Vite)"
npx tsc
npx vite build
ok "Frontend compiled"

# ─────────────────────────────────────────────────────────────────────────────
# 8. PACKAGE AS .APP  (no DMG, no installer)
# ─────────────────────────────────────────────────────────────────────────────
step "Packaging as .app bundle"
npx electron-builder --mac --dir --arch arm64
ok "App bundle ready"

# ─────────────────────────────────────────────────────────────────────────────
# DONE
# ─────────────────────────────────────────────────────────────────────────────
APP_PATH="$(pwd)/dist/mac-arm64/openscreen.app"
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗"
echo -e "║  Build complete!                                 ║"
echo -e "╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}App location:${NC}"
echo -e "  $APP_PATH"
echo ""
echo -e "  To install, run:"
echo -e "  ${BOLD}cp -r \"$APP_PATH\" /Applications/${NC}"
echo ""
echo -e "  Or drag the .app from the dist/mac-arm64/ folder into Applications."
echo ""
