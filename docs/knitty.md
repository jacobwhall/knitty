# Knitty

Knitty is Atom/Hydrogen friendly CLI for [Knotr/Stitch](stitch.md): reproducible report generation tool via Jupyter, Pandoc and Markdown. Insert python code (or other Jupyter kernel code) to the Markdown document and have code's results in the output document. Exports to Jupyter notebook via [Notedown](notedown.md).

Modified versions of [Knotr/Stitch](stitch.md) by Tom Augspurger and [Notedown](notedown.md) by Aaron O'Leary are included in Knitty.


# Contents

* [Knitty usage](#knitty-usage)
* [Differences from original Stitch:](#differences-from-original-stitch)
1. [New interfaces](#1-new-interfaces)
    * [1.1 New command line interfaces][new_cli]
        * [pre-knitty](#pre-knitty)
        * [knitty](#knitty-cli)
        * [post-knitty](#post-knitty)
        * [knotedown](#knotedown)
        * [knotr](#knotr)
    * [1.2 Alternative settings placement][alt_settings]
    * [1.3 Support files with Atom/Hydrogen code cells][code_cells]
    * [1.4 Turn ON code cells mode](#14-turn-on-code-cells-mode)
    * [1.5 Other languages in code cells mode](#15-other-languages-in-code-cells-mode)
    * [1.6 Markdown in code cells mode](#16-markdown-in-code-cells-mode)
    * [1.7 Example files in code cells mode][code_cells_example]
2. [New code chunks options](#2-new-code-chunks-options)
    * [2.1 Original code chunk options](#21-original-code-chunk-options)
    * [2.2 Results Pandoc chunk option](#22-results-pandoc-chunk-option)
    * [2.3 Chunk keyword argument](#23-chunk-keyword-argument)
    * [2.4 Input keyword argument](#24-input-keyword-argument)
3. [New document options](#3-new-document-options)
    * [3.1 Original document options](#31-original-document-options)
    * [3.2 Disabled code chunks prompt prefixes](#32-disabled-code-chunks-prompt-prefixes)
    * [3.3 Languages / Kernels / Styles mappings in YAML metadata](#33-languages-kernels-styles-mappings-in-yaml-metadata)
    * [3.4 Match metadata option](#34-match-metadata-option)
4. [API description](#4-api-description)
5. [Known issues](#5-known-issues)
    * [5.1 No new line after Jupyter output](#51-no-new-line-after-jupyter-output)
    * [5.2 Pandoc-crossref labels move to the new line](#52-pandoc-crossref-labels-move-to-the-new-line)

[alt_settings]: #12-alternative-settings-placement
[new_cli]: #11-new-command-line-interfaces
[code_cells]: #13-support-files-with-atomhydrogen-code-cells
[code_cells_example]: #17-example-files-in-code-cells-mode


# Knitty usage

You can use Hydrogen/Knitty combo to write Markdown documents with Jupyter code chunks (you can use any Jupyter kernel). You can execute code chunks with Atom/Hydrogen right when writing the document and instantly see the results. Knitty helps to export the whole document to other format (html, pdf, output self-contained markdown).

* Write Markdown document: [1.2 Alternative settings placement][alt_settings]
* Write Atom/Hydrogen code cells document: [1.7 Example python file in code cells mode][code_cells_example]

Tip: see how to [install and use Hydrogen Atom package](hydrogen.md).


# Differences from original Stitch:

# 1. New interfaces

New interfaces are exclusive to Knitty.

## 1.1 New command line interfaces

### pre-knitty

`pre-knitty` - CLI app that reads from stdin and writes to stdout. Transforms markdown source code from Knitty format to Pandoc format (replaces Knitty-format code chunk options with Pandoc-format code chunk options).

* first argument is optional input file path (`pre-knitty` reads it's extension that is needed for [code cells][code_cells] mode).

```
Usage: pre-knitty [OPTIONS] [INPUT_FILE]

  A text filter that reads from stdin and writes to stdout. INPUT_FILE is
  optional but it helps to determine language and hence a Jupyter kernel.

  Settings that can be set in stdin OR in the --yaml file:

  ---
  comments-map:
    py: ['#', "'''", "'''", "\"\"\"", "\"\"\""]
    js: ["//", "/*", "*/"]
  ...

  1) Force set document default language name, 2) extenstion to get from
  `comments-map` (can be set in stdin metadata only):

  ---
  knitty-lang: 'py2'
  knitty-comments-ext: 'py'
  ...

Options:
  -y, --yaml PATH  yaml metadata file (wrapped in ---... like in pandoc) with
                   settings for pre-knitty.
  --help           Show this message and exit.
```


### knitty CLI

```
Usage: knitty [OPTIONS] [INPUT_FILE]

  Knitty is a Pandoc AST filter with options. It reads from stdin and writes
  to stdout. It accepts all possible pandoc options and two knitty-only
  options. INPUT_FILE is optional but it helps to auto-name Knitty data
  folder in some cases.

Options:
  -f, -r, --from, --read TEXT  Pandoc reader option. Specify input format.
  -o, --output TEXT            Pandoc writer option. Optional but it helps to
                               auto-name Knitty data folder in some cases.
  -w, -t, --write, --to TEXT   Pandoc writer option. Optional but it helps to
                               auto-name Knitty data folder in some cases.
                               Also the `-t` and `-o` options -> extension ->
                               passed to Stitch that uses it in: `if self.to
                               in ('latex', 'pdf', 'beamer')`.
  --standalone                 Pandoc writer option. Produce a standalone
                               document instead of fragment. The option is
                               added to `pandoc_extra_args` given to Stitch.
  --self-contained             Pandoc writer option. Store resources like
                               images inside document instead of external
                               files. The option is added to
                               `pandoc_extra_args` given to Stitch.
  --dir-name TEXT              Manually name Knitty data folder (instead of
                               default auto-naming).
  --to-ipynb                   Additionally run Pandoc filter that prepares
                               code blocks for md to ipynb conversion via
                               Notedown. Code blocks for cells should have
                               `input=True` key word attribute. Default value
                               can be set in metadata section like `input:
                               True`. Intended to be later used with
                               `post-knitty --to-ipynb`. Another match value for
                               knotedown can be set in metadata section like
                               `codecell-match-class: in`.
  --help                       Show this message and exit.
```

Examples:

```bash
export PYTHONIOENCODING=utf-8

input_file="doc.md"
metadata="metadata.yml"
reader_args=(-f markdown)
writer_args=(-t html --standalone --self-contained)

cat "${input_file}" | \
pre-knitty "${input_file}" --yaml "$metadata" | \
pandoc "${reader_args[@]}" -t json | \
knitty "${input_file}" "${reader_args[@]}" "${writer_args[@]}" | \
pandoc -f json "${writer_args[@]}" -o "${input_file}.html"
```

```bat
chcp 65001 > NUL
set PYTHONIOENCODING=utf-8

set input_file=doc.md
set metadata=metadata.yml
set reader_args=-f markdown
set writer_args=-t html --standalone --self-contained

type "%input_file%" | ^
pre-knitty "%input_file%" --yaml "%metadata%" | ^
pandoc %reader_args% -t json | ^
knitty "%input_file%" %reader_args% %writer_args% | ^
pandoc -f json %writer_args% -o "%input_file%.html"
```


### post-knitty

```
A text filter that reads from stdin and writes to stdout.
Converts to ipynb when `--to-ipynb` option or no options.

Converts Markdown document with specially marked code cells to ipynb
(together with global yaml metadata section).
Can use metadata option: `codecell-match-class: in`
(default or malformed fallback value is `in`)
that is a Pandoc class that marks Jupyter code cells.
If value is `''` (empty string) then all Markdown code cells would be
converted to Jupyter code cells.
```

Supports Pandoc metadata that is then set in notebook metadata. For example:

```yaml
---
kernelspec:
  display_name: Python 3
  language: python
  name: python3
...
```

```yaml
---
kernelspec:
  display_name: R
  language: R
  name: ir
...
```

Export to Jupyter notebook with cross-references (using [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref): [download](https://github.com/lierdakil/pandoc-crossref/releases)) and execute it:

```bash
export PYTHONIOENCODING=utf-8

input_file="doc.md"
metadata="metadata.yml"
reader_args=(-f markdown)
jupymd="markdown-bracketed_spans-fenced_divs-link_attributes-simple_tables\
-multiline_tables-grid_tables-pipe_tables-fenced_code_attributes\
-markdown_in_html_blocks-table_captions-smart"
writer_args=(-t "$jupymd" --standalone --self-contained --filter pandoc-crossref)

cat "${input_file}" | \
pre-knitty "${input_file}" --yaml "$metadata" | \
pandoc "${reader_args[@]}" -t json | \
knitty "${input_file}" "${reader_args[@]}" "${writer_args[@]}" --to-ipynb | \
pandoc -f json "${writer_args}" | \
post-knitty --to-ipynb | \
jupyter nbconvert --to notebook --execute --stdin --stdout > \
"${input_file}.ipynb"
```

(`--standalone --self-contained` are necessary for conversion, `--nomagic` is necessary for R kernel conversion, `$jupymd` is a Markdown flavor compatible with *pandoc-crossref* and with Jupyter markdown cells).


### knotedown

`knotedown` - [patched Notedown module](https://github.com/kiwi0fruit/notedown) by Aaron O'Leary (aaren) was added to Knitty and available via `knotedown` CLI - same API as in `notedown` CLI. Patched version supports Pandoc metadata that is then set in notebook metadata.


### knotr

`knotr` - [same CLI](https://kiwi0fruit.github.io/pystitch/index.html#usage) as `stitch` from original Stitch. It doesn't support most of Knitty new features.


## 1.2 Alternative settings placement

Alternative Knitty settings placement was added for GitHub flavored markdown (GFM) compatibility in Atom editor (**language-gfm** compatibility with working spell checking).

Standard Knitty options inside decorator (`python` will overwrite `py`):
`````python
Markdown text.

@{python, chunk1, echo=True}
```py
print('Hello!')
```

More markdown text.
`````

Language specified in the code chunk so the decorator has only keyword arguments:
`````python
@{chunk=chunk2, echo=True}
```python
print('Hello!')
```
`````

Standard RMarkdown-like Knotr/Stitch options also works:
`````python
```{python, chunk3, echo=True}
print('Hello!')
```
`````

Or simply:
`````python
```python
print('Hello!')
```
`````

**Please note** that Knitty converts Knitty-style and Stitch-style options (that are originally not supported by Pandoc parser) to Pandoc-style options.

Specifics:

* There can't be any white spaces between `@` and `{...}`. But there can be whitespace characters between <code>\`\`\`</code> and `{...}` (all whitespace characters except `\r` and `\n` actually).
* Chunk options arguments and keys should start with alphabetic characters or `_` and can contain alphanumeric characters, `-`, and `.` (but can't end with a `.`).  
* Key values may be put into `''` or `""` but should match the following regex:

```
"[^"]*"|'[^']*'|[^\s,{}"'][^\s,{}]*
```
* Please note that the following settings `@{ir, class=r}` are equivalent to `@{ir, r}` that is equivalent to <code>\`\`\`{.ir .r}</code> (this is because for Pandoc `class=c` attribute is the same as `.c` setting). So `r` would be a chunk name.


## 1.3 Support files with Atom/Hydrogen code cells

Added support for files with Atom/Hydrogen code cells (**.py** extension). You can split the file into code cells via in-line comments with `%%` (there **must** be space or new line after `%%`):
```py
# %% {chunk=chunk2, echo=False} comment text
...

#%% or without space between
...
```
(for python). Knitty will convert such python code cells to markdown code chunks and then convert to output format (md / html / pdf).

Such files for example can be edited in Atom/Hydrogen or in PyCharm.

**Code cells mode is language-agnostic so you can use any Jupyter kernel.**


## 1.4 Turn ON code cells mode

In order to tell Knitty that the file should be treated as raw code you should do the following:

* Set yaml settings that map language name (that can also be automatically taken from file extension) with comments specs (can be put to the exteranl file too: `pre-knitty --yaml file.yaml`):

```yaml
---
comments-map:
  py: ['#', "'''", "'''", "\"\"\"", "\"\"\""]
  js: ["//", "/*", "*/"]
...
```
(should be in pandoc-like format in between `---...`)

* Or the first line should start with 1-3 symbols of the in-line comment (except white spaces), then single white space or nothing, then `%%`, then single white space or end of line. So you actually tell Knitty what symbols are used as in-line comments. For python it would be `# %%` comments. But this way you can only specify in-line comments not block comments.

1) Force set document default language name, 2) extenstion to get from `comments-map` (can be set in stdin metadata only):

```yaml
---
knitty-lang: 'py2'
knitty-comments-ext: 'py'
...
```

Also you can specify Knitty settings: `# %% {python, echo=False}`. If no settings specified or no language specified - `# %% {echo=False}` - then the language would be the one specified in `knitty:` > `language:` metadata (see above), or the file extension, or Markdown (the last one depends on where there are block comments at the next line or not - see the next paragraph).


## 1.5 Other languages in code cells mode

You can insert code cells of other languages to the **.py** file with python main language: for example via `# %% {r}` or `# %% {markdown}` (actually this can be done with any language file not only Python). They optionally may be put inside block comments. In order to automatically remove such comments first you should specify block comments settings either in `knitty:` > `comments:` yaml in the document itself or in `--yaml` option of `pre-knitty` CLI (see previous section).

And ror example for Python to put code cell into block comments you need:

* right after `# %%` line the very next one line should start with `"""` (or `'''`) and the last non-whitespace characters before new line char and next `# %%` line should be `"""` (or `'''`). And the block comments should match. And there should not be the same block comments between them.


## 1.6 Markdown in code cells mode

Code cell can be in markdown as well. It's the `markdown` or `md` language. You can use them to define Knitty metadata.

If cell is block-commented **and** doesn't have language specified then it's a Markdown cell. 


## 1.7 Example files in code cells mode

Example file with language which comments are not in pandoctools settings. Like `file.rb`:

```rb
# %% this comments with `%%` is necessary
puts 0

# %%
puts 1
```


Example python file. Assuming you specified `pre-knitty --yaml <...>` or using pandoctools so you don't need the first line to be `# %%`:

````python
"""
---
kernels-map:
  r: ir
  py: python
...

# Markdown section title

Here is some markdown text.
"""


# %% {echo=False} `py` cell, language name is taken from file extension:
from IPython.display import Markdown
import math
import sugartex as stex
print('This was {py, echo=False} cell')


# %%

"""
Comment that stays after Knitty and would be a `py` code chunk
because it's not right after `# %%`
"""


# %% {r} R cell:
"""
x <- c(10, 20)
x[1]
"""


# %% Markdown cell with R code block:
"""
# Header

```r
x <- c(10, 20)
```
"""


# %%
Markdown(stex.pre(f'''

Another markdown text. Now with SugarTeX formula: ˎα^˱{math.pi:1.3f}˲ˎ.
It works because of the `Markdown` display option and `sugartex` Pandoc filter.
Acually `stex.pre` is redundant here but it is needed when the text is imported
or read from somewhere instead of being written in the same document.

'''))
````


# 2. New code chunks options

Note that default chunk options can be set in the document metadata section like:
```yaml
---
echo: False
...
```

````py
@{echo=True}
```py
pass  # this is echoed
```

```py
pass  # this is not echoed
```
````

## 2.1 Original code chunk options

See Knotr/Stitch code chunks options [here](https://kiwi0fruit.github.io/pystitch/api.html#chunk-options).

Notable options:

* `eval=True`, `eval=False`: whether to execute the code chunk. As well as all other chunk options, default for all chunks `eval` option can be set is yaml metadata section:

```yaml
---
eval: True
...
```


## 2.2 Results Pandoc chunk option

`results` code chunk option was modified:

* default is `results=default` (same as in the original Stitch),
* `results=pandoc`: same as `default` but plain text is parsed via Pandoc:
  - if the output is a stdout message that is not warning/error or if it has `'text/plain'` key.
  - Pandoc setings can be set like `{results='pandoc -f markdown-link_attributes --flag'}` (defaults are taken from knitty CLI).
  - Markdown, HTML and LaTeX outputs are also parsed by Pandoc (with appropriate settigns).
* `results=hide`: evaluate chunk but hide results (same as in the original Stitch).


## 2.3 Chunk keyword argument

Added `chunk=name` new keyword argument option. It's an alternative way to specify code chunk name (together with second positional argument. Keyword argument has a priority over it).

This option is exclusive to Knitty.

## 2.4 Input keyword argument

For `knitty` CLI flag `--to-ipynb` and for `knotedown` CLI flag `--match`, the code blocks for cells can have `input=True` (or `False`) key word attribute. Default value can be set in metadata section like
```yaml
---
input: True
...
```


# 3. New document options

## 3.1 Original document options

See Knotr/Stitch document options [here](https://kiwi0fruit.github.io/pystitch/api.html) (some of the options are chunk options actually).


## 3.2 Disabled code chunks prompt prefixes

Now code chunk prefixes are disabled by default. To enable them set it in the metadata section:

```yaml
---
use_prompt: True
...
```

If you specify `prompt` option for a code chunk then it would have a prompt even if it's disabled.


## 3.3 Languages / Kernels / Styles mappings in YAML metadata

Mappings to markdown YAML metadata are added:

* from **language names** to **Jupyter kernels names**
* from **language names** to **CSS classes names**
* **language names** are used in Stitch code blocks settings

For example:

```yaml
---
kernels-map:
  r: ir
  py2: python2
styles-map:
  py2: py
...
```

## 3.4 Match metadata option

For `knitty` CLI flag `--to-ipynb` and for `post-knitty` another class match value can be  set in metadata section like:
```yaml
---
codecell-match-class: in
...
```


# 4. API description

[`knitty.stitch.Stitch` class API description](https://kiwi0fruit.github.io/pystitch/api.html).


# 5. Known issues

## 5.1 No new line after Jupyter output

Sometimes R language output does not have new line after it (or may be other languages as well). So it might interfere with the next text. Adding

```html
<b></b>
```

below the code chunk fixes the problem.


## 5.2 Pandoc-crossref labels move to the new line

When you add formula labels for **pandoc-crossref** you should place them right after the formula (like `$$x=y+z$${#eq:1}` – no spaces). Otherwise when stitching from markdown to markdown labels would move to the next line and stop working.
