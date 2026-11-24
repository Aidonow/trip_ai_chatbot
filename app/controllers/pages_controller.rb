class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    @results = if user_signed_in?
                 Result.where(id: current_user.chats.select(:result_id))
                       .order(created_at: :desc)
               else
                 Result.none
               end
  end
end
