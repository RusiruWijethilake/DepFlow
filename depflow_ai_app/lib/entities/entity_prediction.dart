class EntityPrediction {
  final String id;
  final int prediction;
  final String author;
  final String link;

  EntityPrediction({
    required this.id,
    required this.prediction,
    required this.author,
    required this.link,
  });

  get getId => id;
  get getPrediction => prediction;
  get getAuthor => author;
  get getLink => link;

  factory EntityPrediction.fromJson(Map<String, dynamic> json) {
    return EntityPrediction(
      id: json['id'],
      prediction: json['prediction'],
      author: json['author'],
      link: json['link'],
    );
  }

  @override
  String toString() {
    return 'EntityPrediction{id: $id, prediction: $prediction, author: $author, link: $link}';
  }
}