class IndividualContribution
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  property :amount, Decimal, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end

