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
    p username
    p password
    p password_confirm
    p email
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

get('/adminpage') do
    slim(:adminpage)
end

post('/adminpage') do

end

get('/adverts') do
    adverts()
end

get('/category') do
    categories()
end

get("/categories/new") do
    slim(:"categories/new")
end

post("/categories/new") do
    category = params[:category]
    new_category(category)
end

post('/categories/:id/delete') do
    id = params[:id].to_i
    db = connect_db()
    db.execute("DELETE FROM category WHERE id = ?",id)
    redirect('/category')
end

get('/myadverts') do
    db = connect_db()
    result = db.execute("SELECT * FROM advertisment WHERE user_id = ?",session[:id])
    slim(:"adverts/personal_index", locals:{adverts:result})
end

get('/adverts/new') do
    new_advert(session[:id].to_i)
end

get('/adverts/:id') do
    id = params[:id].to_i
    db = connect_db()
    result = db.execute("SELECT * FROM advertisment WHERE AdvertId = ?", id).first
    result_user = db.execute("SELECT username FROM users WHERE id IN (SELECT user_id FROM advertisment WHERE AdvertId = ?)", id).first
    slim(:"adverts/show", locals:{result:result, result_user:result_user})

end

post('/adverts/filter') do
    chosen_category = params[:genre]
    filter_adverts(chosen_category)
end

get('/adverts/:id/edit') do
    id = params[:id].to_i
    db = connect_db()
    result = db.execute("SELECT * FROM advertisment WHERE AdvertId = ?", id).first
    slim(:"adverts/edit", locals: { result: result })
end

post('/adverts/new') do

    title = params[:title]
    description = params[:description]
    price = params[:price]
    user_id = session[:id].to_i
    category = params[:category]
    category2 = params[:category2]
    img = params[:img][:tempfile].read if params[:img]
    new_advert_post(title, description, price, img, category, category2, user_id)
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







