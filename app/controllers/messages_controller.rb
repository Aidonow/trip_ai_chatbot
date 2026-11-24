class MessagesController < ApplicationController
  before_action :set_chat

  def create
    @message = @chat.messages.new(message_params)
    @message.role = "user"

    if @message.save
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
