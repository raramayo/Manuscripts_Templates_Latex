%%
%% Compatibility alias for manuscripts created with the earlier local
%% bioRxiv class filename.
%% Repository release: 1.0.0
%%
%% Copyright (C) Ricardo Henriques <r.henriques@ucl.ac.uk>
%%
%% [2026/08/18 compatibility update implemented with OpenAI Codex]
%% This thin wrapper intentionally contains no layout or footer behavior. It
%% forwards every class option to MultiTargetManuscript.cls, allowing an older
%% manuscript to use the consolidated target selector without changing its
%% original \documentclass line. New manuscripts should name
%% _Templates/MultiTargetManuscript directly.
%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{_Templates/bioRxiv-StyleBioRxiv}%
  [2026/08/18 v1.0.0 Compatibility alias for MultiTargetManuscript]

\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{_Templates/MultiTargetManuscript}}
\ProcessOptions\relax
\LoadClass{_Templates/MultiTargetManuscript}
