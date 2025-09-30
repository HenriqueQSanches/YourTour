class User {
  final int? userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userBirth;
  final String userGender;
  final String userCountry;
  final String userPassword;

  User({
    this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userBirth,
    required this.userGender,
    required this.userCountry,
    required this.userPassword,
  });

  // Converte um Map para User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      userPhone: map['userPhone'],
      userBirth: map['userBirth'],
      userGender: map['userGender'],
      userCountry: map['userCountry'],
      userPassword: map['userPassword'],
    );
  }

  // Converte User para Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userBirth': userBirth,
      'userGender': userGender,
      'userCountry': userCountry,
      'userPassword': userPassword,
    };
  }

  // Cria uma cópia do User com campos modificados
  User copyWith({
    int? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userBirth,
    String? userGender,
    String? userCountry,
    String? userPassword,
  }) {
    return User(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userBirth: userBirth ?? this.userBirth,
      userGender: userGender ?? this.userGender,
      userCountry: userCountry ?? this.userCountry,
      userPassword: userPassword ?? this.userPassword,
    );
  }

  @override
  String toString() {
    return 'User{userId: $userId, userName: $userName, userEmail: $userEmail, userPhone: $userPhone, userBirth: $userBirth, userGender: $userGender, userCountry: $userCountry}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.userId == userId &&
        other.userName == userName &&
        other.userEmail == userEmail &&
        other.userPhone == userPhone &&
        other.userBirth == userBirth &&
        other.userGender == userGender &&
        other.userCountry == userCountry &&
        other.userPassword == userPassword;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        userName.hashCode ^
        userEmail.hashCode ^
        userPhone.hashCode ^
        userBirth.hashCode ^
        userGender.hashCode ^
        userCountry.hashCode ^
        userPassword.hashCode;
  }
}
