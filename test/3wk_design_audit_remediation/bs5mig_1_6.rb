# frozen_string_literal: true
#
# Verification: Step 1.6 — Replace jQuery smooth scroll with CSS scroll-behavior
# Outputs TAP format to bs5mig_1_6.tap in the same directory.

require 'fileutils'
require 'nokogiri'

ROOT         = File.expand_path('../..', __dir__)
SITE_DIR     = File.join(ROOT, '_site')
INDEX_PATH   = File.join(SITE_DIR, 'index.html')
FREELANCER   = File.join(ROOT, 'js', 'freelancer.js')
MAINCSS_SRC  = File.join(ROOT, '_includes', 'css', 'main.css')
STYLE_BUILT  = File.join(SITE_DIR, 'style.css')
OUT_PATH     = File.join(__dir__, 'bs5mig_1_6.tap')

# ── build ────────────────────────────────────────────────────────────────────
puts "Building site..."
build_ok = system('bundle exec jekyll build --quiet', chdir: ROOT)

# ── read sources ─────────────────────────────────────────────────────────────
html      = build_ok ? File.read(INDEX_PATH) : ''
doc       = Nokogiri::HTML(html)
freelancer = File.read(FREELANCER)
style_built = build_ok ? File.read(STYLE_BUILT) : ''

# ── checks ───────────────────────────────────────────────────────────────────
checks = [
  [
    build_ok,
    'Jekyll build succeeds',
    'bundle exec jekyll build returned non-zero exit'
  ],
  # ── jQuery smooth scroll block removed ────────────────────────────────────
  [
    !freelancer.include?('page-scroll'),
    'freelancer.js: .page-scroll click handler removed',
    'Found page-scroll in freelancer.js — jQuery smooth scroll block not removed'
  ],
  [
    !freelancer.include?('easeInOutExpo'),
    'freelancer.js: easeInOutExpo reference removed (jQuery Easing dependency gone)',
    'Found easeInOutExpo in freelancer.js — jQuery smooth scroll block not fully removed'
  ],
  [
    !freelancer.include?('_scrollspyFrozen'),
    'freelancer.js: ScrollSpy freeze patch removed',
    'Found _scrollspyFrozen in freelancer.js — BS3 scrollspy patch not removed'
  ],
  # ── jQuery scrollspy IIFE removed ─────────────────────────────────────────
  [
    !freelancer.include?('applyScrollspy'),
    'freelancer.js: jQuery scrollspy IIFE removed (BS5 uses data-bs-spy attribute)',
    'Found applyScrollspy in freelancer.js — jQuery scrollspy init block not removed'
  ],
  [
    !freelancer.include?("$('body').scrollspy"),
    "freelancer.js: $('body').scrollspy() call removed",
    "Found $('body').scrollspy in freelancer.js — BS3 scrollspy init not removed"
  ],
  # ── CSS scroll-behavior added ──────────────────────────────────────────────
  [
    style_built.include?('scroll-behavior: smooth'),
    'Built style.css: scroll-behavior: smooth present in compiled CSS',
    'scroll-behavior: smooth not found in _site/style.css — not added to main.css'
  ],
  [
    style_built.include?('scroll-padding-top'),
    'Built style.css: scroll-padding-top present (offsets fixed navbar on anchor scroll)',
    'scroll-padding-top not found in _site/style.css — sections will land under fixed navbar'
  ],
  # ── BS5 ScrollSpy still wired via data attribute ──────────────────────────
  [
    doc.at_css('body[data-bs-spy="scroll"]') != nil,
    'Rendered HTML: data-bs-spy="scroll" present on <body> (BS5 ScrollSpy auto-init)',
    'data-bs-spy="scroll" missing from <body> — BS5 ScrollSpy not initialized'
  ],
  # ── navbar shrink (vanilla JS) still present ──────────────────────────────
  [
    freelancer.include?('navbar-shrink') && freelancer.include?('requestAnimationFrame'),
    'freelancer.js: vanilla rAF navbar-shrink handler still present',
    'navbar-shrink or requestAnimationFrame missing — vanilla shrink handler was accidentally removed'
  ],
  # ── floating-label handler still present (deferred to Step 1.8) ───────────
  [
    freelancer.include?('floating-label-form-group'),
    'freelancer.js: floating-label handler still present (deferred to Step 1.8)',
    'floating-label-form-group missing from freelancer.js — handler was accidentally removed'
  ]
]

# ── TAP output ───────────────────────────────────────────────────────────────
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
