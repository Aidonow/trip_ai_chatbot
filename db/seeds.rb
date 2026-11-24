# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Nettoyage de la base..."
Message.destroy_all
Result.destroy_all
Chat.destroy_all

puts "Création des chats..."
chat1 = Chat.create!
chat2 = Chat.create!

puts "Création des messages..."
chat1.messages.create!(role: "user", content: "Bonjour, je voudrais organiser un voyage à Lisbonne.")
chat1.messages.create!(role: "assistant", content: "Avec plaisir ! Combien de jours souhaitez-vous y passer ?")
chat1.messages.create!(role: "user", content: "Environ 4 jours.")

chat2.messages.create!(role: "user", content: "Quelles sont les meilleures plages en Grèce ?")
chat2.messages.create!(role: "assistant", content: "Parmi les plus belles : Navagio à Zakynthos, Elafonissi en Crète et Milos.")

puts "Terminé : #{Chat.count} chats et #{Message.count} messages créés."

user = User.create!(email: "test@example.com", password: "password")
chat1 = Chat.create!(user: user)
chat2 = Chat.create!(user: user)
user = User.find_by!(email: "dqavnn@gmail.com")

suggestions = [
  {
    destination: "Lyon, France",
    time: 3,
    price: 360,
    content: <<~TEXT
      Food and history in Lyon — 3 days, 2 nights

      Day 1: Check in near the old town. Explore the traboules of Vieux Lyon,
      then try a traditional pike quenelle at a local bouchon.

      Day 2: Start at the Croix-Rousse market and pick up cheese, bread, and
      fruit for a picnic in Parc de la Tête d’Or. Spend the evening by the Rhône.

      Day 3: Take the funicular to Fourvière for a morning view of the city.
      Walk down through the gardens and stop for lunch before departure.

      Estimated total for one person: €360.
      Accommodation: €180 for 2 nights. Meals: €120.
      Local transport: €30. Activities: €30.
    TEXT
  },
  {
    destination: "Annecy, France",
    time: 2,
    price: 220,
    content: <<~TEXT
      A weekend by Lake Annecy — 2 days, 1 night

      Day 1: Follow the canals through the old town and have lunch near the
      Palais de l’Île. Walk to the Pont des Amours, then enjoy a Savoyard dinner.

      Day 2: Rent a bike and follow the lakeside path to Sévrier. Bring a picnic
      and stop by the water before cycling back to Annecy in the afternoon.

      Estimated total for one person: €220.
      Accommodation: €100 for 1 night. Meals: €75.
      Bike rental: €30. Other local transport: €15.
    TEXT
  },
  {
    destination: "Lisbon, Portugal",
    time: 4,
    price: 480,
    content: <<~TEXT
      Neighbourhoods and viewpoints in Lisbon — 4 days, 3 nights

      Day 1: Settle into your hotel and explore Baixa on foot. Finish the day
      at Praça do Comércio with dinner near the river.

      Day 2: Walk through Alfama in the morning, stopping at viewpoints along
      the way. In the evening, have dinner and listen to a live fado performance.

      Day 3: Take public transport to Belém. Walk along the waterfront, visit
      the Jerónimos Monastery, and stop for a pastel de nata.

      Day 4: Browse the bookshops around Chiado and enjoy a final café lunch
      before departure.

      Estimated total for one person: €480.
      Accommodation: €240 for 3 nights. Meals: €150.
      Local transport: €30. Admissions and fado: €60.
    TEXT
  },
  {
    destination: "Barcelona, Spain",
    time: 3,
    price: 420,
    content: <<~TEXT
      Architecture and the sea in Barcelona — 3 days, 2 nights

      Day 1: Explore the Gothic Quarter on foot. Stop for tapas in El Born
      and walk to the harbour in the late afternoon.

      Day 2: Visit the Sagrada Família in the morning. After lunch, head to
      Park Güell for the mosaic terraces and city views. Book both visits ahead.

      Day 3: Start with a walk along Barceloneta beach, then have a seafood
      lunch before collecting your luggage.

      Estimated total for one person: €420.
      Accommodation: €200 for 2 nights. Meals: €130.
      Local transport: €25. Admission tickets: €65.
    TEXT
  },
  {
    destination: "Amsterdam, Netherlands",
    time: 2,
    price: 295,
    content: <<~TEXT
      Canals and art in Amsterdam — 2 days, 1 night

      Day 1: Explore the Jordaan and stop for lunch at a neighbourhood café.
      Take an afternoon canal cruise, then have dinner near your hotel.

      Day 2: Spend the morning at the Rijksmuseum. After lunch, walk through
      Vondelpark and stop for a coffee before departure.

      Estimated total for one person: €295.
      Accommodation: €130 for 1 night. Meals: €90.
      Local transport: €20. Museum admission and canal cruise: €55.
    TEXT
  }
]

ActiveRecord::Base.transaction do
  suggestions.each do |attributes|
    result = Result.find_or_create_by!(attributes)
    user.chats.find_or_create_by!(result: result)
  end
end

puts "#{suggestions.size} travel suggestions are ready for user #{user.id}."
