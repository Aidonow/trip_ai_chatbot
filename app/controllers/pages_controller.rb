class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home
  require "json"
  require "net/http"
  require "uri"

  def home
    @results = if user_signed_in?
                 Result.where(id: current_user.chats.select(:result_id))
                       .order(created_at: :desc)
               else
                 Result.none
               end

    @result_images = @results.index_with { |result| country_image_url(result.destination) }
  end

  private

  def country_image_url(destination)
    destination = destination.to_s.strip
    return nil if destination.blank?

    city = destination.split(",").first.to_s.strip
    return nil if city.blank?

    Rails.cache.fetch(["trip-city-image-v3", city.downcase], expires_in: 7.days) do
      wikipedia_image(city)
    end
  end

  def wikipedia_image(destination)
    params = URI.encode_www_form(
      action: "query",
      titles: destination,
      redirects: 1,
      prop: "pageimages",
      piprop: "thumbnail",
      pithumbsize: 900,
      format: "json",
      origin: "*"
    )

    data = api_json("https://en.wikipedia.org/w/api.php?#{params}")
    pages = data.dig("query", "pages") || {}

    pages.values
         .sort_by { |page| page["index"].to_i }
         .filter_map { |page| page.dig("thumbnail", "source") }
         .first
  end

  def api_json(url)
      uri = URI(url)
      response = Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: true,
        open_timeout: 3,
        read_timeout: 5
      ) do |http|
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "TripAIChatbot/1.0"
        http.request(request)
      end

      return {} unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue JSON::ParserError, Net::OpenTimeout, Net::ReadTimeout, SocketError
      {}
  end
end
