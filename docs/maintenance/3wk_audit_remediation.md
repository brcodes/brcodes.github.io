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
- Replaced placeholder `description:` with: `"Portfolio of Bryce Rogers, Ph.D. — computational scientist and developer with expertise in data science, modeling, and web development."`
- Removed `keywords:` field entirely — ignored by all major search engines; placeholder text was worse than omitting it.

**`_includes/head.html`**
- Removed `<meta name="keywords">` tag — no field to reference and no SEO value.

### Notes
- Description now appears in Google search result snippets and the RSS feed subtitle via `feed.xml`.
- Intentionally not keyword-optimized; written to legitimize the site without targeting search ranking.
