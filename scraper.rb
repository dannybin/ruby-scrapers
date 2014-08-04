require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rethinkdb'
require 'time'
include RethinkDB::Shortcuts

DB_URL = "http://dealbook.nytimes.com/feed/"
DB_LEGAL_URL = "http://dealbook.nytimes.com/category/main-topics/legal/feed/"
WSJ_URL = "http://blogs.wsj.com/law/feed/"
WSJ_RNC_URL = "http://blogs.wsj.com/riskandcompliance/feed/"
BBL_URL = "http://about.bloomberglaw.com/category/legal-news/feed/"
SCOTUS_URL = "http://www.scotusblog.com/feed/"
FT_URL = "http://www.ft.com/rss/home/us"
LAW_URL = "http://feeds.feedburner.com/LawTechnologyNews-News"
LAT_URL = "http://feeds.latimes.com/latimes/news?format=xml"
NYT_URL = "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"
NYT_BIZ_URL = "http://rss.nytimes.com/services/xml/rss/nyt/Business.xml"
LD_URL = "http://feeds.feedblitz.com/Litigation-Daily"
NLJ_LAW_URL = "http://feeds.feedburner.com/law/nlj/LawFirms?format=xml"
FORBES_URL = "http://www.forbes.com/real-time/feed2/"
FORBES_BIZ_URL = "http://www.forbes.com/business/feed/"
WPO_FED_URL = "http://feeds.washingtonpost.com/rss/rss_federal-eye"
WPO_LOOP_URL = "http://feeds.washingtonpost.com/rss/rss_in-the-loop"
RTR_NEWS_URL = "http://feeds.reuters.com/reuters/topNews?format=xml"
RTR_REG_URL = "http://feeds.reuters.com/reuters/governmentfilingsNews?format=xml"
RTR_FRM_URL = "http://feeds.reuters.com/reuters/blogs/FinancialRegulatoryForum?format=xml"
IC_URL = "http://www.insidecounsel.com/?f=rss"
NC_URL = "http://feeds.feedburner.com/NakedCapitalism?format=xml"
BW_TOP_URL = "http://www.businessweek.com/feeds/most-popular.rss"
TP_URL = "http://thinkprogress.org/feed/"
GUARD_URL = "http://feeds.theguardian.com/theguardian/us/rss"
TIME_URL = "http://feeds.feedburner.com/time/business?format=xml"
CNET_URL = "http://news.cnet.com/8300-13578_3-38.xml"
GOOG_REG_URL = "https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&q=regulatory&output=rss"
GOOG_GCR_URL = "https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&q=compliance&output=rss"

db_page = Nokogiri::XML(open(DB_URL))
db_legal_page = Nokogiri::XML(open(DB_LEGAL_URL))
wsj_page = Nokogiri::XML(open(WSJ_URL))
wsj_rnc_page = Nokogiri::XML(open(WSJ_RNC_URL))
bbl_page = Nokogiri::XML(open(BBL_URL))
scotus_page = Nokogiri::XML(open(SCOTUS_URL))
ft_page = Nokogiri::XML(open(FT_URL))
law_page = Nokogiri::XML(open(LAW_URL))
lat_page = Nokogiri::XML(open(LAT_URL))
nyt_page = Nokogiri::XML(open(NYT_URL))
nyt_biz_page = Nokogiri::XML(open(NYT_BIZ_URL))
ld_page = Nokogiri::XML(open(LD_URL))
nlj_law_page = Nokogiri::XML(open(NLJ_LAW_URL))
forbes_page = Nokogiri::XML(open(FORBES_URL))
forbes_biz_page = Nokogiri::XML(open(FORBES_BIZ_URL))
wpo_fed_page = Nokogiri::XML(open(WPO_FED_URL))
wpo_loop_page = Nokogiri::XML(open(WPO_LOOP_URL))
rtr_news_page = Nokogiri::XML(open(RTR_NEWS_URL))
rtr_reg_page = Nokogiri::XML(open(RTR_REG_URL))
rtr_frm_page = Nokogiri::XML(open(RTR_FRM_URL))
ic_page = Nokogiri::XML(open(IC_URL))
nc_page = Nokogiri::XML(open(NC_URL))
bw_top_page = Nokogiri::XML(open(BW_TOP_URL))
tp_page = Nokogiri::XML(open(TP_URL))
guard_page = Nokogiri::XML(open(GUARD_URL))
time_page = Nokogiri::XML(open(TIME_URL))
cnet_page = Nokogiri::XML(open(CNET_URL))
goog_reg_page = Nokogiri::XML(open(GOOG_REG_URL))
goog_gcr_page = Nokogiri::XML(open(GOOG_GCR_URL))

db_articles = db_page.css('item')
db_legal_articles = db_legal_page.css('item')
wsj_articles = wsj_page.css('item')
wsj_rnc_articles = wsj_rnc_page.css('item')
bbl_articles = bbl_page.css('item')
scotus_articles = scotus_page.css('item')
ft_articles = ft_page.css('item')
law_articles = law_page.css('item')
lat_articles = lat_page.css('item')
nyt_articles = nyt_page.css('item')
nyt_biz_articles = nyt_biz_page.css('item')
ld_articles = ld_page.css('item')
nlj_law_articles = nlj_law_page.css('item')
forbes_articles = forbes_page.css('item')
forbes_biz_articles = forbes_biz_page.css("item")
wpo_fed_articles = wpo_fed_page.css("item")
wpo_loop_articles = wpo_loop_page.css("item")
rtr_news_articles = rtr_news_page.css('item')
rtr_reg_articles = rtr_reg_page.css('item')
rtr_frm_articles = rtr_frm_page.css('item')
ic_articles = ic_page.css('item')
nc_articles = nc_page.css('item')
bw_top_articles = bw_top_page.css('item')
tp_articles = tp_page.css('item')
guard_articles = guard_page.css('item')
time_articles = time_page.css('item')
cnet_articles = cnet_page.css('item')
goog_reg_articles = goog_reg_page.css('item')
goog_gcr_articles = goog_gcr_page.css('item')

sources = [{:source=>"DealBook",:article=>db_articles}, {:source=>"DealBook", :article=>db_legal_articles},
           {:source=>"Wall Street Journal", :article=>wsj_articles}, {:source=>"Wall Street Journal", :article=>wsj_rnc_articles},
           {:source=>"Bloomberg Law", :article=>bbl_articles}, {:source=>"Scotus Blog", :article=>scotus_articles},
           {:source=>"Financial Times", :article=>ft_articles}, {:source=>"Forbes", :article=>forbes_articles},
           {:source=>"Forbes", :article=>forbes_biz_articles}, {:source=>"Washington Post", :article=>wpo_fed_articles},
           {:source=>"Washington Post", :article=>wpo_loop_articles}, {:source=>"Reuters", :article=>rtr_news_articles},
           {:source=>"Reuters", :article=>rtr_frm_articles}, {:source=>"Inside Counsel", :article=>ic_articles},
           {:source=>"Naked Capitalism", :article=>nc_articles}, {:source=>"Think Progress", :article=>tp_articles},
           {:source=>"The Guardian", :article=>guard_articles}, {:source=>"CNET", :article=>cnet_articles}]

r.connect(:host=>"162.242.238.193", :port=>28015).repl
r.db("jurispect").table("news").run


def scraper(source, articles) 
  begin
    for i in 0..articles.length do
      curr_link = articles[i].css("link").text
      curr_title = articles[i].css("title").text
      curr_topics = articles[i].css("category").map(&:text)
      curr_pubdate = articles[i].css("pubDate").text
      curr_author = articles[i].xpath("dc:creator").text
      curr_summary = articles[i].css("description").text

      date_diff = (Time.now - Time.parse(curr_pubdate))
      
      if date_diff < 7200
        r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
         "topics"=> curr_topics, "publication_date"=>curr_pubdate, "author"=>curr_author,
         "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>source}]).run
      end
    end
  rescue
  end
end

for src in sources do
  scraper(src[:source], src[:article])
end

# seperate scraper for Law.com content due to different XML format
begin
  for i in 0..law_articles.length do
    curr_link = law_articles[i].css("link").text
    curr_title = law_articles[i].css("title").text
    curr_topics = law_articles[i].css("category").map(&:text)
    curr_pubdate = law_articles[i].css("pubDate").text
    curr_summary = law_articles[i].css("description").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
  
    if date_diff < 7200
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate,
       "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>"Law Technology News"}]).run
    end
  end
rescue
end

# seperate scraper for LA Time content due to different XML format
begin
  for i in 0..lat_articles.length do
    curr_link = lat_articles[i].css("link").text
    curr_title = lat_articles[i].css("title").text
    curr_topics = lat_articles[i].css("category").map(&:text)
    curr_pubdate = lat_articles[i].css("pubDate").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
  
    if date_diff < 7200
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate, "creation_time"=>Time.now,
       "source"=> "LA Times"}]).run
    end
  end
rescue
end

# seperate scraper for NY Times content due to different XML format
begin
  for i in 0..nyt_articles.length do
    curr_link = nyt_articles[i].css("link").text
    curr_title = nyt_articles[i].css("title").text
    curr_topics = nyt_articles[i].css("category").map(&:text)
    curr_pubdate = nyt_articles[i].css("pubDate").text
    curr_summary = nyt_articles[i].css("description").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
  
    if date_diff < 7200
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate,
       "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>"New York Times"}]).run
    end
  end
rescue
end

# seperate scraper for NY Times Business content due to different XML format
begin
  for i in 0..nyt_biz_articles.length do
    curr_link = nyt_biz_articles[i].css("link").text
    curr_title = nyt_biz_articles[i].css("title").text
    curr_topics = nyt_biz_articles[i].css("category").map(&:text)
    curr_pubdate = nyt_biz_articles[i].css("pubDate").text
    curr_summary = nyt_biz_articles[i].css("description").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
  
    if date_diff < 7200
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate,
       "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>"New York Times Business"}]).run
    end
  end
rescue
end

# seperate scraper for Litigation Daily content due to different XML format
begin
  for i in 0..ld_articles.length do
    curr_link = ld_articles[i].css("link").text
    curr_title = ld_articles[i].css("title").text
    curr_topics = ld_articles[i].css("category").map(&:text)
    curr_pubdate = ld_articles[i].css("pubDate").text
    curr_author = ld_articles[i].css("author").text
    curr_summary = ld_articles[i].css("description").text
    date_diff = (Time.now - Time.parse(curr_pubdate))
    
    if date_diff < 7200
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate, "author"=>curr_author,
       "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>"Litigation Daily"}]).run
    end
  end
rescue
end

# seperate scraper for National Law Journal content due to different XML format
begin
  for i in 0..nlj_law_articles.length do
    curr_link = nlj_law_articles[i].css("link").text
    curr_title = nlj_law_articles[i].css("title").text
    curr_topics = nlj_law_articles[i].css("category").map(&:text)
    curr_pubdate = nlj_law_articles[i].css("pubDate").text
    curr_summary = nlj_law_articles[i].css("description").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
  
    if date_diff < 7200
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate,
       "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>"National Law Journal"}]).run
    end
  end
rescue
end

# seperate scraper for Reuter Regulatory content due to different XML format
begin
  for i in 0..rtr_reg_articles.length do
    curr_link = rtr_reg_articles[i].css("link").text
    curr_title = rtr_reg_articles[i].css("title").text
    curr_topics = rtr_reg_articles[i].css("category").map(&:text)
    curr_pubdate = rtr_reg_articles[i].css("pubDate").text
    curr_summary = rtr_reg_articles[i].css("description").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
  
    if date_diff < 7200
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate,
       "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>"Reuters"}]).run
    end
  end
rescue
end

# seperate scraper for Business Week Top content due to different XML format
begin
  for i in 0..bw_top_articles.length do
    curr_link = bw_top_articles[i].css("link").text
    curr_title = bw_top_articles[i].css("title").text
    curr_topics = bw_top_articles[i].css("category").map(&:text)
    curr_pubdate = bw_top_articles[i].css("pubDate").text
    curr_summary = bw_top_articles[i].css("description").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
    results[i] = {link: curr_link, title: curr_title, topics: curr_topics,
                 publication_date: curr_pubdate, author: curr_author, summary: curr_summary}
    
    if date_diff < 7200 
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate, "author"=>curr_author,
       "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>"Business Week"}]).run
    end
  end
rescue
end

# seperate scraper for TIME content due to different XML format
begin
  for i in 0..time_articles.length do
    curr_link = time_articles[i].css("link").text
    curr_title = time_articles[i].css("title").text
    curr_topics = time_articles[i].css("category").map(&:text)
    curr_pubdate = time_articles[i].css("pubDate").text
    curr_summary = time_articles[i].css("description").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
  
    if date_diff < 7200
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate,
       "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>"TIME"}]).run
    end
  end
rescue
end

# seperate scraper for Google News Regulatory content due to different XML format
begin
  for i in 0..goog_reg_articles.length do
    curr_link = goog_reg_articles[i].css("link").text
    curr_title = goog_reg_articles[i].css("title").text
    curr_topics = goog_reg_articles[i].css("category").map(&:text)
    curr_pubdate = goog_reg_articles[i].css("pubDate").text
    curr_summary = goog_reg_articles[i].css("description").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
  
    if date_diff < 7200
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate,
       "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>"Law Technology News"}]).run
    end
  end
rescue
end

# seperate scraper for Google News Regulatory content due to different XML format
begin
  for i in 0..goog_gcr_articles.length do
    curr_link = goog_gcr_articles[i].css("link").text
    curr_title = goog_gcr_articles[i].css("title").text
    curr_topics = goog_gcr_articles[i].css("category").map(&:text)
    curr_pubdate = goog_gcr_articles[i].css("pubDate").text
    curr_summary = goog_gcr_articles[i].css("description").text

    date_diff = (Time.now - Time.parse(curr_pubdate))
  
    if date_diff < 7200
      r.db("jurispect").table("news").insert([{"title"=> curr_title, "link"=> curr_link,
       "topics"=> curr_topics, "publication_date"=>curr_pubdate,
       "summary"=>curr_summary, "creation_time"=>Time.now, "source"=>"Law Technology News"}]).run
    end
  end
rescue
end
