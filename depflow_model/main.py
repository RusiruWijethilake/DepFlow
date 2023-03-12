import nltk
import pandas as pd
from nltk.corpus import sinica_treebank, treebank
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

# Load the dataset
df = pd.read_csv('depressive_tweets_sinhala.csv') # Insert the path to the dataset file here
text_data = df['tweet']
labels = df['depressive']

# Preprocess the data
text_data = text_data.apply(lambda x: x.lower())
text_data = text_data.apply(nltk.word_tokenize)

# Define the features
def get_features(text):
    features = {}
    for word in text:
        features['contains({})'.format(word)] = True
    return features

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(text_data, labels, test_size=0.2)

# Train the model
train_data = []
for i in range(len(X_train)):
    train_data.append((get_features(X_train.iloc[i]), y_train.iloc[i]))

classifier = nltk.NaiveBayesClassifier.train(train_data)

# Test the model
test_data = []
for i in range(len(X_test)):
    test_data.append((get_features(X_test.iloc[i]), y_test.iloc[i]))

predictions = classifier.classify_many([features for features, label in test_data])

print("Accuracy: ", accuracy_score(y_test, predictions))
print("Precision: ", precision_score(y_test, predictions))
print("Recall: ", recall_score(y_test, predictions))
print("F1-Score: ", f1_score(y_test, predictions))