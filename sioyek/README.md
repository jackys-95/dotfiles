# sioyek

`./build.sh` builds upstream sioyek's `development` branch on Ubuntu 24.04 into
`~/github/sioyek` (cloned from upstream, not a fork), puts `sioyek` on `PATH`
(`~/.local/bin`) and installs a user-level GNOME launcher + icon. Rerun it to
update. The released sioyek (2.0.0, Dec 2022) is old.

The script header explains why upstream's `build_linux.sh` can't be used as-is
(Ubuntu's Qt 6.4 is too old, MuPDF's GLUT viewer needs `glu.h`, `qmake6` isn't
found). It uses Qt 6.8.3 from `aqtinstall` in `~/Qt`; the binary links against
it, so don't delete it.

Notes:

- `sioyek --version` prints `2.0.0` even on `development`; check
  `git -C ~/github/sioyek log -1` instead.
- First built from commit `1e2f8037` (2026-11-04) on Ubuntu 24.04.5.
- Tested interactively on GNOME/Wayland. The script as a whole has not been
  run from a clean machine, and the apt list is a best guess at the minimum.
- Not tried: the non-portable `make install` build against Ubuntu's MuPDF
  1.23 (probably incompatible with this branch's MuPDF 1.26 API).
