import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

class XCast<T> {
  T? cast(dynamic v) => v is T ? v : null;
}

extension GroupByExt<T, S> on Iterable<S> {
  Map<T, List<S>> groupBy(T Function(S) makeKey) {
    Map<T, List<S>> results = {};

    forEach((e) => (results[makeKey(e)] ??= []).add(e));

    return results;
  }
}

extension ListExt on List {
  bool get hasOnlyOne => length == 1;

  bool get hasMoreThanOne => length > 1;

  int get lastIndex => isEmpty ? 0 : (length - 1);

  int? validIndex(int? index) {
    if (index == null || index < 0 || index > lastIndex) return null;

    return index;
  }

  bool isValidIndex(int? index) {
    if (index == null || index < 0 || index > lastIndex) return false;

    return true;
  }

  bool isNotValidIndex(int? index) => !isValidIndex(index);
}

extension BooleanExt on bool {
  int toInteger() => this ? 1 : 0;
}

extension IntegerExt on int {
  static int? fromJson(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;

    return int.tryParse(v) ?? double.tryParse(v)?.toInteger();
  }

  bool toBoolean() => this == 1 ? true : false;
}

extension DoubleExt on double {
  static double? fromJson(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;

    return v is int ? v.toDouble() : double.tryParse(v);
  }

  int? toInteger() {
    try {
      return truncate();
    } catch (error) {
      return null;
    }
  }

  double toPrecision({decimalDigits = 1}) {
    final f = pow(10, decimalDigits).toInt();

    return (this * f).round() / f;
  }
}

extension CurrencyExt on num {
  String? currency({String symbol = 'đ', int decimalDigits = 0}) {
    try {
      final v = this;

      return NumberFormat.currency(
        locale: currencyLocale(),
        symbol: symbol,
        decimalDigits: decimalDigits,
      ).format(v.toInt()).replaceAll(RegExp(r"\s+"), '');
    } catch (error) {
      return null;
    }
  }

  String currencyLocale() {
    final locale = Platform.localeName;
    final formats =
        XCast<Map<String, NumberSymbols?>>().cast(numberFormatSymbols);
    final numberSymbols = formats?[locale];

    return numberSymbols != null ? locale : "vi";
  }
}

extension StringExt on String {
  String removeLast() => isEmpty ? this : substring(0, length - 1);

  String? number({String format = '#0.#'}) {
    try {
      return NumberFormat(format).format(this);
    } catch (error) {
      return null;
    }
  }

  bool isValidEmail() {
    const pattern =
        r"^[a-zA-Z0-9](?:[a-zA-Z0-9]|(?:\.|\-|\_)(?!(?:\.|\-|\_))){0,62}[a-zA-Z0-9]{1}@{1}[a-zA-Z0-9]{1,32}\.(?!\.)[a-zA-Z0-9]{0,16}\.?[a-zA-Z0-9]{1,16}$";
    final regExp = RegExp(pattern, multiLine: false, caseSensitive: true);

    if (regExp.hasMatch(this)) return true;

    return false;
  }

  String? secure({String securedSymbol = '*', int securedLength = 4}) {
    final v = this;

    if (v.isEmpty) return null;
    if (securedLength <= 0) return v;

    final secured = ''.padLeft(securedLength, securedSymbol);

    return v.length > securedLength
        ? v.replaceRange(0, securedLength - 1, secured)
        : secured;
  }

  String? secureEmail({
    String securedSymbol = '*',
    int securedLength = 4,
    int visibleLength = 5,
    bool preferVisible = true,
  }) {
    final v = this;

    if (v.isEmpty) return null;
    if (securedLength <= 0) return v;
    if (!v.isValidEmail()) return null;

    final i = v.indexOf('@');

    if (i < 0) return null;

    final secured = ''.padLeft(securedLength, securedSymbol);

    // ngochichung@gmail.com -> ****chung@gmail.com (i = 11)
    // ngochichun@gmail.com -> ****ichun@gmail.com (i = 10)
    // ngochichu@gmail.com -> ****hichu@gmail.com (i = 9)

    if (i >= (securedLength + visibleLength)) {
      return secured + v.substring(i - visibleLength);
    }

    if (preferVisible) {
      // ngochich@gmail.com -> ***chich@gmail.com (i = 8)
      // ngochic@gmail.com -> **ochic@gmail.com (i = 7)
      // ngochi@gmail.com -> *gochi@gmail.com (i = 6)
      // ngoch@gmail.com -> ngoch@gmail.com (i = 5)

      if (i >= visibleLength) {
        return ''.padLeft(i - visibleLength, securedSymbol) +
            v.substring(i - visibleLength);
      }

      // ngoc@gmail.com -> ngoc@gmail.com (i = 4)

      return v;
    } else {
      // Prefer Secured.
      // ngochich@gmail.com -> ****hich@gmail.com (i = 8)
      // ngochic@gmail.com -> ****hic@gmail.com (i = 7)
      // ngochi@gmail.com -> ****hi@gmail.com (i = 6)
      // ngoch@gmail.com -> ****h@gmail.com (i = 5)
      // ngoc@gmail.com -> ****@gmail.com (i = 4)

      if (i >= securedLength) {
        return secured + v.substring(securedLength);
      }

      // ngo@gmail.com -> ****@gmail.com (i = 3)

      return secured + v.substring(i);
    }
  }
}

extension DateTimeExt on DateTime {
  static DateTime? fromJson(dynamic v,
      {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    try {
      return v is String ? DateFormat(format).parse(v) : null;
    } catch (error) {
      return null;
    }
  }

  String? toJson() => _text('yyyy-MM-dd HH:mm:ss');

  String? _text(String format) {
    try {
      return DateFormat(format).format(this);
    } catch (error) {
      return null;
    }
  }

  String? text({String format = 'dd/MM/yyyy HH:mm:ss'}) => _text(format);

  String? dateText({String format = 'dd/MM/yyyy'}) => _text(format);

  String? timeText({String format = 'HH:mm:ss'}) => _text(format);

  static DateTime get todayStart {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  static DateTime get todayEnd {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
  }

  static const oneDay = Duration(days: 1);

  static DateTime get yesterdayStart => todayStart.subtract(oneDay);

  static DateTime get yesterdayEnd => todayEnd.subtract(oneDay);

  static DateTime get tomorrowStart => todayStart.add(oneDay);

  static DateTime get tomorrowEnd => todayEnd.add(oneDay);

  bool get isToday => !(isBefore(todayStart) || isAfter(todayEnd));

  bool get isYesterday => !(isBefore(yesterdayStart) || isAfter(yesterdayEnd));

  bool get isTomorrow => !(isBefore(tomorrowStart) || isAfter(tomorrowEnd));

  bool get isPast => isBefore(todayStart);

  bool get isFuture => isAfter(todayEnd);

  bool isBetween(DateTimeRange? range) {
    if (range == null) return false;

    return !(isBefore(range.start) || isAfter(range.end));
  }

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  int daysDifference(DateTime other) {
    final v1 = DateTime(year, month, day);
    final v2 = DateTime(other.year, other.month, other.day);

    return (v2.difference(v1).inHours / 24).round();
  }
}
