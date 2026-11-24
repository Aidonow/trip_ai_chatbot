class MakeResultOptionalOnChats < ActiveRecord::Migration[8.1]
def change
  change_column_null :chats, :result_id, true
end
end
