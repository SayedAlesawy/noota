# frozen_string_literal: true

class NotesController < ApplicationController
  include NoteParams

  before_action :load_notebook

  def index
    notes = []

    @current_notebook.notes.find_each do |note|
      notes << decorate(note)
    end

    render json: notes, status: 200
  end

  def show
    note = @current_notebook.notes.find(params[:id])

    render json: decorate(note), status: 200
  end

  def create
    NotesCreator.perform_async(create_note_params.to_json)

    render json: { message: 'success' }, status: 200
  end

  def destroy
    @current_notebook.notes.find(params[:id]).destroy!

    render json: { message: 'success' }, status: 202
  end

  def bulk_destroy
    NotesBulkDestroyer.perform_async(bulk_destroy_note_params.to_json)

    render json: { message: 'success' }, status: 202
  end

  private

  def load_notebook
    @current_notebook = Notebook.find(params[:notebook_id])
  end

  def decorate(note)
    {
      id: note.id,
      title: note.title,
      body: note.body
    }
  end
end
