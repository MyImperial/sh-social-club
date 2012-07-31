class TotalIncome
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true               # default length limit of 50 characters
  property :amount, Decimal, :required => true, :scale => 2, :default => 1
  property :created_at, DateTime
  property :updated_at, DateTime
end

