# Web Design Assessment

## What's There

- **Static site generator (Jekyll)** — Content managed via Liquid templates across `_layouts/`, `_includes/`, and `_posts/`; no server-side rendering or database needed.
- **Single-page application layout** — All sections (hero, portfolio grid, bio, contact) live on one scrollable page with anchor-based navigation.
- **Bootstrap 3 grid** — Layout uses `.col-lg-*`, `.col-md-*`, `.col-xs-*` column classes throughout.
- **Responsive design with media queries** — Multiple breakpoints (480, 640, 700, 768, 960, 992, 1200px) adjust layout, type, and nav across device widths.
- **Fixed/sticky navbar with scroll-shrink** — Navbar is pinned to the top and shrinks on scroll via a JS-toggled class.
- **Hamburger menu / navbar collapse** — Bootstrap's collapsible nav triggers on mobile viewports.
- **Hero section** — Full-width header with circular profile photo, name, and tagline.
- **CSS custom properties (design tokens)** — Extensively uses `--variable-name` for spacing, type scale, and layout measurements; centralizes design decisions.
- **Fluid typography with `clamp()`** — Font sizes for nav, body, and headings use `clamp()` to scale smoothly between breakpoints.
- **Google Fonts (Montserrat + Lato)** — Two-typeface system: geometric sans-serif for headings, humanist for body; loaded via CDN with `display=swap`.
- **Resource hints** — `<link rel="preconnect">` for Google Fonts and `<link rel="preload">` for the profile image improve perceived load time.
- **Image performance attributes** — Profile photo has `fetchpriority="high"`; portfolio thumbnails use `loading="lazy"` and `decoding="async"`.
- **Flexbox portfolio grid** — Custom `portfolio-flex-row` / `portfolio-flex-item` layout with `flex-flow: row wrap` for responsive column counts.
- **Hover caption overlay** — Portfolio cards reveal a title caption on hover via CSS transitions.
- **Modal overlays for portfolio items** — Bootstrap modals display project detail on card click.
- **Image carousel inside modals** — Bootstrap carousel with two configurable modes: `slideshow` (auto-advance) and `click-through` (manual).
- **Data-driven content via YAML front matter** — Portfolio projects are configured entirely in Markdown front matter (grid position, thumbnail, carousel mode, colors, descriptions); no per-project HTML to edit.
- **Smooth scroll with easing** — jQuery + jQuery Easing plugin animates nav link scrolling with `easeInOutExpo`.
- **ScrollSpy with flicker fix** — Bootstrap ScrollSpy highlights the active nav item; a custom JS patch prevents mid-scroll highlight flickering.
- **Contact form with client-side validation** — jqBootstrapValidation provides inline error messages before submission.
- **Inline SVG icons** — GitHub social icon and resume download button use inline SVG (resolution-independent, styleable with CSS).
- **ARIA labels / accessibility basics** — Social links have `aria-label`, decorative icons have `aria-hidden="true"`, `.sr-only` text present on nav toggle.
- **RSS feed** — `feed.xml` provides content syndication.
- **SEO meta tags** — `<meta name="description">`, canonical URL tag, and Google/Bing webmaster verification fields are wired in.
- **Theming via `_config.yml`** — Primary/secondary brand colors, social links, site title, and copy are centralized in config rather than scattered across templates.

---

## Needs Improvement

- **Bootstrap 3 is end-of-life (2019)** — Bootstrap 5 dropped jQuery, added utility classes, and uses a modern grid; Bootstrap 3 is a liability for a portfolio targeting current employers.
- **jQuery dependency** — Used almost entirely for smooth scroll and modals; vanilla JS `scroll-behavior: smooth` and the native `<dialog>` element (or CSS-only modals) would eliminate the ~30KB dependency.
- **Placeholder content in `_config.yml`** — `description` is still `"Write an awesome description for your new site here"` and `keywords` is `"your keywords, separated by commas"` — these appear verbatim in Google search results.
- **No Open Graph or Twitter Card meta tags** — Links shared on LinkedIn, Twitter/X, or Slack will not generate a preview card with image and description.
- **IE8 conditional shims** — `html5shiv` and `Respond.js` conditional comments are dead code; IE8 market share is effectively zero and this adds visual noise to the source.
- **Non-descriptive `alt` on profile photo** — `alt="profile-pic"` describes the element type, not the content; should be the person's name or a brief description.
- **`<meta name="keywords">`** — Ignored by Google since 2009 and by all major search engines; contributes nothing.
- **No favicon** — The site has no `<link rel="icon">` configured; the browser tab shows a blank icon.
- **Color comment syntax in `_config.yml`** — Lines like `primary: 18bc9c #80B3FF` put an inline comment on the same line as the YAML value without a `#` separator on its own — depending on the YAML parser, this may be treated as part of the value string. Worth verifying the rendered color is correct.
