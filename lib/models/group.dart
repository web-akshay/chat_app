class Group {
  String? id;
  String? name;
  String? createdAt;

  Group({
    this.id,
    this.name,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt,
      };

  static Group fromJson(Map<String, dynamic> json) => Group(
        id: json['id'],
        name: json['name'],
        createdAt: json['createdAt'],
      );
}
