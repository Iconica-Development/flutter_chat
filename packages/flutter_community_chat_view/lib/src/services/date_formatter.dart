// SPDX-FileCopyrightText: 2022 Iconica
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:intl/intl.dart';

class DateFormatter {
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

  String format({
    required DateTime date,
    bool showFullDate = false,
  }) =>
      DateFormat(
        _isToday(date)
            ? 'HH:mm'
            : 'dd-MM-yyyy${showFullDate ? ' - HH:mm' : ''}',
      ).format(date);
}
