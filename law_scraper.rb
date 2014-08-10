require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rethinkdb'
require 'time'
include RethinkDB::Shortcuts

LAW_URL = 'https://beta.congress.gov/legislation?q=bill-status:law&pageSize=500&page='


r.connect(:host=>"162.242.238.193", :port=>28015).repl
laws = []
for page in 1..23 do
  curr_law_url = LAW_URL + page.to_s
  law_page = Nokogiri::HTML(open(curr_law_url))
  law_names = law_page.css('li h3')

  law_names.each do |name|
    law_grams = name.text.upcase
    law_grams = law_grams.gsub 'OF', ''
    law_grams = law_grams.gsub 'THE', ''
    law_grams = law_grams.gsub 'AND', ''
    law_grams = law_grams.gsub 'TO', ''
    law = name.text
    
    r.db('jurispect').table('laws').insert({'active'=>true, 'created'=>Time.now, 'law'=>law, 
        'law_grams'=>law_grams, 'precision'=>1}).run
  end
end





