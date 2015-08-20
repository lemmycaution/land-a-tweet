# require "refile"
# Refile.configure do |config|
  # config.store = Refile::Postgres::Backend.new(proc { ActiveRecord::Base.connection.raw_connection } )
# end

Refile.host = {
  'development' => "http://localhost:5000/",
  'test' => "http://localhost:5000/",
  'production' =>  ENV['CF_HOST'],
}[Rails.env]

if Rails.env.production?
  require "refile/s3"

  aws = {
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    region: ENV['FOG_REGION'],
    bucket: ENV['FOG_DIRECTORY'],
  }
  Refile.cache = Refile::S3.new(prefix: "cache", max_size: 5.megabytes, **aws)
  Refile.store = Refile::S3.new(prefix: "store", max_size: 5.megabytes, **aws)
end


