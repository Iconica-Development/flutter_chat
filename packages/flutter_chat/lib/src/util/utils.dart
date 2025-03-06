// add generic utils that are used in the package

/// Extension to simplify detecting how many days relative dates are
extension RelativeDates on DateTime {
  /// Strips timezone information whilst keeping the exact same date
  DateTime get utcDate => DateTime.utc(year, month, day);

  /// Strips time information from the date
  DateTime get date => DateTime(year, month, day);

  /// Get relative date in offset from the current position.
  ///
  /// `today.getDateOffsetInDays(yesterday)` would result in `-1`
  ///
  /// `yesterday.getDateOffsetInDays(tomorrow)` would result in `2`
  int getDateOffsetInDays(DateTime other) =>
      other.utcDate.difference(utcDate).inDays;
}
