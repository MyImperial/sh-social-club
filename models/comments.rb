class Comments
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :content, Text, :required => true
  property :created_at, DateTime
end
