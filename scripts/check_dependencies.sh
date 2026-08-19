#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# check_dependencies.sh
# ------------------------------------------------------------------------------
# Author:                            Rodolfo Aramayo
# Work_Email:                        raramayo@tamu.edu
# Personal_Email:                    rodolfo@aramayo.org
# ------------------------------------------------------------------------------
# Overview:
# Check the command-line tools and LaTeX packages required to compile the
# Manuscript Multi-Target Template. The script always writes a Markdown report
# that identifies missing dependencies and provides installation guidance.
# ------------------------------------------------------------------------------
# Copyright:
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.
# ------------------------------------------------------------------------------
# Version Number:
# Version: 1.0.0
# ------------------------------------------------------------------------------

# Project modification notes:
# The authoritative repository version is read from ../VERSION so all project
# entry points report the same release number.
# [2026/08/18 dependency reporting implemented with OpenAI Codex]
# This script writes a human-readable report on every run. Missing build tools,
# shared template packages, and packages declared by selected manuscript
# sources are listed with official installation resources.

set -uo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
cd "$project_dir"
version_file="VERSION"
template_version="unknown"
if [[ -f "$version_file" ]]; then
  template_version="$(tr -d '[:space:]' < "$version_file")"
fi

report_file="build/DEPENDENCY_REPORT.md"
quiet=false
source_files=()
log_files=()

usage() {
  cat <<'EOF'
Usage: ./scripts/check_dependencies.sh [OPTIONS]

Options:
  --source FILE    inspect a manuscript source for \usepackage declarations
  --log FILE       inspect a failed LaTeX log for a missing file diagnostic
  --report FILE    write the Markdown report to FILE
  --quiet          print output only when dependencies are missing
  -v | --version   print the repository version
  -h, --help       show this help

All file arguments are relative to the repository root. The default report
path is build/DEPENDENCY_REPORT.md.
EOF
}

path_is_absolute() {
  case "$1" in
    /*|[A-Za-z]:[\\/]*) return 0 ;;
    *) return 1 ;;
  esac
}

path_has_parent_reference() {
  case "/$1/" in
    */../*) return 0 ;;
    *) return 1 ;;
  esac
}

validate_repository_path() {
  option_name="$1"
  option_path="$2"
  if path_is_absolute "$option_path" || path_has_parent_reference "$option_path"; then
    printf '%s must remain relative to and inside the repository.\n' \
      "$option_name" >&2
    exit 2
  fi
}

while (($#)); do
  case "$1" in
    --source)
      if (($# < 2)); then
        printf 'Missing value for --source\n' >&2
        exit 2
      fi
      source_files+=("$2")
      shift 2
      ;;
    --log)
      if (($# < 2)); then
        printf 'Missing value for --log\n' >&2
        exit 2
      fi
      log_files+=("$2")
      shift 2
      ;;
    --report)
      if (($# < 2)); then
        printf 'Missing value for --report\n' >&2
        exit 2
      fi
      report_file="$2"
      shift 2
      ;;
    --quiet)
      quiet=true
      shift
      ;;
    -v|--version)
      printf 'Manuscript Multi-Target Template %s\n' "$template_version"
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ((${#source_files[@]})); then
  for source_file in "${source_files[@]}"; do
    validate_repository_path '--source' "$source_file"
  done
fi
if ((${#log_files[@]})); then
  for log_file in "${log_files[@]}"; do
    validate_repository_path '--log' "$log_file"
  done
fi
validate_repository_path '--report' "$report_file"

required_tools=(latexmk pdflatex bibtex kpsewhich)
required_tex_files=(
  amsmath.sty
  amsfonts.sty
  amssymb.sty
  mathptmx.sty
  xcolor.sty
  authblk.sty
  inputenc.sty
  babel.sty
  lmodern.sty
  siunitx.sty
  textgreek.sty
  gensymb.sty
  textcomp.sty
  mhchem.sty
  helvet.sty
  fontenc.sty
  lettrine.sty
  sidecap.sty
  ifsym.sty
  bbding.sty
  geometry.sty
  caption.sty
  hyperref.sty
  nameref.sty
  cleveref.sty
  times.sty
  titlesec.sty
  verbatim.sty
  chapterbib.sty
  natbib.sty
  graphicx.sty
  color.sty
  fancyhdr.sty
  lastpage.sty
)

append_unique_tex_file() {
  candidate_file="$1"
  [[ -n "$candidate_file" ]] || return 0
  for existing_file in "${required_tex_files[@]}"; do
    if [[ "$existing_file" == "$candidate_file" ]]; then
      return 0
    fi
  done
  required_tex_files+=("$candidate_file")
}

# Include packages declared directly by the selected manuscript. Missing
# packages in included sources are also detected from a failed LaTeX log.
if ((${#source_files[@]})); then
  for source_file in "${source_files[@]}"; do
    [[ -f "$source_file" ]] || continue
    while IFS= read -r package_group; do
      package_group="${package_group//[[:space:]]/}"
      previous_ifs="$IFS"
      IFS=','
      package_names=($package_group)
      IFS="$previous_ifs"
      for package_name in "${package_names[@]}"; do
        if [[ "$package_name" == *.sty ]]; then
          append_unique_tex_file "$package_name"
        else
          append_unique_tex_file "$package_name.sty"
        fi
      done
    done < <(sed -nE 's/^[[:space:]]*\\(usepackage|RequirePackage)(\[[^]]*\])?[[:space:]]*\{([^}]*)\}.*/\3/p' "$source_file")
  done
fi

if ((${#log_files[@]})); then
  for log_file in "${log_files[@]}"; do
    [[ -f "$log_file" ]] || continue
    while IFS= read -r log_line; do
      case "$log_line" in
        *"LaTeX Error: File "*" not found."*)
          missing_token="${log_line#*LaTeX Error: File }"
          missing_token="${missing_token%% *}"
          if ((${#missing_token} >= 3)); then
            missing_token="${missing_token:1:${#missing_token}-2}"
            append_unique_tex_file "$missing_token"
          fi
          ;;
      esac
    done < "$log_file"
  done
fi

missing_tools=()
for required_tool in "${required_tools[@]}"; do
  if ! command -v "$required_tool" >/dev/null 2>&1; then
    missing_tools+=("$required_tool")
  fi
done

package_lookup_available=true
if ! command -v kpsewhich >/dev/null 2>&1; then
  package_lookup_available=false
fi

missing_tex_files=()
if [[ "$package_lookup_available" == true ]]; then
  for required_tex_file in "${required_tex_files[@]}"; do
    if ! kpsewhich "$required_tex_file" >/dev/null 2>&1; then
      missing_tex_files+=("$required_tex_file")
    fi
  done
fi

report_dir="$(dirname "$report_file")"
if ! mkdir -p "$report_dir"; then
  printf 'Could not create dependency report directory: %s\n' "$report_dir" >&2
  exit 4
fi

generated_at="$(date -u '+%Y-%m-%d %H:%M:%SZ')"
if ((${#missing_tools[@]} == 0 && ${#missing_tex_files[@]} == 0)); then
  dependency_status="Ready"
else
  dependency_status="Action required"
fi

{
  printf '# Dependency report\n\n'
  printf -- '- Template version: `%s`\n' "$template_version"
  printf -- '- Generated: `%s`\n' "$generated_at"
  printf -- '- Status: **%s**\n\n' "$dependency_status"

  if ((${#source_files[@]})); then
    printf '## Manuscript sources inspected\n\n'
    for source_file in "${source_files[@]}"; do
      printf -- '- `%s`\n' "$source_file"
    done
    printf '\n'
  fi

  printf '## Missing command-line tools\n\n'
  if ((${#missing_tools[@]})); then
    for missing_tool in "${missing_tools[@]}"; do
      printf -- '- `%s`\n' "$missing_tool"
    done
  else
    printf 'None.\n'
  fi
  printf '\n'

  printf '## Missing LaTeX files\n\n'
  if [[ "$package_lookup_available" != true ]]; then
    printf 'Package lookup was skipped because `kpsewhich` is unavailable.\n'
  elif ((${#missing_tex_files[@]})); then
    for missing_tex_file in "${missing_tex_files[@]}"; do
      printf -- '- `%s`\n' "$missing_tex_file"
    done
  else
    printf 'None.\n'
  fi
  printf '\n'

  printf '## Installation guidance\n\n'
  printf 'The recommended solution is a complete TeX Live-compatible distribution.\n\n'
  printf -- '- macOS: install full MacTeX from <https://tug.org/mactex/mactex-download.html>.\n'
  printf -- '- Linux, Unix, and other supported systems: follow the TeX Live quick install guide at <https://tug.org/texlive/quickinstall.html>.\n'
  printf -- '- Windows: use the TeX Live Windows installer described at <https://tug.org/texlive/windows.html>.\n\n'
  printf 'If TeX Live is already installed and only individual files are missing, use the TeX Live Manager documentation at <https://tug.org/texlive/tlmgr.html>. The file name and TeX Live package name can differ, so identify the providing package before installing it.\n\n'
  printf 'After installing or updating TeX, open a new terminal and run:\n\n'
  printf '```sh\n'
  printf './scripts/check_dependencies.sh\n'
  printf './build.sh --target neutral\n'
  printf '```\n\n'
  printf 'Do not download individual `.sty` files from unverified websites. If a missing path starts with `_Templates/`, restore that file from this repository instead of searching a package manager.\n'
} > "$report_file"

if [[ "$dependency_status" == "Action required" ]]; then
  printf 'Missing manuscript build dependencies.\n' >&2
  printf 'Installation instructions were written to: %s\n' "$report_file" >&2
  exit 127
fi

if [[ "$quiet" != true ]]; then
  printf 'Dependency check passed. Report: %s\n' "$report_file"
fi
