require 'sinatra'
require 'sinatra/reloader'
require 'bcrypt'
require 'slim'
require 'sqlite3'
require_relative './model.rb'
enable :sessions

get('/') do
    slim(:start)
end

get('/register') do
    slim(:"/user/register")
end



post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    first_name = params[:f_name]
    last_name = params[:l_name]
  
    if password == password_confirm
      #Add user
      password_digest = BCrypt::Password.create(password)
      db = connect_db()
      db.execute("INSERT INTO users (username,pwdigest,f_name,l_name) VALUES (?,?,?,?)",username, password_digest, first_name, last_name) 
      redirect('/')
    else
      #felhantering
      "Passwords  not matching"
    end
end

get('/login') do
    slim(:"/user/login")
end


post('/login') do
    username = params[:username]
    password = params[:password]
    db = connect_db()
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["id"]
  
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id 
      redirect('/')
    else
      "Wrong password"
  
    end
  
  end

get('/logout') do
    session[:id] = nil
    redirect('/')
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
    user_id = session[:id].to_i
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






