module RSpecInfo
  module Helpers
    def current_blog
      blog(current_blog_name)
    end

    def current_blog_name
      current_lang == :en ? 'en' : 'i18n'
    end

    def current_lang
      current_resource.respond_to?(:lang) ? current_resource.lang : :en
    end

    def other_localized_resources
      localized_resources.reject { |resource| resource.lang == current_lang }
    end

    def localized_resources
      current_resource_name = current_resource.destination_path.sub(%r{\A#{current_lang}}, '')

      resources = langs.map do |lang|
        localized_resource_path = if lang == :en
                                    current_resource_name
                                  else
                                    File.join(lang.to_s, current_resource_name)
                                  end
        sitemap.find_resource_by_destination_path(localized_resource_path)
      end

      resources.compact.sort_by(&:lang)
    end

    def primary_page_class
      classes = page_classes.split(" ").map { |klass| klass.sub(/\A#{current_lang}_?/, '') }
      classes.find { |klass| !klass.empty? }
    end

    def get_poster(id)
      open(File.expand_path("../../../source/casts/#{id}.poster", __FILE__)).read
    end

    def asciinema_video(id, speed: 1)
      <<-HTML.gsub(/^ +\|/, '')
      |<div class="asciinema-video">
      |  <asciinema-player src="/casts/#{id}.cast" speed="#{speed}" data-size="small" id="asciicast-#{id}" poster="#{get_poster(id)}"/>
      |</div>
      HTML
    end

    def rspec_documentation(directory = source_dir)
      hash = Hash.new { |h,k| h[k] = [] }
      Dir["#{directory}/documentation/*/*"].each do |dir|
        version, gem = dir.scan(%r{/source/documentation/([^/]+)/([^/]+)}).first.flatten
        hash[gem] << version
      end
      hash
    end

    def rspec_documentation_latest(directory = source_dir)
      rspec_documentation(directory).each_with_object({}) { |(k,v), a| a[k] = v.max }
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

    module_function :rspec_documentation, :rspec_documentation_latest
  end
end
