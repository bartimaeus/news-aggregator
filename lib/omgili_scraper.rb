#coding: utf-8
require 'wombat'

module NewsAggregator
  class OmgiliScraper
    include Wombat::Crawler

    path "/"

    rows "xpath=//table//tr", :iterator do
      filename 'xpath=.//td[1]//a'
      date_added 'xpath=.//td[2]'
      file_size 'xpath=.//td[3]'
    end

    private
    attr_accessor :base_url
  end
end
