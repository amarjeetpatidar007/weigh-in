class WeightRecord {
  final int? id;
  final String date;  // Date in string format (e.g., '2024-10-09')
  final double? weight;
  final bool missed;  // New field to track if the weight was missed

  WeightRecord({
    this.id,
    required this.date,
    this.weight,
    this.missed = false,  // Default to 'false', assuming weight was recorded
  });

  // Convert a WeightRecord into a Map (to be stored in the database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'weight': weight,
      'missed': missed ? 1 : 0,  // Store as 1 for true, 0 for false
    };
  }

  // Convert a Map into a WeightRecord
  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'],
      date: map['date'],
      weight: map['weight'],
      missed: map['missed'] == 1,  // Convert 1 back to true, 0 to false
    );
  }
}
