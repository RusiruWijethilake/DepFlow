class TwitterFollower {

  String id;
  String username;
  String name;
  String profileImageUrl;

  TwitterFollower({required this.id, required this.username, required this.name, required this.profileImageUrl});

  get userid => id;
  get tweeterusername => username;
  get fullname => name;
  get picurl => profileImageUrl;

}