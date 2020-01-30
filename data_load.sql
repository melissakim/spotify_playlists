


--first create a temple table to load all the data
create local temp table playlists (
playlist_uri varchar(512),
owner varchar(512),
streams int,
stream30s int,
dau int,
wau int,
mau int,
mau_previous_months int,
mau_both_months int,
users int,
skippers int,
owner_country varchar(12),
n_tracks int,
n_local_tracks int,
n_artists int,
n_albums int,
monthly_stream30s int,
monthly_owner_stream30s int,
tokens varchar(512),
genre_1 varchar(128),
genre_2 varchar(128),
genre_3 varchar(128),
mood_1 varchar(128),
mood_2 varchar(128),
mood_3 varchar(128)
) on commit preserve rows;


--now load
copy playlists from local '/Users/mkim/Documents/Playlists/playlist.csv' 
delimiter ',' skip 1 exceptions 'exceptions.csv';

--all rows loaded, yay!
-- +-------------+
-- | Rows Loaded |
-- +-------------+
-- |      403366 |
-- +-------------+









