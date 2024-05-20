class Comment {
  final String name;
  final String comment;

  Comment(this.name, this.comment);

  factory Comment.fromFirestore(Map<String, dynamic> data) {
    return Comment(data["name"], data["comment"]);
  }

  Map<String, dynamic> toFirestore() {
    return {"name": name, "comment": comment};
  }
}
