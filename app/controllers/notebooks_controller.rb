# frozen_string_literal: true

class NotebooksController < ApplicationController
  include NotebookParams

  def index
    notebooks = []

    Notebook.find_each do |notebook|
      notebooks << decorate(notebook)
    end

    render json: notebooks, status: 200
  end

  def show
    notebook = Notebook.find(params[:id])

    render json: decorate(notebook), status: 200
  end

  def create
    notebook = Notebook.create!(notebook_params)

    render json: decorate(notebook), status: 201
  end

  def destroy
    Notebook.find(params[:id]).destroy!

    render json: { message: 'success' }, status: 202
  end

  private

  def decorate(notebook)
    {
      id: notebook.id,
      title: notebook.title,
      description: notebook.description
    }
  end
end
