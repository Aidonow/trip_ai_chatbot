class ResultsController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @result = Result.new(result_params)

    if @result.save
      redirect_to chat_path(@chat), notice: "Result was successfully created."
    else
      redirect_to chat_path(@chat), alert: "Result could not be created."
    end
  end

  def destroy
    @chat = Chat.find(params[:chat_id])
    @result = @chat.result

    if @result&.id == params[:id].to_i
      @result.destroy
      redirect_to chat_path(@chat), notice: "Result was successfully deleted."
    else
      redirect_to chat_path(@chat), alert: "Result not found."
    end
  end

  private
  
  def result_params
    params.require(:result).permit(:content, :destination, :price, :time)
  end
end
