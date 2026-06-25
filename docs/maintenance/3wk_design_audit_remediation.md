# Remediation Plan
_Addresses gaps identified in [3wk_postclean_design_audit.md](3wk_postclean_design_audit.md)_

---

## Item 1 — Bootstrap 3 + jQuery migration to Bootstrap 5

**Why it's large:** Bootstrap 3 → 5 is not a drop-in swap. The navbar, modal, and carousel markup all changed structurally. jQuery is used throughout `freelancer.js`, the inline slideshow script in `js.html`, and `jqBootstrapValidation.js` — all need replacement.

### Step 1.1 — Swap CSS and JS bundle references
- In `_includes/head.html`: replace the Bootstrap 3 `style.css` link with Bootstrap 5 CDN (or local bundle).
- In `_includes/js.html`: remove `jquery-1.11.0.js`, `bootstrap.min.js`, `jquery.easing.min.js`, `jqBootstrapValidation.js`. Add Bootstrap 5 bundle (`bootstrap.bundle.min.js`, which includes Popper).
- Remove the IE8 conditional comment shims (`html5shiv`, `Respond.js`) from `head.html` — they're dead code.

### Step 1.2 — Update navbar markup (`_includes/nav.html`)
BS3 → BS5 class/attribute changes:
- `navbar-default` → `navbar-light bg-white` (or `navbar-dark bg-primary`)
- `navbar-header` div → remove; brand link moves directly into `navbar`
- `navbar-toggle` button → `navbar-toggler`; `data-toggle` → `data-bs-toggle`; `data-target` → `data-bs-target`; `icon-bar` spans → `navbar-toggler-icon` span
- `collapse navbar-collapse` div: `data-toggle`/`data-target` not needed; keep id
- `.navbar-nav.navbar-right` → `ms-auto` utility class on the `ul`
- ScrollSpy: `data-spy` / `data-target` attributes → `data-bs-spy` / `data-bs-target` on `<body>`

### Step 1.3 — Update modal markup (`_includes/modals.html`)
BS3 → BS5 structural changes:
- Wrap `modal-content` in a new `modal-dialog` div (BS3 omits this wrapper at the outer level)
- `data-dismiss="modal"` → `data-bs-dismiss="modal"` on close button
- Carousel inside modal: `data-ride="carousel"` → `data-bs-ride="carousel"`; `data-interval` → `data-bs-interval`; `data-pause` → `data-bs-pause`; `data-wrap` → `data-bs-wrap`
- Trigger links: `data-toggle="modal"` → `data-bs-toggle="modal"`; `data-target` → `data-bs-target`

### Step 1.4 — Update carousel markup (`_includes/modals.html`)
- `.item` → `.carousel-item`
- `.carousel-control.left` / `.right` → `.carousel-control-prev` / `.carousel-control-next`
- `data-slide="prev/next"` → `data-bs-slide="prev/next"`
- `data-target` → `data-bs-target`
- Carousel indicator `data-target` / `data-slide-to` → `data-bs-target` / `data-bs-slide-to`

### Step 1.5 — Update grid/utility classes across all `_includes/`
- `col-xs-12` → `col-12` (BS5 dropped the `xs` infix)
- `col-lg-offset-2` → `offset-lg-2`
- `btn-success` / `btn-outline` — `btn-outline` was a custom class; verify it still exists or migrate to `btn-outline-success`
- `text-center` — still valid in BS5, no change needed

### Step 1.6 — Replace jQuery smooth scroll (`js/freelancer.js`)
- Remove `.page-scroll a` click handler and the ScrollSpy freeze patch.
- Add `scroll-behavior: smooth;` to `html` in `main.css`.
- BS5's ScrollSpy works without jQuery: initialize with `new bootstrap.ScrollSpy(document.body, { target: '#bs-example-navbar-collapse-1' })` or via `data-bs-spy` attribute.
- Navbar shrink on scroll: replace `$(window).scroll(...)` with a `window.addEventListener('scroll', ...)` vanilla handler toggling the `.navbar-shrink` class.

### Step 1.7 — Replace inline slideshow script (`_includes/js.html`)
- The existing timer script uses `$()` throughout. Rewrite using `document.querySelectorAll`, `classList`, and `addEventListener` — logic is the same, no library needed.

### Step 1.8 — Replace form validation (`contact.html` + `js/`)
- Remove `jqBootstrapValidation.js` and `contact_me.js` jQuery dependencies.
- The contact form currently has `novalidate` set. Either:
  - Remove `novalidate` and rely on native HTML5 validation (simplest), or
  - Use the Constraint Validation API (`form.checkValidity()`, `input.setCustomValidity()`) in a small vanilla JS block.

### Step 1.9 — Smoke test all breakpoints and interactions
- Navbar collapse open/close, scroll-to-section, navbar shrink
- Portfolio card hover captions
- Modal open/close, carousel next/prev, slideshow auto-advance
- Mobile (< 768px), tablet (768–991px), desktop (≥ 1200px)

---

## Item 2 — Fix placeholder SEO copy in `_config.yml`

**Effort: ~10 minutes.**

- Replace `description:` value with a real 1–2 sentence bio (this appears verbatim in Google search results and the RSS feed).
- Replace `keywords:` value with relevant terms — or delete the field entirely (major search engines ignore it; keeping placeholder text is worse than omitting it).
- While here: verify that the `color.primary` YAML values don't accidentally include the inline comment text as part of the hex string (e.g., `18bc9c #80B3FF` — the ` #80B3FF` portion may be parsed as part of the value by Jekyll's YAML parser; it should be on a separate comment line).

---

## Item 3 — Add Open Graph and Twitter Card meta tags

**Effort: ~30 minutes. One file: `_includes/head.html`.**

Add the following block after the existing `<meta name="description">` tag:

```html
<!-- Open Graph -->
<meta property="og:type"        content="website">
<meta property="og:url"         content="{{ page.url | absolute_url }}">
<meta property="og:title"       content="{{ site.title }}">
<meta property="og:description" content="{{ site.description }}">
<meta property="og:image"       content="{{ '/img/profile.jpg' | absolute_url }}">

<!-- Twitter Card -->
<meta name="twitter:card"        content="summary_large_image">
<meta name="twitter:title"       content="{{ site.title }}">
<meta name="twitter:description" content="{{ site.description }}">
<meta name="twitter:image"       content="{{ '/img/profile.jpg' | absolute_url }}">
```

Notes:
- `og:image` should be at least 1200×630px for LinkedIn/Facebook previews; check whether `profile.jpg` meets that or supply a dedicated share image.
- Validate with the [LinkedIn Post Inspector](https://www.linkedin.com/post-inspector/) and [Twitter Card Validator](https://cards-dev.twitter.com/validator) after deploying.

---

## Item 4 — Add a favicon

**Effort: ~20 minutes.**

1. Generate a favicon set from a source image (logo, monogram, or cropped profile photo) using a tool like [favicon.io](https://favicon.io) or [RealFaviconGenerator](https://realfavicongenerator.net). Output: `favicon.ico`, `favicon-32x32.png`, `favicon-16x16.png`, `apple-touch-icon.png`, optionally a `site.webmanifest`.
2. Place files in the repo root (they'll be copied to `_site/` by Jekyll).
3. Add to `_includes/head.html` inside `<head>`:

```html
<link rel="icon" type="image/x-icon"   href="{{ '/favicon.ico' | relative_url }}">
<link rel="icon" type="image/png" sizes="32x32" href="{{ '/favicon-32x32.png' | relative_url }}">
<link rel="icon" type="image/png" sizes="16x16" href="{{ '/favicon-16x16.png' | relative_url }}">
<link rel="apple-touch-icon" sizes="180x180"    href="{{ '/apple-touch-icon.png' | relative_url }}">
```

---

## Suggested Order

| # | Item | Effort | Risk |
|---|------|--------|------|
| 1 | Fix `_config.yml` SEO copy | Trivial | None |
| 2 | Add favicon | Low | None |
| 3 | Add Open Graph tags | Low | None |
| 4 | BS5 migration (Steps 1.1–1.9) | High | High — test thoroughly |

Do items 1–3 first: they're independent, shippable immediately, and visibly improve the portfolio with no breakage risk. The BS5 migration is the most impactful long-term but should be done on a branch and tested end-to-end before merging.

---

## Remediation Step 1 (Address Item 2: Fix placeholder SEO copy in `_config.yml`)

**Status: Complete**

### Changes made

**`_config.yml`**
- Replaced placeholder `description:` with: `"Portfolio of Bryce Rogers, Ph.D. — computational scientist and developer with experience in data science, modeling, and web development."`
- Removed `keywords:` field entirely — ignored by all major search engines; placeholder text was worse than omitting it.

**`_includes/head.html`**
- Removed `<meta name="keywords">` tag — no field to reference and no SEO value.

### Notes
- Description now appears in Google search result snippets and the RSS feed subtitle via `feed.xml`.
- Intentionally not keyword-optimized; written to legitimize the site without targeting search ranking.

---

## Remediation Step 2 (Address Item 4: Add a favicon)

**Status: Complete**

### Changes made

**New files in repo root (Jekyll copies these to `_site/` on build)**
- `favicon.svg` — source vector, 32×32 viewBox. Design: white filled circle; teal (`#18bc9c`) inner ring border (stroke at r=14.5, width=3, inset — does not extend circle boundary); dark blue (`#2c3e50`) Christian cross. Vertical arm: 6px wide, top corners rounded (rx=0.5), base curved to match the circle's arc geometry (SVG arc A 16,16). Horizontal bar: 20px wide × 6px tall, rounded ends (rx=0.5), positioned so all three free arm extents (left, right, top) are equal at 7px from the pole edge. Visual language matches the GitHub glyph button in the footer (white circle, dark glyph flush at bottom).
- `favicon-16x16.png` — rasterized at 16×16 via cairosvg
- `favicon-32x32.png` — rasterized at 32×32 via cairosvg
- `apple-touch-icon.png` — rasterized at 180×180 via cairosvg (iOS home screen)
- `favicon.ico` — multi-size ICO (16×16 + 32×32) via Pillow; fallback for older browsers

**`_includes/head.html`**
- Added five `<link>` tags: `.ico` fallback, two PNG sizes, Apple touch icon, and SVG favicon (preferred by modern browsers).

### Notes
- SVG favicon is listed last so modern browsers use it; older browsers fall back to `.ico`.
- Primary color `#18bc9c` sourced directly from `_config.yml` `color.primary`.

---

## Remediation Step 3 (Address Item 3: Add Open Graph and Twitter Card meta tags)

**Status: Complete**

### Changes made

**`_includes/head.html`**
- Added Open Graph block (`og:type`, `og:url`, `og:title`, `og:description`, `og:image`, `og:image:width`, `og:image:height`) after the `<meta name="description">` tag.
- Added Twitter Card block (`twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`).

### Notes
- Image used: `img/profile.jpg` (900×675). Not the ideal 1200×630 LinkedIn spec; platforms will letterbox/crop slightly. Explicit width/height tags added so platforms skip a prefetch request.
- To upgrade: supply a dedicated 1200×630 share image and update the `og:image` path and dimension tags.
- **To verify after deploy:** paste `https://brcodes.github.io` into [opengraph.xyz](https://www.opengraph.xyz) or the [LinkedIn Post Inspector](https://www.linkedin.com/post-inspector/). Local (`127.0.0.1`) is not reachable by these tools. Pre-deploy check: `grep -A1 "og:" _site/index.html` confirms Jekyll rendered the Liquid tags correctly.

---

## Remediation Step 4 (Address Item 1, Step 1.1: Swap CSS and JS bundle references)

**Status: Complete**

### Updated plan

Original plan description was inaccurate about CSS loading. Corrected architecture and execution:

- Bootstrap CSS was **not** a standalone CDN link — it was compiled into `style.css` via a Jekyll pipeline: `_layouts/style.css` concatenated `_includes/css/bootstrap.min.css` (Bootswatch Flatly v3.2.0) + `_includes/css/main.css`. The pipeline was changed to drop Bootstrap from compilation and load BS5 from CDN instead.
- **jQuery kept** — `freelancer.js` and the inline slideshow script still depend on it; removal is deferred to Steps 1.6/1.7.
- **`jqBootstrapValidation.js` kept** — removal deferred to Step 1.8.
- **Expected state after this step:** site visually broken (BS5 CSS + BS3 markup mismatch). Resolved in Steps 1.2–1.5.

### Changes made

**`_layouts/style.css`**
- Removed `{% include css/bootstrap.min.css %}` — `style.css` now compiles only `main.css`

**`_includes/head.html`**
- Added Bootstrap 5 CDN CSS link (`cdn.jsdelivr.net/npm/bootstrap@5.3.3`) before `style.css`
- Removed IE8 `html5shiv` / `Respond.js` conditional comment shims

**`_includes/js.html`**
- Replaced local `bootstrap.min.js` (BS3) with Bootstrap 5 CDN bundle (`bootstrap.bundle.min.js`, includes Popper)
- Removed `jquery.easing.min.js` (to be replaced by `scroll-behavior: smooth` in Step 1.6)

**Verification suite**
- `test/3wk_design_audit_remediation/bs5mig_1_1.rb` — 6-check TAP verification script
- `test/3wk_design_audit_remediation/bs5mig_1_1.tap` — TAP output file

### Notes
- **Results: 6/6 checks passed**
  - Jekyll build succeeds
  - Bootstrap 5 CDN CSS link present in `_site/index.html`
  - Bootstrap 3 local JS bundle absent from `_site/index.html`
  - jQuery Easing plugin absent from `_site/index.html`
  - IE8 html5shiv shim absent from `_site/index.html`
  - Bootswatch source not compiled into `_site/style.css`
- Full TAP output: `test/3wk_design_audit_remediation/bs5mig_1_1.tap`

---

## Remediation Step 5 (Address Item 1, Step 1.2: Update navbar markup)

**Status: Complete** _(plan audited and corrected before finalising)_

### Updated plan

BS3 navbar structure had an outer `navbar-header` wrapper div, `navbar-toggle` button with `data-toggle`/`data-target`, and three `icon-bar` spans. BS5 eliminates the wrapper, uses `navbar-toggler` with `data-bs-*` attributes, and a single `navbar-toggler-icon` span. ScrollSpy moves from JS initialization to `data-bs-spy` on `<body>`.

**Corrections vs. original plan (caught during audit):**
- Original plan said `navbar-default` → `navbar-light bg-white`. Both were wrong: the BS3 Bootswatch theme set `.navbar-default { background-color: #{{ site.color.secondary }} }` (dark blue `#2c3e50`) with white text. Removing BS3's CSS in step 1.1 left the navbar with no background at all. Correct BS5 equivalent is `navbar-dark` (white toggler icon) with the background ported into `main.css`. `navbar-light` would have rendered a dark toggler on a dark background.
- Original plan omitted `navbar-expand-md` — required in BS5 to control the responsive collapse breakpoint; without it the navbar never expands on desktop.
- Original plan omitted `nav-item` / `nav-link` classes on `<li>` / `<a>` — required for BS5 nav styling.
- Keeping `navbar-fixed-top` alongside `fixed-top` not mentioned — necessary for main.css scroll-shrink styles that still target `.navbar-fixed-top`.

### Changes made

**`_includes/nav.html`**
- `navbar-default` → `navbar-dark navbar-expand-md fixed-top` (+ retained `navbar-fixed-top` for custom CSS)
- Removed `navbar-header` wrapper div
- `navbar-toggle` → `navbar-toggler`; `data-toggle` → `data-bs-toggle`; `data-target` → `data-bs-target`
- Three `icon-bar` spans → single `navbar-toggler-icon` span
- Added `aria-controls`, `aria-expanded`, `aria-label` to toggler button
- `navbar-right` removed; `ms-auto` added to `<ul>`
- `<li>` elements: added `nav-item` class; `<a>` elements: added `nav-link` class
- Removed hidden `<li><a href="#page-top">` ScrollSpy placeholder

**`_includes/css/main.css`**
- Added `background-color: #{{ site.color.secondary }}` to `.navbar` rule — ports the dark blue navbar background that was previously provided by BS3's `.navbar-default` rule (now gone after step 1.1)

**`_layouts/default.html`**
- Added `data-bs-spy="scroll"`, `data-bs-target="#bs-example-navbar-collapse-1"`, `data-bs-offset="80"` to `<body>` tag

**Verification suite**
- `test/3wk_design_audit_remediation/bs5mig_1_2.rb` — 10-check TAP verification script (updated to include `navbar-dark` check)
- `test/3wk_design_audit_remediation/bs5mig_1_2.tap` — TAP output file

### Notes
- **Results: 10/10 checks passed**
  - Jekyll build succeeds
  - BS3 `navbar-default` class absent from `<nav>`
  - BS5 `navbar-dark` class present (white toggler icon, correct for dark background)
  - BS5 `fixed-top` class present on `<nav>`
  - BS5 `navbar-toggler` button present
  - `data-bs-toggle="collapse"` present on toggler button
  - `navbar-toggler-icon` span present
  - `ms-auto` class present on nav `<ul>`
  - `data-bs-spy="scroll"` on `<body>`
  - BS3 `navbar-header` wrapper div absent
- Full TAP output: `test/3wk_design_audit_remediation/bs5mig_1_2.tap`

---

## Remediation Step 6 (Address Item 1, Step 1.3: Update modal markup)

**Status: Complete** _(plan audited before implementation)_

### Updated plan

Original plan said "BS3 omits [the modal-dialog] wrapper at the outer level" — corrected: BS3 had the wrapper but this theme's custom markup skipped it entirely. Other plan items were accurate.

**Corrections and additions vs. original plan:**
- `role="dialog"` removed from outer `.portfolio-modal` div — BS5 sets it programmatically via JS; leaving it causes duplicate role conflicts.
- `btn-default` → `btn-secondary` — `btn-default` does not exist in BS5; plan did not mention this but it's in the same file.
- Carousel `.item` → `.carousel-item` and `.carousel-control` changes deliberately left for Step 1.4 per plan scope.
- `data-pause` and `data-wrap` replacements confirmed necessary (slideshow carousel only).

### Changes made

**`_includes/modals.html`**
- Added `<div class="modal-dialog">` wrapper between `.portfolio-modal` and `.modal-content`; added matching closing `</div>`
- Removed `role="dialog"` from outer `.portfolio-modal` div
- `data-dismiss="modal"` → `data-bs-dismiss="modal"` on `.close-modal` div and close button
- Slideshow carousel: `data-ride` → `data-bs-ride`; `data-interval` → `data-bs-interval`; `data-pause` → `data-bs-pause`; `data-wrap` → `data-bs-wrap`
- Click-through carousel: `data-ride` → `data-bs-ride`; `data-interval` → `data-bs-interval`
- `btn btn-default` → `btn btn-secondary` on modal close button

**`_includes/portfolio_grid.html`**
- Already updated with `data-bs-toggle="modal"` and `data-bs-target` on portfolio card links (pre-existing on this branch) ✅

**Verification suite**
- `test/3wk_design_audit_remediation/bs5mig_1_3.rb` — 10-check TAP verification script
- `test/3wk_design_audit_remediation/bs5mig_1_3.tap` — TAP output file

### Notes
- **Results: 10/10 checks passed**
  - Jekyll build succeeds
  - `modal-dialog` wrapper present inside `.portfolio-modal`
  - `modal-content` present inside `modal-dialog`
  - BS3 `data-dismiss` absent
  - `data-bs-dismiss="modal"` present on close controls
  - BS3 `data-ride` absent
  - `data-bs-ride` present on carousels
  - BS3 `data-interval` absent
  - `role="dialog"` absent from outer `.portfolio-modal` div
  - BS3 `btn-default` absent from modal close button
- Full TAP output: `test/3wk_design_audit_remediation/bs5mig_1_3.tap`
