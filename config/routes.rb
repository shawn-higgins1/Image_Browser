# frozen_string_literal: true

Rails.application.routes.draw do
  # Static Pages
  get '/home', to: 'main#home', as: :home
  get '/help', to: 'main#help', as: :help

  # Sign in and sign up routes
  get  '/signup',  to: 'users#new', as: :signup
  get    '/signin',   to: 'sessions#new', as: :signin
  post   '/signin',   to: 'sessions#create'
  delete '/signin',  to: 'sessions#destroy', as: :sign_out

  resource :users, only: [:show, :update, :create, :new]

  root 'main#home'
end
