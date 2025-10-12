class Package {
  final String id;
  final String name;
  final String description;
  final int totalSessions;
  final int remainingSessions;
  final DateTime validUntil;
  final String status;
  final double price;
  final String studentId;
  final String studentName;

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.totalSessions,
    required this.remainingSessions,
    required this.validUntil,
    required this.status,
    required this.price,
    required this.studentId,
    required this.studentName,
  });
}

class Transaction {
  final String id;
  final String invoiceNumber;
  final String studentName;
  final String packageName;
  final double amount;
  final String status;
  final DateTime date;
  final String paymentMethod;
  final String description;

  Transaction({
    required this.id,
    required this.invoiceNumber,
    required this.studentName,
    required this.packageName,
    required this.amount,
    required this.status,
    required this.date,
    required this.paymentMethod,
    required this.description,
  });
}

class PackageType {
  final String name;
  final String description;
  final int sessions;
  final double price;
  final String color;

  PackageType({
    required this.name,
    required this.description,
    required this.sessions,
    required this.price,
    required this.color,
  });
}
