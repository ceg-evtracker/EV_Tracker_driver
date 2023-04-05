class UserModel {
  String? uid;
  String? id;

  UserModel({this.uid, this.id});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      id: map['id'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'id': id,
    };
  }
}
