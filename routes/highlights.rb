class Foundation < Sinatra::Application
  get '/highlights' do
    erb :highlights
  end
end
