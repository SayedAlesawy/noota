# frozen_string_literal: true

# A worker that destroys notes
class NotesBulkDestroyer
  include Sidekiq::Worker

  QUEUE = 'noota::notes-bulk-destroyer'

  sidekiq_options queue: QUEUE, retry: true

  def perform(args)
    args = JSON.parse(args).symbolize_keys

    NotesBulkDestroyer.destroy_note(args)
  end

  def self.destroy_note(params)
    Notebook.find(params[:notebook_id]).notes.destroy_all
  end
end
