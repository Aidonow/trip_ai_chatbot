class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    @results = if current_user
      Result.joins(:chats)
            .where(chats: { user_id: current_user.id })
            .distinct
            .order(created_at: :desc)
    else
      Result.none
    end
  end
end
