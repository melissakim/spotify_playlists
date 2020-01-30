
--now explore the data set 

--first let's see if there are dupes 
select count(*), count(distinct playlist_uri) from playlists;
--no dupes in playlists
-- +--------+--------+
-- | count  | count  |
-- +--------+--------+
-- | 403366 | 403366 |
-- +--------+--------+

select count(*), count(distinct owner) from playlists;
--dupes in owners, which is expected, because spotify is a owner that we know
--create many playlists 
-- +--------+--------+
-- | count  | count  |
-- +--------+--------+
-- | 403366 | 314899 |
-- +--------+--------+

--a user averages about 1.28 playlists 
select (count(*)/count(distinct owner))::numeric(12,2) as avg_playlist_per_user from playlists;
-- +-----------------------+
-- | avg_playlist_per_user |
-- +-----------------------+
-- |                  1.28 |
-- +-----------------------+

--if we exclude spotify...
select (count(*)/count(distinct owner))::numeric(12,2) as avg_playlist_per_user 
from playlists where owner != 'spotify';
--still 1.28, spotify is not outlier enough to skew the average


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

--let's group by number of playlists that a user created 
with base as (
select 
  owner, 
  count(*) as n_playlists 
from 
  playlists 
group by 1)
select 
  n_playlists, 
  count(*) as owners 
from 
  base 
group by 1 
order by 1 desc;
-- +-------------+--------+
-- | n_playlists | owners |
-- +-------------+--------+
-- |         399 |      1 |
-- |          48 |      1 |
-- |          47 |      1 |
-- |          44 |      1 |
-- |          43 |      1 |
-- |          40 |      3 |
-- |          37 |      1 |
-- |          34 |      1 |
-- |          33 |      1 |
-- |          31 |      1 |
-- |          30 |      1 |
-- |          29 |      1 |
-- |          27 |      1 |
-- |          26 |      2 |
-- |          25 |      2 |
-- |          24 |      3 |
-- |          23 |      3 |
-- |          22 |      5 |
-- |          21 |      1 |
-- |          20 |      8 |
-- |          19 |      7 |
-- |          18 |     13 |
-- |          17 |     18 |
-- |          16 |     13 |
-- |          15 |     16 |
-- |          14 |     26 |
-- |          13 |     42 |
-- |          12 |     44 |
-- |          11 |     79 |
-- |          10 |     93 |
-- |           9 |    152 |
-- |           8 |    243 |
-- |           7 |    435 |
-- |           6 |    755 |
-- |           5 |   1564 |
-- |           4 |   3591 |
-- |           3 |   9983 |
-- |           2 |  36746 |
-- |           1 | 261040 |
-- +-------------+--------+






