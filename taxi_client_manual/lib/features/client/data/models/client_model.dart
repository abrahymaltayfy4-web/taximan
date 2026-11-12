/// تمثيل مستند العميل في Firestore (DTO)
class ClientModel {
  final String uid;
  final String? name;
  final String email;
  final String phone;

  /// القيمة الخام لـ accountStatus (قد تكون null في المستندات القديمة)
  final String? accountStatus;

  /// حقل legacy قبل ظهور accountStatus
  final bool isBlocked;

  const ClientModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.accountStatus,
    required this.isBlocked,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json, String id) {
    return ClientModel(
      uid: id,
      name: json['name'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      accountStatus: json['accountStatus'],
      isBlocked: json['isBlocked'] == true,
    );
  }
}
