# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/new'
  get '/home', to: 'main#home', as: :home
  get '/help', to: 'main#help', as: :help
  get  '/signup',  to: 'users#new', as: :signup

  root 'main#home'
end
