# frozen_string_literal: true

Rails.application.routes.draw do
  get '/notebooks' => 'notebooks#index'
  get '/notebooks/:id' => 'notebooks#show'
  post '/notebooks/new' => 'notebooks#create'
  delete '/notebooks/:id' => 'notebooks#destroy'
end
