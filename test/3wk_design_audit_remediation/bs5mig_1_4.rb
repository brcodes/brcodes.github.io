# frozen_string_literal: true
#
# Verification: Step 1.4 — Bootstrap 5 carousel markup
# Outputs TAP format to bs5mig_1_4.tap in the same directory.
#
# Note: All test posts use carousel-mode: slideshow, so only the slideshow
# carousel branch renders in _site/index.html.  Click-through-specific
# elements (indicators, prev/next controls, visually-hidden) are verified
# against the source template _includes/modals.html directly.

require 'fileutils'
require 'nokogiri'

ROOT          = File.expand_path('../..', __dir__)
SITE_DIR      = File.join(ROOT, '_site')
INDEX_PATH    = File.join(SITE_DIR, 'index.html')
TEMPLATE_PATH = File.join(ROOT, '_includes', 'modals.html')
OUT_PATH      = File.join(__dir__, 'bs5mig_1_4.tap')

# ── build ────────────────────────────────────────────────────────────────────
puts "Building site..."
build_ok = system('bundle exec jekyll build --quiet', chdir: ROOT)

# ── parse ────────────────────────────────────────────────────────────────────
html     = build_ok ? File.read(INDEX_PATH) : ''
doc      = Nokogiri::HTML(html)
template = File.read(TEMPLATE_PATH)

# ── checks ───────────────────────────────────────────────────────────────────
checks = [
  # ── rendered HTML checks (slideshow carousel renders) ──────────────────────
  [
    build_ok,
    'Jekyll build succeeds',
    'bundle exec jekyll build returned non-zero exit'
  ],
  [
    !html.include?('class="item ') && !html.include?('class="item"'),
    'Rendered HTML: BS3 .item absent (slideshow uses .carousel-item)',
    'Found class="item" or class="item " — .item not replaced with .carousel-item'
  ],
  [
    doc.css('.carousel-item').any?,
    'Rendered HTML: .carousel-item present on slideshow slides',
    'No elements with class .carousel-item found in rendered HTML'
  ],
  [
    !html.include?('role="listbox"'),
    'Rendered HTML: role="listbox" absent from .carousel-inner',
    'Found role="listbox" on carousel-inner in rendered HTML — should be removed'
  ],
  # ── source template checks (click-through branch) ─────────────────────────
  [
    !template.include?('<ol class="carousel-indicators"'),
    'Template: <ol class="carousel-indicators"> absent (replaced with <div>)',
    'Found <ol class="carousel-indicators"> in template — not replaced with BS5 <div>'
  ],
  [
    template.include?('<div class="carousel-indicators">'),
    'Template: <div class="carousel-indicators"> present (BS5 indicator wrapper)',
    'No <div class="carousel-indicators"> in template — indicator wrapper not updated'
  ],
  [
    template.include?('data-bs-slide-to='),
    'Template: data-bs-slide-to present on indicator buttons',
    'No data-bs-slide-to= in template — indicator buttons not updated to BS5'
  ],
  [
    !template.include?(' data-slide=') && !template.include?('"data-slide='),
    'Template: BS3 data-slide absent (replaced with data-bs-slide)',
    'Found data-slide= in template — not fully replaced with data-bs-slide'
  ],
  [
    template.include?('data-bs-slide='),
    'Template: data-bs-slide present on carousel controls',
    'No data-bs-slide= in template — prev/next controls not updated'
  ],
  [
    template.include?('carousel-control-prev') && template.include?('carousel-control-next'),
    'Template: carousel-control-prev and carousel-control-next classes present',
    'carousel-control-prev or carousel-control-next missing from template'
  ],
  [
    !template.match?(/<a\s[^>]*carousel-control/),
    'Template: no <a> carousel-control elements (replaced with <button>)',
    'Found <a ... carousel-control in template — controls not converted to <button>'
  ],
  [
    !template.include?('class="sr-only"'),
    'Template: BS3 .sr-only absent (replaced with .visually-hidden)',
    'Found class="sr-only" in template — not replaced with BS5 visually-hidden'
  ],
  [
    template.include?('visually-hidden'),
    'Template: visually-hidden present on carousel control labels',
    'No visually-hidden in template — sr-only not updated to BS5 class'
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
