// Enhanced User Model with Provider Support
class User {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? nationalID;
  final String dialCountryCode;
  final String phone;
  final String? phoneVerifiedAt;
  final int isCompleted;
  final Map<String, dynamic>? gender;
  final String token;
  final Map<String, dynamic>? avatar;
  final Map<String, dynamic>? idCard;

  // Profile fields
  final int ordersCount;
  final int pendingOrdersCount;
  final int completedOrdersCount;
  final int points;
  final int pointsInSp;
  final double? rate;
  final int balance;
  final List<dynamic>? addresses;

  final int? providerId;
  final String? providerName;
  final String? providerDescription;
  final String? providerStatus; // "Not approved", "Approved", "rejected"
  final String? rejectReason;
  final double? providerRate;
  final int? providerBalance;
  final List<dynamic>? providerGallery;
  final List<dynamic>? providerCategories;
  final bool canHaveChat;
  final Map<String, dynamic>? provider;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.nationalID,
    required this.dialCountryCode,
    required this.phone,
    this.phoneVerifiedAt,
    required this.isCompleted,
    this.gender,
    required this.token,
    this.avatar,
    this.idCard,
    this.ordersCount = 0,
    this.pendingOrdersCount = 0,
    this.completedOrdersCount = 0,
    this.points = 0,
    this.pointsInSp = 0,
    this.rate,
    this.balance = 0,
    this.addresses,
    // Provider fields
    this.providerId,
    this.providerName,
    this.providerDescription,
    this.providerStatus,
    this.rejectReason,
    this.providerRate,
    this.providerBalance,
    this.providerGallery,
    this.providerCategories,
    this.canHaveChat = false,
    this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      final user = User(
        id: json['id'] ?? 0,
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        nationalID: json['nationalID'],
        dialCountryCode: json['dial_country_code'] ?? '',
        phone: json['phone'] ?? '',
        phoneVerifiedAt: json['phone_verified_at'],
        isCompleted: json['is_completed'] ?? 0,
        gender: json['gender'],
        token: json['token'] ?? '',
        avatar: json['avatar'],
        idCard: json['IDcard'],
        ordersCount: json['orders_cnt'] ?? 0,
        pendingOrdersCount: json['pending_orders_cnt'] ?? 0,
        completedOrdersCount: json['completed_orders_cnt'] ?? 0,
        points: json['points'] ?? 0,
        pointsInSp: json['points_in_sp'] ?? 0,
        rate: json['rate']?.toDouble(),
        balance: json['balance'] ?? 0,
        addresses: json['addresses'],
        providerId: json['provider_id'],
        provider: json['provider'],
      );

      print(' User created successfully:');
      print('   User ID: ${user.id}');
      print('   Provider ID: ${user.providerId}');
      print('   Is Provider: ${user.isProvider}');

      return user;
    } catch (e) {
      print('Error creating User from JSON: $e');
      rethrow;
    }
  }

  // Provider-related getters
  bool get isProvider => provider != null || providerId != null;

  bool get isApprovedProvider =>
      isProvider && (providerStatus == "Approved" || provider?['status'] == "Approved");

  bool get isPendingProvider =>
      isProvider && (providerStatus == "Not approved" || provider?['status'] == "Not approved");

  bool get isRejectedProvider =>
      isProvider && (providerStatus == "rejected" || provider?['status'] == "rejected");

  String get providerStatusText {
    if (!isProvider) return "Not a provider";

    final status = providerStatus ?? provider?['status'] ?? "unknown";
    switch (status.toLowerCase()) {
      case "Approved":
        return " Approved Provider";
      case "Not approved":
        return " Pending Approval";
      case "rejected":
        return " Application Rejected";
      default:
        return " Provider Status: $status";
    }
  }

  // Provider-specific getters with fallbacks
  String get actualProviderName => providerName ?? provider?['name'] ?? fullName;

  String get actualProviderDescription => providerDescription ?? provider?['description'] ?? '';

  double get actualProviderRate => providerRate ?? provider?['rate']?.toDouble() ?? 0.0;

  int get actualProviderBalance => providerBalance ?? provider?['balance'] ?? 0;

  List<dynamic> get actualProviderGallery => providerGallery ?? provider?['gallery'] ?? [];

  List<dynamic> get actualProviderCategories => providerCategories ?? provider?['categories'] ?? [];

  // Existing getters (unchanged)
  bool get isVerified => phoneVerifiedAt != null && phoneVerifiedAt!.isNotEmpty;
  bool get isProfileCompleted => isCompleted == 1;
  bool get hasValidToken => token.isNotEmpty;

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return 'User';
  }

  String get fullPhoneNumber {
    return dialCountryCode.isNotEmpty && phone.isNotEmpty ? '+$dialCountryCode $phone' : phone;
  }

  String get profileImageUrl {
    if (avatar != null && avatar!['original_url'] != null) {
      return avatar!['original_url'];
    }
    return '';
  }

  // Rest of existing methods...
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'nationalID': nationalID,
      'dial_country_code': dialCountryCode,
      'phone': phone,
      'phone_verified_at': phoneVerifiedAt,
      'is_completed': isCompleted,
      'gender': gender,
      'token': token,
      'avatar': avatar,
      'IDcard': idCard,
      'orders_cnt': ordersCount,
      'points': points,
      'balance': balance,
      'provider_id': providerId,
      'provider': provider,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, isProvider: $isProvider, providerStatus: $providerStatusText)';
  }
}
