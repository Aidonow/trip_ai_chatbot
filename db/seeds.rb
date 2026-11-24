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