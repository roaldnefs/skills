# Slide and component catalogue

Every slide is a `<section>` inside `<div id="stage">`. The stage is a fixed
1920×1080 canvas, scaled to the viewport, so all sizes are in canvas pixels.
The content area runs from 160 px to 1760 px horizontally and from 120 px to
920 px vertically. The logo and counter sit in the bottom 160 px.

`assets/template.html` has a working example of everything listed here.

## Slide variants (classes on `<section>`)

| Class | Use | Notes |
|---|---|---|
| `slide` | Standard content slide, dark text on white | Always present |
| `slide title` | Opening card | Extra top padding, icon instead of logo; each time it is shown, the text rises in and an accent rule draws under the h1 |
| `slide divider` | Section break | Flex-centred; `.kicker` becomes a large accent-coloured section number. Usually combined with `dark` |
| `slide dark` | Dark emphasis slide | Re-points `--ink`, `--muted`, `--accent`, `--line` and so on to light-on-dark |
| `slide dark quote` | Large pull-quote | `quote` also works on light; use `blockquote` + `cite` |
| `slide closing` | Final contact card | Same spacing as `title`, icon instead of logo |

Attributes:
- `data-auto="600"` on a section reveals its `.build` elements by themselves, one every N ms, as soon as the slide is shown. `→` and `←` take over.

## Text

```html
<div class="kicker">02 · Section name</div>   <!-- small accent label above the heading -->
<h1>Only on title, divider, closing</h1>
<h2>Slide heading</h2>
<h3>Sub-heading inside a column</h3>
<p class="sub">Large lead sentence (title slide)</p>
<p class="byline">Speaker — Role, Organisation</p>
<p class="small">Footnote or source line</p>
<span class="hl">key figure</span>            <!-- inverted highlight -->
<span class="illustrative">Illustrative data</span>  <!-- REQUIRED next to any unsourced number -->
```

Use the kicker to show where you are (`02 · What we did`). On dividers it holds only the number (`02`).

## Lists

```html
<ul>                           <!-- dot bullets in the accent colour -->
  <li class="build">One sentence each</li>
</ul>

<ol class="agenda">            <!-- 01, 02, 03… large agenda list -->
  <li class="build">Part one</li>
</ol>
```

Keep it to four or five bullets at most, each one line where possible.

## Stats row

```html
<div class="stats">            <!-- 3 equal columns; change grid-template-columns for 2 or 4 -->
  <div class="stat build"><span class="n">42%</span><span class="cap">What it measures · source</span></div>
</div>
```

## Two columns

```html
<div class="cols">             <!-- 1fr 1fr, 80px gap; override inline for other ratios -->
  <div>…</div>
  <div>…</div>
</div>
```

For a different ratio: `<div class="cols" style="grid-template-columns:1.4fr 1fr">`.

## Terminal panel

```html
<div class="term"><span class="b">$</span> <span class="w">command --flag</span>
<span class="d"># dim comment</span>
plain output line
</div>
```

`white-space:pre` applies, so line breaks inside the div are literal: do not indent the contents. Colours: `.b` blue (prompt), `.w` white (typed command), `.d` dim, default green. Keep it to 12 lines or fewer.

## Chart (inline SVG)

```html
<div class="chart">
  <svg viewBox="0 0 1600 640" role="img" aria-label="Describe the data in words">
    <g class="grid"><line x1="120" y1="530" x2="1560" y2="530"/></g>
    <g class="axis" text-anchor="end"><text x="90" y="538">0</text></g>
    <g class="bar"><path d="M300 530 V118 q0 -8 8 -8 h104 q8 0 8 8 V530 Z"><title>Label: value</title></path></g>
    <g class="val" text-anchor="middle"><text x="360" y="90">14</text></g>
  </svg>
</div>
```

Compute the bar geometry by hand: pick a baseline y, a pixel-per-unit scale and an even x spacing. Label only the values that matter. Always write an `aria-label` and a `<title>` per bar.

## Quote

```html
<section class="slide dark quote">
  <blockquote>The quotation.</blockquote>
  <cite>Name · Organisation</cite>
</section>
```

## Logo wall

```html
<div class="logos"><div>Logo 1</div>…</div>   <!-- 4-column grid of 180px tiles -->
```

Replace the text with `<img src="logo.svg" alt="Name" style="max-width:70%;max-height:60%">`.

## Table

```html
<table class="keys"><tr><td>Label</td><td>Value</td></tr></table>
```

`kbd` renders keyboard keys.

## Closing / contact

```html
<div class="contact">
  <div><span class="l">Web</span>example.com</div>
</div>
<a class="btn" href="…">Get in touch</a>        <!-- outline button -->
<a class="btn action" href="…">Sign up</a>     <!-- filled accent button -->
```

## Images

Photos and screenshots are ordinary files next to `index.html`, referenced by a
relative path: `<img src="photo.jpg" alt="…">`. Use `<img>`, not a CSS
`background-image`, because backgrounds can go missing when printed to PDF.
Never base64-encode a photo into the HTML.

A common pattern is a photo beside text:

```html
<div class="cols" style="grid-template-columns:1fr 1fr;align-items:center">
  <div><h2>Heading</h2><p>Text.</p></div>
  <img src="photo.jpg" alt="…" style="width:100%;height:700px;object-fit:cover;border-radius:4px">
</div>
```

If a layout repeats more than once, give it a class under `/* deck-specific */` instead of inline styles.

## Speaker notes

```html
<div class="s-notes"><p>What to say, in the speaker's voice.</p></div>
```

Put this as the last child of every section. Notes appear in an overlay when the presenter presses `N`. They never show on the slide or in the PDF.

## Builds

Add `class="build"` to any element to reveal it on the next `→`. Builds go in
document order. `↓` shows the whole slide at once. Advanced: a hidden marker
element with `class="build"` can drive styling through `:has()`, for example
`.slide:has(#step2.on) .diagram .b{opacity:1}`. Put such rules under
`/* deck-specific */`.
