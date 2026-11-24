class Message < ApplicationRecord
  belongs_to :chat

  ROLES = %w[user assistant].freeze

  validates :content, presence: true
  validates :role, inclusion: { in: ROLES }
end
