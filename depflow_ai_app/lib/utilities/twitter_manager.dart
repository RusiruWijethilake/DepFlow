import 'dart:convert';

import 'package:depflow_ai_app/entities/entity_tweet.dart';
import 'package:depflow_ai_app/utilities/shared_pref_manager.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:twitter_oauth2_pkce/twitter_oauth2_pkce.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;
import 'package:http/http.dart' as http;

class TwitterManager {

  v2.TwitterApi? twitter;

  final oauth2 = TwitterOAuth2Client(
    clientId: 'aVpDZVVqNEUwMGs2MmJzam5WX206MTpjaQ',
    clientSecret: 'YXTRTf8ol8tqMYgEpuIZjmyMG0YymIkN0FAkHfvCDy4-_ljZUt',
    redirectUri: 'org.example.android.oauth://callback/',
    customUriScheme: 'org.example.android.oauth',
  );
  
  Future<void> initTwitter() async {
    String accessToken = await SharedPrefManager().getAccessToken();

    if (accessToken == '') {
      initNewTwitter();
      return;
    }

    print("TWITTER ACCESS TOKEN: $accessToken");

    await initTwitterAPI(accessToken);
  }

  Future<void> initNewTwitter() async {
    String? _accessToken;

    final response = await oauth2.executeAuthCodeFlowWithPKCE(
      scopes: Scope.values,
    );

    _accessToken = response.accessToken;

    await SharedPrefManager().saveAccessToken(_accessToken);

    await initTwitterAPI(_accessToken);
  }

  Future<List<v2.TweetData>> loadLatestTweets() async {
    if (twitter == null) {
      initTwitter();
    }

    try {
      final me = await twitter!.users.lookupMe();

      final response = await twitter!.tweets.lookupHomeTimeline(
        userId: me.data.id.toString(),
        maxResults: 20,
        tweetFields: [
          v2.TweetField.authorId,
          v2.TweetField.id,
          v2.TweetField.lang,
        ],
        excludes: [
          v2.ExcludeTweetType.retweets,
        ],
      );

      return response.data;
    } catch (e) {
      initNewTwitter();

      final me = await twitter!.users.lookupMe();

      final response = await twitter!.tweets.lookupHomeTimeline(
        userId: me.data.id.toString(),
        maxResults: 20,
        tweetFields: [
          v2.TweetField.authorId,
          v2.TweetField.id,
          v2.TweetField.lang,
        ],
        excludes: [
          v2.ExcludeTweetType.retweets,
        ],
      );

      return response.data;
    }
  }

  Future<bool> sendMessage(String message, String recipientId) async {
    if (twitter == null) {
      initTwitter();
    }

    try {
      var response = await twitter!.directMessages.createConversation(
        participantId: recipientId,
        message: v2.MessageParam(text: message),
      );

      return response.status == v2.HttpStatus.ok || response.status == v2.HttpStatus.accepted;
    } catch (e) {
      await initNewTwitter();

      var response = await twitter!.directMessages.createConversation(
        participantId: recipientId,
        message: v2.MessageParam(text: message),
      );

      return response.status == v2.HttpStatus.ok || response.status == v2.HttpStatus.accepted;
    }
  }

  Future<List<v2.TweetData>> loadMyLatestTweets() async {
    if (twitter == null) {
      await initTwitter();
    }

    try {
      final me = await twitter!.users.lookupMe();

      final response = await twitter!.tweets.lookupTweets(
        userId: me.data.id.toString(),
        maxResults: 20,
        tweetFields: [
          v2.TweetField.authorId,
          v2.TweetField.id,
          v2.TweetField.lang,
        ],
        excludes: [
          v2.ExcludeTweetType.retweets,
        ],
      );

      return response.data;
    } catch (e) {
      await initNewTwitter();

      final me = await twitter!.users.lookupMe();

      final response = await twitter!.tweets.lookupTweets(
        userId: me.data.id.toString(),
        maxResults: 20,
        tweetFields: [
          v2.TweetField.authorId,
          v2.TweetField.id,
          v2.TweetField.lang,
        ],
        excludes: [
          v2.ExcludeTweetType.retweets,
        ],
      );

      return response.data;
    }
  }

  Future<String> getTwitterUsername() async {
    if (twitter == null) {
      await initTwitter();
    }

    try {
      var response = await twitter!.users.lookupMe();
      return response.data.username.toString();
    } catch (e) {
      await initNewTwitter();

      var response = await twitter!.users.lookupMe();
      return response.data.username.toString();
    }
  }

  Future<String> getTwitterUserId() async {
    if (twitter == null) {
      await initTwitter();
    }

    try {
      var response = await twitter!.users.lookupMe();
      return response.data.id.toString() ?? '';
    } catch (e) {
      initNewTwitter();

      var response = await twitter!.users.lookupMe();
      return response.data.id.toString() ?? '';
    }
  }

  Future<void> initTwitterAPI(String accessToken) async {
    try {
      twitter = v2.TwitterApi(
        bearerToken: accessToken ?? '',
        oauthTokens: const v2.OAuthTokens(
          consumerKey: 'HxpBVhYlfGCMBzWaz5tV4DJrf',
          consumerSecret: 'Uz7hzhrJuEwdqIMr0Xo08kbBvl3mJsXTPlNrDRf1vcn24x9BmP',
          accessToken: '2791650673-TPNix2A5zMcp9wDoxswQ4Gdkziet1AprdQ6ax5o',
          accessTokenSecret: 'KvdKcgxZfs52QRsyaYtKNfnWdsEiN5tdg75XRwCagGdCT',
        ),
        retryConfig: v2.RetryConfig(
          maxAttempts: 5,
          onExecute: (event) =>
              print(
                'Retry after ${event.intervalInSeconds} seconds... '
                    '[${event.retryCount} times]',
              ),
        ),
        timeout: const Duration(days: 1),
      );
    } catch (e) {
      await initNewTwitter();
    }
  }

  String getCleanedStrings(String twitterText) {
    // Remove multiple "RT"s
    twitterText = twitterText.replaceAll(RegExp(r'RT\s+'), '');

    // Remove multiple usernames
    twitterText = twitterText.replaceAll(RegExp(r'@\w+\s*@\w+'), '');

    // Remove links
    twitterText = twitterText.replaceAll(RegExp(r'https?://\S+'), '');

    // Remove emojis
    final parser = EmojiParser();
    final text = parser.unemojify(twitterText);
    if (text != null) {
      twitterText = text;
    }

    return twitterText.trim();
  }


}