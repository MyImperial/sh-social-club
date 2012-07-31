class Foundation < Sinatra::Application
  get '/contact' do
    erb :contact
  end
end
