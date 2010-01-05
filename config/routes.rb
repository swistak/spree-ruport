map.namespace :admin do |admin|
  admin.resources :monthly_reports
  admin.resources :reports, :member => {:destroy => :post}, :collection => {:options => :get}
end
