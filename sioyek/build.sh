#!/usr/bin/env bash
# Build sioyek's `development` branch on Ubuntu 24.04 (portable build) and
# set up PATH + a GNOME launcher. Idempotent: rerun it to update.
#
# Why not upstream's ./build_linux.sh as-is:
#   - Ubuntu's Qt 6.4.2 is too old for this branch -> use Qt 6.8.3 (aqtinstall).
#   - MuPDF's GLUT demo viewer needs GL/glu.h -> build MuPDF with HAVE_GLUT=no.
#   - the script doesn't find qmake6 -> set QMAKE explicitly.
# The bundled MuPDF submodule (1.26.x) is used on purpose; Ubuntu's is 1.23.
#
# Usage: ./build.sh            (clone/pull, build, link, launcher)
#        SIOYEK_DIR=... QT_VERSION=... ./build.sh
set -euo pipefail

SIOYEK_DIR="${SIOYEK_DIR:-$HOME/github/sioyek}"
QT_VERSION="${QT_VERSION:-6.8.3}"
QT_ROOT="${QT_ROOT:-$HOME/Qt}"
QMAKE="$QT_ROOT/$QT_VERSION/gcc_64/bin/qmake"

# 1. apt build dependencies (needs sudo; skipped if already installed)
APT_PKGS=(build-essential git python3-venv libharfbuzz-dev libgl-dev libxi-dev libxrandr-dev)
missing=()
for p in "${APT_PKGS[@]}"; do dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p"); done
if ((${#missing[@]})); then
  echo ">> installing apt packages: ${missing[*]}"
  sudo apt install -y "${missing[@]}"
fi

# 2. Qt (with the modules sioyek's .pro file needs)
if [[ ! -x "$QMAKE" ]]; then
  echo ">> installing Qt $QT_VERSION into $QT_ROOT"
  venv="$(mktemp -d)"
  python3 -m venv "$venv"
  "$venv/bin/pip" install -q aqtinstall
  "$venv/bin/aqt" install-qt linux desktop "$QT_VERSION" linux_gcc_64 \
    -O "$QT_ROOT" -m qtspeech qtmultimedia
  rm -rf "$venv"
fi

# 3. clone or update upstream (no fork)
if [[ -d "$SIOYEK_DIR/.git" ]]; then
  git -C "$SIOYEK_DIR" pull --recurse-submodules
else
  git clone --recursive --branch development https://github.com/ahrm/sioyek "$SIOYEK_DIR"
fi

# 4. build (HAVE_GLUT=no injected via sed so upstream's script stays unmodified)
cd "$SIOYEK_DIR"
QMAKE="$QMAKE" bash <(sed 's/USE_SYSTEM_HARFBUZZ=yes/USE_SYSTEM_HARFBUZZ=yes HAVE_GLUT=no/' build_linux.sh)

# 5. PATH: symlink into ~/.local/bin (already on PATH on Ubuntu)
mkdir -p "$HOME/.local/bin"
ln -sf "$SIOYEK_DIR/build/sioyek" "$HOME/.local/bin/sioyek"

# 6. GNOME launcher + icon. Wayland matches the window app ID (`sioyek`) to
#    sioyek.desktop; a portable build installs none, so write a user-level one
#    with absolute paths.
icons="$HOME/.local/share/icons/hicolor"
apps="$HOME/.local/share/applications"
mkdir -p "$icons/256x256/apps" "$apps"
cp resources/sioyek-icon-linux.png "$icons/256x256/apps/sioyek.png"
sed -e "s|^TryExec=.*|TryExec=$SIOYEK_DIR/build/sioyek|" \
    -e "s|^Exec=.*|Exec=$SIOYEK_DIR/build/sioyek %f|" \
    -e "s|^Icon=.*|Icon=sioyek|" \
    resources/sioyek.desktop > "$apps/sioyek.desktop"
update-desktop-database "$apps" 2>/dev/null || true
gtk-update-icon-cache -f -t "$icons" 2>/dev/null || true

echo ">> done: $(git log -1 --format='%h %ad' --date=short)  ->  sioyek (on PATH), launcher installed"
