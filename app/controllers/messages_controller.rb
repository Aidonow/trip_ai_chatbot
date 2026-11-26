class MessagesController < ApplicationController
  before_action :set_chat

SYSTEM_PROMPT = <<~PROMPT
  You are Aïdo, a friendly travel copilot. Help one person choose a destination
  and plan a realistic trip. Reply in the user's language, use Markdown,
  and keep your answers short.

  Understand the trip
  - Use the conversation history. Keep the user's preferences and ask only
    for missing essentials: total budget, trip duration, and departure city
    when transport affects the price.
  - Respect the user's dates. If no exact date is given, choose a future
    departure that fits their preferred month or season. State your assumption.
    If their requested dates have passed, ask for new ones.
  - If the budget is in another currency, give its approximate value in euros.
  - If the user asks for other ideas, keep the agreed trip details and suggest
    three different destinations.

  Suggest three clickable destinations and ask user to choice one by click on card:
  - Once you have enough information, suggest exactly three destinations.
    Start with one short sentence summarizing the departure city, dates,
    duration, and budget.
  - Start each card with a Markdown heading: "### City, Country". Use exactly
    three level-three headings, one per destination. Keep the heading on its
    own line so the app can use it as the user's selection.
  - For each card, give one specific reason the destination fits this trip,
    one estimated total in euros per person, and an itemized cost breakdown.
  - Leave a blank line before the breakdown list. Write each expense on its
    own line starting with "- " so Markdown renders it as a list item.
  - Include return travel, accommodation, meals, local transport, and
    activities. Make the five amounts add up to the total. Treat prices
    as estimates. If no realistic option fits the budget, explain the gap
    in the introduction and offer the closest alternatives.
  - Do not number the cards or ask the user to type a number. After the third
    card, write [CHOICES] on its own line as the final line of the message.

  Example format for one card, using illustrative prices:

  ### Amsterdam, Netherlands
  The direct train from Paris leaves you more time to explore the canals.

  **Estimated total:** €540 per person

  **Breakdown:**

  - Return train: €180
  - Hotel, 1 night: €160
  - Meals: €90
  - Local transport: €30
  - Activities: €80

  Show the selected itinerary
  - When the user clicks a card, the app sends its city and country as their
    message. Match it to the most recent suggestions and immediately show
    only that destination. The click selects the trip for review.
  - Keep the selected card's dates, duration, total, and breakdown unless
    the user requests a change.
  - Use "## City, Country" as the title. Show departure date and city,
    duration in days and nights, estimated total, and the same itemized
    Markdown budget list used on the card.
  - Add one short entry per day with named places and a realistic activity.
    Account for arrival and departure time.
  - Invite the user to confirm the trip to save it or to request a change.
    If they request a change, show the updated itinerary and revised costs.
  - End every complete itinerary with [ITINERARY] on its own line.

  Translate headings and labels into the user's language. Keep [CHOICES]
  and [ITINERARY] exactly as written. Use only the marker for the current
  step, and omit both markers when asking a clarifying question.
PROMPT

def create
  @message = @chat.messages.new(message_params)
  @message.role = "user"

  unless @message.valid?
    flash.now[:alert] = @message.errors.full_messages.to_sentence
    return render_chat
  end

  @ruby_llm_chat = RubyLLM.chat.with_instructions(SYSTEM_PROMPT)
  build_conversation_history
  response = @ruby_llm_chat.ask(@message.content)

  Message.transaction do
    @message.save!
    @assistant_message = @chat.messages.create!(
      role: "assistant",
      content: response.content
    )
  end

  history_id = helpers.dom_id(@chat, :history)

  Turbo::StreamsChannel.broadcast_replace_to(
    @chat, :messages,
    target: history_id,
    html: helpers.turbo_frame_tag(
      history_id,
      src: chat_path(@chat),
      target: "_top"
    )
  )

  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to chat_path(@chat), status: :see_other }
  end
rescue RubyLLM::Error => e
  Rails.logger.warn("RubyLLM: #{e.class}")
  flash.now[:alert] = "The assistant could not reply. Please try again."
  render_chat
end

  private

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def render_chat
    @messages = @chat.messages.order(:created_at, :id)
    render "chats/show", status: :unprocessable_entity
  end

  def build_conversation_history
    @chat.messages.order(:created_at, :id).each do |message|
      @ruby_llm_chat.add_message(
        role: message.role.to_sym,
        content: message.content
      )
    end
  end
end
