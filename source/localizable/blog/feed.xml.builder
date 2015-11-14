xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_url = "http://rspec.info"
  xml.title "RSpec"
  xml.subtitle "The Official RSpec Blog"
  xml.id URI.join(site_url, File.dirname(current_path))
  xml.link "href" => URI.join(site_url, File.dirname(current_path))
  xml.link "href" => URI.join(site_url, current_path), "rel" => "self"
  xml.updated(current_blog.local_articles.first.date.to_time.iso8601) unless current_blog.local_articles.empty?
  xml.author { xml.name "The RSpec Core Team" }

  current_blog.local_articles[0..5].each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
      xml.id URI.join(site_url, article.url)
      xml.published article.date.to_time.iso8601
      xml.updated File.mtime(article.source_file).iso8601
      xml.author { xml.name article.data.author }
      # xml.summary article.summary, "type" => "html"
      xml.content article.body, "type" => "html"
    end
  end
end
