class User {
  String? id;
  String? name;
  String? email;
  String? password;
  String? imageUrl;
  String? authId;

  User({
    this.id,
    this.name,
    this.email,
    this.imageUrl,
    this.password,
    this.authId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'imageUrl': imageUrl,
        'authId': authId,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        imageUrl: json['imageUrl'],
        authId: json['authId'],
      );
}
