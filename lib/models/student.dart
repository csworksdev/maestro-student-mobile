class Student {
  final String studentId;
  final String fullname;
  final String nickname;
  final String gender;
  final String parent;
  final String phone;
  final String address;
  final String dob;
  final String pob;
  final String branchName;

  Student({
    required this.studentId,
    required this.fullname,
    required this.nickname,
    required this.gender,
    required this.parent,
    required this.phone,
    required this.address,
    required this.dob,
    required this.pob,
    required this.branchName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'],
      fullname: json['fullname'],
      nickname: json['nickname'],
      gender: json['gender'],
      parent: json['parent'],
      phone: json['phone'],
      address: json['address'],
      dob: json['dob'],
      pob: json['pob'],
      branchName: json['branch_name'],
    );
  }
}
