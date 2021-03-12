CREATE DATABASE labeldiscovery;

CREATE TABLE labels (
    ID SERIAL PRIMARY KEY,
    label_name TEXT,
    spotify_search_term TEXT,
    label_img_url TEXT
    );

CREATE TABLE albums (
    label_ID SERIAL PRIMARY KEY,
    spotify_album_ID TEXT,
    artist TEXT,
    tracks INTEGER,
    release_date DATE,
    external_link TEXT,
    image_lrg TEXT,
    image_med TEXT,
    image_sml TEXT
    );

ALTER TABLE albums ADD COLUMN album_name TEXT;

ALTER TABLE albums ADD COLUMN label_name TEXT;

CREATE TABLE users (
    ID SERIAL PRIMARY KEY,
    spotify_user_id TEXT,
    user_token TEXT,
    refresh_token TEXT
    );

CREATE TABLE watchlist (
    ID SERIAL PRIMARY KEY,
    spotify_user_id TEXT,
    label_id INTEGER
    );

INSERT INTO albums (label_id, spotify_album_id, artist, tracks, release_date, external_link, image_lrg, image_med, image_sml, album_name, label_name) VALUES (1, 'spotify_album_id', 'test_artist', 10, '10/09/1988', 'www.spotify.com/test', 'test_lrg', 'test_med', 'test_sml', 'test_album', 'test_label_name');

sql = "INSERT INTO albums (label_id, spotify_album_id, artist, tracks, release_date, external_link, image_lrg, image_med, image_sml, album_name, label_name) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11);" 

run_sql(sql, [$1, $2, $3, $4, $5, $6, $7, $8, $9, $10])

run_sql("SELECT * FROM dishes where id = $1;", [params[:id]]

-- Search for current releases within 1 month from current date and order by release date

SELECT * FROM albums WHERE label_id = 2 AND release_date BETWEEN CURRENT_DATE - INTERVAL '1 months' AND CURRENT_DATE ORDER BY release_date DESC;

-- Labels input into database

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Hot Creations', 'https://api.spotify.com/v1/search?q=label%3A%22Hot%20Creations%22&type=album', 'https://f4.bcbits.com/img/0018592473_10.jpg');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Innervisions', 'https://api.spotify.com/v1/search?q=label%3A%22Innervisions%22&type=album', 'https://f4.bcbits.com/img/0023151800_10.jpg');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Drumcode', 'https://api.spotify.com/v1/search?q=label%3A%22Drumcode%22&type=album', 'https://i1.sndcdn.com/avatars-000330082621-tj0wzt-t500x500.jpg');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Bondage Music', 'https://api.spotify.com/v1/search?q=label%3A%22Bondage%20music%22&type=album', 'https://www.internationaldjmag.com/mag/images/label/bondage-music_586_1530480837_original.png');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Kompakt', 'https://api.spotify.com/v1/search?q=label%3AKompakt&type=album', 'https://kompaktartistagency.de/assets/components/themebootstrap/images/kompakt-artist-agency-logo.png');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Defected Records', 'https://api.spotify.com/v1/search?q=label%3A%22Defected%20Records%22&type=album', 'https://defected.com/media/magefan_blog/images_defectedlogo_black.jpg');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('The Bunker New York', 'https://api.spotify.com/v1/search?q=label%3A%22The%20Bunker%20New%20York%22&type=album', 'https://img.discogs.com/-xYOEXsA8_-O8UxwjXO_0CObgR0=/fit-in/300x300/filters:strip_icc():format(jpeg):mode_rgb():quality(40)/discogs-images/L-641587-1390279783-9052.jpeg.jpg');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Clone Royal Oak', 'https://api.spotify.com/v1/search?query=label%3A%22Clone+Royal+Oak%22&type=album', 'https://pbs.twimg.com/profile_images/1913288019/family_blue.jpg');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Clone Classic Cuts', 'https://api.spotify.com/v1/search?q=label%3A%22Clone%20Classic%20Cuts%22&type=album', 'https://f4.bcbits.com/img/a0315251372_2.jpg');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Atomnation', 'https://api.spotify.com/v1/search?q=label%3A%22Atomnation%22&type=album', 'https://img.discogs.com/zKIcp5rb9fqOPq9lEST9AQmtRQQ=/fit-in/300x300/filters:strip_icc():format(jpeg):mode_rgb():quality(40)/discogs-images/L-476773-1359552915-5808.jpeg.jpg');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Spazio Disponibile', 'https://api.spotify.com/v1/search?q=label%3A%22Spazio%20Disponibile%22&type=album', 'https://ra.co/images/cover/tr-844105.jpg');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('Klockworks', 'https://api.spotify.com/v1/search?q=label%3A%22Klockworks%22&type=album', 'https://img.discogs.com/9i_TFz90q6pms15a0qi9CXJ3sfE=/fit-in/300x300/filters:strip_icc():format(jpeg):mode_rgb():quality(40)/discogs-images/L-78794-1612376211-7555.jpeg.jpg');

INSERT INTO labels (label_name, spotify_search_term, label_img_url) VALUES ('', '', '');

-- 