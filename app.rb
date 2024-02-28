require 'sinatra'
require 'sinatra/reloader'
require 'bcrypt'
require 'slim'
require 'sqlite3'
require_relative './model.rb'


get('/') do
    slim(:start)
end

get('/adverts') do
    db = connect_db()
    result = db.execute("SELECT * FROM advertisment")
    slim(:"adverts/index", locals:{adverts:result})
end

get('/adverts/new') do

    slim(:"adverts/new")

end

post('/adverts/new') do

    db = connect_db()
    title = params[:title]
    category = params[:category_id]
    description = params[:description]
    price = params[:price]
    user_id = params[:user_id]
    db.execute("INSERT INTO advertisment (title, category, price, description, user_id) VALUES (?,?,?,?,?)", title, category, price, description, user_id)
    redirect("/adverts")

end


=begin
get('/advertisments/new') do
    slim(:"advertisments/new")
end

post("/advertisments/new") do
    title = params[:title]
end
=end






