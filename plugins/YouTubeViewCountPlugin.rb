require_relative 'Plugin'
require 'net/http'
require 'nokogiri'
require 'uri'

class YouTubeViewCountPlugin < Plugin
    attr_reader :data, :username
      
    def initialize(data)
        @data = data
        @username = data[0]["username"]
    end

    def execute
        return load_yt_views("https://www.youtube.com/@{@username}")
    end


    def load_yt_views(url, limit = 10)
        return 0 if limit.zero?

        uri = URI(url)
        response = Net::HTTP.get_response(uri)
        case response
        when Net::HTTPSuccess then
            document = Nokogiri::HTML(response.body)

            view_count_element = document.at('td.style-scope ytd-about-channel-renderer')
           view_count = view_count_element&.text&.split(' ')&.first

            return view_count || 0
        when Net::HTTPRedirection then
          location = response['location']
          return load_medium_followers(location, limit - 1)
        else
            return 0
        end
    end

end
