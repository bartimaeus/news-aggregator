require 'colorize'
require './lib/downloader'

task :fetch, [:total_files_to_parse] do |t, args|
  begin
    puts "Checking for new zips files on omgili.com...".green
    total_files_to_parse = !args[:total_files_to_parse].nil? && args[:total_files_to_parse].to_i || nil
    downloader = NewsAggregator::Downloader.new("http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/")
    downloader.scrape(total_files_to_parse)
    downloader.process
    puts "Done.".green
  rescue Exception => e
    puts "Error: #{e.to_s}"
  end
end
