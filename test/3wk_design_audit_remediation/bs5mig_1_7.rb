# frozen_string_literal: true
#
# Verification: Step 1.7 — Rewrite slideshow and remaining freelancer.js jQuery to vanilla
# Outputs TAP format to bs5mig_1_7.tap in the same directory.

require 'fileutils'
require 'nokogiri'

ROOT        = File.expand_path('../..', __dir__)
SITE_DIR    = File.join(ROOT, '_site')
INDEX_PATH  = File.join(SITE_DIR, 'index.html')
JS_HTML     = File.join(ROOT, '_includes', 'js.html')
FREELANCER  = File.join(ROOT, 'js', 'freelancer.js')
MODALS_SRC  = File.join(ROOT, '_includes', 'modals.html')
OUT_PATH    = File.join(__dir__, 'bs5mig_1_7.tap')

# ── build ─────────────────────────────────────────────────────────────────────
puts "Building site..."
build_ok = system('bundle exec jekyll build --quiet', chdir: ROOT)

# ── parse ─────────────────────────────────────────────────────────────────────
html       = build_ok ? File.read(INDEX_PATH) : ''
doc        = Nokogiri::HTML(html)
js_html    = File.read(JS_HTML)
freelancer = File.read(FREELANCER)
modals_src = File.read(MODALS_SRC)

# ── checks ────────────────────────────────────────────────────────────────────
checks = [
  [
    build_ok,
    'Jekyll build succeeds',
    'bundle exec jekyll build returned non-zero exit'
  ],
  # ── slideshow script: old jQuery patterns gone ─────────────────────────────
  [
    !js_html.include?('$.portfolio-modal') && !js_html.include?("$('.portfolio-modal')"),
    'js.html: jQuery $(\'.portfolio-modal\') removed from slideshow script',
    'Found $(\'.portfolio-modal\') in js.html — slideshow script not converted to vanilla'
  ],
  [
    !js_html.include?('.carousel-inner .item'),
    'js.html: stale .item selector removed (script now uses .carousel-item)',
    'Found .carousel-inner .item in js.html — script still uses old BS3 item class'
  ],
  [
    !js_html.include?('$carousel.carousel'),
    'js.html: $carousel.carousel() jQuery plugin call removed',
    'Found $carousel.carousel in js.html — BS3 jQuery carousel API not replaced'
  ],
  # ── slideshow script: vanilla JS patterns present ──────────────────────────
  [
    js_html.include?('querySelectorAll') && js_html.include?('carousel-item'),
    'js.html: vanilla querySelectorAll + .carousel-item present in slideshow script',
    'querySelectorAll or .carousel-item missing — slideshow not converted to vanilla JS'
  ],
  [
    js_html.include?('bootstrap.Carousel.getOrCreateInstance'),
    'js.html: bootstrap.Carousel.getOrCreateInstance().pause() present',
    'bootstrap.Carousel.getOrCreateInstance missing — BS5 carousel not paused via vanilla API'
  ],
  [
    js_html.include?('dataset.bsInterval'),
    'js.html: dataset.bsInterval used (reads data-bs-interval attribute)',
    'dataset.bsInterval missing — script may still read old data-interval attribute'
  ],
  # ── freelancer.js: old jQuery patterns gone ────────────────────────────────
  [
    !freelancer.include?("$('.navbar-toggle"),
    "freelancer.js: $('.navbar-toggle') removed (BS3 class replaced with .navbar-toggler)",
    "Found $('.navbar-toggle') in freelancer.js — responsive menu close not updated"
  ],
  [
    !freelancer.include?(".modal({"),
    "freelancer.js: .modal({}) jQuery plugin call removed",
    "Found .modal({ in freelancer.js — BS3 modal init not replaced"
  ],
  # ── freelancer.js: vanilla JS patterns present ─────────────────────────────
  [
    freelancer.include?('navbar-toggler') && freelancer.include?('getComputedStyle'),
    'freelancer.js: vanilla navbar-toggler + getComputedStyle visibility check present',
    'navbar-toggler or getComputedStyle missing — responsive menu close not updated to vanilla'
  ],
  [
    freelancer.include?('bootstrap.Modal.getInstance'),
    'freelancer.js: bootstrap.Modal.getInstance present for close-on-image-click',
    'bootstrap.Modal.getInstance missing — modal close-on-image-click not converted to vanilla'
  ],
  # ── modals.html: BS5 backdrop/keyboard attributes present ──────────────────
  [
    modals_src.include?('data-bs-backdrop="static"'),
    'modals.html: data-bs-backdrop="static" present on portfolio modal divs',
    'data-bs-backdrop="static" missing — modal backdrop policy moved from jQuery to HTML'
  ],
  [
    modals_src.include?('data-bs-keyboard="false"'),
    'modals.html: data-bs-keyboard="false" present on portfolio modal divs',
    'data-bs-keyboard="false" missing — modal keyboard policy moved from jQuery to HTML'
  ],
  # ── rendered HTML: data attributes on modals ──────────────────────────────
  [
    doc.css('.portfolio-modal[data-bs-backdrop="static"]').any?,
    'Rendered HTML: .portfolio-modal has data-bs-backdrop="static"',
    'No .portfolio-modal[data-bs-backdrop="static"] in rendered HTML'
  ],
  # ── jQuery still loaded (floating-label deferred to Step 1.8) ─────────────
  [
    freelancer.include?('floating-label-form-group'),
    'freelancer.js: floating-label handler still present (deferred to Step 1.8)',
    'floating-label-form-group missing — handler accidentally removed'
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
exit(passed == checks.size ? 0 : 1)
