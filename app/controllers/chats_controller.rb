class ChatsController < ApplicationController
def new
    #ouverture d'un nouvel objet chat sans suvegarde dans la base
    @chat = Chat.new 
end

def create
    @chat = current_user.chats.build #créer un chat associé à l'utilisateur connecté

    if @chat.save #enregistre le chat en base de donnéés
        redirect_to_chat_path(@chat) #redirige vers la nouvelle conversation
    else 
        render :new, status: :unprocessable_entity
    end
end

def show
    @chat = current_user.chats.find(params[:id]) #récupère le chat de l'utilisateur connecté
    @messages = @chat.messages.order(:created_at) #récupère les msg dans l'ordre chronologique
    @message = Message.new #msg prépare le formulaire pour envoyer un nouveau msg

    #le current_user.chats.find empêche l'utilisateur connecté de voir le chat d'un autre utilisateur
end
