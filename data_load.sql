


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


--TAIM analysis:
--Task: 15-20 presentation on what makes a successful playlist 
--Audience: A panel of 4 team members including 3 data scientists and one Artist and Label Marketing 
--Intent: explain WHAT components make up a successful playlist and WHY
--Message: up to me!


--data point wishlist:
--playlist creation date - there may be a ramp-up period for playlists and looking at 
--success/engagement measures may not be an accurate measure for success for new playlists 
--followers


--open questions / things i'd want to explore:
--what amout of time is right to determine when it's the right time to evaluate whether 
--a user's playlist is successful?
--what is the play rate by the playlist's visibility? (i.e. spotify playlists have more
--exposure/impressions than individual playlists )
--other markets (this is us only, but would love to understand what diff markets' successful
--playlists look like)


--initial thoughts on success measures:
--engagement/activity: avg streams per user today, avg streams per user this month
--consistency/stickiness: do users vary wildly, or are they pretty consistent? if it varies, is it growing?
--consumption: are most of the tracks being listened to / are the tracks being listened to?

/* 
popularity: streams30, monthly_stream30s by decile 
relevance: stream30s/streams
consistency: dau/mau, dau/wau, 
*/



