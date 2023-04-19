class Tweet {

  String id;
  String text;
  String author;
  String url;

  Tweet({required this.id, required this.text, required this.author, required this.url});

  get tweetid => id;
  get tweettext => text;
  get tweetauthor => author;
  get tweeturl => url;

  Tweet fromJson(Map<String, dynamic> json) {
    return Tweet(
      id: json['id'],
      text: json['text'],
      author: json['author'],
      url: json['url'],
    );
  }
}