class User {
  String? firstName;
  String? lastName;
  String? email;
  String? countryISOCode;
  String? countryCode;
  String? phoneNumber;
  bool? status = false;
  bool? isAdmin;
  String? uid;
  bool? isActive;
  bool? isDeleted;
  String? photoUrl;

  User.fromJson(data) {
    firstName = data['firstName'] ?? '';
    lastName = data['lastName'] ?? '';
    email = data['email'] ?? '';
    countryISOCode = data['countryISOCode'] ?? '';
    countryCode = data['countryCode'] ?? '';
    phoneNumber = data['phoneNumber'] ?? '';
    status = data['status'] ?? false;
    uid = data['id'] ?? '';
    isAdmin = data['isAdmin'] ?? false;
    isActive = data['isActive'] ?? false;
    isDeleted = data['isDeleted'] ?? false;
    photoUrl = data['photoUrl'] ?? '';
  }

  User.fromSnapshot(data) {
    firstName = data['firstName'] ?? '';
    lastName = data['lastName'] ?? '';
    email = data['email'] ?? '';
    countryISOCode = data['countryISOCode'] ?? '';
    countryCode = data['countryCode'] ?? '';
    phoneNumber = data['phoneNumber'] ?? '';
    status = data['status'] ?? false;
    uid = data['uid'] ?? '';
    isAdmin = data['isAdmin'] ?? false;
    isActive = data['isActive'] ?? false;
    isDeleted = data['isDeleted'] ?? false;
    photoUrl = data['photoUrl'] ?? '';
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'countryISOCode': countryISOCode,
        'countryCode': countryCode,
        'phoneNumber': phoneNumber,
        'status': status,
        'uid': uid,
        'isAdmin': isAdmin,
        'isActive': isActive,
        'isDeleted': isDeleted,
        'photoUrl': photoUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
      };
}
