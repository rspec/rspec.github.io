module TagsTemplateHelper

  def url_for(*args)
    super
      .gsub(/^[\.\/]*/,'/')                     # Makes paths absolute
      .gsub(/^[\.\/]*css/, '/stylesheets/docs') # Links to our css
      .gsub(/^[\.\/]*js/, '/javascripts/docs')  # Links to our js
  end

  def url_for_file(*args)
    super.gsub(/^[\.\/]*/,'/')
  end

end

module YARD
  module Templates::Helpers

    module HtmlHelper

      def url_for_list(*args)
        super.gsub(/^[\.\/]*/,'/')
      end

    end
  end
end
