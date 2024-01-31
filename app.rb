require 'sinatra'
require 'sinatra/reloader'
require 'bcrypt'
require 'slim'
require 'sqlite3'
require_relative './model.rb'

get('/') do
    slim(:start)
end

get('/advertisments') do
    db = SQLite3::Database.new("db/blocketmini.db")
    db.results_as_hash = true
    slim(:"advertisments/index", locals:{advertisments:result})
end


=begin
get('/advertisments/new') do
    slim(:"advertisments/new")
end

post("/advertisments/new") do
    title = params[:title]
end
=end






