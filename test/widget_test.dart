// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:test_novel_i_r_i_s3/main.dart';

void main() {
  print(_convertToCellPosition(0, 0));
}


String? _convertToCellPosition(int row, int col) {
  if (row < 0 || col < 0) return null;

  // 열(Column)을 Excel의 A1 형식으로 변환
  String columnPart = '';
  col += 1; // 1-based index로 변환
  while (col > 0) {
    col--; // 0-based index로 변환
    columnPart = String.fromCharCode((col % 26) + 'A'.codeUnitAt(0)) + columnPart;
    col ~/= 26; // 자리수 이동
  }

  // 행(Row)을 Excel의 A1 형식으로 변환
  String rowPart = (row + 1).toString(); // 1-based index로 변환

  return '$columnPart$rowPart';
}