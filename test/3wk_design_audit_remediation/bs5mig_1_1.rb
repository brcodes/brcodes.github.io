# frozen_string_literal: true
#
# Verification: Step 1.1 — Bootstrap 5 CSS/JS bundle swap
# Outputs TAP format to bs5mig_1_1.tap in the same directory.

require 'fileutils'

ROOT       = File.expand_path('../..', __dir__)
SITE_DIR   = File.join(ROOT, '_site')
INDEX_PATH = File.join(SITE_DIR, 'index.html')
STYLE_PATH = File.join(SITE_DIR, 'style.css')
OUT_PATH   = File.join(__dir__, 'bs5mig_1_1.tap')

# ── build ────────────────────────────────────────────────────────────────────
puts "Building site..."
build_ok = system('bundle exec jekyll build --quiet', chdir: ROOT)

# ── checks ───────────────────────────────────────────────────────────────────
index_html = build_ok ? File.read(INDEX_PATH) : ''
style_css  = build_ok && File.exist?(STYLE_PATH) ? File.read(STYLE_PATH) : ''

checks = [
  [
    build_ok,
    'Jekyll build succeeds',
    'bundle exec jekyll build returned non-zero exit'
  ],
  [
    index_html.include?('cdn.jsdelivr.net/npm/bootstrap@5'),
    'Bootstrap 5 CDN CSS link present in index.html',
    'Expected cdn.jsdelivr.net/npm/bootstrap@5 in <head>'
  ],
  [
    !index_html.include?('/js/bootstrap.min.js'),
    'Bootstrap 3 local JS bundle absent from index.html',
    'Found /js/bootstrap.min.js — should have been removed'
  ],
  [
    !index_html.include?('jquery.easing.min.js'),
    'jQuery Easing plugin absent from index.html',
    'Found jquery.easing.min.js — should have been removed'
  ],
  [
    !index_html.include?('html5shiv'),
    'IE8 html5shiv shim absent from index.html',
    'Found html5shiv conditional comment — should have been removed'
  ],
  [
    !style_css.include?('Bootswatch'),
    'Bootstrap/Bootswatch source not compiled into style.css',
    'Found Bootswatch header in style.css — bootstrap.min.css still included'
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
