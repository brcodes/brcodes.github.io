# frozen_string_literal: true
#
# Verification: Step 1.2 — Bootstrap 5 navbar markup
# Outputs TAP format to bs5mig_1_2.tap in the same directory.

require 'fileutils'
require 'nokogiri'

ROOT       = File.expand_path('../..', __dir__)
SITE_DIR   = File.join(ROOT, '_site')
INDEX_PATH = File.join(SITE_DIR, 'index.html')
OUT_PATH   = File.join(__dir__, 'bs5mig_1_2.tap')

# ── build ────────────────────────────────────────────────────────────────────
puts "Building site..."
build_ok = system('bundle exec jekyll build --quiet', chdir: ROOT)

# ── parse ────────────────────────────────────────────────────────────────────
html      = build_ok ? File.read(INDEX_PATH) : ''
doc       = Nokogiri::HTML(html)
nav       = doc.at_css('nav')
body      = doc.at_css('body')

# ── checks ───────────────────────────────────────────────────────────────────
checks = [
  [
    build_ok,
    'Jekyll build succeeds',
    'bundle exec jekyll build returned non-zero exit'
  ],
  [
    nav ? !nav['class'].to_s.include?('navbar-default') : false,
    'BS3 navbar-default class absent from <nav>',
    'navbar-default still present — BS3 class not removed'
  ],
  [
    nav ? nav['class'].to_s.include?('navbar-dark') : false,
    'BS5 navbar-dark class present (dark background, white toggler icon)',
    'navbar-dark missing — toggler icon will not contrast on dark background'
  ],
  [
    nav ? nav['class'].to_s.include?('fixed-top') : false,
    'BS5 fixed-top class present on <nav>',
    'fixed-top missing — navbar will not be position:fixed'
  ],
  [
    doc.at_css('button.navbar-toggler') != nil,
    'BS5 navbar-toggler button present',
    'Expected <button class="navbar-toggler"> — not found'
  ],
  [
    doc.at_css('button[data-bs-toggle="collapse"]') != nil,
    'data-bs-toggle="collapse" present on toggler button',
    'data-bs-toggle missing — BS5 collapse trigger not wired'
  ],
  [
    doc.at_css('span.navbar-toggler-icon') != nil,
    'navbar-toggler-icon span present',
    'Expected <span class="navbar-toggler-icon"> — not found'
  ],
  [
    doc.at_css('ul.ms-auto') != nil,
    'ms-auto class present on nav ul (replaces navbar-right)',
    'ms-auto missing — nav links will not be right-aligned'
  ],
  [
    body && body['data-bs-spy'] == 'scroll',
    'data-bs-spy="scroll" on <body> for ScrollSpy',
    'data-bs-spy missing from <body> — ScrollSpy not initialized'
  ],
  [
    doc.at_css('div.navbar-header') == nil,
    'BS3 navbar-header wrapper div absent',
    'navbar-header div still present — BS3 wrapper not removed'
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
