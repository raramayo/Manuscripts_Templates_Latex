# Dependency report

- Template version: `1.0.0`
- Generated: `2026-08-19 20:14:43Z`
- Status: **Ready**

## Manuscript sources inspected

- `input/Manuscript.tex`

## Missing command-line tools

None.

## Missing LaTeX files

None.

## Installation guidance

The recommended solution is a complete TeX Live-compatible distribution.

- macOS: install full MacTeX from <https://tug.org/mactex/mactex-download.html>.
- Linux, Unix, and other supported systems: follow the TeX Live quick install guide at <https://tug.org/texlive/quickinstall.html>.
- Windows: use the TeX Live Windows installer described at <https://tug.org/texlive/windows.html>.

If TeX Live is already installed and only individual files are missing, use the TeX Live Manager documentation at <https://tug.org/texlive/tlmgr.html>. The file name and TeX Live package name can differ, so identify the providing package before installing it.

After installing or updating TeX, open a new terminal and run:

```sh
./scripts/check_dependencies.sh
./build.sh --target neutral
```

Do not download individual `.sty` files from unverified websites. If a missing path starts with `_Templates/`, restore that file from this repository instead of searching a package manager.
