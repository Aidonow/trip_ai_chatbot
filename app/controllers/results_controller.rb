class ResultsController < ApplicationController
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
end
