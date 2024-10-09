class WeightRecord {
  final int? id;
  final String date;  // Date in string format (e.g., '2024-10-09')
  final double? weight;

  WeightRecord({
    this.id,
    required this.date,
    this.weight,
  });

  // Convert a WeightRecord into a Map (to be stored in the database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'weight': weight,
    };
  }

  // Convert a Map into a WeightRecord
  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'],
      date: map['date'],
      weight: map['weight'],
    );
  }
}
