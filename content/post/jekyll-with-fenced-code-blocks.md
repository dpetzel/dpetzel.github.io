---
layout: post
title: "Jekyll with fenced code blocks"
categories:
  - tips/jekyll
tags: jekyll, markdown, redcarpet
date: 2015-01-04
---

While hacking up some markdown files to use under Jekyll I hit a weird
issue where code blocks written with triple ticks (aka fenced code blocks)
wouldn't render correctly.

When writing markdown, I like to express code blocks using the
[fenced-code-blocks](https://help.github.com/articles/github-flavored-markdown/#fenced-code-blocks)
syntax. I'm just getting up to speed with using Jekyll and after reading their
documentation I found I could use their `highlight` liquid tag, but I just didn't
care for the look and feel of that. I'm just used to the fenced style, so I
wanted to use that.

If I did something like this, it would work:

```
    ```
    my code snippet
    ```
```
But doing this would result in the language getting included inside the code
block. Normally you'd see the language used as a guide for highlighting, and it
would not get actually output in the rendered content.

```
    ```console
    my code snippet
    ```
```

After a bit of digging and trial error I narrowed this down to the fact that
I was rendering with `kramdown`. There were some mentions of the fenced code
blocks on <http://jekyllrb.com/docs/configuration/> page, but it was not clear
to me what needed to happen. This is almost certainly a result of me being new
to Jekyll. I ended up determining that `Redcarpet` is an alternate renderer to
`kramdown`. So I added the following to my `_config.yml`:

```yaml
markdown: redcarpet
```

After making that change the fenced code blocks were now properly rendering
even with the language being specified.
