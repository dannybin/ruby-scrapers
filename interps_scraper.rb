require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rethinkdb'
require 'time'
include RethinkDB::Shortcuts

ROOT = "http://www.sec.gov"
SEC_IM_NOACTION_URL = "http://www.sec.gov/divisions/investment/im-noaction.shtml"
SEC_MKT_NOACTION_URL = "http://www.sec.gov/divisions/marketreg/mr-noaction.shtml"


sec_im_noaction_page = Nokogiri::HTML(open(SEC_IM_NOACTION_URL))
sec_mkt_noaction_page = Nokogiri::HTML(open(SEC_MKT_NOACTION_URL))

sec_im_noaction_data = sec_im_noaction_page.css('p b')
sec_mkt_noaction_data_raw = sec_mkt_noaction_page.css('p b')
sec_mkt_noaction_data = sec_mkt_noaction_data_raw[1..-2]
sec_mkt_interps_data = sec_mkt_noaction_page.css('h3')

agency  = {'SEC'=>466}

sources = [{:source=>agency['SEC'],:data=>sec_im_noaction_data}, {:source=>agency['SEC'],:data=>sec_mkt_noaction_data}]

r.connect(:host=>"162.242.238.193", :port=>28015).repl
r.db("jurispect").table("interps").run

def scraper(source, data) 
 begin
    for i in 0..data.length do
      curr_category = data[i].text
      articles = data[i].parent.next_element.css('li')

      begin
        for j in 0..articles.length do
          curr_title = articles[j].css('a').text
          curr_link = ROOT + articles[j].css('a')[0]['href']
          parse_date = articles[j].text.split(',')
          curr_date = [parse_date[-2], parse_date[-1]].join(',')

          date_diff = (Time.now - Time.parse(curr_date))
          
          if date_diff < 43200
            r.db("jurispect").table("interps").insert([{"title"=> curr_title, "link"=> curr_link,
            "topic"=> curr_category, "publication_date"=>Time.parse(curr_date), "creation_time"=>Time.now, 
            "source"=>source}]).run
          end
        end
      rescue
      end
    end
  rescue
  end
end

for src in sources do
  scraper(src[:source], src[:data])
end

# Due to different DOM structure, one off scraper for SEC tradig and market interpretive letter
begin
  for i in 0..sec_mkt_interps_data.length do
    curr_category = sec_mkt_interps_data[i].text
    articles = sec_mkt_interps_data[i].next_element.css('li')

    begin
      for j in 0..articles.length do
        curr_title = articles[j].css('a').text
        curr_link = ROOT + articles[j].css('a')[0]['href']
        parse_date = articles[j].text.split(',')
        curr_date = [parse_date[-2], parse_date[-1]].join(',')

        date_diff = (Time.now - Time.parse(curr_date))
        
        if date_diff < 43200
          r.db("jurispect").table("interps").insert([{"title"=> curr_title, "link"=> curr_link,
          "topic"=> curr_category, "publication_date"=>Time.parse(curr_date), "creation_time"=>Time.now, 
          "source"=>agency['SEC']}]).run
        end
      end
    rescue
    end
  end
rescue
end