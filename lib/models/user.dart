class User {
  final int? userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userBirth;
  final String userGender;
  final String userCountry;
  final String? userPassword;
  final bool isForget;
  final String? resetCode;
  final String? codeExpiry;

  User({
    this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userBirth,
    required this.userGender,
    required this.userCountry,
    this.userPassword,
    this.isForget = false,
    this.resetCode,
    this.codeExpiry,
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
      isForget: map['isForget'] == 1 || map['isForget'] == true,
      resetCode: map['resetCode'],
      codeExpiry: map['codeExpiry'],
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
      'isForget': isForget ? 1 : 0,
      'resetCode': resetCode,
      'codeExpiry': codeExpiry,
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
    bool? isForget,
    String? resetCode,
    String? codeExpiry,
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
      isForget: isForget ?? this.isForget,
      resetCode: resetCode ?? this.resetCode,
      codeExpiry: codeExpiry ?? this.codeExpiry,
    );
  }

  @override
  String toString() {
    return 'User{userId: $userId, userName: $userName, userEmail: $userEmail, userPhone: $userPhone, userBirth: $userBirth, userGender: $userGender, userCountry: $userCountry, isForget: $isForget}';
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
        other.userPassword == userPassword &&
        other.isForget == isForget &&
        other.resetCode == resetCode &&
        other.codeExpiry == codeExpiry;
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
        userPassword.hashCode ^
        isForget.hashCode ^
        resetCode.hashCode ^
        codeExpiry.hashCode;
  }
}
