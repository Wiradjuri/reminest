import 'package:flutter/material.dart';
import 'dart:io';
import '../models/journal_entry.dart';

class ViewEntryScreen extends StatelessWidget {
  final JournalEntry entry;

  const ViewEntryScreen({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('View Entry'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              entry.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 16),

            // Entry metadata
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Created: ${entry.createdAt.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (entry.reviewDate != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        SizedBox(width: 8),
                        Text(
                          entry.isInVault
                              ? 'Vault unlock date: ${entry.reviewDate!.toLocal().toString().split(' ')[0]}'
                              : 'Review date: ${entry.reviewDate!.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (entry.isInVault) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.lock, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Vault Entry',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24),

            // Entry body
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Text(
                entry.body,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),

            // Image attachment if present
            if (entry.imagePath != null) ...[
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.photo, color: theme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Photo Attachment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(entry.imagePath!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.broken_image, color: Colors.grey),
                                SizedBox(width: 8),
                                Text(
                                  'Image not found',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
