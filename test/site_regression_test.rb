require 'minitest/autorun'
require 'nokogiri'
require 'yaml'

class SiteRegressionTest < Minitest::Test
	ROOT = File.expand_path('..', __dir__)
	SITE_DIR = File.join(ROOT, '_site')
	INDEX_PATH = File.join(SITE_DIR, 'index.html')
	CONFIG_PATH = File.join(ROOT, '_config.yml')

	def self.build_site_once
		return if @built

		success = system('bundle exec jekyll build --quiet', chdir: ROOT)
		raise 'Jekyll build failed during test setup' unless success

		@built = true
		@index_doc = Nokogiri::HTML(File.read(INDEX_PATH))
		@config = YAML.load_file(CONFIG_PATH)
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

	def test_index_is_generated
		assert File.exist?(INDEX_PATH), '_site/index.html should be generated'
	end

	def test_primary_sections_exist
		%w[portfolio about contact].each do |section_id|
			refute_nil index_doc.at_css("##{section_id}"), "Missing ##{section_id} section"
		end
	end

	def test_navigation_targets_expected_sections
		hrefs = index_doc.css('nav .page-scroll a').map { |a| a['href'] }
		%w[#portfolio #about #contact].each do |anchor|
			assert_includes hrefs, anchor, "Nav should include #{anchor}"
		end
	end

	def test_portfolio_grid_item_count_matches_posts
		expected = Dir.glob(File.join(ROOT, '_posts', '*.markdown')).count do |path|
			File.read(path).match?(/^grid-position:\s*\d+/)
		end

		actual = index_doc.css('#portfolio .portfolio-flex-item').count
		assert_equal expected, actual, 'Portfolio card count should match grid-position posts'
	end

	def test_profile_image_is_prioritized_and_stable
		image = index_doc.at_css('header .profile-frame img')
		refute_nil image, 'Profile image should exist in header'

		assert_equal 'async', image['decoding']
		assert_equal 'high', image['fetchpriority']
		assert_equal 'eager', image['loading']
		refute_nil image['width']
		refute_nil image['height']
	end

	def test_portfolio_images_are_lazy_loaded
		images = index_doc.css('#portfolio img')
		refute_empty images, 'Portfolio should contain images'

		images.each do |img|
			assert_equal 'lazy', img['loading']
			assert_equal 'async', img['decoding']
			refute_nil img['alt']
			refute_empty img['alt'].strip
		end
	end

	def test_static_contact_mode_omits_contact_form_scripts
		return unless config['contact'] == 'static'

		scripts = index_doc.css('script[src]').map { |s| s['src'] }

		refute scripts.any? { |src| src.include?('jqBootstrapValidation.js') },
					 'Static contact mode should not load jqBootstrapValidation'
		refute scripts.any? { |src| src.include?('contact_me_static.js') },
					 'Static contact mode should not load contact_me_static.js'
		refute scripts.any? { |src| src.include?('contact_me.js') },
					 'Static contact mode should not load contact_me.js'
	end

	def test_core_scripts_use_defer
		expected = %w[
			/js/jquery-1.11.0.js
			/js/bootstrap.min.js
			/js/jquery.easing.min.js
			/js/freelancer.js
		]

		script_nodes = index_doc.css('script[src]')
		scripts_by_src = script_nodes.each_with_object({}) do |node, memo|
			memo[node['src']] = node
		end

		expected.each do |src|
			script = scripts_by_src[src]
			refute_nil script, "Missing script #{src}"
			assert_equal 'defer', script['defer'], "#{src} should use defer"
		end
	end

	def test_no_font_awesome_stylesheet_is_loaded
		hrefs = index_doc.css('link[rel="stylesheet"]').map { |l| l['href'] }
		refute hrefs.any? { |href| href.include?('font-awesome') },
					 'Font Awesome stylesheet should not be loaded'
	end
end
