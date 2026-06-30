# frozen_string_literal: true
#
# Verification: Step 1.5 — BS5 grid/utility class renames
# Outputs TAP format to bs5mig_1_5.tap in the same directory.
#
# Deferred to Step 1.8: help-block, control-group (form validation markup)
# No change needed:    btn-success (valid BS5), btn-outline (custom main.css class)

require 'fileutils'
require 'nokogiri'

ROOT          = File.expand_path('../..', __dir__)
SITE_DIR      = File.join(ROOT, '_site')
INDEX_PATH    = File.join(SITE_DIR, 'index.html')
ABOUT_SRC     = File.join(ROOT, '_includes', 'about.html')
MODALS_SRC    = File.join(ROOT, '_includes', 'modals.html')
CONTACT_SRC   = File.join(ROOT, '_includes', 'contact.html')
CS_SRC        = File.join(ROOT, '_includes', 'contact_static.html')
GRID_SRC      = File.join(ROOT, '_includes', 'portfolio_grid.html')
MAINCSS_SRC   = File.join(ROOT, '_includes', 'css', 'main.css')
OUT_PATH      = File.join(__dir__, 'bs5mig_1_5.tap')

# ── build ────────────────────────────────────────────────────────────────────
puts "Building site..."
build_ok = system('bundle exec jekyll build --quiet', chdir: ROOT)

# ── parse ────────────────────────────────────────────────────────────────────
html     = build_ok ? File.read(INDEX_PATH) : ''
doc      = Nokogiri::HTML(html)

about    = File.read(ABOUT_SRC)
modals   = File.read(MODALS_SRC)
contact  = File.read(CONTACT_SRC)
cs       = File.read(CS_SRC)
grid     = File.read(GRID_SRC)
maincss  = File.read(MAINCSS_SRC)

# ── checks ───────────────────────────────────────────────────────────────────
checks = [
  # ── build ─────────────────────────────────────────────────────────────────
  [
    build_ok,
    'Jekyll build succeeds',
    'bundle exec jekyll build returned non-zero exit'
  ],
  # ── col-xs-* → col-* (rendered) ──────────────────────────────────────────
  [
    !html.include?('col-xs-'),
    'Rendered HTML: col-xs-* absent (xs infix dropped in BS5)',
    'Found col-xs- in rendered index.html — col-xs-12 not fully replaced'
  ],
  [
    contact.include?('col-12') && !contact.include?('col-xs-12'),
    'Template: col-12 present in contact.html (contact.html uses contact: static, not rendered)',
    'col-12 not found or col-xs-12 still present in contact.html — xs→col-12 replacement failed'
  ],
  # ── col-lg-offset-2 → offset-lg-2 (rendered) ─────────────────────────────
  [
    !html.include?('col-lg-offset-'),
    'Rendered HTML: col-lg-offset-* absent (BS5 uses offset-{bp}-{n} syntax)',
    'Found col-lg-offset- in rendered index.html — not fully replaced'
  ],
  [
    doc.css('.offset-lg-2').any?,
    'Rendered HTML: .offset-lg-2 present on centered content columns',
    'No .offset-lg-2 elements — col-lg-offset-2 → offset-lg-2 replacement may have failed'
  ],
  # ── img-responsive → img-fluid (rendered) ────────────────────────────────
  [
    !html.include?('img-responsive'),
    'Rendered HTML: img-responsive absent (BS5 uses img-fluid)',
    'Found img-responsive in rendered index.html — not fully replaced'
  ],
  [
    doc.css('img.img-fluid').any?,
    'Rendered HTML: img.img-fluid present on portfolio thumbnails',
    'No img.img-fluid found — img-responsive → img-fluid replacement may have failed'
  ],
  # ── source template checks (unrendered branches) ──────────────────────────
  [
    !modals.include?('img-responsive') && !about.include?('img-responsive') &&
      !contact.include?('img-responsive') && !grid.include?('img-responsive'),
    'Templates: img-responsive absent from all _includes HTML sources',
    'Found img-responsive in one or more template sources — replacement incomplete'
  ],
  [
    !modals.include?('col-lg-offset-2') && !about.include?('col-lg-offset-2') &&
      !contact.include?('col-lg-offset-2') && !cs.include?('col-lg-offset-2'),
    'Templates: col-lg-offset-2 absent from all _includes HTML sources',
    'Found col-lg-offset-2 in one or more template sources — replacement incomplete'
  ],
  [
    !contact.include?('col-xs-12'),
    'Template: col-xs-12 absent from contact.html',
    'Found col-xs-12 in contact.html — replacement incomplete'
  ],
  # ── verify custom class preserved (no accidental removal) ─────────────────
  [
    maincss.include?('.btn-outline'),
    'main.css: custom .btn-outline class still present (not accidentally removed)',
    '.btn-outline missing from main.css — custom button style was accidentally dropped'
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
