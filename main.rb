# frozen_string_literal: true

require 'sinatra'
require 'httparty'
require 'pg'
require 'pg_exec_array_params'

if development?
  require 'pry'
  require 'sinatra/reloader'
end

enable :sessions

# api_request to spotify. URL should be in "" and token should be valid token returned from spotify server

def api_request(url, user_token)
  request = HTTParty.get(url,
    headers: { 'Accept' => 'application/json',
               'Authorization' => "Bearer #{user_token}" })
  return request
end

def token_request(code)
  result = HTTParty.post('https://labeldiscovery-token-swap.herokuapp.com/api/token',
    body: { code: code }).parsed_response
  return result['access_token']
end

def run_sql(sql, arr = [])
  db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'labeldiscovery'})
  results = db.exec_params(sql, arr)
  db.close
  return results
end

def logged_in?
  if session[:user_id]
    return true
  else
    return false
  end
end

get '/' do
  erb :index, :layout => :login_layout
end

get '/login' do
 erb :index
end

get '/labels' do

  redirect '/' unless logged_in?

  labels = run_sql("SELECT * FROM labels;")

  user_details = api_request("https://api.spotify.com/v1/me", session[:user_token])

  erb :mainpage, locals: { labels: labels, user: user_details }
end

get '/callback' do
  # Swapping code for access_token
  user_token = token_request(params[:code])
  user_details = api_request("https://api.spotify.com/v1/me", user_token)
  
  labels = run_sql("SELECT * FROM labels;")

  # For development to allow access to token inside terminal
  puts "user_token"
  puts user_token

  session[:user_token] = user_token
  session[:user_id] = user_details["id"]

  redirect '/labels'
end

get '/label/:id' do

  redirect '/login' unless logged_in?

  albums = run_sql("SELECT * FROM albums WHERE label_id = $1;", [params[:id]])

  watchlist_check = run_sql("SELECT * FROM watchlist WHERE label_id = $1 AND spotify_user_id = $2;", [params[:id], session[:user_id]])

  if watchlist_check.count.zero?
    watchlist = false;
  else
    watchlist = true;
  end

  user_details = api_request("https://api.spotify.com/v1/me", session[:user_token])

  erb :label_results, locals: { albums: albums, id: params[:id], user: user_details, watchlist: watchlist}
end

get '/label/:id/sort/' do

  redirect '/login' unless logged_in?

  watchlist_check = run_sql("SELECT * FROM watchlist WHERE label_id = $1 AND spotify_user_id = $2;", [params[:id], session[:user_id]])

  if watchlist_check.count.zero?
    watchlist = false;
  else
    watchlist = true;
  end

  if params[:year] == 'asc'
    albums = run_sql("SELECT * FROM albums WHERE label_id = $1 ORDER BY release_date ASC;", [params[:id]])
  elsif params[:year] == 'desc'
    albums = run_sql("SELECT * FROM albums WHERE label_id = $1 ORDER BY release_date DESC;", [params[:id]])
  elsif params[:album] == 'a-z'
    albums = run_sql("SELECT * FROM albums WHERE label_id = $1 ORDER BY album_name ASC;", [params[:id]])
  elsif params[:album] == 'z-a'
    albums = run_sql("SELECT * FROM albums WHERE label_id = $1 ORDER BY album_name DESC;", [params[:id]])
  elsif params[:artist] == 'a-z'
    albums = run_sql("SELECT * FROM albums WHERE label_id = $1 ORDER BY artist ASC;", [params[:id]])
  elsif params[:artist] == 'z-a'
    albums = run_sql("SELECT * FROM albums WHERE label_id = $1 ORDER BY artist DESC;", [params[:id]])
  elsif params[:latest_releases] == '1-month'
    albums = run_sql("SELECT * FROM albums WHERE label_id = $1 AND release_date BETWEEN CURRENT_DATE - INTERVAL '1 months' AND CURRENT_DATE ORDER BY release_date DESC;", [params[:id]])
  elsif params[:latest_releases] == '3-month'
    albums = run_sql("SELECT * FROM albums WHERE label_id = $1 AND release_date BETWEEN CURRENT_DATE - INTERVAL '3 months' AND CURRENT_DATE ORDER BY release_date DESC;", [params[:id]])
  elsif params[:latest_releases] == '6-month'
    albums = run_sql("SELECT * FROM albums WHERE label_id = $1 AND release_date BETWEEN CURRENT_DATE - INTERVAL '6 months' AND CURRENT_DATE ORDER BY release_date DESC;", [params[:id]])
  elsif params[:latest_releases] == 'all'
    albums = run_sql("SELECT * FROM albums WHERE label_id = $1;", [params[:id]])
  end

  user_details = api_request("https://api.spotify.com/v1/me", session[:user_token])
    
  erb :label_results, locals: { albums: albums, id: params[:id], user: user_details, watchlist: watchlist }
end

delete '/sessions' do
  session[:user_id] = nil
  redirect '/'
end

get '/user/watchlist/edit/:id' do

  result = run_sql("SELECT * FROM watchlist WHERE spotify_user_id = $1 AND label_id = $2;", [session[:user_id], params[:id]])

  if result.count.zero?
    run_sql("INSERT INTO watchlist (spotify_user_id, label_id) VALUES ($1, $2);", [session[:user_id], params[:id]])
  end

  redirect "/label/#{params[:id]}"
end

get '/user/watchlist/delete/:id' do

  result = run_sql("SELECT * FROM watchlist WHERE spotify_user_id = $1 AND label_id = $2;", [session[:user_id], params[:id]])

  if result.count == 1
    run_sql("DELETE FROM watchlist WHERE spotify_user_id = $1 AND label_id = $2;", [session[:user_id], params[:id]])
  end

  redirect "/label/#{params[:id]}"
end

get '/user/watchlist/:id' do

  user_details = api_request("https://api.spotify.com/v1/me", session[:user_token])
  
  user_watchlist = run_sql("SELECT label_id FROM watchlist where spotify_user_id = $1;", [params[:id]])

  if user_watchlist.count.zero?
     erb :watchlist_empty, locals: { user: user_details }
  elsif
    array = user_watchlist.to_a.map { |item| item["label_id"] }
    
    db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'labeldiscovery'})
    
    albums = PgExecArrayParams.exec_array_params(db, 'SELECT * FROM albums WHERE label_id = $1;', [array])
  
    erb :watchlist_results, locals: { albums: albums, id: params[:id], user: user_details }
  end
end

get '/user/watchlist/:id/sort/' do

  redirect '/login' unless logged_in?

  user_watchlist = run_sql("SELECT label_id FROM watchlist where spotify_user_id = $1;", [params[:id]])

  if user_watchlist.count.zero?
     redirect '/'
  end

  array = user_watchlist.to_a.map { |item| item["label_id"] }
  db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'labeldiscovery'})

  if params[:year] == 'asc'
    albums = PgExecArrayParams.exec_array_params(db, 'SELECT * FROM albums WHERE label_id = $1 ORDER BY release_date ASC;', [array])
  elsif params[:year] == 'desc'
    albums = PgExecArrayParams.exec_array_params(db, 'SELECT * FROM albums WHERE label_id = $1 ORDER BY release_date DESC;', [array])
  elsif params[:album] == 'a-z'
    albums = PgExecArrayParams.exec_array_params(db, 'SELECT * FROM albums WHERE label_id = $1 ORDER BY album_name ASC;', [array])
  elsif params[:album] == 'z-a'
    albums = PgExecArrayParams.exec_array_params(db, 'SELECT * FROM albums WHERE label_id = $1 ORDER BY album_name DESC;', [array])
  elsif params[:artist] == 'a-z'
    albums = PgExecArrayParams.exec_array_params(db, 'SELECT * FROM albums WHERE label_id = $1 ORDER BY artist ASC;', [array])
  elsif params[:artist] == 'z-a'
    albums = PgExecArrayParams.exec_array_params(db, 'SELECT * FROM albums WHERE label_id = $1 ORDER BY artist DESC;', [array])
  elsif params[:latest_releases] == '1-month'
    albums = PgExecArrayParams.exec_array_params(db, "SELECT * FROM albums WHERE label_id = $1 AND release_date BETWEEN CURRENT_DATE - INTERVAL '1 months' AND CURRENT_DATE ORDER BY release_date DESC;", [array])
  elsif params[:latest_releases] == '3-month'
    albums = PgExecArrayParams.exec_array_params(db, "SELECT * FROM albums WHERE label_id = $1 AND release_date BETWEEN CURRENT_DATE - INTERVAL '3 months' AND CURRENT_DATE ORDER BY release_date DESC;", [array])
  elsif params[:latest_releases] == '6-month'
    albums = PgExecArrayParams.exec_array_params(db, "SELECT * FROM albums WHERE label_id = $1 AND release_date BETWEEN CURRENT_DATE - INTERVAL '6 months' AND CURRENT_DATE ORDER BY release_date DESC;", [array])
  elsif params[:latest_releases] == 'all'
    albums = PgExecArrayParams.exec_array_params(db, 'SELECT * FROM albums WHERE label_id = $1;', [array])
  end

  user_details = api_request("https://api.spotify.com/v1/me", session[:user_token])
    
  erb :watchlist_results, locals: { albums: albums, id: params[:id], user: user_details }
end