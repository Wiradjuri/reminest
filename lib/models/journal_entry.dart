import 'dart:io';

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

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    int? parseId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    bool parseBool(dynamic value) {
      if (value is int) return value == 1;
      if (value is bool) return value;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    return JournalEntry(
      id: parseId(map['id']),
      title: map['title'] as String,
      body: map['body'] as String,
      imagePath: map['imagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      reviewDate: DateTime.parse(map['reviewDate'] as String),
      isReviewed: parseBool(map['isReviewed']),
      isInVault: parseBool(map['isInVault']),
    );
  }
}
