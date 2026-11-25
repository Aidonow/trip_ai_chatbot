class ResultsController < ApplicationController
require "json"
require "net/http"
require "uri"

def create
  @chat = current_user.chats.find(params[:chat_id])
  message = @chat.messages.where(role: "assistant").find(params[:message_id])

  @result = @chat.generate_result_from_message(message)

  if @result
    redirect_to result_path(@result), notice: "Destination saved."
  else
    redirect_to chat_path(@chat), alert: "Please confirm a trip with a destination, budget and duration."
  end
rescue JSON::ParserError, RubyLLM::Error
  redirect_to chat_path(@chat), alert: "We couldn't read the trip details. Please try again."
end

  def show
    @chat = current_user.chats.find_by!(result_id: params[:id])
    @result = @chat.result
    @result_image = country_image_url(@result.destination)
  end

  def show
    @chat = current_user.chats.find_by!(result_id: params[:id])
    @result = @chat.result
    @result_image = country_image_url(@result.destination)
  end

  def destroy
    @chat = current_user.chats.find_by!(result_id: params[:id])
    @result = @chat.result

    @result.destroy!
    redirect_to root_path, notice: "Result was successfully deleted."
  end

  private

  def result_params
    params.require(:result).permit(:content, :destination, :price, :time)
  end

  def country_image_url(destination)
    city = destination.to_s.strip.split(",").first.to_s.strip
    return nil if city.blank?

    Rails.cache.fetch(["trip-city-image-v3", city.downcase], expires_in: 7.days) do
      params = URI.encode_www_form(
        action: "query",
        titles: city,
        redirects: 1,
        prop: "pageimages",
        piprop: "thumbnail",
        pithumbsize: 900,
        format: "json",
        origin: "*"
      )

      uri = URI("https://en.wikipedia.org/w/api.php?#{params}")
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

      next nil unless response.is_a?(Net::HTTPSuccess)

      pages = JSON.parse(response.body).dig("query", "pages") || {}
      pages.values
           .sort_by { |page| page["index"].to_i }
           .filter_map { |page| page.dig("thumbnail", "source") }
           .first
    rescue JSON::ParserError, Net::OpenTimeout, Net::ReadTimeout, SocketError
      nil
    end
  end
end
