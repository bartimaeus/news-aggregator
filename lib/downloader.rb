require 'redis'
require 'json'
require 'zip'
require 'crack'
require 'httparty'
require './lib/omgili_scraper'

module NewsAggregator
  class Downloader
    def initialize(url, redis_config = {})
      self.base_url = url
      self.files = []
      self.stories = []
      self.redis = Redis.new(redis_config)
    end

    def scrape(number_of_files = 1)
      files = NewsAggregator::OmgiliScraper.new.crawl(base_url)

      # sanitize and sort by most recently added
      ordered_files = files["rows"].reverse.keep_if { |v| !v["date_added"].nil? && v["filename"] != "Parent Directory" }

      if number_of_files
        puts "Parsing #{number_of_files} newest archives. Sit back and relax...".yellow
        self.files = ordered_files[0..number_of_files]

      # default to only parsing one file
      else
        puts ":total_files_to_parse not specified. Only parsing most recent news archive".yellow
        self.files = [ordered_files.first]
      end
    end

    # Download, save, and remove temporary files
    def process
      files.each do |file|
        # downloads, extracts, and saves stories in self.stories
        fetch(file)

        # save all of the stories from the file
        stories.each { |story| save(story) }

        # reset stories
        stories = []
      end
    end

    # Download zipped file. Save the contained stories in self.stories
    #
    # expecting the following format for files:
    # files = [
    #   {
    #     "filename"   => "1485889401568.zip",
    #     "date_added" => "31-Jan-2017 21:07",
    #     "file_size"  => "9.9M"
    #   },
    #   {...}
    # ]
    def fetch(file)
      # puts "Downloading file #{file["filename"]}".yellow
      # create a temporary file of the zip we are fetching
      tmp_file = Tempfile.new("file")
      tmp_file.binmode # This might not be necessary depending on the zip file
      tmp_file.write(HTTParty.get("#{base_url}/#{file["filename"]}").body)
      tmp_file.close

      ::Zip::File.open(tmp_file.path) do |files|
        files.each do |content|
          # save story information into self.stories
          self.stories << format_story(files.read(content))
        end
      end

      # delete the temporary file
      tmp_file.unlink
    end

    def format_story(story)
      Crack::XML.parse(story)
    end

    # The post_url seems unique for each post so we'll use that for the redis key
    def save(story)
      # add the record to redis
      key = "news-aggregator|#{story["document"]["post_url"]}"
      redis.set(key, story.to_json) unless redis.get(key)
    end

    protected
    attr_accessor :base_url, :files, :stories, :redis
  end
end
