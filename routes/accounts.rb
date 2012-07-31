class Foundation < Sinatra::Application
  get '/accounts' do
    erb :accounts
  end

  get '/accounts/total_income' do
    @income = TotalIncome.all :order => :id.asc
    erb :total_income
  end

  get '/accounts/individual_contribution' do
    erb :individual_contribution
  end

  get '/admin/total_income' do
    erb :admin_total_income
  end

  post '/admin_total_income' do
    new_income = TotalIncome.new
    new_income.title = params[:title]
    new_income.amount = params[:amount]
    new_income.created_at = Time.now
    new_income.updated_at = Time.now
    unless new_income.save
      new_income.errors.each do |error|
        puts error
      end
    end
    redirect '/accounts/total_income'
  end
end
