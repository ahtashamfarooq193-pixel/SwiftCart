class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? profileImageUrl;
  final DateTime dateOfBirth;
  final String gender;
  final Address? defaultAddress;
  final List<Address> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final UserPreferences preferences;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.dateOfBirth,
    required this.gender,
    this.defaultAddress,
    required this.addresses,
    required this.createdAt,
    required this.updatedAt,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.preferences,
  });

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    Address? defaultAddress,
    List<Address>? addresses,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Address {
  final String id;
  final String type; // 'home', 'work', 'other'
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Address({
    required this.id,
    required this.type,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedAddress {
    return '$addressLine1${addressLine2.isNotEmpty ? ', $addressLine2' : ''}\n$city, $state $postalCode\n$country';
  }

  Address copyWith({
    String? id,
    String? type,
    String? fullName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      type: type ?? this.type,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class UserPreferences {
  final bool notificationsEnabled;
  final bool emailUpdatesEnabled;
  final bool smsUpdatesEnabled;
  final String language;
  final String currency;
  final bool darkModeEnabled;

  const UserPreferences({
    required this.notificationsEnabled,
    required this.emailUpdatesEnabled,
    required this.smsUpdatesEnabled,
    required this.language,
    required this.currency,
    required this.darkModeEnabled,
  });

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? emailUpdatesEnabled,
    bool? smsUpdatesEnabled,
    String? language,
    String? currency,
    bool? darkModeEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailUpdatesEnabled: emailUpdatesEnabled ?? this.emailUpdatesEnabled,
      smsUpdatesEnabled: smsUpdatesEnabled ?? this.smsUpdatesEnabled,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}


