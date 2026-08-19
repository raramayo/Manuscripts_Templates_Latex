# Manuscript input workspace

Place all author-supplied manuscript materials in this directory.

Required starting materials:

- `Manuscript.tex`: manuscript text, authors, affiliations, and LaTeX metadata.
- `References.bib`: BibTeX reference database.
- `Figures/`: figures and any source files included by the manuscript.

The supplied files form a working toy example. To start a new manuscript in
this default workspace, replace their content while keeping the paths stable.
Figure references may retain the existing repository-relative form:

```tex
\includegraphics[width=\columnwidth]{input/Figures/example-figure.pdf}
```

The bibliography command in `Manuscript.tex` should remain:

```tex
\bibliography{input/References}
```

Run all build commands from the repository root, not from inside `input/`.

Authors may instead keep a manuscript in another self-contained directory
inside this repository with its original `.tex` and `.bib` names. That
directory must have a top-level main TeX source, at least one top-level BibTeX
database, and `Figures/`. Select it without copying or renaming files:

```sh
./build.sh --target arxiv --input-dir path/to/manuscript
```

Inside a separate bundle, use bundle-relative references such as
`Figures/example-figure.pdf` and `\bibliography{Paper_References}`. See the root
`README.md` for automatic main-file discovery, `--main`, Makefile equivalents,
output naming, and the complete workflow.
