require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'haml'
require 'sass'
require 'twitter'

set :haml, { :format => :html5, :escape_html => true }

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/names.db")

class Tory
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
  property :created_at, DateTime
end

configure do
  DataMapper.auto_upgrade!
end

before do
  headers 'Content-Type' => 'text/html; charset=utf-8'
  @tories = Tory.all(:limit => 10, :order => [:created_at.desc])
end

helpers do
  def send_to_twitter(name)
    oauth = Twitter::OAuth.new(ENV['consumer_key'], ENV['consumer_secret'])
    oauth.authorize_from_access(ENV['oauth_token'], ENV['oauth_token_secret'])
    client = Twitter::Base.new(oauth)
    client.update("#{name} (Dad’s name + street where you grew up + headteacher’s surname)" + ' #torynames')
  end
end

get '/?' do
  haml :index
end

post '/result' do
  forename = params[:forename].capitalize
  surname1 = params[:surname1].capitalize
  surname2 = params[:surname2].capitalize
  if forename != 'Dad’s name' && surname1 != 'Street where you grew up' && surname2 != 'Headteacher’s surname'
    @name = "#{forename} #{surname1}-#{surname2}"
    @tory = Tory.create(:name => @name)
    send_to_twitter(@name) if params[:twitter]
  end
  haml :index
end

get '/styles.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :styles
end