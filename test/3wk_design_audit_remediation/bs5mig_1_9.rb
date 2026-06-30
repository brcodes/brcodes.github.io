# frozen_string_literal: true
#
# Verification: Step 1.9 — Structural smoke test for all breakpoint interactions
#
# This test verifies the structural prerequisites that make each interaction
# work in a browser.  Visual/interactive verification must be done manually
# (see "Manual browser checklist" in the tap output notes below).
#
# Outputs TAP format to bs5mig_1_9.tap in the same directory.

require 'fileutils'
require 'nokogiri'

ROOT        = File.expand_path('../..', __dir__)
SITE_DIR    = File.join(ROOT, '_site')
INDEX_PATH  = File.join(SITE_DIR, 'index.html')
STYLE_PATH  = File.join(SITE_DIR, 'style.css')
FREELANCER  = File.join(ROOT, 'js', 'freelancer.js')
MODALS_SRC  = File.join(ROOT, '_includes', 'modals.html')
OUT_PATH    = File.join(__dir__, 'bs5mig_1_9.tap')

# ── build ─────────────────────────────────────────────────────────────────────
puts "Building site..."
build_ok = system('bundle exec jekyll build --quiet', chdir: ROOT)

# ── parse ─────────────────────────────────────────────────────────────────────
html       = build_ok ? File.read(INDEX_PATH) : ''
style      = build_ok ? File.read(STYLE_PATH) : ''
doc        = Nokogiri::HTML(html)
freelancer = File.read(FREELANCER)
modals_src = File.read(MODALS_SRC)

# helpers
nav        = doc.at_css('nav.navbar')
body_el    = doc.at_css('body')

# ── checks ────────────────────────────────────────────────────────────────────
checks = [
  # ── 1. Page loads correctly ───────────────────────────────────────────────
  [
    build_ok,
    '[Load] Jekyll build succeeds',
    'bundle exec jekyll build returned non-zero exit'
  ],
  [
    doc.at_css('link[href*="bootstrap@5"]') != nil,
    '[Load] Bootstrap 5 CSS CDN link present',
    'No Bootstrap 5 CSS link found — BS5 styles not loaded'
  ],
  [
    doc.at_css('script[src*="bootstrap.bundle"]') != nil,
    '[Load] Bootstrap 5 JS bundle script present',
    'No bootstrap.bundle script tag found — BS5 JS not loaded'
  ],
  [
    !html.include?('jquery'),
    '[Load] jQuery absent — page is jQuery-free',
    'Found jquery in rendered HTML — jQuery not fully removed'
  ],

  # ── 2. Navbar collapse (mobile breakpoint) ────────────────────────────────
  [
    nav != nil && nav['class'].to_s.include?('fixed-top'),
    '[Navbar] fixed-top class on <nav>',
    '<nav> missing fixed-top — navbar will not stick to top'
  ],
  [
    nav != nil && nav['class'].to_s.include?('navbar-expand-md'),
    '[Navbar] navbar-expand-md present (collapses below 768px)',
    'navbar-expand-md missing — collapse breakpoint not set'
  ],
  [
    doc.at_css('button.navbar-toggler[data-bs-toggle="collapse"]') != nil,
    '[Navbar] navbar-toggler button with data-bs-toggle="collapse" present',
    'No navbar-toggler[data-bs-toggle="collapse"] — mobile toggle will not work'
  ],
  [
    doc.at_css('#bs-example-navbar-collapse-1.collapse.navbar-collapse') != nil,
    '[Navbar] #bs-example-navbar-collapse-1.collapse.navbar-collapse present',
    'Collapse target div missing — navbar will not expand/collapse'
  ],

  # ── 3. Scroll to section ─────────────────────────────────────────────────
  [
    body_el != nil && body_el['data-bs-spy'] == 'scroll',
    '[Scroll] data-bs-spy="scroll" on <body> (BS5 ScrollSpy auto-init)',
    'data-bs-spy="scroll" missing from <body> — ScrollSpy not active'
  ],
  [
    style.include?('scroll-behavior: smooth'),
    '[Scroll] scroll-behavior: smooth in built style.css',
    'scroll-behavior: smooth missing — anchor links will jump instead of scroll'
  ],
  [
    style.include?('scroll-padding-top'),
    '[Scroll] scroll-padding-top in built style.css (offsets fixed navbar)',
    'scroll-padding-top missing — sections will land under fixed navbar on scroll'
  ],
  [
    %w[portfolio about contact].all? { |id| doc.at_css("##{id}") != nil },
    '[Scroll] Section ids #portfolio, #about, #contact all present',
    'One or more section ids missing — scroll nav targets do not exist'
  ],

  # ── 4. Navbar shrink on scroll ────────────────────────────────────────────
  [
    style.include?('navbar-shrink'),
    '[Shrink] navbar-shrink CSS rule in built style.css',
    'navbar-shrink missing from style.css — shrink animation has no CSS target'
  ],
  [
    freelancer.include?('navbar-shrink') && freelancer.include?('requestAnimationFrame'),
    '[Shrink] vanilla rAF navbar-shrink handler in freelancer.js',
    'navbar-shrink or requestAnimationFrame missing from freelancer.js'
  ],

  # ── 5. Portfolio card hover captions ──────────────────────────────────────
  [
    doc.css('.portfolio-item .portfolio-link').any?,
    '[Caption] .portfolio-item .portfolio-link elements present in rendered HTML',
    'No .portfolio-item .portfolio-link found — portfolio grid structure missing'
  ],
  [
    doc.css('.portfolio-link img.img-fluid').any?,
    '[Caption] Portfolio thumbnails use img.img-fluid (BS5 responsive image)',
    'No .portfolio-link img.img-fluid — thumbnails not using BS5 img class'
  ],
  [
    style.include?('.portfolio-link .caption'),
    '[Caption] .portfolio-link .caption CSS rule in built style.css',
    '.portfolio-link .caption missing from style.css — hover captions have no style'
  ],

  # ── 6. Modal open/close ───────────────────────────────────────────────────
  [
    doc.css('a[data-bs-toggle="modal"][data-bs-target]').any?,
    '[Modal] Portfolio card triggers with data-bs-toggle="modal" + data-bs-target present',
    'No modal trigger links found — clicking portfolio cards will not open modals'
  ],
  [
    doc.css('.portfolio-modal[data-bs-backdrop="static"]').any?,
    '[Modal] .portfolio-modal divs with data-bs-backdrop="static" present',
    'data-bs-backdrop="static" missing — clicking outside modal will dismiss it'
  ],
  [
    doc.css('[data-bs-dismiss="modal"]').any?,
    '[Modal] data-bs-dismiss="modal" present on close controls',
    'No data-bs-dismiss="modal" found — X button will not close modals'
  ],
  [
    freelancer.include?('bootstrap.Modal.getInstance'),
    '[Modal] bootstrap.Modal.getInstance in freelancer.js (close-on-image-click)',
    'bootstrap.Modal.getInstance missing from freelancer.js — image click will not close modal'
  ],

  # ── 7. Slideshow carousel (rendered — posts use carousel-mode: slideshow) ──
  [
    doc.css('.carousel.carousel-fade[data-bs-ride]').any?,
    '[Slideshow] .carousel.carousel-fade[data-bs-ride] present in rendered HTML',
    'No .carousel.carousel-fade[data-bs-ride] — slideshow carousel not in output'
  ],
  [
    doc.css('.carousel-inner .carousel-item').any?,
    '[Slideshow] .carousel-inner .carousel-item present (BS5 class, not BS3 .item)',
    'No .carousel-inner .carousel-item — carousel items using wrong class'
  ],
  [
    html.include?('bootstrap.Carousel.getOrCreateInstance'),
    '[Slideshow] bootstrap.Carousel.getOrCreateInstance in inline script',
    'bootstrap.Carousel.getOrCreateInstance missing — BS5 carousel not paused by slideshow script'
  ],

  # ── 8. Click-through carousel prev/next (template check — not rendered) ───
  [
    modals_src.include?('carousel-control-prev') && modals_src.include?('carousel-control-next'),
    '[Carousel] carousel-control-prev + carousel-control-next in modals template',
    'carousel-control-prev or -next missing from modals.html template'
  ],
  [
    modals_src.include?('data-bs-slide='),
    '[Carousel] data-bs-slide= on carousel control buttons in modals template',
    'data-bs-slide= missing from modals.html — prev/next controls will not advance carousel'
  ]
]

# ── TAP output ────────────────────────────────────────────────────────────────
FileUtils.mkdir_p(__dir__)

tap_lines = ["TAP version 13", "1..#{checks.size}"]
checks.each_with_index do |(pass, desc, diag), i|
  tap_lines << (pass ? "ok #{i + 1} - #{desc}" : "not ok #{i + 1} - #{desc}")
  tap_lines << "  # FAIL: #{diag}" unless pass
end

tap_output = tap_lines.join("\n") + "\n"
File.write(OUT_PATH, tap_output)
print tap_output

passed = checks.count { |c| c[0] }
puts "#{passed}/#{checks.size} checks passed — results written to #{OUT_PATH}"
puts ""
puts "Manual browser checklist (run: bundle exec jekyll serve):"
puts "  [ ] Mobile (<768px):  navbar toggle opens/closes; nav links collapse menu; smooth scroll"
puts "  [ ] Tablet (768-991): navbar visible, no toggler; shrinks on scroll >120px"
puts "  [ ] Desktop (>=1200): full navbar; hover captions on portfolio cards"
puts "  [ ] All: click portfolio card → modal opens; X / close button works; Esc does NOT close"
puts "  [ ] Slideshow modal:  images fade automatically; modal close resets to first image"
exit(passed == checks.size ? 0 : 1)
