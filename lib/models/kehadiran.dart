import 'package:maestro_client_mobile/services/absensi_service.dart';

class Kehadiran {
  String orderDetailId;
  String orderId;
  int meet;
  bool isPresence;
  bool isPaid;
  String day;
  String time;
  String scheduleDate;
  String? realDate;
  String? presenceDay;
  String? paidDate;
  String? realTime;
  String pricePerMeet;
  String periode;
  String student;
  List<dynamic> studentsInfo;
  String trainerFullname;
  String poolName;
  String orderDate;
  String? expireDate;
  String product;

  Kehadiran({
    required this.orderDetailId,
    required this.orderId,
    required this.meet,
    required this.isPresence,
    required this.isPaid,
    required this.day,
    required this.time,
    required this.scheduleDate,
    this.realDate,
    this.presenceDay,
    this.paidDate,
    this.realTime,
    required this.pricePerMeet,
    required this.periode,
    required this.student,
    required this.studentsInfo,
    required this.trainerFullname,
    required this.poolName,
    required this.orderDate,
    this.expireDate,
    required this.product,
  });

  static Future<List<Kehadiran>> fetchAbsensiData(String userId) async {
    try {
      List<dynamic> data = await AbsensiService.fetchAbsensi(userId);
      return data.map((item) => Kehadiran(
        orderDetailId: item['order_detail_id'],
        orderId: item['order'],
        meet: item['meet'],
        isPresence: item['is_presence'],
        isPaid: item['is_paid'],
        day: item['day'],
        time: item['time'],
        scheduleDate: item['schedule_date'],
        realDate: item['real_date'],
        presenceDay: item['presence_day'],
        paidDate: item['paid_date'],
        realTime: item['real_time'],
        pricePerMeet: item['price_per_meet'],
        periode: item['periode'],
        student: item['student'],
        studentsInfo: item['students_info'] ?? [],
        trainerFullname: item['trainer_fullname'],
        poolName: item['pool_name'],
        orderDate: item['order_date'],
        expireDate: item['expire_date'],
        product: item['product'],
      )).toList();
    } catch (e) {
      print("Error fetching absensi: $e");
      return [];
    }
  }

  @override
  String toString() {
    return 'Kehadiran(orderDetailId: $orderDetailId, orderId: $orderId, meet: $meet, isPresence: $isPresence, isPaid: $isPaid, day: $day, time: $time, scheduleDate: $scheduleDate, realDate: $realDate, presenceDay: $presenceDay, paidDate: $paidDate, realTime: $realTime, pricePerMeet: $pricePerMeet, periode: $periode, student: $student, studentsInfo: $studentsInfo, trainerFullname: $trainerFullname, poolName: $poolName, orderDate: $orderDate, expireDate: $expireDate, product: $product)';
  }

  String get siswa => studentsInfo.map((student) => student['fullname']).join(", ");
  String get kolam => poolName;
  String get jam => time;
  String get tanggal => scheduleDate;
}
