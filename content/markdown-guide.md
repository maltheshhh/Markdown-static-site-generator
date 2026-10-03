---
title: Markdown Guide
date: 2026-10-02
description: Every Markdown feature Salam Press understands.
---
# Markdown Guide

Everything below is rendered by the generator itself.

## Headings

Use one to six `#` characters followed by a space. Every heading gets an
`id`, so you can link to it directly.

## Emphasis and links

Write *italic*, **bold** and `inline code`. Links look like
[the Salam repo](https://github.com/SalamLang/Salam) and images look like
`![alt text](picture.png)`.

### Lists

- Bullets start with a dash, star or plus
- Numbers work too

1. First
2. Second
3. Third

## Code blocks

Fence code with three backticks and an optional language:

```salam
func main:
    println "Hello from Salam"
end
```

HTML inside code is escaped, so `<div>` stays visible.

## Quotes

> Simplicity is prerequisite for reliability.
> Keep the source readable.
