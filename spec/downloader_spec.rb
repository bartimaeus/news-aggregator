require 'spec_helper'
require_relative '../lib/downloader'

describe "downloader" do
  before(:all) do
    @downloader = NewsAggregator::Downloader.new("http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/")
  end

  context "#scrape"  do
    it "should return a zip archive" do
      VCR.use_cassette('zip archive of new stories') do
        @downloader.scrape(1)
      end
    end
  end
end
