
--now explore the data set 

--first let's see if there are dupes 
select count(*), count(distinct playlist_uri) from playlists;

--notes about the dataset: the owner country is US only 
--number of playlists spotify owns vs. individuals 
select 
  case when owner = 'spotify' then owner else 'user' end as owner_type, 
  count(distinct playlist_uri) as n_playlists 
from 
  playlists 
group by 1;
-- +------------+-------------+
-- | owner_type | n_playlists |
-- +------------+-------------+
-- | spotify    |         399 |
-- | user       |      402967 |
-- +------------+-------------+