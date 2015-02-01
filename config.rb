# Bower specific setup
after_configuration do
  @bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
  @bower_assets_path = File.join "#{root}", @bower_config["directory"]
  sprockets.append_path @bower_assets_path
end

# dev mode addons
activate :livereload if ENV['LIVERELOAD']

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "blog"
  blog.layout = "blog_post"

  blog.permalink = "/{year}/{month}/{title}"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
end

page "/blog/feed.xml", layout: false

# for build
activate :syntax
set :markdown_engine, :kramdown
activate :directory_indexes

page "documentation/**/*.html", directory_index: false
config[:ignored_sitemap_matchers][:partials] = ->(file) do
  # Only files with 1 (but not two) underscores at the start
  # of the file name are candidates for being considered a partial.
  return false unless file =~ %r{/_[^_]}

  # ...but not our generated docs -- YARD generates `_index.html` files
  # which are not partials.
  file !~ %r{source/documentation/[0-9\.]+/}
end

set :css_dir,    'stylesheets'
set :js_dir,     'javascripts'
set :images_dir, 'images'
set :frontmatter_extensions, %w(.html .slim)

# necessary whilst testing
set :relative_links, true

configure :build do
  activate :minify_css
  activate :minify_javascript
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

def deploy_to target
  activate :deploy do |deploy|
    deploy.method = :git
    deploy.build_before = true
    deploy.branch = 'master'
    deploy.remote = target
  end
end

case ENV['TARGET'].to_s
when /prod/i
  deploy_to 'git@github.com:rspec/rspec.github.io.git'
else
  deploy_to 'git@github.com:RSpec-Staging/rspec-staging.github.io.git'
  ignore 'CNAME'
end

helpers do
  def primary_page_class
    page_classes.split(" ").first
  end

  def asciinema_video(id, speed: 1)
    <<-HTML.gsub(/^ +\|/, '')
      |<div class="asciinema-video">
      |  <script type="text/javascript" src="https://asciinema.org/a/#{id}.js" id="asciicast-#{id}" data-size="small" data-speed="#{speed}", async></script>
      |</div>
    HTML
  end

  def rspec_documentation
    hash = Hash.new { |h,k| h[k] = [] }
    Dir["#{root}/source/documentation/*/*"].each do |dir|
      version, gem = dir.scan(%r{/source/documentation/([^/]+)/([^/]+)}).first.flatten
      hash[gem] << version
    end
    hash
  end

  def documentation_links_for(gem_name)
    versions = rspec_documentation.fetch(gem_name) { [] }.sort.reverse
    unless versions.empty?
      content_tag :div, 'class' => 'version-dropdown' do
        list = content_tag :ul do
          versions.map do |version|
            content_tag :li do
              link_to version, "/documentation/#{version}/#{gem_name}/"
            end
          end.join('')
        end

        link_to(versions.first, '#') + list
      end
    end
  end

  POSTS_IMPORTED_FROM_MYRONS_BLOG  = %w[
    /blog/2014/09/rspec-3-1-has-been-released/
    /blog/2014/06/rspec-team-changes/
    /blog/2014/06/rspec-2-99-0-and-3-0-0-have-been-released/
    /blog/2014/05/notable-changes-in-rspec-3/
    /blog/2014/05/rspec-2-99-and-3-0-rc-1-have-been-released/
    /blog/2014/02/rspec-2-99-and-3-0-beta-2-have-been-released/
    /blog/2014/01/new-in-rspec-3-composable-matchers/
    /blog/2013/11/rspec-2-99-and-3-0-betas-have-been-released/
    /blog/2013/07/the-plan-for-rspec-3/
    /blog/2013/07/rspec-2-14-is-released/
    /blog/2013/04/rspec-team-changes/
    /blog/2013/02/rspec-2-13-is-released/
    /blog/2012/07/mixing-and-matching-parts-of-rspec/
    /blog/2012/06/constant-stubbing-in-rspec-2-11/
    /blog/2012/06/rspecs-new-expectation-syntax/
    /blog/2011/11/recent-rspec-configuration-warnings-and-errors/
  ].to_set

  def imported_from_myrons_blog?(page)
    POSTS_IMPORTED_FROM_MYRONS_BLOG.include?(page.url)
  end

  def disqus_shortname_for(page)
    if imported_from_myrons_blog?(page)
      'myronmarston-personal-site'
    else
      "rspec"
    end
  end

  def disqus_identifier_for(page)
    path = page.url
    if imported_from_myrons_blog?(page)
      path.sub(%r{^/blog/}, "/n/dev-blog/").sub(%r{/$}, '')
    else
      path
    end
  end
  alias disqus_path_for disqus_identifier_for

  def disqus_url_for(page)
    path = disqus_path_for(page)
    if imported_from_myrons_blog?(page)
      "http://myronmars.to#{path}"
    else
      "http://rspec.info#{path}"
    end
  end

=begin
  Borrowed from the EJS gem:
    https://github.com/sstephenson/ruby-ejs/blob/v1.1.1/lib/ejs.rb#L6-L17
    https://github.com/sstephenson/ruby-ejs/blob/v1.1.1/lib/ejs.rb#L60-L63

  Copyright (c) 2011 Sam Stephenson

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
=end
  JS_UNESCAPES = {
    '\\' => '\\',
    "'" => "'",
    'r' => "\r",
    'n' => "\n",
    't' => "\t",
    'u2028' => "\u2028",
    'u2029' => "\u2029"
  }
  JS_ESCAPES = JS_UNESCAPES.invert
  JS_ESCAPE_PATTERN = Regexp.union(JS_ESCAPES.keys)
  def js_escape(string)
    string.gsub(JS_ESCAPE_PATTERN) { |match| '\\' + JS_ESCAPES[match] }
  end
end
