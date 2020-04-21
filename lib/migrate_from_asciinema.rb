require 'nokogiri'
require 'open-uri'

CASTS_IDS = [14083, 14084, 14085, 14086, 14087, 14088, 14089, 14090, 14091,
             14092, 14093, 14095, 14100, 14101, 14102, 14103, 14103].freeze

def get_cast(id)
  open(File.expand_path("../../source/casts/#{id}.cast", __FILE__), 'w') do |f|
    cast = open("https://asciinema.org/a/#{id}.cast").readlines.map do |r|
      # remove redundant timing precision
      r.gsub(/(\[\d+\.\d{2})\d+/, '\1')
    end.join
    f.puts cast
  end
end

def get_poster(id)
  poster = Nokogiri::HTML.parse(open("https://asciinema.org/a/#{id}/embed?size=small"))
                         .xpath('//asciinema-player')
                         .first[:poster]
  open(File.expand_path("../../source/casts/#{id}.poster", __FILE__), 'w') do |f|
    f.puts poster
  end
end

CASTS_IDS.each do |id|
  get_cast(id)
  get_poster(id)
end
