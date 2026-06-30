# frozen_string_literal: true
#
# Verification: Step 1.8 — Remove jQuery; migrate floating-label to vanilla; clean form
# Outputs TAP format to bs5mig_1_8.tap in the same directory.

require 'fileutils'
require 'nokogiri'

ROOT        = File.expand_path('../..', __dir__)
SITE_DIR    = File.join(ROOT, '_site')
INDEX_PATH  = File.join(SITE_DIR, 'index.html')
JS_HTML     = File.join(ROOT, '_includes', 'js.html')
FREELANCER  = File.join(ROOT, 'js', 'freelancer.js')
CONTACT_SRC = File.join(ROOT, '_includes', 'contact.html')
OUT_PATH    = File.join(__dir__, 'bs5mig_1_8.tap')

# ── build ─────────────────────────────────────────────────────────────────────
puts "Building site..."
build_ok = system('bundle exec jekyll build --quiet', chdir: ROOT)

# ── parse ─────────────────────────────────────────────────────────────────────
html       = build_ok ? File.read(INDEX_PATH) : ''
doc        = Nokogiri::HTML(html)
js_html    = File.read(JS_HTML)
freelancer = File.read(FREELANCER)
contact    = File.read(CONTACT_SRC)

# ── checks ────────────────────────────────────────────────────────────────────
checks = [
  [
    build_ok,
    'Jekyll build succeeds',
    'bundle exec jekyll build returned non-zero exit'
  ],
  # ── jQuery fully removed ──────────────────────────────────────────────────
  [
    !html.include?('jquery'),
    'Rendered HTML: jQuery script tag absent (jQuery removed from page)',
    'Found jquery in rendered index.html — jQuery not fully removed from js.html'
  ],
  [
    !js_html.include?('jquery'),
    'js.html: jQuery script tag absent',
    'Found jquery in js.html — jQuery not removed'
  ],
  [
    !js_html.include?('jqBootstrapValidation'),
    'js.html: jqBootstrapValidation script tag absent',
    'Found jqBootstrapValidation in js.html — conditional load block not removed'
  ],
  # ── freelancer.js: no jQuery remaining ────────────────────────────────────
  [
    !freelancer.include?('$(function') && !freelancer.match?(/\$\(["']/) && !freelancer.include?('$(this)'),
    'freelancer.js: zero jQuery $() calls remaining',
    'Found $() calls in freelancer.js — jQuery not fully removed from source'
  ],
  # ── vanilla floating-label handler present ────────────────────────────────
  [
    freelancer.include?('floating-label-form-group') && freelancer.include?("closest('.floating-label-form-group')"),
    'freelancer.js: vanilla floating-label handler present (uses .closest())',
    'floating-label-form-group or .closest() missing — floating-label handler not converted'
  ],
  [
    freelancer.include?('focusin') && freelancer.include?('focusout'),
    'freelancer.js: focusin/focusout event listeners present (bubble-capable focus events)',
    'focusin or focusout missing — vanilla focus delegation not implemented'
  ],
  # ── contact.html: BS3 artifacts removed ───────────────────────────────────
  [
    !contact.include?('novalidate'),
    'contact.html: novalidate attribute removed (native HTML5 validation enabled)',
    'Found novalidate in contact.html — not removed'
  ],
  [
    !contact.include?('control-group'),
    'contact.html: control-group class removed (BS3 jQuery validation hook)',
    'Found control-group in contact.html — BS3 artifact not removed'
  ],
  [
    !contact.include?('help-block'),
    'contact.html: help-block class removed (BS3 jQuery validation feedback)',
    'Found help-block in contact.html — BS3 artifact not removed'
  ],
  [
    !contact.include?('data-validation-required-message'),
    'contact.html: data-validation-required-message attributes removed (jQuery plugin artifacts)',
    'Found data-validation-required-message in contact.html — plugin attribute not removed'
  ],
  [
    !contact.include?('id="success"'),
    'contact.html: id="success" AJAX placeholder div removed',
    'Found id="success" in contact.html — AJAX response placeholder not removed'
  ],
  # ── Bootstrap 5 bundle still loads ───────────────────────────────────────
  [
    html.include?('bootstrap@5.3.3') || html.include?('bootstrap.bundle.min.js'),
    'Rendered HTML: Bootstrap 5 bundle script tag present',
    'Bootstrap 5 bundle missing from rendered HTML — accidentally removed'
  ],
  # ── site-wide: no remaining jQuery dependency patterns ────────────────────
  [
    !html.include?('jquery-1.11.0'),
    'Rendered HTML: jquery-1.11.0.js script tag absent',
    'Found jquery-1.11.0.js in rendered HTML — old script tag not removed'
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
