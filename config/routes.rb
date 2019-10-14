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

  resource :users, only: [:create, :new, :edit, :update]

  # Routes related to photos
  get '/upload', to: 'photos#new', as: :new_photo
  post '/upload', to: 'photos#upload', as: :upload_photos
  delete '/upload', to: 'photos#delete', as: :delete_photos
  get '/gallery', to: 'photos#gallery', as: :gallery
  post '/gallery/search', to: 'photos#search', as: :search_photos
  get '/gallery/:id', to: 'photos#show', as: :show_photo

  scope '/photo' do
    get '/download/:id', to: "photos#download", as: :download_photo
    get '/edit/:id', to: 'photos#edit', as: :edit_photo
    patch '/edit', to: 'photos#update', as: :update_photo
  end

  scope '/password' do
    get '/forgot', to: 'reset_password#forgot_password', as: :forgot_password_form
    post '/forgot/send', to: 'reset_password#send_email', as: :forgot_password
    get '/reset/:token/:id', to: 'reset_password#edit_password', as: :new_password
    post '/reset/:token/:id', to: 'reset_password#reset_password', as: :reset_password
  end

  scope '/email' do
    get '/send/:id', to: 'email_verification#send_email', as: :send_email_verification
    get '/verify/:token/:id', to: 'email_verification#verify_account', as: :verify_email
  end

  root 'main#home'
end
