class MessagesController < ApplicationController
  before_action :set_chat

SYSTEM_PROMPT = <<~PROMPT
  You are a travel assistant helping one person choose a destination.
  Reply in the user's language, use Markdown, and keep answers short.

  Use the conversation history. Ask only for missing essentials: total budget,
  trip duration, and departure city if transport affects the price. If no date
  is given, suggest a future departure date and say it is your assumption.
  If the budget is in another currency, show its approximate value in euros.

  Suggest exactly 3 numbered destinations. For each, give the city and country,
  one reason it fits the trip, and the estimated total cost in euros for one
  person. Include return transport, accommodation, meals, and activities.
  If none fits the budget, explain the gap before offering alternatives.

  Ask the user to choose 1, 2, or 3. End this message with [CHOICES] on its
  own line so the app can display the three buttons.

  When the user chooses, use the numbering from your last list. Show only
  the selected trip, following this Markdown example in the user's language:

  ## Rome, Italy
  **Departure:** 15 January 2027 from Paris
  **Duration:** 3 days / 2 nights
  **Estimated total:** €650 per person
  **Breakdown:** €180 return travel + €220 accommodation + €120 meals
  + €50 local transport + €80 activities.

  - **Day 1:** Walk from Piazza Navona to the Pantheon.
  - **Day 2:** Visit the Colosseum and have dinner in Trastevere.
  - **Day 3:** Explore Testaccio Market before returning to Paris.

  Use the actual trip details. Make the breakdown add up to one numeric
  total in euros. Invite the user to confirm or request a change.
  Use [CHOICES] only after a list of three destinations.
PROMPT

  def create
    @message = @chat.messages.new(message_params)
    @message.role = "user"

    unless @message.valid?
      flash.now[:alert] = @message.errors.full_messages.to_sentence
      return render_chat
    end

    chatbot = RubyLLM.chat.with_instructions(SYSTEM_PROMPT)

    @chat.messages.order(:created_at, :id).each do |message|
      chatbot.add_message(role: message.role.to_sym, content: message.content)
    end
    response = chatbot.ask(@message.content)

    Message.transaction do
      @message.save!
      @chat.messages.create!(role: "assistant", content: response.content)
    end

    redirect_to chat_path(@chat), status: :see_other
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
end
