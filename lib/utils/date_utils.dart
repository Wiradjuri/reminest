import 'constants.dart';

class DateUtils {
  // Format date for display
  static String formatDateForDisplay(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
  }
  
  // Format date and time for display
  static String formatDateTimeForDisplay(DateTime dateTime) {
    return dateTime.toLocal().toString().split('.')[0];
  }
  
  // Check if date is in the future
  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }
  
  // Check if entry is unlocked (for vault)
  static bool isEntryUnlocked(DateTime reviewDate) {
    final now = DateTime.now();
    return reviewDate.isBefore(now) || reviewDate.isAtSameMomentAs(now);
  }
  
  // Get minimum selectable date (tomorrow)
  static DateTime getMinSelectableDate() {
    return DateTime.now().add(const Duration(days: AppConstants.minFutureDays));
  }
  
  // Get maximum selectable date
  static DateTime getMaxSelectableDate() {
    return DateTime.now().add(const Duration(days: AppConstants.maxFutureDays));
  }
  
  // Calculate days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays;
  }
  
  // Get relative date description
  static String getRelativeDateDescription(DateTime date) {
    final days = daysUntil(date);
    
    if (days < 0) return 'Past date';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 7) return 'In $days days';
    if (days < 30) return 'In ${(days / 7).round()} weeks';
    if (days < 365) return 'In ${(days / 30).round()} months';
    return 'In ${(days / 365).round()} years';
  }
}