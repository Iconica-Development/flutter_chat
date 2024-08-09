// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter_chat/src/config/chat_options.dart";
import "package:intl/intl.dart";

/// The date formatter
class DateFormatter {
  /// Constructs a [DateFormatter]
  DateFormatter({
    required this.options,
  });

  /// The chat options
  final ChatOptions options;
  final _now = DateTime.now();

  bool _isToday(DateTime date) =>
      DateTime(
        date.year,
        date.month,
        date.day,
      )
          .difference(
            DateTime(
              _now.year,
              _now.month,
              _now.day,
            ),
          )
          .inDays ==
      0;

  bool _isYesterday(DateTime date) =>
      DateTime(
        date.year,
        date.month,
        date.day,
      )
          .difference(
            DateTime(
              _now.year,
              _now.month,
              _now.day,
            ),
          )
          .inDays ==
      -1;

  bool _isThisYear(DateTime date) => date.year == _now.year;

  /// Formats the date
  String format({
    required DateTime date,
    bool showFullDate = false,
  }) {
    if (options.dateformat != null) {
      return options.dateformat!(showFullDate, date);
    }
    if (_isToday(date)) {
      return DateFormat(
        "HH:mm",
      ).format(date);
    } else if (_isYesterday(date)) {
      return "yesterday";
    } else if (_isThisYear(date)) {
      return DateFormat("dd-MM${showFullDate ? " HH:mm" : ""}").format(date);
    } else {
      return DateFormat("dd-MM-yyyy${showFullDate ? " HH:mm" : ""}")
          .format(date);
    }
  }
}
