require 'sinatra'
require 'omniauth'
require 'omniauth-twitter'

enable :sessions

use OmniAuth::Builder do
  if Sinatra::Base.development?
    OmniAuth.config.full_host = "http://127.0.0.1:#{settings.port}"
  end
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

configure do
  require 'sequel'
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://local.db')
  Sequel.extension :named_timezones
  Sequel.database_timezone = :utc
  Sequel.application_timezone = 'America/Los_Angeles'
  Sequel.datetime_class = DateTime
  Sequel.extension :migration
  Sequel::Migrator.run(DB, 'db/migrations')
  Sequel::Model.plugin :timestamps, :update_on_create => true

  require File.join(File.dirname(__FILE__), 'lib/user')
  require File.join(File.dirname(__FILE__), 'lib/message')
end

def find_user(handle)
  return nil unless handle
  handle = handle.downcase
  User.find(:twitter_id => handle)
end

def find_or_create_user(handle, name)
  find_user(handle) || create_user(handle, name)
end

def create_user(handle, name)
  u = User.new
  u.twitter_id = handle
  u.name = name
  u.save
end

def current_user
  @current_user ||= User.find(:id => session[:user_id]) if session[:user_id]
end

def current_message
  if session[:suppress_message]
    nil
  else
    if msg = Message.find(:id => current_user.current_message_id)
      msg.message
    else
      "We've run out of inspiration"
    end
  end
end

%w(get post).each do |method|
  send(method, "/auth/:provider/callback") do
    auth = env['omniauth.auth'] # => OmniAuth::AuthHash
    user = find_or_create_user auth[:info][:nickname], auth[:info][:name]
    session[:user_id] = user.id
    location = env['omniauth.origin'] || '/'
    redirect location
  end
end

get '/logout' do
  session.clear
  location = env['HTTP_REFERER'] || '/'
  redirect location
end

get '/' do
  erb :message
end

get '/message/dismiss' do
  session[:suppress_message] = true
  location = env['HTTP_REFERER'] || '/'
  current_user.current_message_id += 1
  current_user.save
  redirect location
end