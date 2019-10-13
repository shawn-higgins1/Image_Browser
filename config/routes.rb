# frozen_string_literal: true

Rails.application.routes.draw do
  # Static Pages
  get '/home', to: 'main#home', as: :home
  get '/help', to: 'main#help', as: :help

  # Sign in and sign up routes
  get '/signup', to: 'users#new', as: :signup
  get    '/signin',   to: 'sessions#new', as: :signin
  post   '/signin',   to: 'sessions#create'
  delete '/signin', to: 'sessions#destroy', as: :sign_out

  resource :users, only: [:create, :new]

  # Routes related to photos
  get '/upload', to: 'photos#new', as: :new_photo
  post '/upload', to: 'photos#upload', as: :upload_photos
  delete '/upload', to: 'photos#delete', as: :delete_photos
  get '/gallery', to: 'photos#gallery', as: :gallery
  get '/gallery/:id', to: 'photos#show', as: :show_photo

  scope '/photo' do
    get '/download/:id', to: "photos#download", as: :download_photo
    get '/edit/:id', to: 'photos#edit', as: :edit_photo
    patch '/edit', to: 'photos#update', as: :update_photo
  end

  root 'main#home'
end
