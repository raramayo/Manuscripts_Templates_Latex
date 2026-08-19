# Mini tutorial

This tutorial walks through one complete author workflow. It assumes the
repository has already been downloaded and intentionally avoids repeating the
flag and Makefile reference maintained in the root `README.md`.

## 1. Confirm the starting point

Open a terminal in the repository root and display the template release:

```sh
./build.sh --version
```

The repository includes a small working manuscript. Its purpose is to confirm
the local TeX toolchain before personal manuscript files are introduced.

## 2. Check the TeX installation

Run the standalone preflight:

```sh
./scripts/check_dependencies.sh --source input/Manuscript.tex
```

Read `build/DEPENDENCY_REPORT.md`. Continue when its status is `Ready`. If the
status is `Action required`, follow the platform guidance in that report,
restart the terminal after installation, and run the check again.

## 3. Build and inspect the toy manuscript

Compile all four presentation profiles:

```sh
make all-targets
```

Open the four PDFs under `output/pdf/`. Compare their footers and confirm that
the article body, citations, figure, and bibliography remain identical. The
neutral copy should have no repository label.

## 4. Keep one manuscript per input directory

Do not place the files for a second manuscript beside the first manuscript's
files in `input/`. Although an explicit `MAIN_TEX` can select one of several
top-level TeX files, mixing manuscripts makes it difficult to tell which
bibliography and figures belong together.

The selection rules are:

1. If the selected directory contains `Manuscript.tex`, that file is used.
2. Otherwise, the only top-level `.tex` file is used automatically.
3. If several top-level `.tex` files exist, the build stops and asks for
   `MAIN_TEX` or `--main`.
4. At least one top-level `.bib` file and a `Figures/` directory must exist.
   The bibliography command inside the selected TeX source determines which
   `.bib` database BibTeX reads.

The recommended convention is therefore one self-contained directory per
manuscript. Keep the supplied example in `input/` and place a second manuscript
in a sibling directory such as `input2/`:

```text
.
├── input/                       # first manuscript or supplied toy fixture
│   ├── Manuscript.tex
│   ├── References.bib
│   └── Figures/
└── input2/                      # second manuscript
    ├── Manuscript02.tex
    ├── Manuscript02_References.bib
    └── Figures/
        └── result.pdf
```

The build processes only the directory named by `INPUT_DIR`. Files in `input/`
do not compete with files in `input2/`.

## 5. Prepare the second manuscript

Create a new directory inside the repository with this shape:

```text
input2/
├── Manuscript02.tex
├── Manuscript02_References.bib
└── Figures/
    └── result.pdf
```

In `Manuscript02.tex`, keep the consolidated class path and use
bundle-relative supporting-file paths:

```tex
\documentclass[times,twoside]{_Templates/MultiTargetManuscript}

% Manuscript content goes here.

\includegraphics[width=\columnwidth]{Figures/result.pdf}
\bibliography{Manuscript02_References}
```

There is no need to copy `_Templates/` into `input2/` or change the
`\documentclass` path. `build.sh` runs from the repository root and adds the
repository and `_Templates/` to TeX's search path. Only figure and bibliography
references that were tied to an earlier bundle, such as
`input/Figures/result.pdf`, should be changed to bundle-relative forms such as
`Figures/result.pdf`.

The build system supplies the profile selector. Do not create four manuscript
copies or hard-code a target solely for scripted builds.

A nested organization such as `input/manuscript02/` also works when selected
with `INPUT_DIR=input/manuscript02`; it does not require a different class
declaration. The sibling `input2/` form is used here because it makes the two
complete bundles especially easy to distinguish.

## 6. Check the new bundle

Ask the build entry point to perform only its preflight:

```sh
./build.sh \
  --check-dependencies \
  --target neutral \
  --input-dir input2
```

Because `Manuscript02.tex` is the only top-level TeX file, it is selected
automatically. This step checks the bundle contract and package requirements
without starting LaTeX compilation.

If `input2/` intentionally contains several top-level TeX files, identify the
entry point explicitly:

```sh
./build.sh \
  --check-dependencies \
  --target neutral \
  --input-dir input2 \
  --main Manuscript02.tex
```

## 7. Produce a review copy

Build the unbranded profile first:

```sh
make \
  TARGET=neutral \
  INPUT_DIR=input2
```

Review `output/pdf/Manuscript02-neutral.pdf`. Correct manuscript content,
missing figures, citation warnings, or layout problems in `input2/` rather than
in generated files under `build/`.

## 8. Produce destination-labeled copies

After the neutral review copy is satisfactory, build the full target set:

```sh
make all-targets INPUT_DIR=input2
```

This command leaves the first manuscript in `input/` untouched and generates
four PDFs from `input2/Manuscript02.tex`. Add
`MAIN_TEX=Manuscript02.tex` only if automatic selection is ambiguous.

Inspect every PDF before distribution. A successful local build verifies the
template workflow, not the current submission rules of an external service.

## 9. Clean generated files

When local outputs are no longer needed, run:

```sh
make clean
```

This removes generated auxiliary files and PDFs. It does not remove
`input2/`, `input/`, `_Templates/`, or documentation.

## Troubleshooting checkpoints

- No main source found: confirm the TeX file is at the bundle's top level.
- Multiple main-source candidates: select the intended entry file explicitly.
- Wrong manuscript selected: confirm that `INPUT_DIR` names the intended
  one-manuscript bundle and avoid combining separate manuscripts in one
  directory.
- Bibliography preflight failure: place at least one `.bib` file at the bundle's
  top level.
- Wrong bibliography used: confirm that the selected main TeX file names its
  own bundle-relative bibliography database.
- Figure-directory preflight failure: create the exact `Figures/` directory.
- Missing command or style file: use the generated dependency report rather
  than copying unverified package files into the repository.
- LaTeX failure with a `Ready` dependency report: inspect the target log under
  `build/` for a manuscript syntax or content problem.

For option semantics, defaults, positional compatibility, and exit statuses,
return to the root `README.md`. For implementation details, read
`docs/code-overview.md`.
