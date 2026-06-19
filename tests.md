# Test Suite

Run with `bundle exec rake test`. This executes three sequential stages.

---

## Stages

- **`rake test:build`** — Jekyll build (`jekyll build`); fails fast if the site cannot compile
- **`rake test:site`** — Minitest regression suite against the generated HTML (`test/site_regression_test.rb`)
- **`rake test:links`** — HTMLProofer internal link and asset validation on `_site/`

---

## Regression Tests (`test/site_regression_test.rb`)

### 1. Build Artifacts
- `_site/index.html` is generated
- `_site/style.css` is generated
- Core JS assets exist: `jquery`, `bootstrap.min`, `freelancer`, `jquery.easing.min`
- `_site/feed.xml` exists and parses as valid XML

### 2. Head / SEO
- `_config.yml` defines non-empty `title`, `url`, and `email`
- `<title>` text includes `site.title` from config
- `<meta charset>` is `utf-8`
- `<meta name="viewport">` is present and includes `width=device-width`
- `<meta name="description">` is present and non-empty
- `<link rel="canonical">` is present with an absolute URL
- RSS `<link rel="alternate">` is present in `<head>`
- `style.css` is referenced via `<link rel="stylesheet">`
- Font Awesome stylesheet is **not** loaded (inline SVG icons are used instead)

### 3. Navigation
- Sections `#portfolio`, `#about`, and `#contact` all exist in the document
- Nav links include `#portfolio`, `#about`, and `#contact`
- `.navbar-brand` links to `#page-top`

### 4. Portfolio Grid
- Card count matches the number of posts with a `grid-position` front matter key
- No two posts share the same `grid-position` value
- Every grid-positioned post defines `grid-position`, `card-title`, and `alt` in front matter
- Portfolio images have `loading=lazy` and `decoding=async`
- Portfolio images have a non-empty `alt` attribute
- Portfolio card links have `data-toggle="modal"`

### 5. Portfolio Modals
- A `#portfolioModal-{N}` element exists for every post with `grid-position: N`
- Each modal has `tabindex` and `role="dialog"`
- Each modal contains a non-empty `<h2>` title
- Each modal has a `.close-modal[data-dismiss="modal"]` close button

### 6. Performance
- Profile image has `decoding=async`, `fetchpriority=high`, `loading=eager`, and explicit `width`/`height`
- Core scripts (`jquery`, `bootstrap.min`, `jquery.easing.min`, `freelancer`) use the `defer` attribute

### 7. Contact
- `#contact` section contains a `mailto:` link or a `<form>`
- In `static` contact mode, `jqBootstrapValidation.js` and `contact_me.js` are **not** loaded

### 8. Footer
- Footer text includes the copyright name from `_config.yml`
- Every `.btn-social` link in the footer has a non-empty `aria-label`
- Footer contains at least one link to `github.com`
- Scroll-to-top button exists and links to `#page-top`

### 9. Accessibility
- Every `<img>` in the document has an `alt` attribute
- Decorative SVG icons inside `.btn-social` have `aria-hidden="true"`

---

## CI Usage

```sh
bundle exec rake test        # full pipeline
bundle exec rake test:build  # build only
bundle exec rake test:site   # regression tests only (runs build first)
bundle exec rake test:links  # HTMLProofer only (runs build first)
```
