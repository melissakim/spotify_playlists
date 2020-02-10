
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
--still 1.28, spotify alone is not outlier enough to skew the average


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

--on average, how many tracks does each playlist have?
select avg(n_tracks) from playlists;
-- +-----------------+
-- |       avg       |
-- +-----------------+
-- | 201.48343192039 |
-- +-----------------+

select distinct median(n_tracks) over() as median from playlists;
-- +----------+
-- |  median  |
-- +----------+
-- |       84 |
-- +----------+


-- select count(*) from playlists where tokens is not null;


--now let's start pulling in some measures for the playlist
--because today's stats are more commonly 0 (streams, stream30s, dau), 0 stats could still have
--a decent percentage. so, for any 0 values, force it to 1%.
drop table if exists playlist_stats;
create local temp table playlist_stats on commit preserve rows as (
select 
  playlist_uri,
  owner,
  streams,
  stream30s,
  (ntile(100) over(order by stream30s)/100)::numeric(12,2) as stream30s_percentile,
  (stream30s/nullif(streams,0))::numeric(12,4) as perc_streams_nonskipped_today,
  dau,
  (ntile(100) over(order by dau)/100)::numeric(12,2) as dau_percentile,
  wau,
  mau,
  (ntile(100) over(order by mau)/100)::numeric(12,2) as mau_percentile,
  (dau/nullif(wau,0))::numeric(12,4) as dau_to_wau,
  (dau/nullif(mau,0))::numeric(12,4) as dau_to_mau,
  mau_previous_months,
  mau_both_months,
  ((mau_previous_months/nullif(mau,0))-1)::numeric(12,4) as monthly_growth,
  (mau_both_months/nullif(mau,0))::numeric(12,4) as perc_existing_mau,
  (mau/nullif(users,0))::numeric(12,4) as perc_user_engagement, 
  users,
  skippers,
  owner_country,
  n_tracks,
  n_local_tracks,
  (n_local_tracks/nullif(n_tracks,0))::numeric(12,4) as perc_new_tracks,
  n_artists,
  n_albums,
  (n_albums/nullif(n_artists,0))::numeric(12,2) as playlist_mix_ratio,
  monthly_stream30s,
  (ntile(100) over(order by monthly_stream30s)/100)::numeric(12,2) as monthly_stream30s_percentile,
  monthly_owner_stream30s,
  (monthly_stream30s/30.42/nullif(stream30s,0))::numeric(12,4) as daily_stream_index, -- proxy for consistency in stream plays
  (monthly_owner_stream30s/nullif(monthly_stream30s,0))::numeric(12,4) owner_stream_contribution,
  tokens,
  case when tokens is not null then char_length(tokens)-char_length(replace(tokens, ':', ''))+1 end as n_tokens,
  genre_1,
  genre_2,
  genre_3,
  mood_1,
  mood_2,
  mood_3
from 
  playlists 
);

-- --let's explore into a csv so we can explore further using visualizations in R

-- \o ~/Documents/Playlists/playlist_stats.csv;
-- select * from playlist_stats;
-- \o


-- select 
--   perc_streams_nonskipped_today::numeric(12,2) as perc_trunc,
--   count(*) 
-- from 
--   playlist_stats 
-- group by 1 
-- order by 1;

-- select avg(perc_streams_nonskipped_today) from playlist_stats;

--now create a composite scoring based on a weighting system:
--for purpose of exercise, choose a weighting system
--popularity: 60%
--relevance: 30%
--consistency: 10%
drop table if exists success_score;
create local temp table success_score on commit preserve rows as (
with base as (
select 
  *,
  ((dau_percentile+mau_percentile+stream30s_percentile+monthly_stream30s_percentile)/4)::numeric(12,4) as popularity_score,
  ((dau_percentile+mau_percentile+stream30s_percentile+monthly_stream30s_percentile)/4*0.60)::numeric(12,4) as popularity_weight,
  perc_streams_nonskipped_today as relevance_score,
  (perc_streams_nonskipped_today*0.30)::numeric(12,4) as relevance_weight,
  ((dau_to_mau+dau_to_wau+perc_existing_mau)/3)::numeric(12,4) as consistency_score,
  ((dau_to_mau+dau_to_wau+perc_existing_mau)/3*0.10)::numeric(12,4) as consistency_weight
from 
  playlist_stats
  )
select 
  *, 
  round(((coalesce(popularity_weight,0)+coalesce(relevance_weight,0)+coalesce(consistency_weight,0))*100))::numeric(12,0) as success_score 
from 
  base 
); 

select
  success_score,
  count(*)
from 
  success_score 
group by 1 
order by 1;
--plot the distribution curve? bimodal




--use success score to describe the playlists (group success scores into three buckets: 16-51,52-78,79-97)
--distribution falls within a normal bell curve
--on average, how many artists/tracks/albums do they feature? (boxplot)
--what are the most often appearing genres/moods? (wordcloud)
--average number of tokens
select 
  case when success_score <= 38 then 'low'
       when success_score between 39 and 74 then 'average'
       when success_score >= 75 then 'high' end as success_score_group,
  count(*) as n_playlists,
  avg(n_artists)::numeric(12,2) as average_artists,
  avg(n_tracks)::numeric(12,2) as average_tracks,
  avg(n_albums)::numeric(12,2) as average_albums 
from 
  success_score 
group by 1;

-- +---------------------+-------------+-----------------+----------------+----------------+
-- | success_score_group | n_playlists | average_artists | average_tracks | average_albums |
-- +---------------------+-------------+-----------------+----------------+----------------+
-- | high                |       43307 |           98.04 |         275.77 |         103.42 |
-- | average             |      146015 |           99.51 |         232.50 |         104.85 |
-- | low                 |      214044 |           70.30 |         165.30 |          73.81 |
-- +---------------------+-------------+-----------------+----------------+----------------+


drop table if exists success_score_group;
create local temp table success_score_group on commit preserve rows as (
select 
  *,
  case when success_score <= 38 then 'low'
       when success_score between 39 and 74 then 'average'
       when success_score >= 75 then 'high' end as success_score_group,
  (n_artists/nullif(n_tracks,0))::numeric(12,4) as artist_mix,
  (n_albums/nullif(n_tracks,0))::numeric(12,4) as album_mix,
  mood_1||'-'||genre_1 as genre_mood_1,
  mood_2||'-'||genre_1 as genre_mood_2,
  mood_3||'-'||genre_1 as genre_mood_3,
  (skippers/users)::numeric(12,4) as perc_skippers,
  case when owner = 'spotify' then owner else 'user' end as user_group
from 
  success_score
) order by 1;



-- \o ~/Documents/Playlists/playlist_scores_4.csv;
-- select * from success_score_group;
-- \o



-- select success_score_group, avg(perc_new_tracks) from success_score_group group by 1;
-- +---------------------+--------------------+
-- | success_score_group |        avg         |
-- +---------------------+--------------------+
-- | low                 |  0.011862229728467 |
-- | high                | 0.0103183018911492 |
-- | average             | 0.0120712173406842 |
-- +---------------------+--------------------+











