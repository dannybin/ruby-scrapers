#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rethinkdb'
require 'time'
include RethinkDB::Shortcuts

TREASURY = "http://www.treasury.gov"

FR_PR_URL = "http://www.federalreserve.gov/feeds/press_all.xml"
FR_SPEECH_URL="http://www.federalreserve.gov/feeds/speeches.xml"
TREA_PR_URL="http://www.treasury.gov/press-center/press-releases/Pages/default.aspx"
TREA_DG_URL="http://www.treasury.gov/press-center/daily-guidance/Pages/default.aspx"

fr_pr_page = Nokogiri::XML(open(FR_PR_URL))
fr_speech_page = Nokogiri::XML(open(FR_SPEECH_URL))
trea_pr_page = Nokogiri::HTML(open(TREA_PR_URL))
trea_dg_page = Nokogiri::HTML(open(TREA_DG_URL))

fr_pr_articles = fr_pr_page.css('item')
fr_speech_articles = fr_speech_page.css('item')
trea_pr_articles = trea_pr_page.css('.datarow')
trea_dg_articles = trea_dg_page.css('.datarow')

agencies = {"Treasury" =>497, "Federal Reserve"=>188}
sources = [{:source=>"Federal Reserve", :article=>fr_pr_articles}]

r.connect(:host=>"162.242.238.193", :port=>28015).repl
r.db("jurispect").table("press_releases").run

def scraper(source, articles) 
  agencies = {"Treasury" =>497, "Federal Reserve"=>188}
  begin
    for i in 0..articles.length do
      curr_link = articles[i].css("link").text
      curr_title = articles[i].css("title").text
      curr_topics = articles[i].xpath("cb:news").xpath("cb:keyword").text
      curr_pubdate = articles[i].xpath("dc:date").text
      curr_summary = articles[i].css("description").text

      date_diff = (Time.now - Time.parse(curr_pubdate))
      if date_diff < 86400   
        r.db("jurispect").table("press_releases").insert([{"title"=> curr_title, "link"=> curr_link,
         "topics"=> curr_topics, "publication_date"=>curr_pubdate, "summary"=>curr_summary, 
         "creation_time"=>Time.now, "source"=>source, "agency"=>agencies[source]}]).run
      end
    end
  rescue
  end
end

for src in sources do
  scraper(src[:source], src[:article])
end

#Separate scraper for federal reserve speeches due to different xlm format
begin
  for i in 0..fr_speech_articles.length do
    curr_link = fr_speech_articles[i].css("link").text
    curr_title = fr_speech_articles[i].css("title").text
    curr_pubdate = fr_speech_articles[i].xpath("dc:date").text
    curr_summary = fr_speech_articles[i].css("description").text
    curr_author = fr_speech_articles[i].xpath('cb:speech').xpath('cb:person').xpath("cb:nameAsWritten").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
    if date_diff < 86400    
      r.db("jurispect").table("press_releases").insert([{"title"=> curr_title, "link"=> curr_link,
       "author"=> curr_author, "publication_date"=>curr_pubdate, "summary"=>curr_summary, 
       "creation_time"=>Time.now, "source"=>"Federal Reserve", "agency"=>188}]).run
    end
  end
rescue
end

#Separate scraper for treasury press releases due to different html format
begin
  for i in 0..trea_pr_articles.length do
    sub_link = trea_pr_articles[i].css('a').map{ |link| link['href'] }[0]
    curr_link = TREASURY + sub_link
    curr_title = trea_pr_articles[i].css("a").text
    curr_pubdate = Time.strptime(trea_pr_articles[i].css(".firstcol").text, "%m/%d/%Y")
    
    date_diff = (Time.now - curr_pubdate)
    if date_diff < 86400  
      r.db("jurispect").table("press_releases").insert([{"title"=> curr_title, "link"=> curr_link,
       "publication_date"=>curr_pubdate, "creation_time"=>Time.now, "source"=>"Treasury", "agency"=>497}]).run
    end
  end
rescue
end

#Separate scraper for treasury daily guidance due to different html format
begin
  for i in 0..trea_dg_articles.length do
    sub_link = trea_dg_articles[i].css('a').map{ |link| link['href'] }[0]
    curr_link = TREASURY + sub_link
    curr_pubdate = Time.strptime(trea_dg_articles[i].css("a").text, "%m/%d/%Y")
    curr_title = trea_dg_articles[i].css('a').map{ |title| title['title']}[0]
    
    date_diff = (Time.now - curr_pubdate)
    if date_diff < 86400
      r.db("jurispect").table("press_releases").insert([{"title"=> curr_title, "link"=> curr_link,
       "publication_date"=>curr_pubdate, "creation_time"=>Time.now, "source"=>"Treasury", "agency"=>497}]).run
    end
  end
rescue
end
