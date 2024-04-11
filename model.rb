
def connect_db
    db = SQLite3::Database.new("db/blocketmini.db")
    db.results_as_hash = true
    return db
end
#Tidsfunktioner
def last_checked_time
    session[:last_checked_time] ||= Time.now - 61
end

def expired_reg
    Time.now - last_checked_time > 5
end

def time_expired
    Time.now - last_checked_time > 5
end


def require_login
    if session[:id].nil?
        redirect('/')
    end
end

def new_user(username, password, password_confirm, email)

    if expired_reg()
        session[:last_checked_time] = Time.now
    else
        session[:error] = "Lugna ner dig, försök registrera dig igen senare."
        redirect('/')
    end
    db = connect_db()
    existing_user = db.execute("SELECT username FROM users WHERE username = ?", username).first
    existing_email = db.execute("SELECT email FROM users WHERE email = ?", email).first
    if existing_user
        session[:error] = "Användarnamnet #{username} är redan taget."
        redirect('/')
    elsif existing_email
        session[:error] = "Mailadressen #{email} är redan registrerad."
        redirect('/')
    elsif password != password_confirm
        session[:error] = "Lösenordet matchade inte."
        redirect('/')
    elsif username.nil? || username.strip.empty?
        session[:error] = "Du måste ha ett användarnamn"
        redirect('/')
    else
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO users (username, pwdigest, email) VALUES (?, ?, ?)", username, password_digest, email)
    end
end

def login(username, password)
    if time_expired()
        session[:last_checked_time] = Time.now
    else
        session[:error] = "Lugna ner dig, försök logga in igen senare."
        redirect('/')
    end

    db = connect_db()
    result = db.execute("SELECT * FROM users WHERE username = ?", username).first
    pwdigest = result["pwdigest"] if result

    if result && BCrypt::Password.new(pwdigest) == password
        session[:id] = result["id"]
        redirect('/')
    else
        session[:error] = "Fel användarnamn eller lösenord"
        redirect('/')
    end
end

def adverts()
    db = connect_db()
    adverts = db.execute("SELECT * FROM advertisment")
    categories = db.execute("SELECT * From category")
    adverts.each do |advert|
        user_info = db.execute("SELECT username FROM users WHERE id = ?", advert['user_id']).first
        advert['username'] = user_info['username'] if user_info
    end

    slim(:"/adverts/index", locals:{adverts:adverts, categories:categories})
end

def new_advert(user_id)
    require_login()
    db = connect_db()
    categories = db.execute("SELECT * FROM category")
    user_info = db.execute("SELECT * FROM users WHERE id = ?", user_id).first
    username = user_info['username'] if user_info
    slim(:"/adverts/new", locals:{username:username, categories:categories})
end

def new_advert_post(title, description, price, img, category, category2, user_id)
    if title.nil? || title.strip.empty?
        session[:error] = "Du måste ha en titel på din annons."
        redirect('/myadverts')
    elsif description.nil? || description.strip.empty?
        session[:error] = "Du måste ha en beskrivning av din annons."
        redirect('/myadverts')
    elsif price.nil? || price.strip.empty?
        session[:error] = "Du måste sätta ett pris på din vara."
        redirect('/myadverts')
    elsif img.nil? || img.strip.empty?
        session[:error] = "Du måste ha en bild på din annons." #lägga till så att man inte måste ha en bild om man inte vill
        redirect('/myadverts')
    end
    
    db = connect_db()
    db.execute("INSERT INTO advertisment (title, category, category2, user_id, price, description, img) VALUES (?, ?, ?, ?, ?, ?, ?)", title, category, category2, user_id, price, description, img)
    advert_id = db.last_insert_row_id
    db.execute("INSERT INTO advert_category (ad_id, category_id, category_id2) VALUES (?, ?, ?)", advert_id, category, category2)
    redirect('/myadverts')
end

def categories()
    db = connect_db()
    categories = db.execute("SELECT * FROM category")
    slim(:"/categories/index", locals:{categories:categories})
end

def new_category(category)
    p category
    p "jani"
    db = connect_db()
    db.execute("INSERT INTO category (name) VALUES (?)", category)
    redirect('/category')
end










