# frozen_string_literal: true

class AddCountryToNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :notes, :country, :string
  end
end
