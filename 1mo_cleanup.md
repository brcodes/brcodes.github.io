# 1mo Cleanup

## Problems Found

- Repo contained a large vendored Ruby dependency tree under vendor/bundle tracked in git, creating unnecessary repository bloat.
- Build output under _site was generated content and should not be committed.
- Multiple image/document assets in img were not referenced by templates/posts and increased repo size.
- Unused frontend assets remained (legacy JS files and full Font Awesome payload) with no references in current templates.
- Theme vestige files remained from template packaging/legacy CI (.travis.yml, freelancer-theme-jekyll.gemspec, screenshot.png).
- Bundler was pinned to vendor/bundle via .bundle/config, coupling local installs to a tracked path pattern.

## Actions Taken

- Untracked vendored gems from git going forward by removing vendor from the index while keeping vendor ignored.
- Removed .bundle/config from tracking and local workspace to stop forcing bundled gems into vendor/bundle.
- Kept _site ignored and made ignore explicit as _site/ in .gitignore.
- Deleted verified unused media assets from img and removed unused JS assets.
- Removed unused Font Awesome asset directory (css/font-awesome) that was not loaded by the site.
- Removed theme vestige files: .travis.yml, freelancer-theme-jekyll.gemspec, screenshot.png.
- Replaced gemspec-based Gemfile with explicit runtime/test dependencies so local and CI builds still work without theme packaging files.
