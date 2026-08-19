# Provenance and consolidation notes

## Lineage

The template is derived from Ricardo Henriques's HenriquesLab bioRxiv template:

<https://github.com/HenriquesLab/HenriquesLab-bioRxiv-template>

The upstream repository identifies the work as GPL-3.0 licensed. The complete
GPL version 3 text is provided in `LICENSE`.

The local source variants already contained later modifications by Rodolfo
Aramayo. Their comments were preserved in `_Templates/MultiTargetManuscript.cls`,
including the 2026 filename clarification, running-author footer logic, and
optional journal-name controls.

## 2026-08-18 consolidation

The consolidated template was based on the following local inputs without
changing them. These are historical paths relative to the former
`Manuscript_MultiTarget_Template.dir` staging directory at consolidation time:

- `../Manuscript_01_arXiv_Journal_Config.dir/arXiv-StyleArXiv.cls`
- `../Manuscript_01_arXiv_Journal_Config.dir/arXiv-StyleBib.bst`
- the class-name and footer-label differences observed in
  `../Manuscript_01_bioRxiv.dir/_Templates/bioRxiv-StyleBioRxiv.cls`

New logic is marked in the class with comments containing
`2026/08/18 consolidation`. It adds:

- one selector with `arxiv`, `biorxiv`, `zenodo`, and `neutral` values;
- matching native class options;
- profile-specific footer labels;
- conditional separators for neutral output; and
- clear errors for unsupported target names.

The legacy internal prefix `biorxiv@` is retained in pre-existing author-running
logic to minimize unnecessary changes and preserve provenance. Newly introduced
target/footer internals use the `multitarget@` prefix.

The bibliography style was renamed but not behaviorally changed. Its header
records that rename.

## Toy fixture

The long scientific manuscript was replaced in the consolidated template by a
short fictional manuscript, a two-entry bibliography, and a portable TeX
figure. Those author-facing files now live under `input/`. The fixture exists to
make four-profile compilation and visual regression checks fast. It contains no
claims about real authors, affiliations, experiments, repository acceptance, or
publication status.

## Repository organization

On 2026-08-18, author-supplied materials were grouped under `input/` and project
evidence under `docs/`. The class, bibliography style, license, build entry
points, output directory, and target-profile behavior were not relocated or
changed. The reorganization keeps manuscript content separate from template
infrastructure while preserving one-command builds from the repository root.

## Repository-root promotion

Later on 2026-08-18, the contents of the former
`Manuscript_MultiTarget_Template.dir` staging directory were promoted to the Git
repository root, beside `.git`. The staging directory was then removed.

Root-level collisions were merged deliberately:

- The original repository title was retained at the top of `README.md`, followed
  by the complete multi-target workflow and usage guide.
- The existing root GPL version 3 license was retained as the canonical
  `LICENSE`. Comparison showed that the duplicate license differed only by
  modern HTTPS links in the root copy versus HTTP links in the staged copy.
- Existing repository ignore rules were retained and the `build/` and `tmp/`
  LaTeX exclusions were added to the root `.gitignore`.

The `Makefile`, `build.sh`, `_Templates/`, `input/`, `docs/`, `output/`, and
ignored `build/` directory now live directly at the Git repository root.

## Flexible manuscript bundles

Later on 2026-08-18, `build.sh` and the `Makefile` were extended to accept a
repository-relative manuscript directory and main TeX filename. This preserves
the default `input/Manuscript.tex` workflow while allowing a real manuscript to
retain its original filenames and bundle-relative figure and bibliography
paths. The script performs deterministic main-file discovery, requires the
expected bibliography and figure components, and does not rewrite user input.

`_Templates/bioRxiv-StyleBioRxiv.cls` was added as a documented compatibility
alias for the consolidated class. It contains no independent layout behavior:
all options are forwarded to `_Templates/MultiTargetManuscript.cls`. This keeps
older local manuscripts buildable while directing new manuscripts to the
single maintained class.

## Version 1.0.0 and dependency reporting

On 2026-08-18, the consolidated repository was assigned its first semantic
release identifier, `1.0.0`. The root `VERSION` file is the single source of
truth used by `build.sh`, the dependency checker, the Makefile, documentation,
and LaTeX class metadata. The inherited source and license version notes remain
unchanged and distinct from the repository release number.

`scripts/check_dependencies.sh` was added to check the required command-line
tools, shared LaTeX packages, and packages declared by a selected manuscript.
It writes `build/DEPENDENCY_REPORT.md` on every run. A missing dependency stops
the build and leaves actionable guidance with official TeX distribution and
package-manager links. A failed LaTeX run also refreshes the report from any
missing-file diagnostic in the log.

The root ignore policy was tightened to exclude `build/`, `output/`,
`test-manuscript/`, and `tmp/` in full. Previously tracked example PDFs under
`output/` were removed from the proposed repository contents; builds continue
to recreate local output files on demand.
