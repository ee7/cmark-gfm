# cmark-gfm

A Nim wrapper for [libcmark-gfm][libcmark-gfm], which is an extended version of the C reference implementation of [CommonMark][commonmark].

GitHub Flavored Markdown (GFM) is the dialect of Markdown that, for example, GitHub supports for user content.
The [GFM specification][gfm-spec] is a strict superset of the [CommonMark specification][commonmark-spec].

There are five main extra features:

- [`tables`][ext-tables]
- [`tasklists`][ext-tasklists]
- [`strikethrough`][ext-strikethrough]
- [`autolinks`][ext-autolinks]
- [`tagfilter`][ext-tagfilter]

## Installation

This package includes a full copy of the `libcmark-gfm` dependency, which avoids problems with Nimble's handling of git submodules.
Therefore, you don't need to install `libcmark-gfm` yourself.

If you do have `libcmark-gfm` installed elsewhere on your system, this wrapper intentionally uses the in-repo version.

The wrapper currently uses `libcmark-gfm` version `0.29.0.gfm.13` (released on 2023-07-21).

## Usage

### High-level wrapper

The high-level wrapper currently has these functions, which parse a string as GitHub Flavored Markdown and return a string:

- `toHtml`
- `toXml`
- `toMan`
- `toCommonmark`
- `toPlaintext`
- `toLatex`

These functions enable the GFM extensions by default.

For example, to render a string (with GFM-specific syntax) as an HTML fragment:

```nim
import cmark_gfm

const markdown = """
# Heading

Hello, ~~there~~world!

See https://example.com for more information.

- [ ] foo
- [x] bar
"""

echo toHtml(markdown)
```

which produces the output:

```html
<h1>Heading</h1>
<p>Hello, <del>there</del>world!</p>
<p>See <a href="https://example.com">https://example.com</a> for more information.</p>
<ul>
<li><input type="checkbox" disabled="" /> foo</li>
<li><input type="checkbox" checked="" disabled="" /> bar</li>
</ul>
```

### ABI wrapper

The low-level ABI wrapper `src/cmark_gfm/abi.nim` wraps every function from the upstream `cmark-gfm.h` file apart from `cmark_parse_file`.

An example of using that wrapper to render an HTML fragment:

```nim
import cmark_gfm/abi

const markdown = cstring"""
# Heading

Hello, world!
"""

let html = cmarkMarkdownToHtml(markdown, markdown.len.csize_t, 0.cint)
echo html
c_free(html)
```

which produces the output:

```html
<h1>Heading</h1>
<p>Hello, world!</p>
```

Note that this **doesn't** include the GFM-specific extensions.

[commonmark]: https://commonmark.org/
[commonmark-spec]: https://spec.commonmark.org/
[ext-tables]: https://github.github.com/gfm/#tables-extension-
[ext-tasklists]: https://github.github.com/gfm/#task-list-items-extension-
[ext-strikethrough]: https://github.github.com/gfm/#strikethrough-extension-
[ext-autolinks]: https://github.github.com/gfm/#autolinks-extension-
[ext-tagfilter]: https://github.github.com/gfm/#disallowed-raw-html-extension-
[gfm-spec]: https://github.github.com/gfm/
[libcmark-gfm]: https://github.com/github/cmark-gfm
