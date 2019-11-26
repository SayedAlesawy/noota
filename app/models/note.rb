# frozen_string_literal: true

class Note < ApplicationRecord
  validates :title, :author_id, :notebook_id, presence: true

  belongs_to :author, class_name: 'User'
  belongs_to :notebook
end
