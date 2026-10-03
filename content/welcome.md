---
title: Welcome to Salam Press
date: 2026-10-03
description: A tour of the static site generator written entirely in Salam.
nav: true
---
# Welcome to Salam Press

Salam Press turns a folder of **Markdown** files into a small, fast website.
It is written in the [Salam Programming Language](https://github.com/SalamLang/Salam)
and compiles to a single native binary.

## What you get

- Markdown pages with front matter
- A table of contents built from your headings
- A generated home page, newest posts first
- Reading time for every page

## How it works

Each `.md` file goes through four steps:

1. The front matter is split from the body.
2. Block rules find headings, lists, quotes and code.
3. Inline rules handle *emphasis*, **strong text**, links and `code`.
4. The result is poured into `templates/page.html`.

> Drafts stay private: add `draft: true` to the header and the page is skipped.

---

Read the [Markdown guide](markdown-guide.html) next.
