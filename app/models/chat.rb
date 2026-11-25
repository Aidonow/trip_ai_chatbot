class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :user
  belongs_to :result, optional: true

RESULT_PROMPT = <<~PROMPT
  Extract the destination, duration in days, and estimated total trip cost in euros.
  If the cost is a range, use its upper bound. For example, "650 à 1 000 €" means 1000.
  Return only JSON. Use a string for destination and numbers for price and time.
  Example: {"destination":"Rome, Italie","price":1000,"time":3}
  Use the actual values from the message. Use null for missing information.
PROMPT

def generate_result_from_message(message)
  response = RubyLLM.chat.with_instructions(RESULT_PROMPT).ask(message.content)
  details = JSON.parse(response.content)

  unless details.is_a?(Hash) &&
         details["destination"].is_a?(String) && details["destination"].present? &&
         details["price"].is_a?(Numeric) && details["price"] >= 0 &&
         details["time"].is_a?(Integer) && details["time"].positive?
    return nil
  end

  with_lock do
    trip = result || build_result
    trip.update!(
      destination: details["destination"],
      price: details["price"],
      time: details["time"],
      content: message.content
    )
    update!(result: trip)
    trip
  end
end
end
