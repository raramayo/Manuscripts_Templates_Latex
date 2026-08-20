![alt text](https://github.com/raramayo/Manuscripts_Templates_Latex_Priv_Devo_Repo/blob/main/images/zenodo.22018962.svg)

# Manuscripts_Templates_Latex
![alt text](https://github.com/raramayo/Manuscripts_Templates_Latex/blob/main/images/Manuscripts_Templates_Latex_Logo.png)

# Manuscript Multi-Target LaTeX Template

## Project Overview

The Manuscript Multi-Target LaTeX Template compiles one scientific manuscript
into arXiv, bioRxiv, Zenodo, or neutral PDF profiles. The manuscript content,
figures, citations, bibliography, and page layout remain shared; the selected
profile controls the footer label.

The repository includes a small working manuscript under `input/`, a
consolidated document class and bibliography style under `_Templates/`, a
portable build driver, and an automatic dependency checker. All path arguments
accepted or printed by the project scripts are repository-relative.

## Key Functions

- Build four presentation profiles from one unchanged manuscript source.
- Use either the default `input/` workspace or another manuscript bundle kept
  inside the repository.
- Discover `Manuscript.tex` automatically or select another main TeX file.
- Keep LaTeX auxiliary files separate for each target.
- Generate final PDFs under `output/pdf/`.
- Check required command-line tools and LaTeX packages before compilation.
- Write an actionable dependency report when software is missing.
- Preserve compatibility with manuscripts that use the earlier local bioRxiv
  class name.
- Keep build products, private test materials, and generated PDFs out of Git.

## Motivation

Maintaining a separate LaTeX template for every preprint destination creates
avoidable drift in formatting and manuscript content. This project keeps one
authoritative manuscript and one shared class while making the intended
presentation target an explicit build choice. The neutral profile also supports
review copies or archives that should not display a repository label.

## Authorship

Author: Rodolfo Aramayo

Work email: raramayo@tamu.edu

Personal email: rodolfo@aramayo.org

The consolidated class and bibliography style derive from Ricardo Henriques's
HenriquesLab bioRxiv template. See [docs/PROVENANCE.md](docs/PROVENANCE.md) for
the retained attribution and modification history.

## Version

Current repository version: `1.0.0`

The authoritative value is stored in `VERSION`. Display it with either:

```sh
./build.sh --version
make version
```

## Documentation

- [Code overview](docs/code-overview.md): script architecture, data flow, error
  handling, and maintenance notes.
- [Mini tutorial](docs/mini-tutorial.md): a guided first build and practical
  manuscript-replacement workflow.
- [Keywords](docs/keywords.md): five descriptive project keywords.
- [Provenance](docs/PROVENANCE.md): upstream lineage and local modifications.
- [Validation record](docs/VALIDATION.md): completed build and render checks.
- [Input workspace guide](input/README.md): required author-supplied materials.
- [Agent handoff](codex-notes/agent-notes.md): current development state and
  restart evidence.

## Quick Start

Run commands from the repository root. Check the local TeX installation and
build the default neutral manuscript:

```sh
make dependencies
make
```

The dependency report is written to `build/DEPENDENCY_REPORT.md`. The resulting
PDF is written to `output/pdf/Manuscript-neutral.pdf`. For a guided replacement
of the toy inputs, follow [docs/mini-tutorial.md](docs/mini-tutorial.md).

## Repository Layout

```text
.
├── _Templates/
│   ├── MultiTargetManuscript.bst
│   ├── MultiTargetManuscript.cls
│   └── bioRxiv-StyleBioRxiv.cls
├── codex-notes/
│   ├── AGENTS.md
│   └── agent-notes.md
├── docs/
│   ├── PROVENANCE.md
│   ├── README.md
│   ├── VALIDATION.md
│   ├── code-overview.md
│   ├── keywords.md
│   └── mini-tutorial.md
├── input/
│   ├── Figures/
│   ├── Manuscript.tex
│   ├── README.md
│   └── References.bib
├── scripts/
│   └── check_dependencies.sh
├── build.sh
├── LICENSE
├── Makefile
├── README_Example.md
├── README.md
└── VERSION
```

The scripts create `build/` and `output/pdf/` when needed. Root-level
`build/`, `output/`, `test-manuscript/`, and `tmp/` are local-only directories
excluded by `.gitignore`.

## Prerequisites

Use a TeX Live-compatible installation that supplies:

- Bash;
- `latexmk`;
- `pdflatex`;
- `bibtex`;
- `kpsewhich`; and
- the LaTeX packages loaded by the shared class and selected manuscript.

The dependency checker identifies missing commands and LaTeX files. Recommended
installation sources are [MacTeX for macOS](https://tug.org/mactex/),
[TeX Live](https://tug.org/texlive/), and the
[TeX Live Manager](https://tug.org/texlive/tlmgr.html).

## Manuscript Bundle Contract

The default bundle is:

```text
input/
├── Manuscript.tex
├── References.bib
└── Figures/
```

An alternate bundle must also remain inside the repository and contain:

- one top-level main `.tex` file;
- at least one top-level `.bib` file; and
- a `Figures/` directory.

If `Manuscript.tex` is absent, `build.sh` selects the only top-level `.tex`
file. When more than one candidate exists, use `--main`. Paths inside the
manuscript should be bundle-relative, for example:

```tex
\includegraphics[width=\columnwidth]{Figures/result.pdf}
\bibliography{References}
```

## Target Profiles

| Target    | Footer behavior                                          |
|-----------|----------------------------------------------------------|
| `arxiv`   | Stylized arXiv label                                     |
| `biorxiv` | Stylized bioRxiv label retained from the source template |
| `zenodo`  | Plain Zenodo label                                       |
| `neutral` | No repository or journal label                           |

These values select presentation profiles only. They do not establish an
affiliation with a service or validate current submission requirements.

## Script Reference

The repository has two executable scripts. Their options are documented
separately below.

### `build.sh`

Purpose: validate one manuscript bundle, run dependency preflight, compile one
target, and copy the finished PDF to `output/pdf/`.

Usage:

```text
./build.sh [TARGET] [INPUT_DIR] [MAIN_TEX]
./build.sh --target TARGET --input-dir INPUT_DIR [--main MAIN_TEX]
```

Public flags:

| Flag                   | Required | Value and default                                             | Behavior                                                                                |
|------------------------|----------|---------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| `-t`, `--target`       | No       | `arxiv`, `biorxiv`, `zenodo`, or `neutral`; default `neutral` | Select the output profile.                                                              |
| `-i`, `--input-dir`    | No       | Repository-relative directory; default `input`                | Select the manuscript bundle. The resolved directory must remain inside the repository. |
| `-m`, `--main`         | No       | Filename relative to `INPUT_DIR`                              | Select the main TeX file when automatic discovery is unsuitable.                        |
| `--check-dependencies` | No       | No value                                                      | Write the dependency report and exit without compiling.                                 |
| `-v` \| `--version`   | No       | No value                                                      | Print the repository version and exit.                                                  |
| `-h`, `--help`         | No       | No value                                                      | Print usage information and exit.                                                       |
| `--`                   | No       | Followed by positional values                                 | Stop option parsing and treat remaining values as positional arguments.                 |

The legacy positional form maps values in this order: `TARGET`, `INPUT_DIR`,
then `MAIN_TEX`. Do not mix positional values with `--target`, `--input-dir`,
or `--main`.

Examples:

```sh
./build.sh arxiv
./build.sh --target biorxiv --input-dir test-manuscript
./build.sh --target neutral --input-dir drafts/paper --main article.tex
```

### `scripts/check_dependencies.sh`

Purpose: inspect required build commands, shared class dependencies,
manuscript-declared packages, and optional LaTeX failure logs. It always writes
a Markdown report.

Usage:

```text
./scripts/check_dependencies.sh [OPTIONS]
```

Public flags:

| Flag              | Required | Value and default                                                       | Behavior                                                                    |
|-------------------|----------|-------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `--source`        | No       | Repository-relative TeX file; repeatable                                | Add packages declared with `\usepackage` or `\RequirePackage` to the check. |
| `--log`           | No       | Repository-relative LaTeX log; repeatable                               | Inspect a failed log for a missing-file diagnostic.                         |
| `--report`        | No       | Repository-relative Markdown file; default `build/DEPENDENCY_REPORT.md` | Select the report destination. Parent directories are created when needed.  |
| `--quiet`         | No       | No value                                                                | Suppress successful console output; missing-dependency errors still print.  |
| `-v` \| `--version` | No       | No value                                                                | Print the repository version and exit.                                      |
| `-h`, `--help`    | No       | No value                                                                | Print usage information and exit.                                           |

All file arguments must stay inside the repository. A successful check exits
with status 0. Missing dependencies exit with status 127 and leave installation
guidance in the selected report.

Examples:

```sh
./scripts/check_dependencies.sh
./scripts/check_dependencies.sh --source input/Manuscript.tex
./scripts/check_dependencies.sh \
  --source input/Manuscript.tex \
  --report build/custom-dependency-report.md
```

## Makefile Reference

The Makefile delegates compilation to `build.sh`.

Variables:

| Variable    | Default   | Purpose                                         |
|-------------|-----------|-------------------------------------------------|
| `TARGET`    | `neutral` | Select one of the four presentation profiles.   |
| `INPUT_DIR` | `input`   | Select a repository-relative manuscript bundle. |
| `MAIN_TEX`  | Empty     | Select the main TeX file within `INPUT_DIR`.    |

Targets:

| Target         | Behavior                                               |
|----------------|--------------------------------------------------------|
| `all`, `pdf`   | Build the selected target; this is the default action. |
| `all-targets`  | Build arXiv, bioRxiv, Zenodo, and neutral PDFs.        |
| `dependencies` | Write the dependency report without compiling.         |
| `version`      | Print the repository version.                          |
| `clean`        | Remove generated build products and PDFs.              |
| `help`         | Print Makefile examples.                               |

Examples:

```sh
make TARGET=zenodo
make all-targets INPUT_DIR=test-manuscript
make TARGET=neutral INPUT_DIR=drafts MAIN_TEX=article.tex
```

## Output Layout

Each target has an isolated auxiliary directory:

```text
build/arxiv/
build/biorxiv/
build/zenodo/
build/neutral/
```

Final filenames combine the main TeX stem and target:

```text
output/pdf/Manuscript-arxiv.pdf
output/pdf/Manuscript-biorxiv.pdf
output/pdf/Manuscript-zenodo.pdf
output/pdf/Manuscript-neutral.pdf
```

For `test-manuscript/Manuscript_01.tex`, the arXiv output is
`output/pdf/Manuscript_01-arxiv.pdf`.

## LaTeX Target Selection

The build script defines `\ManuscriptTarget` before loading the manuscript.
Direct LaTeX use may instead select a native class option:

```tex
\documentclass[zenodo,times,twoside]{_Templates/MultiTargetManuscript}
```

The retained journal controls can replace or suppress the footer label:

```tex
\journalname{Example Journal}
\nojournalname
```

Older manuscripts may continue to use
`_Templates/bioRxiv-StyleBioRxiv.cls`, which forwards options to the
consolidated class. New manuscripts should use `MultiTargetManuscript`.

## Repository

<https://github.com/raramayo/Manuscripts_Templates_Latex>

## Issues

<https://github.com/raramayo/Manuscripts_Templates_Latex/issues>

## License

This project is distributed under the GNU General Public License version 3 or,
at your option, any later version. See [LICENSE](LICENSE).
