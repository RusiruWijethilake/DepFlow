class Tweet {

  String id;
  String text;
  String author;
  String authorid;
  String url;
  bool isDepressive;

  Tweet({required this.id, required this.text, required this.author, required this.url, this.isDepressive = false, this.authorid = ""});

  get tweetid => id;
  get tweettext => text;
  get tweetauthor => author;
  get tweeturl => url;
  get tweetisDepressive => isDepressive;
  get tweetauthorid => authorid;

  Tweet fromJson(Map<String, dynamic> json) {
    return Tweet(
      id: json['id'],
      text: json['text'],
      author: json['author'],
      url: json['url'],
    );
  }
}