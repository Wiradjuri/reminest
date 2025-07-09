class JournalEntry {
  final int? id;
  final String title;
  final String body;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime reviewDate;
  final bool isReviewed;

  JournalEntry({
    this.id,
    required this.title,
    required this.body,
    this.imagePath,
    required this.createdAt,
    required this.reviewDate,
    this.isReviewed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title, // store encrypted in DB layer
      'body': body,   // store encrypted in DB layer
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'reviewDate': reviewDate.toIso8601String(),
      'isReviewed': isReviewed ? 1 : 0,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as int?,
      title: map['title'] as String,
      body: map['body'] as String,
      imagePath: map['imagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      reviewDate: DateTime.parse(map['reviewDate'] as String),
      isReviewed: map['isReviewed'] == 1,
    );
  }
}
