#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
  # Nokogiri::HTML(open(url).read, nil, 'utf-8')
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('.//table[contains(@class,"top-candidates-by-votes")][1]//tr[td]').take(9).each do |tr|
    tds = tr.css('td')
    data = { 
      name: tds[2].text.tidy,
      party: tds[3].text.tidy,
      image: tds[1].css('img/@src').text,
      term: 1,
      source: url,
    }
    data[:image] = URI.join(url, URI.escape(data[:image])).to_s unless data[:image].to_s.empty?
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

term = { 
  id: 1,
  name: "1st Legislative Assembly",
  start_date: '2014',
  source: 'https://en.wikipedia.org/wiki/Legislative_Assembly_of_Montserrat',
}
ScraperWiki.save_sqlite([:id], term, 'terms')

scrape_list('http://www.elections.ms/')
