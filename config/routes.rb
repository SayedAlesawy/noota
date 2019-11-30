# frozen_string_literal: true

Rails.application.routes.draw do
  get '/notebooks' => 'notebooks#index'
  get '/notebooks/:id' => 'notebooks#show'
  post '/notebooks/new' => 'notebooks#create'
  delete '/notebooks/:id' => 'notebooks#destroy'

  get '/notebooks/:notebook_id/notes' => 'notes#index'
  get '/notebooks/:notebook_id/notes/:id' => 'notes#show'
  post '/notebooks/:notebook_id/notes/new' => 'notes#create'
  delete '/notebooks/:notebook_id/notes/:id' => 'notes#destroy'
  delete '/notebooks/:notebook_id/notes' => 'notes#bulk_destroy'
end
