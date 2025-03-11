

import 'package:logger/logger.dart';
import 'package:test_novel_i_r_i_s3/utils/app_logger.dart';
import 'package:test_novel_i_r_i_s3/utils/const.dart';
import '../data/nobel_data.dart';
import 'dart:io';
import 'package:excel/excel.dart';

import '../flutter_flow/flutter_flow_util.dart';

/// UI 평균값 칸에 값을 표시
/// param 1 :    소재 이름
/// param 2 :    검사 항목 번호
/// param 3 :    초, 중, 종 인덱스
/// return :     초, 중, 종 중 하나의 측정값
/// auther :     John
/// date :       2024-01-06
String getValue(String name, String checkNum, int index){
  String currentDate = FFAppState().CurrentDate;
  if (Measurements.data[name]!.containsKey(currentDate)){
    return Measurements.data[name]![currentDate]!.getValue(checkNum, index);
  }
  return '';
}

/// UI 평균값 칸에 값을 표시
/// param 1 :    소재 이름
/// param 2 :    검사 항목 번호
/// return :     초, 중, 종 측정 평균값
/// auther :     John
/// date :       2024-01-06
String getAverage(String name, String checkNum){
  String currentDate = FFAppState().CurrentDate;
  if (Measurements.data[name]!.containsKey(currentDate)){
    return Measurements.data[name]![currentDate]!.averageByCheckNum(checkNum).toString();
  }
  return '';
}


/// 기존 데이터에 중, 종 측정값을 저장하기 위해 
/// 소재 데이터 클래스 인스턴스를 가져오기
/// param 1 :    var json 파이썬 서버로부터 받은 json 데이터
/// return :     Measurements 해당 클래스 인스턴스
/// auther :     John
/// date :       2024-12-26
Measurements? getDataForWriteValue(var jsonData){
  Map data = Measurements.data;
  Logger logger = AppLogger.instance;

  String date = jsonData['date'];
  String name = jsonData['name'];
  
  if (hasDateInData(date)){
    if (hasDataByDateAndName(date, name)){
      return data[date]![name];
    }
    logger.e('해당 날짜에 {$name} 데이터가 존재하지 않습니다.');
  }
  logger.e('해당 날짜의 데이터가 존재하지 않습니다.');
  return null;
}


/// !!class method!!
/// 기존 데이터의 특정 날짜에 특정 소재 데이터가 있는지 확인
/// param 1 :    string 날짜 (ex "2024-12-26")
/// param 2 :    string 소재 이름 (ex "MS-010")
/// return :     true(해당 데이터 존재)
///              false(데이터 없음) 
/// auther :     John
/// date :       2024-12-26
bool hasDataByDateAndName(String date, String name){
  Map data = Measurements.data;
  return data[date]!.containsKey(name);
}

/// !!class method!!
/// name품명의 특정 날짜 데이터가 있는지 확인
/// param 1 :    string 날짜 (ex "2024-12-26")
/// return :     true(해당 날짜에 데이터 존재)
///              false(데이터 없음) 
/// auther :     John
/// date :       2024-12-27
bool hasDateInData(String date){
  Map data = Measurements.data;
  for (String name in data.keys){
    if (data[name]!.containsKey(date)){
      return true;
    }
  }
  return false;
}


/// 자주검사 체크시트 엑셀 파일에 값을 입력하기 위해
/// 특정 품목의 자주검사 한 주의 검사 데이터를 Json 형식의 데이터로 변환
/// param 1 :    String 시작 날짜(보통 월요일이지만 공휴일일 경우도 있기 때문)
/// return :     json (시작 날짜부터 처음 나오는 토요일 까지의 데이터)
///              false (실패 시)
/// auther :     John
/// date :       2024-12-27
dynamic toJsonFromStartDateToSaturday(String startDateString){
  DateTime startDate = DateTime.parse(startDateString);
  DateTime firstSaturday = findNextSaturday(startDate);
  Logger logger = AppLogger.instance;
  Map data = Measurements.data;
  
  Map jsonDataMap = Map.from(Constants.JSON_DATA_MAP);
  bool isExist = false;

  for (String name in data.keys){
    for (int day=startDate.day; day<=firstSaturday.day; day++){
      String date = "${startDate.year}-${startDate.month}-${day}";
      
      if (data[name]!.containsKey(date)){
        var jsonData = data[name]![date]!.toJsonForExcel();
          
        jsonDataMap[name][date] = jsonData;
        isExist = true;
      }
    }
  }
  
  if (!isExist){
    return false;
  }

  logger.i(jsonDataMap);

  return jsonDataMap;
}

dynamic toJsonFromCurrentMonth(String name){
  String currentDate = FFAppState().CurrentDate;
  String startDate = '${currentDate.substring(0, currentDate.length - 2)}01';
  int currentMonth = FFAppState().getCurrentMonth();

  Map data = Measurements.data;

  List dateList = [];
  dateList.add(startDate);
  String? date;

  while(true){
    date = findNextDate(startDate);
    if (date == null || FFAppState().getCurrentMonth(date: date) != currentMonth){
      break;
    }

    if (date == startDate){
      // 1. 입력된 날짜 문자열을 DateTime으로 변환
      DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);

      // 2. 다음 날짜 계산
      DateTime nextDate = dateTime.add(const Duration(days: 1));

      date = DateFormat('yyyy-MM-dd').format(nextDate);
      startDate = date;
      continue;
    }

    dateList.add(date);
    startDate = date;
  }
  dynamic jsonMap = {};

  for(String name in Constants.names){
    for(String date in dateList){
      jsonMap[date] = data[name][date];
    }
  }

  return jsonMap;
}

/// 자주검사 체크시트 엑셀 파일에 값을 입력하기 위해
/// 특정 품목의 자주검사 1주일 검사 데이터를 Json 형식의 데이터로 변환
/// param 1 :    String 시작 날짜(보통 월요일이지만 공휴일일 경우도 있기 때문)
/// return :     Map(Constants.JSON_DATA_MAP) (시작 날짜부터 처음 나오는 토요일 까지의 데이터)
/// auther :     John
/// date :       2024-01-09
dynamic toJsonFromStartDateToWeek(String startDate){

  Map data = Measurements.data;

  List dateList = [];
  String? date;
  while(dateList.length < 6){
    date = findNextDate(startDate);

    if (date!=null){
      dateList.add(date);

      if (date == startDate){
        // 1. 입력된 날짜 문자열을 DateTime으로 변환
        DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);

        // 2. 다음 날짜 계산
        DateTime nextDate = dateTime.add(const Duration(days: 1));

        date = DateFormat('yyyy-MM-dd').format(nextDate);
      }
      
      startDate = date;
    }
    else{
      break;
    }
  }
  
  Map jsonMap =   {
    "MS-010": <String, dynamic>{},
    "MS-011": <String, dynamic>{},
    "MS-012": <String, dynamic>{},
    "MS-013": <String, dynamic>{},
    "MS-014": <String, dynamic>{},
    "MS-015": <String, dynamic>{}
  };

  for(String name in Constants.names){
    for(String date in dateList){
      jsonMap[name][date] = data[name][date];
    }
  }

  return jsonMap;
}


/// 특정 날짜에서부터 처음 나오는 토요일 찾기
/// param 1 :    String 시작 날짜
/// return :     Datetime 시작 날짜부터 처음 나오는 토요일
/// auther :     John
/// date :       2024-12-27
DateTime findNextSaturday(DateTime date) {
// 현재 날짜의 요일
  int weekday = date.weekday; // 1: 월요일, 7: 일요일

  // 요일 차이 계산 (토요일은 6)
  int daysToAdd = (6 - weekday) % 7; // 남은 요일 수 계산
  if (daysToAdd == 0) {
    daysToAdd = 7; // 이미 토요일이면 다음 주 토요일
  }

  // 첫 번째 토요일
  return date.add(Duration(days: daysToAdd));
}


String? findNextDate(String targetDate) {
  List sortedDates = Measurements.dateList;

  // 정렬된 리스트가 입력되었다고 가정
  if (sortedDates.isEmpty) return null;

  // 문자열을 DateTime으로 변환
  List<DateTime> dateTimes = sortedDates.map((date) => DateTime.parse(date)).toList();
  DateTime target = DateTime.parse(targetDate);

  // 이진 탐색으로 적절한 위치를 찾음
  int index = lowerBound(dateTimes, target);

  // 다음 순서의 날짜 반환
  if (index < dateTimes.length) {
    return sortedDates[index];
  }

  // targetDate보다 큰 날짜가 없으면 null 반환
  return null;
}

// lowerBound 구현
int lowerBound(List<DateTime> list, DateTime value) {
  int low = 0, high = list.length;
  while (low < high) {
    int mid = (low + high) >> 1;
    if (list[mid].isAfter(value) || list[mid].isAtSameMomentAs(value)) {
      high = mid;
    } else {
      low = mid + 1;
    }
  }
  return low;
}

Future<void> saveExcelFile({
  required Map mapData, // 입력할 값
}) async {
  
  String filePath = Constants.excelPath;
  String firstDate = '';

  try {
    // 1. 기존 Excel 파일을 읽기
    var file = File(filePath);
    if (!await file.exists()) {
      throw Exception("파일이 존재하지 않습니다: $filePath");
    }

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    int dateIndex = 0;
    int dataIndex = 0;
    int row; // 숫자
    int col; // 영어
    Measurements data;

    for (String name in mapData.keys){
      var sheet = excel[Constants.sheetNames[name]];

      for (String date in mapData[name].keys){
        if (firstDate == ''){
          firstDate = date;
        }

        if (mapData[name].containsKey(date)){
          data = mapData[name][date];
        }
        else{
          continue;
        }
        
        var dateCellCoordinates = _parseCellPosition(Constants.cellIndex['date']![dateIndex]);

        if (dateCellCoordinates == null) {
          throw Exception("잘못된 셀 위치 형식입니다: $dateCellCoordinates");
        }  
        row = dateCellCoordinates[0];
        col = dateCellCoordinates[1];

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)).value = date;

        for (String checkNum in data.checkList){
          for (int i = 0; i< data.measurements[checkNum].length; i++){
            
            var valueCellCoordinates = _parseCellPosition(Constants.cellIndex['values']![dateIndex]);

            if (valueCellCoordinates == null) {
              throw Exception("잘못된 셀 위치 형식입니다: $valueCellCoordinates");
            }

            if (dateIndex > 2){
              row = valueCellCoordinates[0] + Constants.getDataParams(name)[5] as int;
            }
            else{
              row = valueCellCoordinates[0];
            }


            if (i == data.measurements[checkNum].length - 1){
              col = valueCellCoordinates[1] + 2 * 3;
            }
            else{
              col = valueCellCoordinates[1] + 2 * dataIndex++;
            }

            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)).value = data.measurements[checkNum][i];
            String newFilePath = 'C:\\UND\\$firstDate$dataIndex';
            var newFile = File(newFilePath)
              ..createSync(recursive: true)
              ..writeAsBytesSync(excel.encode()!);

            print("파일이 성공적으로 저장되었습니다: $firstDate");
          }
          dataIndex = 0;
        }
        dateIndex++;
      }
      dateIndex = 0;
    }
    
    // 4. 새 파일로 저장
    String newFilePath = 'C:\\UND\\$firstDate$dataIndex';
    var newFile = File(newFilePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    print("파일이 성공적으로 저장되었습니다: $firstDate");
  } catch (e) {
    print("오류 발생: $e");
  }
}

List<int>? _parseCellPosition(String cellPosition) {
  final regex = RegExp(r'^([A-Z]+)([0-9]+)$');
  final match = regex.firstMatch(cellPosition);
  if (match == null) return null;

  String columnPart = match.group(1)!;
  String rowPart = match.group(2)!;

  int row = int.parse(rowPart) - 1; // 0-based index로 변환
  int col = 0;

  // 열(Column) 계산
  for (int i = 0; i < columnPart.length; i++) {
    col *= 26; // 자리수 반영
    col += columnPart.codeUnitAt(i) - 'A'.codeUnitAt(0) + 1;
  }
  col -= 1; // 0-based index로 변환

  return [row, col];
}