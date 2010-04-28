require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'haml'
require 'sass'

set :haml, { :format => :html5 }

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/names.db")

class Tory
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
  @tories = Tory.all :limit => 10, :order => :created_at.desc
end

get '/' do
  haml :index
end

post '/result' do
  forename = params[:forename].capitalize
  surname1 = params[:surname1].capitalize
  surname2 = params[:surname2].capitalize
  if forename != 'Dad’s name' && surname1 != 'Street where you grew up' && surname2 != 'Headteacher’s surname'
    @name = "#{forename} #{surname1}-#{surname2}"
    @tory = Tory.create(:name => @name)
  end
  haml :index
end

get '/styles.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :styles
end