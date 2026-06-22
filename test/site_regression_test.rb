require 'minitest/autorun'
require 'nokogiri'
require 'yaml'
require 'rexml/document'
require 'date'

class SiteRegressionTest < Minitest::Test
  ROOT        = File.expand_path('..', __dir__)
  SITE_DIR    = File.join(ROOT, '_site')
  INDEX_PATH  = File.join(SITE_DIR, 'index.html')
  FEED_PATH   = File.join(SITE_DIR, 'feed.xml')
  CONFIG_PATH = File.join(ROOT, '_config.yml')

  # ── shared setup (builds once per process) ─────────────────────────────────
  # When invoked via `rake test`, test:build already ran; skip the rebuild.
  # When invoked directly (ruby -Itest ...) the site is built here.

  def self.build_site_once
    return if @built

    unless File.exist?(INDEX_PATH)
      success = system('bundle exec jekyll build --quiet', chdir: ROOT)
      raise 'Jekyll build failed during test setup' unless success
    end

    @built     = true
    @index_doc = Nokogiri::HTML(File.read(INDEX_PATH))
    @config    = YAML.load_file(CONFIG_PATH)
  end

  def setup
    self.class.build_site_once
  end

  def index_doc
    self.class.instance_variable_get(:@index_doc)
  end

  def config
    self.class.instance_variable_get(:@config)
  end

  def all_post_front_matters
    @all_post_front_matters ||= Dir.glob(File.join(ROOT, '_posts', '*.markdown')).map do |path|
      body = File.read(path)
      front_matter = body[/\A---\s*\n(.*?)\n---\s*(?:\n|\z)/m, 1]
      parsed = front_matter ? YAML.safe_load(front_matter, [Date], [], true) : {}
      parsed ||= {}
      parsed['__source_path'] = path
      parsed
    end
  end

  def grid_posts
    all_post_front_matters.select { |post| post['grid-position'] }
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # 1. Build Artifacts
  # ─────────────────────────────────────────────────────────────────────────────

  def test_index_html_is_generated
    assert File.exist?(INDEX_PATH), '_site/index.html must be generated'
  end

  def test_style_css_is_generated
    assert File.exist?(File.join(SITE_DIR, 'style.css')), '_site/style.css must be generated'
  end

  def test_core_js_assets_exist
    %w[
      js/jquery-1.11.0.js
      js/bootstrap.min.js
      js/freelancer.js
      js/jquery.easing.min.js
    ].each do |rel|
      assert File.exist?(File.join(SITE_DIR, rel)), "_site/#{rel} must exist"
    end
  end

  def test_feed_xml_exists_and_is_valid_xml
    assert File.exist?(FEED_PATH), '_site/feed.xml must be generated'
    doc = REXML::Document.new(File.read(FEED_PATH))
    refute_nil doc.root, 'feed.xml must have a root element'
  end

  def test_feed_contains_required_channel_metadata
    doc = REXML::Document.new(File.read(FEED_PATH))
    if (channel = doc.elements['rss/channel'])
      %w[title link description].each do |element_name|
        node = channel.elements[element_name]
        refute_nil node, "feed.xml channel must include <#{element_name}>"
        refute_empty node.text.to_s.strip, "feed.xml channel <#{element_name}> must not be empty"
      end
      return
    end

    feed = doc.root
    refute_nil feed, 'feed.xml must have a root element'
    assert_equal 'feed', feed.name, 'feed.xml root should be <feed> when Atom is used'

    title = feed.elements['title']
    refute_nil title, 'Atom feed must include <title>'
    refute_empty title.text.to_s.strip, 'Atom feed <title> must not be empty'

    alternate_link = feed.elements.to_a('link').find { |link| link.attributes['rel'] == 'alternate' }
    refute_nil alternate_link, 'Atom feed must include an alternate link'
    refute_empty alternate_link.attributes['href'].to_s.strip,
                 'Atom feed alternate link href must not be empty'

    updated = feed.elements['updated']
    refute_nil updated, 'Atom feed must include <updated>'
    refute_empty updated.text.to_s.strip, 'Atom feed <updated> must not be empty'
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # 2. Head / SEO
  # ─────────────────────────────────────────────────────────────────────────────

  def test_config_has_required_keys
    %w[title url email].each do |key|
      assert config.key?(key) && !config[key].to_s.strip.empty?,
             "_config.yml must define non-empty '#{key}'"
    end
  end

  def test_page_title_matches_config
    title = index_doc.at_css('head title')&.text.to_s.strip
    assert_includes title, config['title'].to_s.strip, '<title> must include site.title'
  end

  def test_meta_charset_utf8
    node = index_doc.at_css('head meta[charset]')
    refute_nil node, '<meta charset> must be present'
    assert_equal 'utf-8', node['charset'].downcase
  end

  def test_meta_viewport_present
    node = index_doc.at_css('head meta[name="viewport"]')
    refute_nil node, '<meta name="viewport"> must be present'
    assert_includes node['content'].to_s, 'width=device-width'
  end

  def test_meta_description_present
    node = index_doc.at_css('head meta[name="description"]')
    refute_nil node, '<meta name="description"> must be present'
    refute_empty node['content'].to_s.strip, 'meta description must not be empty'
  end

  def test_canonical_link_is_absolute
    node = index_doc.at_css('head link[rel="canonical"]')
    refute_nil node, '<link rel="canonical"> must be present'
    assert node['href'].to_s.start_with?('http'), 'canonical href must be an absolute URL'
  end

  def test_rss_alternate_link_present
    node = index_doc.at_css('head link[type="application/rss+xml"]')
    refute_nil node, 'RSS <link rel="alternate"> must be present in <head>'
  end

  def test_font_resource_hints_are_present
    preconnect_google = index_doc.at_css('head link[rel="preconnect"][href="https://fonts.googleapis.com"]')
    refute_nil preconnect_google, 'head should include preconnect hint for fonts.googleapis.com'

    preconnect_gstatic = index_doc.at_css('head link[rel="preconnect"][href="https://fonts.gstatic.com"]')
    refute_nil preconnect_gstatic, 'head should include preconnect hint for fonts.gstatic.com'
    assert preconnect_gstatic.key?('crossorigin'),
           'fonts.gstatic.com preconnect should include crossorigin for optimal reuse'
  end

  def test_profile_image_preload_is_present
    node = index_doc.at_css('head link[rel="preload"][as="image"]')
    refute_nil node, 'head should include an image preload hint for the profile image'
    assert_includes node['href'].to_s, 'img/profile.jpg',
                    'image preload should point at the profile image asset'
  end

  def test_stylesheet_link_present
    hrefs = index_doc.css('head link[rel="stylesheet"]').map { |l| l['href'].to_s }
    assert hrefs.any? { |href| href.include?('style.css') },
           'style.css must be referenced in <head>'
  end

  def test_no_font_awesome_stylesheet_loaded
    hrefs = index_doc.css('link[rel="stylesheet"]').map { |l| l['href'].to_s }
    refute hrefs.any? { |href| href.include?('font-awesome') },
           'Font Awesome stylesheet must not be loaded (inline SVG icons are used instead)'
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # 3. Navigation
  # ─────────────────────────────────────────────────────────────────────────────

  def test_primary_sections_exist
    %w[portfolio about contact].each do |id|
      refute_nil index_doc.at_css("##{id}"), "Section ##{id} must exist"
    end
  end

  def test_navigation_links_target_primary_sections
    hrefs = index_doc.css('nav .page-scroll a').map { |a| a['href'] }
    %w[#portfolio #about #contact].each do |anchor|
      assert_includes hrefs, anchor, "Nav must include link to #{anchor}"
    end
  end

  def test_nav_brand_links_to_page_top
    brand = index_doc.at_css('nav .navbar-brand')
    refute_nil brand, 'nav .navbar-brand must exist'
    assert_equal '#page-top', brand['href'], 'Navbar brand must link to #page-top'
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # 4. Portfolio Grid
  # ─────────────────────────────────────────────────────────────────────────────

  def test_portfolio_grid_card_count_matches_posts
    expected = grid_posts.length
    actual = index_doc.css('#portfolio .portfolio-flex-item').count
    assert_equal expected, actual, 'Portfolio card count must match posts with grid-position'
  end

  def test_no_duplicate_grid_positions
    positions = grid_posts.map { |post| post['grid-position'].to_i }
    assert_equal positions.uniq.length, positions.length,
                 'grid-position values must be unique across all posts'
  end

  def test_grid_positions_are_positive_integers
    grid_posts.each do |post|
      source = File.basename(post['__source_path'])
      value = post['grid-position']
      assert value.to_s.match?(/\A\d+\z/),
             "#{source} grid-position must be an integer-like value"
      assert_operator value.to_i, :>, 0,
                      "#{source} grid-position must be greater than zero"
    end
  end

  def test_all_grid_posts_have_required_front_matter
    required_keys = %w[grid-position card-title alt]
    grid_posts.each do |post|
      source = File.basename(post['__source_path'])
      required_keys.each do |key|
        assert post.key?(key),
               "#{source} must define front matter key '#{key}'"
        refute_empty post[key].to_s.strip,
                     "#{source} front matter key '#{key}' must not be empty"
      end
    end
  end

  def test_portfolio_images_are_lazy_loaded
    images = index_doc.css('#portfolio img')
    refute_empty images, 'Portfolio must contain images'
    images.each do |img|
      assert_equal 'lazy',  img['loading'],  "Portfolio img #{img['src'].inspect} must have loading=lazy"
      assert_equal 'async', img['decoding'], "Portfolio img #{img['src'].inspect} must have decoding=async"
    end
  end

  def test_portfolio_images_have_nonempty_alt
    index_doc.css('#portfolio img').each do |img|
      refute_nil   img['alt'],        "Portfolio img #{img['src'].inspect} must have an alt attribute"
      refute_empty img['alt'].strip,  "Portfolio img #{img['src'].inspect} must have a non-empty alt"
    end
  end

  def test_portfolio_cards_have_modal_triggers
    index_doc.css('#portfolio .portfolio-link').each do |link|
      assert_equal 'modal', link['data-toggle'],
                   "Portfolio link #{link['href'].inspect} must have data-toggle=\"modal\""
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # 5. Portfolio Modals
  # ─────────────────────────────────────────────────────────────────────────────

  def test_portfolio_modals_exist_for_each_grid_post
    positions = grid_posts.map { |post| post['grid-position'].to_s }
    positions.each do |pos|
      refute_nil index_doc.at_css("#portfolioModal-#{pos}"),
                 "Modal #portfolioModal-#{pos} must be rendered for grid-position #{pos}"
    end
  end

  def test_portfolio_modal_ids_are_unique
    ids = index_doc.css('.portfolio-modal[id]').map { |modal| modal['id'] }
    assert_equal ids.uniq.length, ids.length,
                 'Portfolio modal IDs must be unique'
  end

  def test_portfolio_links_target_existing_modals
    modal_ids = index_doc.css('.portfolio-modal[id]').map { |modal| "##{modal['id']}" }
    index_doc.css('#portfolio .portfolio-link').each do |link|
      href = link['href'].to_s
      assert_includes modal_ids, href,
                      "Portfolio link href=#{href.inspect} must target an existing modal"
    end
  end

  def test_portfolio_modals_have_accessibility_attributes
    index_doc.css('.portfolio-modal').each do |modal|
      id = modal['id'].inspect
      refute_nil modal['tabindex'],          "Modal #{id} must have a tabindex attribute"
      assert_equal 'dialog', modal['role'],  "Modal #{id} must have role=\"dialog\""
    end
  end

  def test_portfolio_modals_have_nonempty_titles
    index_doc.css('.portfolio-modal').each do |modal|
      h2 = modal.at_css('h2')
      refute_nil   h2,               "Modal #{modal['id'].inspect} must contain an <h2> title"
      refute_empty h2.text.strip,    "Modal #{modal['id'].inspect} <h2> title must not be empty"
    end
  end

  def test_portfolio_modals_have_close_buttons
    index_doc.css('.portfolio-modal').each do |modal|
      close = modal.at_css('.close-modal[data-dismiss="modal"]')
      refute_nil close, "Modal #{modal['id'].inspect} must have .close-modal[data-dismiss=\"modal\"]"
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # 6. Performance
  # ─────────────────────────────────────────────────────────────────────────────

  def test_profile_image_has_performance_attributes
    img = index_doc.at_css('header .profile-frame img')
    refute_nil img, 'Profile image must exist inside header .profile-frame'
    assert_equal 'async', img['decoding'],      'Profile image must have decoding=async'
    assert_equal 'high',  img['fetchpriority'], 'Profile image must have fetchpriority=high'
    assert_equal 'eager', img['loading'],       'Profile image must have loading=eager'
    refute_nil img['width'],  'Profile image must declare width'
    refute_nil img['height'], 'Profile image must declare height'
  end

  def test_core_scripts_use_defer
    required = %w[
      /js/jquery-1.11.0.js
      /js/bootstrap.min.js
      /js/jquery.easing.min.js
      /js/freelancer.js
    ]
    scripts_by_src = index_doc.css('script[src]').each_with_object({}) { |s, h| h[s['src']] = s }
    required.each do |src|
      node = scripts_by_src[src]
      refute_nil node,           "Script #{src} must be present"
      assert node.key?('defer'), "Script #{src} must use the defer attribute"
    end
  end

  def test_core_scripts_load_in_dependency_order
    srcs = index_doc.css('script[src]').map { |node| node['src'].to_s }
    jquery_index = srcs.index('/js/jquery-1.11.0.js')
    bootstrap_index = srcs.index('/js/bootstrap.min.js')
    easing_index = srcs.index('/js/jquery.easing.min.js')
    freelancer_index = srcs.index('/js/freelancer.js')

    refute_nil jquery_index, 'jQuery script must be present'
    refute_nil bootstrap_index, 'Bootstrap script must be present'
    refute_nil easing_index, 'jQuery easing script must be present'
    refute_nil freelancer_index, 'Freelancer script must be present'

    assert_operator jquery_index, :<, bootstrap_index,
                    'jQuery must load before Bootstrap'
    assert_operator bootstrap_index, :<, freelancer_index,
                    'Bootstrap must load before freelancer.js'
    assert_operator easing_index, :<, freelancer_index,
                    'jquery.easing.min.js must load before freelancer.js'
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # 7. Contact
  # ─────────────────────────────────────────────────────────────────────────────

  def test_contact_section_has_actionable_cta
    section = index_doc.at_css('#contact')
    refute_nil section, '#contact section must exist'
    cta = section.at_css('a[href^="mailto:"], form')
    refute_nil cta, '#contact must contain a mailto link or a <form>'
  end

  def test_static_contact_mode_omits_form_validation_scripts
    return unless config['contact'] == 'static'

    srcs = index_doc.css('script[src]').map { |s| s['src'].to_s }
    refute srcs.any? { |s| s.include?('jqBootstrapValidation') },
           'Static contact mode must not load jqBootstrapValidation.js'
    refute srcs.any? { |s| s.include?('contact_me.js') },
           'Static contact mode must not load contact_me.js'
  end

  def test_static_contact_mode_exposes_site_email
    return unless config['contact'] == 'static'

    mailto = index_doc.at_css('#contact a[href^="mailto:"]')
    refute_nil mailto, 'Static contact mode must render a mailto contact link'
    assert_equal "mailto:#{config['email']}", mailto['href'],
                 'Static contact mode mailto must match site.email'
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # 8. Footer
  # ─────────────────────────────────────────────────────────────────────────────

  def test_footer_copyright_text_present
    footer = index_doc.at_css('footer')
    refute_nil footer, '<footer> must exist'
    assert_includes footer.text, config.dig('footer', 'copyright').to_s,
                    'Footer must include the copyright name defined in _config.yml'
  end

  def test_footer_social_links_have_aria_labels
    index_doc.css('footer .btn-social').each do |link|
      label = link['aria-label'].to_s.strip
      refute_empty label,
                   "Footer social link href=#{link['href'].inspect} must have a non-empty aria-label"
    end
  end

  def test_footer_github_link_present
    github_links = index_doc.css('footer a[href*="github.com"]')
    refute_empty github_links, 'Footer must contain at least one link to github.com'
  end

  def test_footer_social_links_are_http_or_https
    index_doc.css('footer .btn-social[href]').each do |link|
      href = link['href'].to_s
      assert href.match?(/\Ahttps?:\/\//i),
             "Footer social link href=#{href.inspect} must use http or https"
    end
  end

  def test_scroll_to_top_button_present
    btn = index_doc.at_css('.scroll-top.page-scroll a[href="#page-top"]')
    refute_nil btn, 'Scroll-to-top button must exist and link to #page-top'
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # 9. Accessibility
  # ─────────────────────────────────────────────────────────────────────────────

  def test_all_images_have_alt_attribute
    index_doc.css('img').each do |img|
      assert img.key?('alt'),
             "img src=#{img['src'].inspect} must have an alt attribute (even if empty for decorative images)"
    end
  end

  def test_social_svg_icons_are_aria_hidden
    index_doc.css('footer .btn-social svg[role="img"]').each do |svg|
      assert_equal 'true', svg['aria-hidden'],
                   'Decorative SVG inside .btn-social must have aria-hidden="true"'
    end
  end
end
