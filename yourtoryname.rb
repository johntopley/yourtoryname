require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'haml'
require 'sass'

set :haml, { :format => :html5 }

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/names.db")

class Name
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
  property :created_at, DateTime
end

configure :development do
  DataMapper.auto_upgrade!
end

before do
  headers 'Content-Type' => 'text/html; charset=utf-8'
end

get '/' do
  haml :index
end

post '/result' do
  @tory_name = "#{params[:forename].capitalize} #{params[:surname1].capitalize}-#{params[:surname2].capitalize}"
  haml :index
end

get '/styles.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :styles
end