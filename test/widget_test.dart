// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:test_novel_i_r_i_s3/app_state.dart';

void main() {
  print(getCurrentMonth('2025-02-01'));
}

int? getCurrentMonth(String currentDate){
  String month = currentDate.split('-')[1];
  return int.tryParse(month);
}