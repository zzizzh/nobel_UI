
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:test_novel_i_r_i_s3/app_state.dart';
import 'package:test_novel_i_r_i_s3/utils/app_logger.dart';
import 'package:test_novel_i_r_i_s3/utils/const.dart';
import 'dart:collection';
import '../data/data.dart';


/// UI 평균값 칸에 값을 표시
/// param 1 :    소재 이름
/// param 2 :    검사 항목 번호
/// param 3 :    초, 중, 종 인덱스
/// return :     초, 중, 종 중 하나의 측정값
/// auther :     John
/// date :       2024-01-06
String getValue(String name, String checkNum, int index){
  String currentDate = FFAppState().CurrentDate;
  if (Data.data[name]!.containsKey(currentDate)){
    return Data.data[name]![currentDate]!.getValue(checkNum, index);
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
  if (Data.data[name]!.containsKey(currentDate)){
    return Data.data[name]![currentDate]!.averageByCheckNum(checkNum).toString();
  }
  return '';
}


/// 기존 데이터에 중, 종 측정값을 저장하기 위해 
/// 소재 데이터 클래스 인스턴스를 가져오기
/// param 1 :    var json 파이썬 서버로부터 받은 json 데이터
/// return :     Data 해당 클래스 인스턴스
/// auther :     John
/// date :       2024-12-26
Data? getDataForWriteValue(var jsonData){
  Map data = Data.data;
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
  Map data = Data.data;
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
  Map data = Data.data;
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
  Map data = Data.data;
  
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

/// 자주검사 체크시트 엑셀 파일에 값을 입력하기 위해
/// 특정 품목의 자주검사 1주일 검사 데이터를 Json 형식의 데이터로 변환
/// param 1 :    String 시작 날짜(보통 월요일이지만 공휴일일 경우도 있기 때문)
/// return :     Map(Constants.JSON_DATA_MAP) (시작 날짜부터 처음 나오는 토요일 까지의 데이터)
/// auther :     John
/// date :       2024-01-09
dynamic toJsonFromStartDateToWeek(String startDate){

  Map data = Data.data;

  List dateList = [];
  String? date;
  while(dateList.length < 7){
    date = findNextDate(startDate);

    if (date!=null){
      dateList.add(date);
    }
    else{
      break;
    }
  }
  
  Map jsonMap = json.decode(json.encode(Constants.JSON_DATA_MAP));

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
  List sortedDates = Data.dateList;

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