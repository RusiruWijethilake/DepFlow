import 'dart:convert';

import 'package:depflow_ai_app/entities/entity_tweet.dart';
import 'package:depflow_ai_app/utilities/shared_pref_manager.dart';
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

    initTwitterAPI(accessToken);
  }

  Future<void> initNewTwitter() async {
    String? _accessToken;

    final response = await oauth2.executeAuthCodeFlowWithPKCE(
      scopes: [
        Scope.followsRead,
        Scope.likeRead,
        Scope.listRead,
        Scope.tweetRead,
        Scope.usersRead,
        Scope.directMessageWrite,
      ],
    );

    _accessToken = response.accessToken;

    await SharedPrefManager().saveAccessToken(_accessToken);

    initTwitterAPI(_accessToken);
  }

  Future<List<v2.TweetData>> loadLatestTweets() async {
    if (twitter == null) {
      initTwitter();
    }

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

  Future<String> getTwitterUsername() async {
    var response = await twitter!.users.lookupMe();
    return response.data.username.toString();
  }

  Future<String> getTwitterUserId() async {
    var response = await twitter!.users.lookupMe();
    return response.data.id.toString() ?? '';
  }

  void initTwitterAPI(String accessToken) {
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
      initNewTwitter();
    }
  }

}