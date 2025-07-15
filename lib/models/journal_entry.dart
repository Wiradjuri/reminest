class JournalEntry {
  final int? id;
  final String title;
  final String body;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime reviewDate;
  final bool isReviewed;
  final bool isInVault;

  JournalEntry({
    this.id,
    required this.title,
    required this.body,
    this.imagePath,
    required this.createdAt,
    required this.reviewDate,
    this.isReviewed = false,
    this.isInVault = false,
  });

  /// Convert JournalEntry to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'reviewDate': reviewDate.toIso8601String(),
      'isReviewed': isReviewed ? 1 : 0,
      'isInVault': isInVault ? 1 : 0,
    };
  }

  /// Create JournalEntry from Map
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      imagePath: map['imagePath'],
      createdAt: DateTime.parse(map['createdAt']),
      reviewDate: DateTime.parse(map['reviewDate']),
      isReviewed: map['isReviewed'] == 1,
      isInVault: map['isInVault'] == 1,
    );
  }

  /// Create a copy of this JournalEntry with some fields replaced
  JournalEntry copyWith({
    int? id,
    String? title,
    String? body,
    String? imagePath,
    DateTime? createdAt,
    DateTime? reviewDate,
    bool? isReviewed,
    bool? isInVault,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      reviewDate: reviewDate ?? this.reviewDate,
      isReviewed: isReviewed ?? this.isReviewed,
      isInVault: isInVault ?? this.isInVault,
    );
  }

  @override
  String toString() {
    return 'JournalEntry{id: $id, title: $title, createdAt: $createdAt, isInVault: $isInVault}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is JournalEntry &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.imagePath == imagePath &&
        other.createdAt == createdAt &&
        other.reviewDate == reviewDate &&
        other.isReviewed == isReviewed &&
        other.isInVault == isInVault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        body.hashCode ^
        imagePath.hashCode ^
        createdAt.hashCode ^
        reviewDate.hashCode ^
        isReviewed.hashCode ^
        isInVault.hashCode;
  }
}
