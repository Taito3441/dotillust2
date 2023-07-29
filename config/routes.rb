Rails.application.routes.draw do
  devise_for :users  
  resources :users, only: [:show, :index]
  get 'illusts/draw' => 'illusts#draw', as: :draw_illust
  get 'illusts/weekly_rank' => 'illusts#weekly_rank'
  get 'illusts/tagindex', to: 'illusts#tagindex', as: :illusts_tagindex
  resources :illusts do
    resources :likes, only: [:create, :destroy]
  end

  root 'illusts#top'

  resources :tags do
    get 'illusts', to: 'illusts#search'
  end

  get 'illusts/search' => 'illusts#search'

  resources :users do
    member do
      get :following, :followers
    end
  end
  
  resources :relationships, only: [:create, :destroy]
end
