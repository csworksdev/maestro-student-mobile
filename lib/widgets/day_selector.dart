import 'package:flutter/material.dart';

Future<DateTime?> pickDate({
  required BuildContext context,
  required DateTime? initialDate,
  required DateTime? minDate,
  required DateTime? maxDate,
}) async {
  return await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: minDate ?? DateTime.now(),
    lastDate: maxDate ?? DateTime.now().add(const Duration(days: 30)),
  );
}

Future<String?> pickTime({
  required BuildContext context,
}) async {
  List<String> times = List.generate(14, (i) => '${(i + 6).toString().padLeft(2, '0')}:00');

  return await showModalBottomSheet<String>(
    context: context,
    builder: (_) => Container(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: times.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(times[i]),
                  onTap: () {
                    Navigator.pop(context, times[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}