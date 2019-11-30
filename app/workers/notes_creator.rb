# frozen_string_literal: true

# A worker that creates notes
class NotesCreator
  include Sidekiq::Worker

  QUEUE = 'noota::notes-creator'

  sidekiq_options queue: QUEUE, retry: true

  def perform(args)
    args = JSON.parse(args).symbolize_keys

    NotesCreator.create_note(args)
  end

  def self.create_note(params)
    Note.create!(
      title: params[:title],
      body: params[:body],
      notebook_id: params[:notebook_id]
    )
  end
end
