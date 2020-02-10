#Melissa Kim
#Spotify Assignment: What Makes a Successful Playlist?

library(dplyr)
library(reshape2)
library(ggplot2)
library(wordcloud)
library(ggthemes)


playlist_scores <- read.csv("playlist_scores_4.csv", header = TRUE)

nrow(playlist_scores)
#[1] 403366
str(playlist_scores) 
#because my dataset from SQL has null, R imported them as characters rather than 
#numeric let's change that now, NULL should -> NA by coercion
playlists <- transform(playlist_scores, 
                       perc_streams_nonskipped_today = as.numeric(as.character(perc_streams_nonskipped_today)),
                       dau_to_wau = as.numeric(as.character(dau_to_wau)),
                       daily_stream_index = as.numeric(as.character(daily_stream_index)),
                       n_tokens = as.numeric(as.character(n_tokens)),
                       relevance_score = as.numeric(as.character(relevance_score)),
                       relevance_weight = as.numeric(as.character(relevance_weight)),
                       consistency_score = as.numeric(as.character(consistency_score)),
                       consistency_weight = as.numeric(as.character(consistency_weight)))

#now let's do this for all of the measures
#first, pull in the columns i want 
#my_measures <- c("n_tracks", "n_artists", "n_albums", "n_tokens", "success_score_group")

#playlist_subset <- playlists[my_measures]

#now melt the data so that all of the columns become one
#playlists_m <- melt(playlist_subset, id.vars = "success_score_group")

#p <- ggplot(data = playlists_m, aes(x=success_score_group, y=value)) + geom_boxplot()
#p + facet_wrap( ~ variable, scales="free")

#there are too many outliers for the boxplot to tell us anything. 
#let's look at the ratio of albums/artists to tracks
my_measures <- c("artist_mix", 
                 "album_mix", 
                 "dau_to_mau", 
                 "dau_to_wau", 
                 "perc_streams_nonskipped_today",
                 "perc_existing_mau",
                 "success_score_group",
                 "perc_skippers",
                 "monthly_stream30s", 
                 "mau",
                 "dau",
                 "stream30s", 
                 "n_tokens")

playlist_subset <- playlists[my_measures]
playlist_subset$success_score_group <- factor(playlist_subset$success_score_group, ordered = TRUE, levels = c("low", "average", "high"))

playlist_sub1 <- playlist_subset[c("success_score_group", "stream30s", "monthly_stream30s","dau","mau")]
colnames(playlist_sub1) <- c("success_score_group", "# of Streams Over 30 Seconds", "# of Monthly Streams Over 30 Seconds", "DAU", "MAU")
playlist_sub2 <- playlist_subset[c("success_score_group", "dau_to_mau", "dau_to_wau","perc_existing_mau","perc_streams_nonskipped_today")]
colnames(playlist_sub2) <- c("success_score_group", "DAU to MAU", "DAU to WAU", "Percent Existing MAU From Month Prior", "Percent Streams Played Through")
playlist_sub3 <- playlist_subset[c("success_score_group", "artist_mix", "album_mix")]
colnames(playlist_sub3) <- c("success_score_group", "Artist to Track Ratio", "Album to Track Ratio")

#now melt the data so that all of the columns become one
playlists_m <- melt(playlist_subset, id.vars = "success_score_group")
playlists_1 <- melt(playlist_sub1, id.vars = "success_score_group")
playlists_2 <- melt(playlist_sub2, id.vars = "success_score_group")
playlists_3 <- melt(playlist_sub3, id.vars = "success_score_group")

p <- ggplot(data = playlists_m, aes(x=success_score_group, y=value, fill=success_score_group)) + geom_boxplot()
p + facet_wrap( ~ variable, scales="free")

p <- ggplot(data = playlists_1, aes(x=success_score_group, y=value, fill=success_score_group)) + geom_boxplot(show.legend = FALSE)
p + facet_wrap( ~ variable, scales="free") + 
  labs(title="Playlist Popularity by Success Group", 
       x="Success Group",
       y="Logged Values",
       fill="Success Group") +
   scale_fill_brewer(palette="Greens") +
    theme(axis.text = element_text(size = 20, face = "bold"),
        axis.title = element_text(size=20),
        plot.title = element_text(size=30),
        legend.title = element_blank()) +
    theme_hc() + 
    scale_y_log10() +
   theme(strip.text.x = element_text(size = 20))

p <- ggplot(data = playlists_2, aes(x=success_score_group, y=value, fill=success_score_group)) + geom_boxplot(show.legend = FALSE)
p + facet_wrap( ~ variable, scales="free") + 
  labs(title="Playlist Relevance/Consistency by Success Group", 
       x="Success Group",
       y=element_blank(),
       fill="Success Group") +
  scale_fill_brewer(palette="Greens") +
  theme(axis.text = element_text(size = 20, face = "bold"),
        axis.title = element_text(size=20),
        plot.title = element_text(size=30),
        legend.title = element_blank()) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  theme_hc() + 
  theme(strip.text.x = element_text(size = 20))

p <- ggplot(data = playlists_3, aes(x=success_score_group, y=value, fill=success_score_group)) + geom_boxplot(show.legend = FALSE)
p + facet_wrap( ~ variable, scales="free") + 
  labs(title="Artist/Album to Track Ratio by Success Group", 
       x="Success Group",
       y=element_blank(),
       fill="Success Group") +
  scale_fill_brewer(palette="Greens") +
  theme(axis.text = element_text(size = 20, face = "bold"),
        axis.title = element_text(size=20),
        plot.title = element_text(size=30),
        legend.title = element_blank()) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  theme_hc() + 
  theme(strip.text.x = element_text(size = 20))


#now let's get some wordcloud by success level
#genre - low success
genres <- playlists[c("genre_mood_1", "genre_mood_2", "genre_mood_3", "success_score_group")]
genre_melt <- melt(genres, id.vars = "success_score_group")
colnames(genre_melt) <- c("success_score_group", "genre_mood_level", "genre_mood_combo")

genre_cloud_low <- genre_melt %>% filter(success_score_group == "low") %>% count(genre_mood_combo,sort = TRUE)
set.seed(23)
wordcloud(words=genre_cloud_low$genre_mood_combo,
          min.freq = 1,
          freq=genre_cloud_low$n*100,
          random.order=FALSE,
          scale=c(1,0.1),
          max.words = 300,
          rot.per=0.15,
          colors=brewer.pal(8, "Dark2"))


genre_cloud_avg <- genre_melt %>% filter(success_score_group == "average") %>% count(genre_mood_combo,sort = TRUE)
set.seed(27)
wordcloud(words=genre_cloud_avg$genre_mood_combo,
          min.freq = 1,
          freq=genre_cloud_low$n*100,
          random.order=FALSE,
          scale=c(1,0.1),
          max.words = 300,
          rot.per=0.15,
          colors=brewer.pal(8, "Dark2"))


genre_cloud_high <- genre_melt %>% filter(success_score_group == "high") %>% count(genre_mood_combo,sort = TRUE)
set.seed(29)
wordcloud(words=genre_cloud_high$genre_mood_combo,
          min.freq = 1,
          freq=genre_cloud_low$n,
          random.order=FALSE,
          scale=c(1,0.1),
          max.words = 300,
          rot.per=0.15,
          colors=brewer.pal(8, "Dark2"))

genre_cloud_spotify <- genre_melt %>% filter(success_score_group == "spotify") %>% count(genre_mood_combo,sort = TRUE)
set.seed(29)
wordcloud(words=genre_cloud_spotify$genre_mood_combo,
          min.freq = 1,
          freq=genre_cloud_low$n,
          random.order=FALSE,
          scale=c(1,0.1),
          max.words = 300,
          rot.per=0.15,
          colors=brewer.pal(8, "Dark2"))

genre_cloud_user <- genre_melt %>% filter(success_score_group == "spotify") %>% count(genre_mood_combo,sort = TRUE)
set.seed(29)
wordcloud(words=genre_cloud_user$genre_mood_combo,
          min.freq = 1,
          freq=genre_cloud_low$n,
          random.order=FALSE,
          scale=c(1,0.1),
          max.words = 300,
          rot.per=0.15,
          colors=brewer.pal(8, "Dark2"))

# let's look at how spotify specifically plays a role in creating successful playlists
playlist_owner <- playlist_scores %>% 
                  group_by(user_group, success_score_group) %>%
                  summarize(playlists = n())

owner_summary <- playlist_scores %>% 
  group_by(user_group) %>%
  summarize(playlists = n())

playlist_joined <-
playlist_owner %>%
  inner_join(owner_summary, by = "user_group")

as.data.frame(playlist_joined)
colnames(playlist_joined) <- c("user_group", "success_score_group", "playlists", "total_playlists")
playlist_final <- playlist_joined %>% mutate(perc_of_total = playlists/total_playlists)
playlist_final$success_score_group <- factor(playlist_final$success_score_group, ordered = TRUE, levels = c("low", "average", "high"))


p <- ggplot(data = playlist_final, aes(x=success_score_group, y=perc_of_total, fill=success_score_group)) + geom_bar(stat ="identity", show.legend = FALSE)
p + facet_wrap( ~ user_group) + 
  labs(title="% of Playlists in Success Group by User", 
       x="Success Group",
       y=element_blank(),
       fill="Success Group") +
  scale_fill_brewer(palette="GnBu") +
  theme(axis.text = element_text(size = 20, face = "bold"),
        axis.title = element_text(size=20),
        plot.title = element_text(size=30),
        legend.title = element_blank(),
        legend.position = "none") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  theme_hc() + 
  theme(strip.text.x = element_text(size = 20))

