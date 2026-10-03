# Theming a deck

The template ships a light, neutral theme. Any brand is applied by changing the
tokens in `:root` and, if needed, appending CSS under `/* deck-specific */`.
The engine CSS above that heading and the `<script>` are never edited.

## Tokens

| Token | Role | Default |
|---|---|---|
| `--primary` | Text colour on light slides; background of `.dark` slides | `#1F2A44` |
| `--black` | Page background around the stage | `#111827` |
| `--dark` | Terminal background | `#1E2533` |
| `--grey` | Muted text on light slides | `#5B6475` |
| `--light` | Panel background (stats, charts) on light slides | `#F4F6F9` |
| `--white` | Slide background | `#FFFFFF` |
| `--action` | Accent: bullets, numbers, kickers, buttons, bars | `#2F5DA8` |
| `--action-dark` | Accent on `.dark` slides, a lighter tint of `--action` | `#9DB8E8` |
| `--line` / `--rule` | Hairlines and dashed borders on light slides | `--primary` at 12 % / 45 % alpha |
| `--font-display` / `--font-body` / `--font-mono` | Font stacks | Source Serif 4 / Source Sans 3 / Source Code Pro |
| `--logo` / `--icon` | Logo on light slides (bottom-left) / icon on title and closing | `none` |
| `--logo-dark` / `--icon-dark` | The same, on `.dark` slides | `none` |
| `--watermark` / `--watermark-dark` | Optional large low-contrast mark, bottom-right | `none` |

`--ink`, `--muted`, `--accent` and `--panel` are derived from the tokens above
and re-pointed by `.dark`; don't set them in `:root`.

When you change `--primary`, update `--line` and `--rule` to match: they are
the rgb of `--primary` at 12 % and 45 % alpha.

Check contrast: `--action` and `--grey` on `--white`, and `--action-dark` on
`--primary`, all need to stay readable (aim for WCAG AA, 4.5:1 for body text).

## Fonts

Use **only fonts whose licence allows embedding and redistribution**, such as
SIL Open Font License faces from Google Fonts. Never name a commercial typeface,
not even as a fallback. Fallbacks are generic CSS families only (`ui-serif`, `serif`,
`system-ui`, `sans-serif`, `ui-monospace`, `monospace`), so the deck names no
operating-system font.

To swap fonts:
1. Edit the Google Fonts `<link>` in `<head>` (`family=Name:wght@300;400;600;700`).
2. Set the token: `--font-display:"Name",system-ui,sans-serif;`

The deck must still look acceptable offline, when only the fallback renders.

## Logos

Logos are inline SVG data-URIs in CSS variables, so the deck stays a single
file. Supply a dark version for light slides and a white version for `.dark` ones.
Use the full lock-up for `--logo` (fits 260×60) and the square mark for `--icon`
(60×60).

To turn an SVG file into a token value:
1. Remove the `<?xml …?>` prolog, comments and editor metadata.
2. Collapse all whitespace to single spaces, and change double quotes to single quotes.
3. Percent-encode `%` (`%25`) first, then at least `#` (`%23`), `<` (`%3C`) and `>` (`%3E`).
4. Wrap it as `url("data:image/svg+xml,…")`.

Set it as `--logo:url("data:image/svg+xml,…");`. Keep each logo under
about 10 KB: strip editor metadata and round coordinates first. For a colour
variant, change the `fill` in the SVG before encoding.

Larger logos (above 10 KB) can stay as files next to the deck:
`--logo:url("logo.svg")`.

## Favicon

The `<link rel="icon">` is a tiny inline SVG: a rounded square in the accent colour. Change its `fill` (`%23` = `#`) to match, or point it at a file next to the deck.

## Going further: a skin

For a brand that needs more than colours (rounded panels, uppercase
headings, no title animation, a different logo position), append overrides under
`/* deck-specific */`. Examples:

```css
/* uppercase headings in the body font */
h1,h2{font-family:var(--font-body);text-transform:uppercase;letter-spacing:.01em}
/* no animation on the title */
.slide.title *,.slide.title *::after{animation:none!important}
/* rounded panels and pill buttons */
.stat,.term,.chart{border-radius:28px}
.btn{border-radius:999px}
/* no accent rule under the title */
.slide.title h1::after{display:none}
```

Override, don't fork: keep the engine CSS intact above the heading, so later
engine fixes can be copied in without merge pain.
