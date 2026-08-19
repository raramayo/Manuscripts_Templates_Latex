#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# build.sh
# ------------------------------------------------------------------------------
# Author:                            Rodolfo Aramayo
# Work_Email:                        raramayo@tamu.edu
# Personal_Email:                    rodolfo@aramayo.org
# ------------------------------------------------------------------------------
# Overview:
# Build an arXiv, bioRxiv, Zenodo, or neutral manuscript PDF from either the
# repository's default input/ workspace or a repository-relative manuscript
# bundle.
# The script validates inputs and dependencies, isolates intermediate files,
# and writes the finished PDF under output/pdf/.
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
# The authoritative Manuscript Multi-Target Template version is read from
# VERSION so the command-line output and other project components stay aligned.
# Added during the 2026/08/18 multi-target consolidation and extended on
# 2026/08/18 so real manuscripts do not need to be renamed or copied into
# input/ before compilation. Dependency reporting was added for version 1.0.0.

set -euo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$project_dir"
version_file="VERSION"
if [[ ! -f "$version_file" ]]; then
  printf 'Repository version file not found: %s\n' "$version_file" >&2
  exit 4
fi
template_version="$(tr -d '[:space:]' < "$version_file")"

path_is_absolute() {
  case "$1" in
    /*|[A-Za-z]:[\\/]*) return 0 ;;
    *) return 1 ;;
  esac
}

usage() {
  cat <<'EOF'
Usage:
  ./build.sh [TARGET] [INPUT_DIR] [MAIN_TEX]
  ./build.sh --target TARGET --input-dir INPUT_DIR [--main MAIN_TEX]

Options:
  -t, --target TARGET     arxiv, biorxiv, zenodo, or neutral (default: neutral)
  -i, --input-dir DIR    repository-relative bundle directory (default: input)
  -m, --main FILE        main .tex file inside and relative to INPUT_DIR
      --check-dependencies
                         write the dependency report without compiling
  -v | --version         show the repository version
  -h, --help             show this help
      --                 treat remaining values as positional arguments

If --main is omitted, the script uses Manuscript.tex when present. Otherwise,
it automatically selects the only top-level .tex file in INPUT_DIR. If more
than one candidate exists, use --main explicitly.

Examples:
  ./build.sh arxiv
  ./build.sh --target biorxiv --input-dir test-manuscript
  ./build.sh --target neutral --input-dir drafts/paper --main article.tex
EOF
}

target="neutral"
input_arg="input"
main_arg=""
dependencies_only=false
explicit_options=false
positionals=()

while (($#)); do
  case "$1" in
    -t|--target)
      if (($# < 2)); then
        printf 'Missing value for %s\n' "$1" >&2
        usage >&2
        exit 2
      fi
      target="$2"
      explicit_options=true
      shift 2
      ;;
    -i|--input-dir)
      if (($# < 2)); then
        printf 'Missing value for %s\n' "$1" >&2
        usage >&2
        exit 2
      fi
      input_arg="$2"
      explicit_options=true
      shift 2
      ;;
    -m|--main)
      if (($# < 2)); then
        printf 'Missing value for %s\n' "$1" >&2
        usage >&2
        exit 2
      fi
      main_arg="$2"
      explicit_options=true
      shift 2
      ;;
    --check-dependencies)
      dependencies_only=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -v|--version)
      printf 'Manuscript Multi-Target Template %s\n' "$template_version"
      exit 0
      ;;
    --)
      shift
      while (($#)); do
        positionals+=("$1")
        shift
      done
      ;;
    -*)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      positionals+=("$1")
      shift
      ;;
  esac
done

if ((${#positionals[@]})); then
  if [[ "$explicit_options" == true ]]; then
    printf 'Do not mix positional arguments with --target, --input-dir, or --main.\n' >&2
    usage >&2
    exit 2
  fi
  if ((${#positionals[@]} > 3)); then
    printf 'Too many positional arguments.\n' >&2
    usage >&2
    exit 2
  fi
  target="${positionals[0]}"
  if ((${#positionals[@]} >= 2)); then
    input_arg="${positionals[1]}"
  fi
  if ((${#positionals[@]} == 3)); then
    main_arg="${positionals[2]}"
  fi
fi

case "$target" in
  arxiv|biorxiv|zenodo|neutral)
    ;;
  *)
    printf 'Unsupported target: %s\n' "$target" >&2
    printf 'Choose one of: arxiv, biorxiv, zenodo, neutral\n' >&2
    exit 2
    ;;
esac

if path_is_absolute "$input_arg"; then
  printf 'The input directory must be relative to the repository root.\n' >&2
  exit 2
fi
requested_input_dir="$input_arg"

if [[ ! -d "$requested_input_dir" ]]; then
  printf 'Manuscript input directory not found: %s\n' "$requested_input_dir" >&2
  exit 3
fi

input_dir="$(cd "$requested_input_dir" && pwd)"
case "$input_dir" in
  "$project_dir")
    input_repo_dir="."
    ;;
  "$project_dir"/*)
    input_repo_dir="${input_dir#"$project_dir"/}"
    ;;
  *)
    printf 'The input directory must resolve inside the repository: %s\n' \
      "$input_arg" >&2
    exit 2
    ;;
esac
if [[ "$input_repo_dir" == "." ]]; then
  input_display_prefix=""
else
  input_display_prefix="$input_repo_dir/"
fi

# Flexible input selection - START (2026/08/18)
# Prefer the documented canonical filename, but permit a real manuscript to
# retain its own name when it is the only top-level TeX source in the bundle.
if [[ -n "$main_arg" ]]; then
  if path_is_absolute "$main_arg"; then
    printf 'The --main value must be relative to the manuscript input directory.\n' >&2
    exit 2
  fi
  main_file="$input_dir/$main_arg"
elif [[ -f "$input_dir/Manuscript.tex" ]]; then
  main_file="$input_dir/Manuscript.tex"
else
  tex_candidates=()
  while IFS= read -r candidate; do
    tex_candidates+=("$candidate")
  done < <(find "$input_dir" -maxdepth 1 -type f -name '*.tex' -print | LC_ALL=C sort)

  if ((${#tex_candidates[@]} == 0)); then
    printf 'No top-level .tex manuscript found in: %s\n' "$input_repo_dir" >&2
    printf 'Add Manuscript.tex or select a relative file with --main.\n' >&2
    exit 3
  fi
  if ((${#tex_candidates[@]} > 1)); then
    printf 'Multiple top-level .tex files found in %s:\n' "$input_repo_dir" >&2
    printf '  %s\n' "${tex_candidates[@]##*/}" >&2
    printf 'Select the entry point with --main FILE.\n' >&2
    exit 3
  fi

  main_file="${tex_candidates[0]}"
fi

if [[ ! -f "$main_file" ]]; then
  printf 'Main manuscript file not found: %s%s\n' \
    "$input_display_prefix" "${main_arg:-Manuscript.tex}" >&2
  exit 3
fi

# Normalize harmless ./ and ../ segments, then keep the selected entry point
# inside the declared bundle so its figures and bibliography share one clear
# search root.
main_file="$(cd "$(dirname "$main_file")" && pwd)/${main_file##*/}"
case "$main_file" in
  "$input_dir"/*)
    main_relative="${main_file#"$input_dir"/}"
    ;;
  *)
    printf 'Main manuscript must be inside the input directory: %s\n' \
      "$input_repo_dir" >&2
    exit 3
    ;;
esac

if [[ "$input_repo_dir" == "." ]]; then
  main_repo_path="$main_relative"
else
  main_repo_path="$input_repo_dir/$main_relative"
fi

bib_files=()
while IFS= read -r bibliography; do
  bib_files+=("$bibliography")
done < <(find "$input_dir" -maxdepth 1 -type f -name '*.bib' -print | LC_ALL=C sort)

if ((${#bib_files[@]} == 0)); then
  printf 'No top-level .bib reference database found in: %s\n' \
    "$input_repo_dir" >&2
  exit 3
fi

if [[ ! -d "$input_dir/Figures" ]]; then
  printf 'Required figure directory not found: %sFigures\n' \
    "$input_display_prefix" >&2
  exit 3
fi
# Flexible input selection - END

# Dependency reporting - START (version 1.0.0, 2026/08/18)
# Check the shared class requirements and packages declared by the selected
# manuscript before LaTeX runs. The report lives under ignored build/ so it is
# available to the user without becoming repository content.
dependency_checker="scripts/check_dependencies.sh"
dependency_report="build/DEPENDENCY_REPORT.md"
if [[ ! -f "$dependency_checker" ]]; then
  printf 'Dependency checker not found: %s\n' "$dependency_checker" >&2
  exit 4
fi
if ! "$BASH" "$dependency_checker" \
  --quiet \
  --report "$dependency_report" \
  --source "$main_repo_path"; then
  exit 127
fi
if [[ "$dependencies_only" == true ]]; then
  printf 'Template version: %s\n' "$template_version"
  printf 'Dependency check passed. Report: %s\n' "$dependency_report"
  exit 0
fi
# Dependency reporting - END

main_name="${main_file##*/}"
main_stem="${main_name%.tex}"
# Keep generated filenames portable even when a source filename contains
# spaces or punctuation that would be unsafe in a TeX job name.
job_base="${main_stem//[^A-Za-z0-9._-]/_}"
build_dir="build/$target"
pdf_dir="output/pdf"
job_name="$job_base-$target"
driver_file="$build_dir/$job_name-driver.tex"
texmf_var="$build_dir/texmf-var"

mkdir -p "$build_dir" "$pdf_dir" "$texmf_var"

# latexmk 4.88 rejects a raw TeX expression as an input filename. Generate a
# tiny disposable driver instead; it selects the target before loading the one
# authoritative manuscript source.
printf '%% Generated by build.sh version %s from %s\n\\def\\ManuscriptTarget{%s}\\input{%s}\n' \
  "$template_version" "$input_repo_dir" "$target" "$main_relative" > "$driver_file"

# The explicit search paths allow BibTeX and LaTeX to find shared inputs even
# though auxiliary files are isolated under build/<target>/. The selected
# bundle comes first, so source-relative paths such as Figures/plot.png and
# \bibliography{Paper_References} work without edits.
export TEXINPUTS="$input_repo_dir//:.:_Templates//:${TEXINPUTS:-}"
export BIBINPUTS="$input_repo_dir//:.:${BIBINPUTS:-}"
export BSTINPUTS=".:_Templates:${BSTINPUTS:-}"
# Keep generated TeX fonts and cache data inside this disposable target build.
# TeX's font generator requires this environment value to be fully resolved;
# compute it at runtime without storing or printing a machine-specific path.
export TEXMFVAR="$project_dir/$texmf_var"

set +e
latexmk \
  -pdf \
  -interaction=nonstopmode \
  -halt-on-error \
  -file-line-error \
  -outdir="$build_dir" \
  -jobname="$job_name" \
  "$driver_file"
latexmk_status=$?
set -e

if [[ "$latexmk_status" -ne 0 ]]; then
  # A package used only by an included source may not be visible during the
  # initial preflight. Refresh the report from LaTeX's missing-file diagnostic.
  set +e
  "$BASH" "$dependency_checker" \
    --quiet \
    --report "$dependency_report" \
    --source "$main_repo_path" \
    --log "$build_dir/$job_name.log"
  dependency_status=$?
  set -e
  printf 'LaTeX build failed. Dependency report: %s\n' "$dependency_report" >&2
  if [[ "$dependency_status" -ne 0 ]]; then
    exit 127
  fi
  exit "$latexmk_status"
fi

cp "$build_dir/$job_name.pdf" "$pdf_dir/$job_name.pdf"
printf 'Template version: %s\n' "$template_version"
printf 'Input directory: %s\n' "$input_repo_dir"
printf 'Main manuscript: %s\n' "$main_relative"
printf 'Built %s\n' "$pdf_dir/$job_name.pdf"
