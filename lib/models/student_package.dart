class StudentAvatar {
  final String thumbnail;
  final String original;

  StudentAvatar({
    required this.thumbnail,
    required this.original,
  });

  factory StudentAvatar.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StudentAvatar(thumbnail: '', original: '');
    }
    return StudentAvatar(
      thumbnail: json['thumbnail']?.toString() ?? '',
      original: json['original']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
      'original': original,
    };
  }
}

class StudentPackage {
  final int id;
  final String studentId;
  final String orderId;
  final String studentFullname;
  final StudentAvatar studentAvatar;
  final String packageName;
  final DateTime? expireDate; // null for TODO packages
  final int meetings; // same as meetings_amount based on API sample
  final int meetingsAmount;
  final int meetingsRemainder;
  final int meetingsPercentage;
  final String status; // e.g., "Aktif"

  StudentPackage({
    required this.id,
    required this.studentId,
    required this.orderId,
    required this.studentFullname,
    required this.studentAvatar,
    required this.packageName,
    required this.expireDate,
    required this.meetings,
    required this.meetingsAmount,
    required this.meetingsRemainder,
    required this.meetingsPercentage,
    required this.status,
  });

  int get usedMeetings => (meetingsAmount - meetingsRemainder).clamp(0, meetingsAmount);
  double get progress => meetingsAmount > 0 ? usedMeetings / meetingsAmount : 0.0;

  factory StudentPackage.fromJson(Map<String, dynamic> json) {
    DateTime? parsedExpireDate;
    final expire = json['expire_date'];
    if (expire != null && expire.toString().isNotEmpty) {
      try {
        parsedExpireDate = DateTime.parse(expire.toString());
      } catch (_) {
        parsedExpireDate = null;
      }
    }

    return StudentPackage(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      studentId: json['student_id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      studentFullname: json['student_fullname']?.toString() ?? '',
      studentAvatar: StudentAvatar.fromJson(json['student_avatar'] as Map<String, dynamic>?),
      packageName: json['package']?.toString() ?? '',
      expireDate: parsedExpireDate,
      meetings: int.tryParse(json['meetings']?.toString() ?? '') ?? 0,
      meetingsAmount: int.tryParse(json['meetings_amount']?.toString() ?? '') ?? 0,
      meetingsRemainder: int.tryParse(json['meetings_remainder']?.toString() ?? '') ?? 0,
      meetingsPercentage: int.tryParse(json['meetings_percentage']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'order_id': orderId,
      'student_fullname': studentFullname,
      'student_avatar': studentAvatar.toJson(),
      'package': packageName,
      'expire_date': expireDate?.toIso8601String(),
      'meetings': meetings,
      'meetings_amount': meetingsAmount,
      'meetings_remainder': meetingsRemainder,
      'meetings_percentage': meetingsPercentage,
      'status': status,
    };
  }
}
