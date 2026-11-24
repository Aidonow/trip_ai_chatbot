class ResultsController < ApplicationController
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @result = Result.new(result_params)

    saved = Result.transaction do
      if @result.save && @chat.update(result: @result)
        true
      else
        raise ActiveRecord::Rollback
      end
    end

    if saved
      redirect_to result_path(@result), notice: "Result was successfully created."
    else
      errors = @result.errors.full_messages + @chat.errors.full_messages
      redirect_to chat_path(@chat), alert: errors.presence&.to_sentence || "Result could not be created."
    end
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
