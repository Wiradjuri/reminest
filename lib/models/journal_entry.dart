class JournalEntry {
    final int? id;
    final String title;
    final String body;
    final Strin? imagePath;
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
            'title': title,
            'body': body,
            'imagePath': imagePath,
            'createdAt': createdAt.toIso8601String(),
            'reviewDate': reviewDate.toIso8601String(),
            'isReviewed': isReviewed ? 1 : 0,
        }
    }

    factory JournalEntry.fromMap(Map<String, dynamic> map) {
        return JournalEntry(
            id: map['id'],
            title: map['title'],
            body: map['body'],
            imagePath: map['imagePath'],
            createdAt: DateTime.parse(map['createdAt']),
            reviewDate: DateTime.parse(map['reviewDate']),
            isReviewed: map['isReviewed'] == 1,
        );
    }
}