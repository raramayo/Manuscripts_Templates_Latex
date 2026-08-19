# Script code overview

## Scope

This document describes the implementation of the repository's two executable
scripts. User-facing flags and Makefile targets are cataloged in the root
`README.md`; the guided author workflow is kept in `mini-tutorial.md`.

## Execution flow

```text
build.sh
  |
  +-- validate target and repository-relative manuscript paths
  +-- discover or select the main TeX source
  +-- verify the bundle has a bibliography and Figures/
  +-- call scripts/check_dependencies.sh
  |     |
  |     +-- check required executables
  |     +-- check shared and manuscript-declared LaTeX packages
  |     +-- optionally inspect a failed LaTeX log
  |     +-- write build/DEPENDENCY_REPORT.md
  |
  +-- generate a target-selection driver under build/<target>/
  +-- run latexmk with isolated auxiliary and TeX cache files
  +-- refresh the dependency report if LaTeX reports a missing file
  +-- copy the completed PDF to output/pdf/
```

## `build.sh`

### Startup and versioning

The script resolves its own location, changes to the repository root, and reads
`VERSION`. This lets the same command work when launched from another current
directory without embedding a machine-specific location. A missing `VERSION`
file is treated as a repository-integrity error.

### Argument parsing

The parser supports named options and the retained positional interface. It
rejects unknown options, missing option values, unsupported targets, excessive
positional arguments, and ambiguous mixtures of named and positional input
selectors. The accepted target set is deliberately closed:

```text
arxiv  biorxiv  zenodo  neutral
```

### Path containment

`--input-dir` must be relative to the repository root. After resolving harmless
path components, the script confirms that the directory is still inside the
checkout. `--main` must be relative to the selected bundle, and its resolved
file must remain inside that bundle. Console messages, generated driver
comments, and dependency reports use repository-relative labels.

These checks make the repository relocatable and prevent local filesystem
locations from becoming publication artifacts or documentation.

### Input discovery

The main-file selection order is:

1. the file supplied with `--main`;
2. `Manuscript.tex`, when present; or
3. the only top-level `.tex` file in the selected bundle.

No candidate or multiple candidates produce a clear input error. The bundle
must also contain at least one top-level `.bib` file and a `Figures/` directory.
The build never edits the selected bundle.

### Target driver

`latexmk` expects a filename rather than a raw TeX expression. The script
therefore creates a disposable driver in the target build directory. The driver
defines `\ManuscriptTarget` and then inputs the selected source. This keeps the
author manuscript identical across all four builds.

### TeX search environment

The script prepends repository-relative entries to `TEXINPUTS`, `BIBINPUTS`,
and `BSTINPUTS`. The selected bundle is searched before shared repository
locations, allowing bundle-relative figure and bibliography references.
`TEXMFVAR` points into the target build directory so generated fonts and cache
data remain disposable. TeX's font generator requires that environment value
to be fully resolved, so the script computes it from its own location at
runtime. The computed value is neither stored in source nor printed by the
project scripts.

### Compilation

The internal `latexmk` invocation enables PDF output, noninteractive processing,
halt-on-error behavior, file-and-line diagnostics, a target-specific output
directory, and a predictable job name. Source stems containing unsafe job-name
characters are normalized before generated filenames are constructed.

If compilation fails, the script asks the dependency checker to inspect the
LaTeX log. A newly detected missing file changes the final status to the
dependency-specific exit code; other LaTeX failures retain the `latexmk` status.

## `scripts/check_dependencies.sh`

### Command checks

The checker verifies `latexmk`, `pdflatex`, `bibtex`, and `kpsewhich`. If
`kpsewhich` is unavailable, the report states that package-file lookup could
not run instead of claiming that packages are present.

### LaTeX file checks

The baseline list represents packages loaded by
`_Templates/MultiTargetManuscript.cls`. Each supplied source is also scanned for
single-line `\usepackage` and `\RequirePackage` declarations. Comma-separated
package groups are split and deduplicated before `kpsewhich` lookup.

An optional failed log supplies a second detection route for dependencies used
by included sources or conditional code. Lines matching LaTeX's missing-file
diagnostic are added to the report.

### Report generation

The checker creates the report parent directory, records the template version
and UTC generation time, and writes one of two states:

- `Ready`: no checked dependency is missing;
- `Action required`: one or more commands or LaTeX files are unavailable.

The report includes official TeX distribution resources, recovery commands,
and a warning against downloading unverified standalone style files. File
arguments and report destinations must remain inside the repository.

## Makefile delegation

The Makefile contains no independent compilation logic. It converts `TARGET`,
`INPUT_DIR`, and optional `MAIN_TEX` variables into named `build.sh` options.
The `all-targets` recipe calls the script once per profile; `dependencies`,
`version`, `clean`, and `help` provide convenience entry points.

## Exit status model

| Status | Meaning |
| ---: | --- |
| `0` | Requested operation completed successfully. |
| `2` | Invalid option, target, argument combination, or path scope. |
| `3` | Required manuscript input is missing or ambiguous. |
| `4` | Repository metadata, checker, or report directory could not be used. |
| `127` | A required command or LaTeX dependency is missing. |
| Other | A non-dependency `latexmk` failure status was preserved. |

## Maintenance invariants

- Keep `VERSION`, script header versions, and class metadata synchronized.
- Keep public help output and the root README flag tables synchronized.
- Keep every user-facing and documented filesystem location
  repository-relative.
- Preserve the original upstream attribution and dated modification notes.
- Do not introduce target-specific copies of the manuscript.
- Do not track `build/`, `output/`, `test-manuscript/`, or `tmp/` contents.
- Update `VALIDATION.md` only with checks that were actually performed.

## Known boundaries

The source scanner recognizes direct, single-line package declarations. Missing
packages reached through included sources are detected only after LaTeX emits a
missing-file diagnostic. Successful local compilation does not prove acceptance
by arXiv, bioRxiv, Zenodo, a journal, or another external service.
