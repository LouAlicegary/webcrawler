Scraper::Application.routes.draw do
  resources :websites
  
  get 'welcome', to: 'online_resources#welcome'
  
  get 'resource_count', to: 'online_resources#resource_count'
  post 'websites/update_last_completed', to: 'online_resources#update_last_completed'
  
  
  get 'gutenberg', to: 'online_resources#gutenberg'
  get 'librivox', to: 'online_resources#librivox'
  get 'bartleby', to: 'online_resources#bartleby'
  get 'poemhunter', to: 'online_resources#poemhunter'
  get 'justinguitar', to: 'online_resources#justinguitar'
  get 'wikibooks', to: 'online_resources#wikibooks'
  
  namespace :crawlers do
    get 'tedtalks', to: 'tedtalks#crawl'
    get 'instructables', to: 'instructables#crawl'
  end
   
  root 'websites#index'
  #root 'online_resources#index'
end
