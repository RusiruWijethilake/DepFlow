import tweepy
import pandas as pd

# Set up your Twitter API credentials
consumer_key = 'yXRt6YfxYcCmHjG3Fk0aGiDCn'
consumer_secret = '4xa0zEROY7zU2AubVPmrtZLfatwnSvoY8AcLnzwAuDW4wktZOD'
access_token = '2791650673-lhGU34kNLa9uVffeohIUsIKgfk7gliqYyNJfZwz'
access_token_secret = '5qbcqdCLMA4u2iyxzlKJVtW5QFy9wyEjZLzMMb6z4K68P'

# Authenticate with the Twitter API
auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth)

# Define the search query
query = 'දුක'

# Get the tweets in Sinhala related to depression
tweets = tweepy.Cursor(api.search_tweets, q=query, lang='si').items(1000)

# Create a list to store the tweets
tweet_list = []
for tweet in tweets:
    tweet_list.append(tweet.text)
    print(tweet.text)

# Create a Pandas DataFrame from the list of tweets
df = pd.DataFrame(tweet_list, columns=['text'])

# Save the DataFrame to a CSV file
df.to_csv('depressive_tweets.csv', index=False, encoding='utf-8')
