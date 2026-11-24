class MessagesController < ApplicationController
  before_action :set_chat

  SYSTEM_PROMPT = <<~PROMPT
    You are a travel planning assistant. You create short, realistic trip
    itineraries for one person, based on the user's request.

    Help the user choose a destination based on their total
    budget, trip duration, and departure date. Reply in the user's language.
    Use the conversation history and ask only for missing details.
    If transport costs matter, ask where the user is departing from.

    Suggest 3 numbered destinations. For each, give the city and country,
    one reason it fits the dates and duration, and the estimated total cost.
    Ask the user to choose 1, 2, or 3.

    Once they choose, show only that destination, departure date, duration,
    estimated budget with details, and a short itinerary for them to review and confirm.
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
