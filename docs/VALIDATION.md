# Validation record

Date: 2026-08-18

## Environment

- Template release: 1.0.0
- LaTeX engine: pdfTeX 3.141592653-2.6-1.40.29 (TeX Live 2026)
- Build driver: latexmk 4.88
- Bibliography processor: BibTeX 0.99e
- PDF inspection: Poppler `pdfinfo`, `pdftotext`, and `pdftoppm`

## Commands

```sh
bash -n build.sh
make all-targets
```

The four target builds completed successfully from the same
`input/Manuscript.tex` after promotion to the Git repository root. The commands
were executed from the same directory that contains `.git`, `Makefile`, and
`build.sh`.
The final logs contain no LaTeX/package warnings, undefined citations or
references, overfull boxes, underfull boxes, or fatal errors.

## Input-path checks

- `input/Manuscript.tex`, `input/References.bib`, and `input/Figures/` are
  present; their former repository-root paths are absent.
- The arXiv `.fls` recorder file identifies `input/Manuscript.tex` and
  `input/Figures/toy-workflow.tex` as compilation inputs.
- The BibTeX log identifies `input/References.bib` as its database.
- `build.sh` performs explicit preflight checks for all three required input
  locations before invoking LaTeX.
- The former `Manuscript_MultiTarget_Template.dir` staging path is absent.

## Output checks

| PDF                                 | Pages | Page size | Expected footer label |
|-------------------------------------|------:|-----------|-----------------------|
| `output/pdf/Manuscript-arxiv.pdf`   |     2 | US Letter | arXiv                 |
| `output/pdf/Manuscript-biorxiv.pdf` |     2 | US Letter | bioRxiv (stylized)    |
| `output/pdf/Manuscript-zenodo.pdf`  |     2 | US Letter | Zenodo                |
| `output/pdf/Manuscript-neutral.pdf` |     2 | US Letter | none                  |

Text extraction confirmed the profile label on both first-page and even-page
footers. The neutral output contains no empty label field and no doubled footer
separator. Citations, the figure reference, and `LastPage` resolve in every
profile.

All eight pages were rendered to PNG and reviewed. The latest renders showed no
clipped text, overlap, broken glyphs, malformed separators, or illegible figure
content. `flushend` balances the deliberately short fixture's final columns.

## Flexible-directory real-manuscript validation

The user-supplied `test-manuscript/` bundle was also compiled without renaming,
copying, or editing its source components:

```text
test-manuscript/Manuscript_01.tex
test-manuscript/Manuscript_01_References.bib
test-manuscript/Figures/*.png
```

The following interfaces were tested:

```sh
./build.sh --target neutral --input-dir test-manuscript
make all-targets INPUT_DIR=test-manuscript
make all-targets
```

The first command verified automatic discovery of the only top-level `.tex`
file. The second exercised the Makefile's alternate-input support for all four
profiles. The third reran the default toy fixture and confirmed that the
original `input/` workflow remains backward-compatible. The explicit
`--main Manuscript_01.tex` and `MAIN_TEX=Manuscript_01.tex` forms are available
for directories containing more than one top-level TeX file.

The real manuscript retains its earlier
`_Templates/bioRxiv-StyleBioRxiv` class declaration. The compatibility class
forwarded its options to `MultiTargetManuscript`, and the generated driver
still selected each requested footer profile. Recorder and BibTeX logs confirm
that compilation read the original TeX file, its named bibliography database,
and all five source-relative figures from `test-manuscript/`.

| PDF                                    | Pages | Page size | Expected footer label |
|----------------------------------------|------:|-----------|-----------------------|
| `output/pdf/Manuscript_01-arxiv.pdf`   |    17 | US Letter | arXiv                 |
| `output/pdf/Manuscript_01-biorxiv.pdf` |    17 | US Letter | bioRxiv (stylized)    |
| `output/pdf/Manuscript_01-zenodo.pdf`  |    17 | US Letter | Zenodo                |
| `output/pdf/Manuscript_01-neutral.pdf` |    17 | US Letter | none                  |

The final logs contain no unresolved citations, unresolved references, TeX
errors, or fatal errors. They consistently retain warnings from the unchanged
real manuscript: substitution of the unavailable `LGR/ptm` font shape and a
tightly packed float-only page 3 with overfull vertical boxes. Render review of
that page confirmed that both figures, captions, and footers remain inside the
page and legible. All 68 pages across the four generated profiles were rendered
and reviewed; page flow, figures, equations, bibliography transitions, and
footer placement were consistent, with no visible clipping, overlap, broken
glyphs, or malformed target separators. These manuscript-specific warnings are
distinct from the alternate-input implementation; the toy fixture continues to
build with clean logs.

## Version, dependency-report, and ignore checks

The release identifier is stored once in `VERSION`. Each supported interface
reported the same value, and the generated LaTeX logs identified the shared
class as version 1.0.0:

```sh
./build.sh --version
./scripts/check_dependencies.sh --version
make version
```

Dependency preflight was exercised both directly and through the public build
interfaces:

```sh
make dependencies
make dependencies INPUT_DIR=test-manuscript
./build.sh --target neutral --input-dir test-manuscript
```

With the installed TeX environment, these checks produced a `Ready` report at
`build/DEPENDENCY_REPORT.md`. Controlled missing-dependency tests also verified
all three failure paths:

- a restricted `PATH` reported the absent `latexmk`, `pdflatex`, `bibtex`, and
  `kpsewhich` commands;
- a synthetic LaTeX failure log reported the absent
  `definitely-not-installed.sty` file; and
- a controlled `kpsewhich` result reported a source-declared missing
  `fontawesome.sty` package.

Each failure returned status 127, wrote an `Action required` Markdown report,
printed its location, and included platform-appropriate links and commands for
installing or updating a TeX distribution. The normal report was restored
after these simulations.

`git check-ignore -v` confirmed that repository-root `build/`, `output/`,
`test-manuscript/`, and `tmp/` contents are ignored. A synthetic nested
`nested/build/source.tex` path was intentionally not ignored, confirming that
the patterns are root-anchored rather than overbroad. Files previously tracked
under `output/pdf/` were removed after PDF validation so a future commit will
stop tracking generated PDFs; subsequent builds recreate them only as ignored
local artifacts.

For release 1.0.0, all four toy and all four real-manuscript profiles were
rebuilt. All 76 resulting PDF pages were rendered and visually reviewed before
the generated outputs were removed. The release metadata and dependency
preflight introduced no layout regressions.

## Repository-relative path and documentation checks

On 2026-08-18, path handling was tightened so public script arguments must
remain relative to and inside the repository. Both scripts were launched with
their supported help and version options. Controlled out-of-scope path tests
were rejected with status 2, while the default `input/` and the unchanged
`test-manuscript/` bundles passed dependency preflight. The generated report
listed only repository-relative source and report locations.

After this change, the following builds completed successfully:

```sh
make all-targets
make all-targets INPUT_DIR=test-manuscript
```

All four toy logs remained free of TeX errors, unresolved citations,
unresolved references, and box warnings. All four real-manuscript logs remained
free of TeX errors and unresolved references or citations; they retained only
the previously documented manuscript-specific font and float-page warnings.

The new root README was checked against the live `--help` output from both
scripts. Every public option, alias, default, positional form, Makefile
variable, and Makefile target is documented. Relative Markdown links were
checked for existing destinations, and a maintained-file scan found no
machine-specific filesystem locations in scripts or repository documentation.
Generated `build/` and `output/` contents were removed after validation because
they are reproducible local artifacts.

## Supported conclusion

This validates local compilation and rendering of the four profile outputs. It
does not validate live upload acceptance, external repository processing,
repository metadata, DOI reservation, or future submission-policy compliance.
