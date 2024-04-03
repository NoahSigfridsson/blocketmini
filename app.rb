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
    email = params[:email]

    new_user(username, password, password_confirm, email)
    redirect('/')
    
end

get('/login') do
    slim(:"/user/login")
end


post('/login') do
    username = params[:username]
    password = params[:password]
    login(username, password)
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

get('/myadverts') do
    db = connect_db()
    result = db.execute("SELECT * FROM advertisment WHERE user_id = ?",session[:id])
    slim(:"adverts/personal_index", locals:{adverts:result})
end

get('/adverts/new') do
    db = connect_db()
    categories = db.execute("SELECT * FROM category")
    slim(:"adverts/new", locals:{categories:categories})

end

post('/adverts/new') do

    db = connect_db()
    title = params[:title]
    description = params[:description]
    price = params[:price]
    user_id = session[:id].to_i
    category = params[:category_id].to_i
    #category2 = params[:category_id2].to_i
    db.execute("INSERT INTO advertisment (title, category, price, description, user_id) VALUES (?,?,?,?,?)", title, category, price, description, user_id)
    redirect("/adverts")

end

get('/adverts/:id') do
    id = params[:id].to_i
    db = connect_db()
    result = db.execute("SELECT * FROM advertisment WHERE AdvertId = ?", id).first
    result_user = db.execute("SELECT username FROM users WHERE id IN (SELECT user_id FROM advertisment WHERE AdvertId = ?)", id).first
    slim(:"adverts/show", locals:{result:result, result_user:result_user})

end

get('/adverts/:id/edit') do
    id = params[:id].to_i
    db = connect_db()
    result = db.execute("SELECT * FROM advertisment WHERE AdvertId = ?", id).first
    slim(:"adverts/edit", locals: { result: result })
end

post('/adverts/:id/update') do
    id = params[:id].to_i
    db = connect_db()
    title = params[:title]
    category = params[:category_id]
    description = params[:description]
    price = params[:price]
    db.execute("UPDATE advertisment SET title = ?, category = ?, price = ?, description = ? WHERE AdvertId = ?", title, category, price, description, id)
    redirect("/adverts/#{id}")
end

post('/adverts/:id/delete') do
    id = params[:id].to_i
    db = connect_db()
    db.execute("DELETE FROM advertisment WHERE AdvertId = ?",id)
    redirect('/myadverts')
end







