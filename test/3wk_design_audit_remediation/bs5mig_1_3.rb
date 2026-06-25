# frozen_string_literal: true
#
# Verification: Step 1.3 — Bootstrap 5 modal markup
# Outputs TAP format to bs5mig_1_3.tap in the same directory.

require 'fileutils'
require 'nokogiri'

ROOT       = File.expand_path('../..', __dir__)
SITE_DIR   = File.join(ROOT, '_site')
INDEX_PATH = File.join(SITE_DIR, 'index.html')
OUT_PATH   = File.join(__dir__, 'bs5mig_1_3.tap')

# ── build ────────────────────────────────────────────────────────────────────
puts "Building site..."
build_ok = system('bundle exec jekyll build --quiet', chdir: ROOT)

# ── parse ────────────────────────────────────────────────────────────────────
html = build_ok ? File.read(INDEX_PATH) : ''
doc  = Nokogiri::HTML(html)

first_modal    = doc.at_css('div.portfolio-modal')
modal_dialog   = first_modal&.at_css('div.modal-dialog')
modal_content  = modal_dialog&.at_css('div.modal-content')

# ── checks ───────────────────────────────────────────────────────────────────
checks = [
  [
    build_ok,
    'Jekyll build succeeds',
    'bundle exec jekyll build returned non-zero exit'
  ],
  [
    modal_dialog != nil,
    'modal-dialog wrapper div present inside .portfolio-modal',
    'Expected div.modal-dialog as child of .portfolio-modal — not found'
  ],
  [
    modal_content != nil,
    'modal-content div present inside modal-dialog',
    'Expected div.modal-content inside div.modal-dialog — not found'
  ],
  [
    !html.include?('data-dismiss='),
    'BS3 data-dismiss absent (replaced with data-bs-dismiss)',
    'Found data-dismiss= — not fully replaced with data-bs-dismiss'
  ],
  [
    doc.css('[data-bs-dismiss="modal"]').any?,
    'data-bs-dismiss="modal" present on close controls',
    'No elements with data-bs-dismiss="modal" found'
  ],
  [
    !html.include?(' data-ride='),
    'BS3 data-ride absent (replaced with data-bs-ride)',
    'Found data-ride= — not fully replaced with data-bs-ride'
  ],
  [
    doc.css('[data-bs-ride]').any?,
    'data-bs-ride present on carousel(s)',
    'No elements with data-bs-ride found'
  ],
  [
    !html.include?(' data-interval=') && !html.include?('"data-interval='),
    'BS3 data-interval absent (replaced with data-bs-interval)',
    'Found data-interval= — not fully replaced with data-bs-interval'
  ],
  [
    first_modal && !first_modal['role'],
    'role="dialog" absent from outer .portfolio-modal div (handled by BS5 JS)',
    'role="dialog" still on outer .portfolio-modal — should be removed'
  ],
  [
    !html.include?('btn-default'),
    'BS3 btn-default absent from modal close button',
    'Found btn-default — should be btn-secondary in BS5'
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
