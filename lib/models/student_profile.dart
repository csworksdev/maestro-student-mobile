class StudentProfile {
  final String studentId;
  final String? branchName;
  final bool isDeleted;
  final String? deletedAt;
  final String fullname;
  final String nickname;
  final String gender;
  final String parent;
  final String phone;
  final String address;
  final String dob;
  final String pob;
  final String createdAt;
  final String? pendidikan;
  final String? institusi;
  final String? oldId;
  final String parentId;
  final bool isFollowup;
  final String? branch;
  final String? level;

  StudentProfile({
    required this.studentId,
    this.branchName,
    required this.isDeleted,
    this.deletedAt,
    required this.fullname,
    required this.nickname,
    required this.gender,
    required this.parent,
    required this.phone,
    required this.address,
    required this.dob,
    required this.pob,
    required this.createdAt,
    this.pendidikan,
    this.institusi,
    this.oldId,
    required this.parentId,
    required this.isFollowup,
    this.branch,
    this.level,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      studentId: json['student_id'] ?? '',
      branchName: json['branch_name'],
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'],
      fullname: json['fullname'] ?? '',
      nickname: json['nickname'] ?? '',
      gender: json['gender'] ?? '',
      parent: json['parent'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      dob: json['dob'] ?? '',
      pob: json['pob'] ?? '',
      createdAt: json['created_at'] ?? '',
      pendidikan: json['pendidikan'],
      institusi: json['institusi'],
      oldId: json['old_id'],
      parentId: json['parent_id'] ?? '',
      isFollowup: json['is_followup'] ?? false,
      branch: json['branch'],
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'nickname': nickname,
      'gender': gender,
      'parent': parent,
      'phone': phone,
      'address': address,
      'dob': dob,
      'pob': pob,
      'pendidikan': pendidikan,
      'institusi': institusi,
      'level': level,
    };
  }
}