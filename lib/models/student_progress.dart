class Student {
  final String id;
  final String name;
  final String avatar;
  final String currentLevel;
  final List<Badge> badges;
  final List<ProgressSession> sessions;

  Student({
    required this.id,
    required this.name,
    required this.avatar,
    required this.currentLevel,
    required this.badges,
    required this.sessions,
  });
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime earnedDate;
  final String color;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.earnedDate,
    required this.color,
  });
}

class ProgressSession {
  final String id;
  final DateTime date;
  final String coachName;
  final String notes;
  final Map<String, double> scores; // skill -> score
  final List<String> improvements;
  final List<String> areasToWorkOn;

  ProgressSession({
    required this.id,
    required this.date,
    required this.coachName,
    required this.notes,
    required this.scores,
    required this.improvements,
    required this.areasToWorkOn,
  });
}

class ProgressLevel {
  final String name;
  final String description;
  final int order;
  final String color;

  ProgressLevel({
    required this.name,
    required this.description,
    required this.order,
    required this.color,
  });
}
