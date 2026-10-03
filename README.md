# Salam Press

A Markdown static site generator, written entirely in the
[Salam Programming Language](https://github.com/SalamLang/Salam).

Point it at a folder of `.md` files and it writes a small, fast website:
one HTML page per file, a generated home page sorted newest first, a table of
contents, reading times and a navigation bar. It compiles to a single native
binary with no runtime dependencies.

> Built with the Salam Programming Language for the
> [Salam community build challenge](https://github.com/SalamLang/Salam/issues/1713).

## Features

- Markdown: headings, paragraphs, bullet and numbered lists, fenced code
  blocks with a language class, blockquotes, horizontal rules, `**bold**`,
  `*italic*`, `` `code` ``, links and images
- Front matter (`title`, `date`, `description`, `nav`, `draft`)
- Heading ids and an automatic table of contents for pages with two or more
  `##`/`###` headings
- Home page listing every page, newest first
- Reading time per page
- Drafts (`draft: true`) are skipped
- HTML in text and code is always escaped
- Plain `{{placeholder}}` templates and a dark-mode aware default stylesheet
- LF and CRLF input

## Quick start

Install Salam 0.4.4 (Linux/macOS):

```sh
{ curl -fsSL https://raw.githubusercontent.com/SalamLang/Salam/refs/heads/main/install.sh || wget -qO- https://raw.githubusercontent.com/SalamLang/Salam/refs/heads/main/install.sh; } | sh -s -- --version 0.4.4
export PATH="$HOME/.salam/bin:$PATH"
```

Build the generator and render the example site:

```sh
salam build src/main.salam --output=salam-press
./salam-press
```

```
Built 3 pages (1 draft skipped) -> site
```

Open `site/index.html` in a browser.

Install the [Salam VS Code extension](https://marketplace.visualstudio.com/items?itemName=salamlanguage.salam-programming-language)
for syntax highlighting while you hack on the source.

## Usage

```
salam-press [build] [options]
salam-press help
salam-press version
```

| Option            | Default         | Meaning                          |
| ----------------- | --------------- | -------------------------------- |
| `--src=DIR`       | `content`       | directory with the `.md` files   |
| `--out=DIR`       | `site`          | where HTML is written            |
| `--templates=DIR` | `templates`     | `page.html`, `index.html`, `style.css` |
| `--title=TEXT`    | `Salam Press Site` | site title                    |

`--out dir` works as well as `--out=dir`. Exit codes: `0` success, `1` build
error (missing directory or template, unwritable output), `2` bad command line.

## Writing pages

```markdown
---
title: My First Post
date: 2026-10-03
description: Shown under the title on the home page.
nav: true
---
## A section

Some **bold** text and a [link](https://github.com/SalamLang/Salam).
```

| Key           | Effect                                                     |
| ------------- | ---------------------------------------------------------- |
| `title`       | page title; falls back to a leading `# Heading`, then the file name |
| `date`        | shown on the page; the home page sorts by it (use `YYYY-MM-DD`) |
| `description` | meta description and home page blurb                       |
| `nav`         | `true` adds the page to the navigation bar                 |
| `draft`       | `true` skips the page                                      |

The file name becomes the URL: `markdown-guide.md` is written as
`markdown-guide.html`. `index.md` is reserved for the generated home page.
A leading `# Title` that repeats the page title is dropped, because the
template already renders it.

### Templates

`templates/page.html` and `templates/index.html` are ordinary HTML with
`{{placeholders}}`. Page templates can use `site_title`, `title`,
`description`, `date`, `minutes`, `nav`, `toc` and `content`; the index
template gets `site_title`, `title`, `nav`, `count` and `list`. Unknown
placeholders become empty strings. `templates/style.css` is copied next to
the pages.

## Project layout

```
src/
  main.salam         entry point, exit codes
  cli.salam          argument parsing and usage text
  site.salam         reads pages, renders them, writes the site
  frontmatter.salam  splits the "key: value" header from the body
  blocks.salam       headings, lists, code fences, quotes, rules, paragraphs
  spans.salam        inline code, bold, italic, links, images
  toc.salam          table of contents from collected headings
  template.salam     single-pass {{placeholder}} expansion
  slug.salam         "Hello, World!" -> "hello-world"
  stats.salam        word count and reading time
  escape.salam       HTML escaping
content/             example Markdown pages
templates/           page, index and stylesheet
tests/               unit tests, fixtures and smoke.sh
```

Rendering pipeline for each page:
`frontmatter.Parse` -> `blocks.Render` (which calls `spans.Render` for inline
text and collects headings) -> `toc.Build` -> `template.Apply`.

## Tests

```sh
sh tests/smoke.sh
```

This compiles and runs each `tests/unit_*.salam` program (one per module),
builds the CLI, checks exit codes and error handling, renders the example
site and renders the edge-case fixtures in `tests/fixtures/` (CRLF files,
missing front matter, HTML in titles, unclosed Markdown markers, drafts).
Set `SALAM=/path/to/salam` if `salam` is not on your `PATH`.

## Docker

The Dockerfile builds the generator on the official
[`basemax/salam`](https://hub.docker.com/repository/docker/basemax/salam)
image:

```sh
docker build -t salam-press .
docker run --rm -v "$PWD/site:/app/site" salam-press
```

or `docker compose up --build`, which renders `./content` into `./site`.

## Limitations

- Lists are one level deep (no nesting) and items are single lines
- No tables, footnotes, reference-style links or raw HTML blocks
- `*` and `**` pairs are matched left to right on a single paragraph
- Pages are read from one directory, not recursively

## License

MIT, see [LICENSE](LICENSE). Salam itself is GPL-3.0; see the
[Salam repository](https://github.com/SalamLang/Salam).
