class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :user
  belongs_to :result, optional: true

  #optional: true:-> permet de créer un Chat
  #avant qu'un Result soit associé. Il faut aussi que la colonne result_id existe
  #dans chats et accepte NULL.
  #Cela ne valide pas encore votre choix de relation :
  #vérifie avec ton équipe que le schéma prévoit bien result_id dans chats,
  #et non chat_id dans results.

end
