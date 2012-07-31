class Foundation < Sinatra::Application
  get '/' do
    erb :home
  end
end
