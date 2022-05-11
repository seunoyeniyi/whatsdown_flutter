class Comment {
  String? username;
  String? comment;
  String? rating;
  String? userImage;

  Comment({this.username, this.comment, this.rating, this.userImage});

  String get getUsername => username!;

  set setUsername(String username) => this.username = username;

  String get getComment => comment!;

  set setComment(String comment) => this.comment = comment;

  String get getRating => rating!;

  set setRating(String rating) => this.rating = rating;

  String get getUserImage => userImage!;

  set setUserImage(String userImage) => this.userImage = userImage;
}
