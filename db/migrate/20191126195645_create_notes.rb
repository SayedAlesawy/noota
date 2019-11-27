# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :notes do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.integer :notebook_id, null: false

      t.timestamps null: false
    end

    add_index :notes, :notebook_id
  end
end
