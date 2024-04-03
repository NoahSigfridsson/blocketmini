
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
















