$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'patches/uri'

# Assets
# Framework requires set themselves up
require 'bourbon'
require 'neat'

# dev mode addons
activate :livereload if ENV['LIVERELOAD']

activate :i18n, langs: [:en, :ja], mount_at_root: :en

def configure_blog(blog)
  blog.layout = "blog_post"

  blog.permalink = "/{year}/{month}/{title}"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
end

# middleman-blog does not allow the `mount_at_root` like feature
# so we define two blog instances for English one and localized one.

# English blog at /blog
activate :blog do |blog|
  blog.name = 'en'
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "blog"
  configure_blog(blog)
end

# Localized blogs at /{lang}/blog
activate :blog do |blog|
  blog.name = 'i18n'
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "{lang}/blog"
  configure_blog(blog)
end

page "/**/feed.xml", layout: false

# for build
activate :syntax
set :markdown_engine, :kramdown
activate :directory_indexes

page "documentation/**/*.html", directory_index: false
config[:ignored_sitemap_matchers][:partials] = ->(source_file, _) do
  # Only files with 1 (but not two) underscores at the start
  # of the file name are candidates for being considered a partial.
  ignored = false
  source_file[:relative_path].ascend do |f|
    if /^_[^_]/.match?(f.basename.to_s)
      ignored = true
      break
    end
  end

  # ...but not our generated docs -- YARD generates `_index.html` files
  # which are not partials.
  if source_file[:full_path].to_s =~ %r{source/documentation/[0-9\.]+/}
    ignored = false
  end

  ignored
end

set :build_dir,  'docs'
set :css_dir,    'stylesheets'
set :js_dir,     'javascripts'
set :images_dir, 'images'
set :frontmatter_extensions, %w(.html .slim)

# necessary whilst testing
set :relative_links, true

configure :build do
  activate :minify_css, ignore: 'documentation/*'
  activate :minify_javascript, ignore: 'documentation/*'
  activate :favicon_maker, icons: { "_favicon_template.png" =>
      [
        { icon: "apple-touch-icon-152x152-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPad with iOS7.
        { icon: "apple-touch-icon-144x144-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPad with iOS6 or prior.
        { icon: "apple-touch-icon-120x120-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPhone with iOS7.
        { icon: "apple-touch-icon-114x114-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPhone with iOS6 or prior.
        { icon: "apple-touch-icon-76x76-precomposed.png" },               # Same as apple-touch-icon-57x57.png, for non-retina iPad with iOS7.
        { icon: "apple-touch-icon-72x72-precomposed.png" },               # Same as apple-touch-icon-57x57.png, for non-retina iPad with iOS6 or prior.
        { icon: "apple-touch-icon-60x60-precomposed.png" },               # Same as apple-touch-icon-57x57.png, for non-retina iPhone with iOS7.
        { icon: "apple-touch-icon-57x57-precomposed.png" },               # iPhone and iPad users can turn web pages into icons on their home screen. Such link appears as a regular iOS native application. When this happens, the device looks for a specific picture. The 57x57 resolution is convenient for non-retina iPhone with iOS6 or prior. Learn more in Apple docs.
        { icon: "apple-touch-icon-precomposed.png", size: "57x57" },      # Same as apple-touch-icon.png, expect that is already have rounded corners (but neither drop shadow nor gloss effect).
        { icon: "apple-touch-icon.png", size: "57x57" },                  # Same as apple-touch-icon-57x57.png, for "default" requests, as some devices may look for this specific file. This picture may save some 404 errors in your HTTP logs. See Apple docs
        { icon: "favicon-196x196.png" },                                  # For Android Chrome M31+.
        { icon: "favicon-160x160.png" },                                  # For Opera Speed Dial (up to Opera 12; this icon is deprecated starting from Opera 15), although the optimal icon is not square but rather 256x160. If Opera is a major platform for you, you should create this icon yourself.
        { icon: "favicon-96x96.png" },                                    # For Google TV.
        { icon: "favicon-32x32.png" },                                    # For Safari on Mac OS.
        { icon: "favicon-16x16.png" },                                    # The classic favicon, displayed in the tabs.
        { icon: "favicon.png", size: "16x16" },                           # The classic favicon, displayed in the tabs.
        { icon: "favicon.ico", size: "64x64,32x32,24x24,16x16" },         # Used by IE, and also by some other browsers if we are not careful.
        { icon: "mstile-70x70.png", size: "70x70" },                      # For Windows 8 / IE11.
        { icon: "mstile-144x144.png", size: "144x144" },
        { icon: "mstile-150x150.png", size: "150x150" },
        { icon: "mstile-310x310.png", size: "310x310" },
      ]
    }
end

require 'rspec_info/helpers'
helpers RSpecInfo::Helpers

RSpecInfo::Helpers.rspec_documentation_latest(app.source_dir).each do |gem_name, version|
  Dir.glob(File.join(app.source_dir, "/documentation/#{version}/#{gem_name}/**/*.html")).select { |f| File.file? f }.each do |f|
    relative_path = Pathname.new(f).relative_path_from(Pathname.new(app.source_dir))
    proxy "/#{relative_path.to_s.gsub(version, 'latest')}", "/redirect-latest.html", locals: { url: '/' + relative_path.to_s }
  end
end

ignore '/redirect-latest.html'
