import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';

String? getCurrentDate() {
  final now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
}

String? updateDate(
  String? currentDate,
  int? daysToAdd,
) {
  // null-safe 처리: currentDate와 daysToAdd가 null일 경우 기본값 설정
  if (currentDate == null || daysToAdd == null) {
    return null; // 둘 중 하나라도 null이면 null 반환
  }

  // currentDate를 DateTime으로 변환
  final parsedDate = DateTime.parse(currentDate);

  // 날짜 계산
  final updatedDate = parsedDate.add(Duration(days: daysToAdd));

  // yyyy-MM-dd 형식으로 반환
  return "${updatedDate.year}-${updatedDate.month.toString().padLeft(2, '0')}-${updatedDate.day.toString().padLeft(2, '0')}";
}

DateTime? getCurrenDateType() {
  return DateTime.now();
}
