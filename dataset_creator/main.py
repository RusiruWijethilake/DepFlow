import tweepy
import pandas as pd
import csv

# Replace with your own Twitter API credentials
consumer_key = "5MajFBXBO9y9YELKG1F9bF9nG"
consumer_secret = "VNgziyWnGPFBDrIV05SrHhZyK4Yia9vlFVo5U2NnJaupaw0S7x"
access_token = "2791650673-QOl6BLhSaOljL45ZKixnYhrizNLn9dEkpk9buK2"
access_token_secret = "48Z6eDGFhoC9gRIBX5zjGZyqEyGCQLPV8Qybs4KMDUPXc"

# Authenticate with the Twitter API using Tweepy
auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth)

# Define query parameters
query = "suicide lang:si"
language = "si"

# Collect tweets matching the query
tweets = tweepy.Cursor(api.search_full_archive, label="depflowdb", query=query).items(200)

# Write tweets to CSV file
with open('depressive_tweets_si_10.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['text', 'label'])
    for tweet in tweets:
        print(tweet.text)
        writer.writerow([tweet.text, 0])