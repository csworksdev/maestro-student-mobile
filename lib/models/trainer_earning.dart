class Earning {
  final String id;
  final String pertemuan;
  final String tanggal;
  final double amount;

  Earning({required this.id, required this.pertemuan, required this.tanggal, required this.amount});

  factory Earning.fromJson(Map<String, dynamic> json) {
    return Earning(
      id: json['id'],
      pertemuan: json['pertemuan'],
      tanggal: json['tanggal'],
      amount: double.parse(json['amount'].toString()),
    );
  }
}