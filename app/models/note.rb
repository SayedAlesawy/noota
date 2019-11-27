# frozen_string_literal: true

class Note < ApplicationRecord
  validates :title, :notebook_id, presence: true

  belongs_to :notebook
end
