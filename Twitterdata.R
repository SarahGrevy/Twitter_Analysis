#### Set Up ####

#Set Working Directory 


#Download Packages

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

packages <- c("tidyverse", "XQuartz", "tidygraph", "rtweet", "ggraph", "tidytext", "stopwords", "sentimentr", "lubridate", "textfeatures", "wordcloud", "RColorBrewer", "academicTwitterR", "dotwhisker", "jtools")
ipak(packages)
packages <- c("rtweet", "plyr")
ipak(packages)

install.packages("academictwitteR")
library(academictwitteR)

#### Getting Twitter Data ####

#Information about rtweet: https://github.com/cran/rtweet
#Apply for twitter API account: https://developer.twitter.com/en/apply-for-access 

#Create Twitter Token With Regular Account
#Enter your credentials from the Twitter API below or ask Sarah to make you a collaboratoer 
create_token(
  app = "",
  consumer_key = "",
  consumer_secret = "",
  access_token = "",
  access_secret = "",
  set_renv = TRUE
)


#Create Twitter Token with Academic Account, see https://github.com/cjbarrie/academictwitteR
set_bearer()

#### Getting Profile ####'

#Testing: let's look at Soma's most recent tweets 

soma <- get_timeline("dangerscarf", n = 200)

###look at right-winged newsorganizations tweets 

DailyCaller <- get_timeline("DailyCaller", n = 3200)
MailOnline <- get_timeline("MailOnline", n = 3200)
FoxNews <- get_timeline("FoxNews", n = 3200)
nypost <- get_timeline("nypost", n = 3200)
BrietbartNews <- get_timeline("BreitbartNews", 3200)

#bind them together in one coolumn 
dataset <- rbind(DailyCaller, MailOnline, FoxNews, nypost, BrietbartNews)

saveRDS(dataset, "dataset.rds")

#### Get Recent Tweets ####

#look for tweets using search words, in this case, "#fakenews" 
tweets <- search_tweets("#fakenews", n = 100, include_rts = FALSE, geocode = lookup_coords("usa"))

#tweets containing right-leaning low quality news sites URL 
infowars <- search_tweets("infowars.com*", n = 3200)
brietbart <- search_tweets("breitbart.com*", n = 3200)

#right-leaning low quality new sites
occupy <- search_tweets("occupydemocrats.com*", n = 3200)
palmer <- search_tweets("palmerreport.com*", n = 3200)

#### Academic API #### 

#View documentation here: https://github.com/cjbarrie/academictwitteR


tweets <-
  get_all_tweets(
    query = "#fakenews",
    start_tweets = "2020-01-01T00:00:00Z",
    end_tweets = "2020-01-05T00:00:00Z",
    file = "fakenews"
  )

View(tweets)


###look at who follows Soma 

network <- get_friends("dangerscarf")
followers <- get_followers("dangerscarf")
users <- lookup_users(network$user_id)
users <- lookup_users(network$screen_name)

rate_limit(get_friends)

# DATA ANALYSIS # 

#### Get most retweeted tweets/words ####

#Look at most popular tweets 
mostPopular <-  dataset %>% 
  dplyr::select(text, retweet_count, screen_name) %>% 
  arrange(desc(retweet_count)) 

nGrams <- mostPopular %>%
  unnest_tokens(word, text, token = "ngrams", n = 1) 

nGramSort <- nGrams %>%
  group_by(word) %>%
  dplyr::summarize(n = n(),
                   avg_retweets = mean(retweet_count)) %>%
  filter(n > 10) %>%
  arrange(desc(avg_retweets))

View(nGramSort)

