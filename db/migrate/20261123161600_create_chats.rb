class CreateChats < ActiveRecord::Migration[8.1]
  def up
    return if table_exists?(:chats)

    create_table :chats do |t|
      t.references :user, null: false, foreign_key: true
      t.references :result, null: true, foreign_key: true
      t.timestamps
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
