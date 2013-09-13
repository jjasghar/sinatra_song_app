require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/flash'
require 'slim'
require 'sass'
require 'pony'
require 'v8'
require 'coffee-script'

require './song'
require './sinatra/auth'

configure do
  enable :sessions
end

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
        end.join
  end

  def current?(path='/')
    (request.path==path || request.path==path+'/' ) ? "current" : nil
  end

  def set_title
    @title ||= "Songs By Sinatra"
  end
end

def send_message
  Pony.mail(
    :from => params[:name] + "<" + params[:email] + ">",
    :to   => 'jjasghar@gmail.com',
    :subject => params[:name] + " has contacted you",
    :body => params[:message],
    :via => :smtp
  )
end

before do
  set_title
end

get('/styles.css'){ scss :styles }
get('/javascripts/application.js'){ coffee :application }

get '/' do
  slim :home
end

get '/login' do
  slim :login
end

post '/login' do
    slim :login
end

get '/about' do
  @title = "All about the website"
  slim :about
end

get '/contact' do
  @title = "Contact page"
  slim :contact
end

post '/contact' do
  send_message
  flash[:notice] = "Thank you for the message, now fuck off."
  redirect to('/')
end

not_found do
  slim :not_found
end

get '/fake-error' do
  status 500
  "There's nothing wrong, really :P"
end

get '/set/:name' do
  session[:name] = params[:name]
end

get '/get/hello' do
  "Hello #{session[:name]}"
end

get '/logout' do
  session.clear
  redirect to('/login')
end
