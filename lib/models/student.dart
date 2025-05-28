class Student {
  final String? fullname;
  final String? nickname;
  final String? gender;
  final String? parent;
  final String? phone;
  final String? address;
  final String? dob;
  final String? pob;
  final String? parentId;
  final String? branch;
  final String? username;
  final String? password;

  Student({
    this.fullname,
    this.nickname,
    this.gender,
    this.parent,
    this.phone,
    this.address,
    this.dob,
    this.pob,
    this.parentId,
    this.branch,
    this.username,
    this.password,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      fullname: json['fullname'],
      nickname: json['nickname'],
      gender: json['gender'],
      parent: json['parent'],
      phone: json['phone'],
      address: json['address'],
      dob: json['dob'],
      pob: json['pob'],
      parentId: json['parent_id'],
      branch: json['branch'],
      username: json['username'],
      password: json['password'],
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
      'parent_id': parentId,
      'branch': branch,
      'username': username,
      'password': password,
    };
  }
}
