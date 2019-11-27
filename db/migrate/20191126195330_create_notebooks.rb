# frozen_string_literal: true

class CreateNotebooks < ActiveRecord::Migration[5.2]
  def change
    create_table :notebooks do |t|
      t.string :title, null: false
      t.string :description

      t.timestamps null: false
    end
  end
end
