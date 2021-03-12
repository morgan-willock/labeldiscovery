# Script to scrape album data for albums using spotify API and input into postgres database

require 'pg'
require 'httparty'
require 'pry'

# Connect to database and run sql command

def run_sql(sql, arr = []) # set default argument of arr incase nothing is passed into the func
  db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'labeldiscovery'})
  results = db.exec_params(sql, arr)
  db.close
  return results
end

# api_request to spotify. URL should be in "" and token should be valid token returned from spotify server

user_token = "BQDfLpMql_gl9DhK8SrFoG1nZK7RVQiSNDBMsoblI_fooniSRIMi3SLIOZUECnpxWggPrx4xL1OhyBEQPZp9VW2SsIVQkf4E9aY-PO0JDXW_YDIRypT_aWoND-07rAEbfmLpzuPwZ-XDpHBRB9oeSFzrS5ybyyBy4Q"

def api_request(url, user_token)
  request = HTTParty.get(url,
    headers: { 'Accept' => 'application/json',
              'Authorization' => "Bearer #{user_token}" })
  return request
end

####### ID needs to be input - This ID is from labeldiscovery database - label (table) - On correct input of the id this pre fills the request url / label id / label name fields.
id = 13
#######

label_details = run_sql("SELECT * FROM labels WHERE id = $1;", [id])

results = api_request("#{label_details.values[0][2]}&offset=0&limit=50", user_token)

label_id = label_details.values[0][0]
label_name = label_details.values[0][1]
total = 5000
start = 0
limit = 50

while start < total

  binding.pry

  results = api_request("#{label_details.values[0][2]}&offset=#{start}&limit=#{limit}", user_token)

  total = results["albums"]["total"]

  results["albums"]["items"].each do | item |

    result = run_sql("SELECT * FROM albums WHERE spotify_album_id = $1;", [item["id"]]);

    

    if result.count.zero?

      sql = "INSERT INTO albums (label_id, spotify_album_id,  artist, tracks, release_date, external_link, image_lrg, image_med, image_sml, album_name, label_name) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11);"

      if item["release_date"].length > 4
        run_sql(sql, [label_id, item["id"], item["artists"][0]["name"], item["total_tracks"], item["release_date"], item["external_urls"]["spotify"], item["images"][0]["url"], item["images"][1]["url"], item["images"][2]["url"], item["name"], label_name]) 
      end

    end
  end
  start += 50
end


# ######
# # Locators for search results
# ######
# #artist name num1
# result["albums"]["items"][0]["artists"][0]["name"]
# #external url
# result["albums"]["items"][0]["external_urls"]["spotify"]
# #album spotify ID
# result["albums"]["items"][0]["id"]
# #images #large #medium #small
# result["albums"]["items"][0]["images"][0]["url"]
# result["albums"]["items"][0]["images"][1]["url"]
# result["albums"]["items"][0]["images"][2]["url"]
# #album name
# result["albums"]["items"][0]["name"]
# #release date
# result["albums"]["items"][0]["release_date"]
# #total tracks
# result["albums"]["items"][0]["total_tracks"]