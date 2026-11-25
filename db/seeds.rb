# db/seeds.rb

user = User.find_or_create_by!(email: "demo@example.com") do |new_user|
  new_user.password = ENV.fetch("DEMO_PASSWORD")
end

# Conversation 1 : l'utilisateur donne tous ses critères dès le début.
rome_options = <<~TEXT.strip
  Here are three ideas for a solo trip from Paris, leaving on 15 January 2027
  for 3 days and 2 nights. Each estimate covers the whole stay, including
  return travel, accommodation, meals, local transport, and activities.

  1. Seville, Spain — €590. Explore Santa Cruz and the Real Alcázar.
  2. Rome, Italy — €650. Discover ancient Rome and try Roman food in Testaccio.
  3. Prague, Czechia — €540. Walk through the Old Town and visit Prague Castle.

  These are estimates and depend on availability. Which destination do you prefer?
  Reply with 1, 2, or 3.

  [CHOICES]
TEXT

rome_itinerary = <<~TEXT.strip
  A winter weekend in Rome, Italy — 3 days, 2 nights

  Departure: 15 January 2027 from Paris. Return: 17 January 2027.
  Estimated total for one person: €650.

  Day 1: Fly to Rome and check in. Walk from Piazza Navona to the Pantheon,
  then stop for a plate of cacio e pepe near Campo de' Fiori.

  Day 2: Spend the morning at the Colosseum and Roman Forum. In the afternoon,
  cross the river for a walk and dinner in Trastevere.

  Day 3: Visit Testaccio Market for breakfast and pick up something for lunch
  before travelling back to the airport.

  Budget breakdown: €180 return flights, €220 accommodation, €120 meals,
  €50 local transport, and €80 activities. Prices are estimates.
TEXT

# Conversation 2 : l'IA doit d'abord demander les informations manquantes.
lyon_options = <<~TEXT.strip
  For 2 days and 1 night from Paris, leaving on 12 March 2027, here are three
  food-focused trips within your €350 budget. Estimates include return travel.

  1. Lyon, France — €320. Explore the bouchons and the food market at Les Halles.
  2. Lille, France — €275. Try an estaminet and visit the bakeries of Vieux-Lille.
  3. Dijon, France — €295. Discover Burgundy specialities around the old town.

  Which destination sounds best? Reply with 1, 2, or 3.

  [CHOICES]
TEXT

lyon_itinerary = <<~TEXT.strip
  A food weekend in Lyon, France — 2 days, 1 night

  Departure: 12 March 2027 from Paris. Return: 13 March 2027.
  Estimated total for one person: €320.

  Day 1: Take the train to Lyon and leave your bag at the hotel. Explore
  Vieux Lyon on foot, then try a traditional quenelle at a local bouchon.

  Day 2: Start at Les Halles de Lyon Paul Bocuse. Pick up cheese and a praline
  tart, then walk along the Rhône before taking the train back to Paris.

  Budget breakdown: €100 return train tickets, €95 accommodation, €85 meals,
  €15 local transport, and €25 activities. Prices are estimates.
TEXT

trips = [
  {
    messages: [
      ["user", "I'm travelling alone from Paris on 15 January 2027 for 3 days. My total budget is €700. I like history and local food."],
      ["assistant", rome_options],
      ["user", "2"],
      ["assistant", rome_itinerary]
    ],
    result: {
      destination: "Rome, Italy",
      price: 650,
      time: 3,
      content: rome_itinerary
    }
  },
  {
    messages: [
      ["user", "I'd love a short food trip. My total budget is €350."],
      ["assistant", "Which city are you leaving from, on what date, and for how many days?"],
      ["user", "From Paris on 12 March 2027, for 2 days."],
      ["assistant", lyon_options],
      ["user", "1"],
      ["assistant", lyon_itinerary]
    ],
    result: {
      destination: "Lyon, France",
      price: 320,
      time: 2,
      content: lyon_itinerary
    }
  }
]

user.with_lock do
  trips.each do |trip|
    # Retrouve ce chat de démonstration si le seed a déjà été exécuté.
    first_question = trip.fetch(:messages).first.last
    chat = user.chats.joins(:messages).find_by(
      messages: { role: "user", content: first_question }
    )
    chat ||= user.chats.create!

    trip.fetch(:messages).each do |role, content|
      chat.messages.find_or_create_by!(role: role, content: content)
    end

    # Simule le clic sur « Confirm this destination ».
    result = chat.result || Result.new
    result.update!(trip.fetch(:result))
    chat.update!(result: result)
  end
end

puts "Deux voyages de démonstration sont prêts pour #{user.email}."
