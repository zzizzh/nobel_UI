
// ignore_for_file: slash_for_doc_comments

import 'dart:convert';

import '../utils/app_logger.dart';
import '../utils/const.dart';

class Data{

  /**
   * 전체 데이터
   * 소재 이름 - 날짜 : 측정값 데이터(소재명, 데이터)
   * auther :     John
   * date :       2024-12-27
   */
  static Map data = Map.from(Constants.JSON_DATA_MAP);
  static List<String> dateList = [];

  static var logger = AppLogger.instance; // 로그 출력용

  late String date;                              // 검사 일자
  late String name;                              // 소재 이름(ex: MS-015)
  late List<double> referenceValues;                      // 측정 기준값
  late List<double> errors;                      // 오차
  List<double> manageErrors = [];                // 관리 오차
  late List<String> checkList;                      // 검사 항목 번호
  bool isComplete = false;

  // 사용 미정 데이터
  String productNum = '';
  String worker = '';
  String admin = '';
  int numOfNondefective = 0;

  /**
   * 처음 소재에 대한 측정값을 파이썬 서버에서 받으면
   * 소재 클래스가 생성되고 전체 데이터 셋의 날짜에 
   * 소재 이름에 저장된다. Map<이름, Map<날짜, Data>>
   * 
   * ex) 
   * {
   *    'MS-010' : {
   *        '2024-12-27' : data,
   *        '2024-12-28' : data,...
   *    },
   *    'MS-011' : {
   *        '2024-12-27' : data,
   *        '2024-12-28' : data,...
   *    },...       
   * }
   * 
   * param 1 :  List Constants 클래스의 해당 소재 이름에
   *            해당하는 상수값 리스트
   * param 2 :  파이썬 서버로부터 전달받은 소재 측정값
   * auther :     John
   * date :       2024-12-27
   */
  Data(var jsonData){
    List params = Constants.getDataParams(jsonData['name']);

    checkList = params[2];
    referenceValues = params[1];

    if (checkList.length == jsonData['values'].length){
      name = params[0];
      errors = params[3];

      if (name == 'MS-014' || name == 'MS-015'){
          manageErrors = params[4];
      } 
      
      List<double> values = jsonData['values'];
      date = jsonData['date'];

      writeValue(values);
      
      data[name]![date] = this; 
    }
    else{
      logger.e('검사 항목 수와 실제 데이터의 수가 일치하지 않음.');
    }
  }


  /**
   * 모든 측정값 데이터
   * key :        검사 항목
   * List[0~2] :  초 중 종 측정값
   * auther :     John
   * date :       2024-12-26
   */
  Map<String, List<double>> measurements = {}; 


  /**
   * 초, 중, 종 검사 중 에러가 있는지 확인
   * 측정값 - 기준값 > 오차값 : 불량
   * param 1 :    int 검사 항목 번호(checkNum)
   * param 2 :    int 초(0), 중(1), 종(2) 중 하나(index)
   * return :     true(에러가 있을 시)
   *              false(에러가 없을 시) 
   * auther :     John
   * date :       2024-12-26
   */
  bool? isErrorByCheckItemNumber(String checkNum, int index){
    if (measurements.containsKey(checkNum) && measurements[checkNum]!.length > index){
      int i = checkList.indexOf(checkNum);
      if (name != 'MS-014' && name != 'MS-015'){
        if ((measurements[checkNum]![index]-referenceValues[i]) > errors[i*2] || (measurements[checkNum]![index]-referenceValues[i]) < errors[i*2+1]){
          return true;
        }
      }
      // MS-014와 MS-015는 규격한계, 관린한계 따로 있음.
      else{
        if ((measurements[checkNum]![index]-referenceValues[i]) > errors[i*2] || (measurements[checkNum]![index]-referenceValues[i]) < errors[i*2+1]){
          return true;
        }
        else if ((measurements[checkNum]![index]-referenceValues[i]) > manageErrors[i*2] || (measurements[checkNum]![index]-referenceValues[i]) < manageErrors[i*2+1]){
          return true;
        }
      }
    }
    else{
      return null;
    }
    return false;
  }


  /**
   * 오차 범위를 벗어나는 측정값의 index와 
   * 전체 오차가 발생한 값의 갯수,
   * 오차가 발생한 소재의 갯수를 반환
   * return :     List<[index, checkNum], ..., [numOfValueError, numItemError]>
   * auther :     John
   * date :       2024-12-26
   */
  List<dynamic> getErrorData(){
    List<dynamic> result = [];
    int numOfValueError = 0;
    int numItemError = 0;
    bool isError = false;
    
    for (int index=0; index < measurements.values.first.length; index++) {
      isError = false;
      
      for (var checkNum in measurements.keys){
        if (isErrorByCheckItemNumber(checkNum, index)!){
          numOfValueError += 1;
          // 에러가 발생한 초중종, 검사항목 반환
          result.add([index, checkNum]);
          isError = true;
        }
      }
      if (isError){
        numItemError += 1;
      } 
    }
    result.add([numOfValueError, numItemError]);
    return result;
  }


  /**
   * 오차가 발생한 소재의 갯수를 반환
   * return :     int 불량 수량
   * auther :     John
   * date :       2024-12-26
   */
  int getErrorCount(){
    int numItemError = 0;
    for (int index = 0; index < measurements.values.first.length; index++) {
      for (var checkNum in measurements.keys){
        if (isErrorByCheckItemNumber(checkNum, index)!){
          // 에러가 발생한 초중종, 검사항목 반환
          numItemError += 1;
          break;
        }
      }
    }
    return numItemError;
  }


  /**
   * 특정 검사항목의 초, 중, 종 측정값 평균 구하기
   * param :      int 검사 항목 index 
   * return :     double 해당 검사항목의 초, 중, 종 측정값의 평균값
   * auther :     John
   * date :       2024-12-26
   */
  double averageByCheckNum(String checkNum){
    double result = 0;
    List valueList = measurements[checkNum]!;
    for (double value in valueList){
      result += value;
    }
    return result/valueList.length;
  }


  /**
   * 모든 검사 항목의 초, 중, 종 측정값의 평균 구하기
   * return :     List<double> 각 검사 항목의 초, 중, 종 평균값 리스트
   * auther :     John
   * date :       2024-12-26
   */
  List<double> averageAllValues(){
    List<double> result = [];

    for (String checkNum in measurements.keys){
      result.add(averageByCheckNum(checkNum));
    }

    return result;
  }


  /**
   * !!class method!!
   * 기존 데이터에 중, 종 측정값을 저장하기 위해 
   * 소재 데이터 클래스 인스턴스를 가져오기
   * param 1 :    var json 파이썬 서버로부터 받은 json 데이터
   * return :     Data 해당 클래스 인스턴스
   * auther :     John
   * date :       2024-12-26
   */
  static Data? getDataForWriteValue(var jsonData){
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


  /**
   * !!class method!!
   * name품명의 특정 날짜 데이터가 있는지 확인
   * param 1 :    string 날짜 (ex "2024-12-26")
   * return :     true(해당 날짜에 데이터 존재)
   *              false(데이터 없음) 
   * auther :     John
   * date :       2024-12-27
   */
  static bool hasDateInData(String date){
    for (String name in data.keys){
      if (data[name].containsKey(date)){
        return true;
      }
    }
    return false;
  }


  /**
   * !!class method!!
   * 기존 데이터의 특정 날짜에 특정 소재 데이터가 있는지 확인
   * param 1 :    string 날짜 (ex "2024-12-26")
   * param 2 :    string 소재 이름 (ex "MS-010")
   * return :     true(해당 데이터 존재)
   *              false(데이터 없음) 
   * auther :     John
   * date :       2024-12-26
   */
  static bool hasDataByDateAndName(String date, String name){
    return data[date]!.containsKey(name);
  }


  /**
   * 파이썬 서버로부터 받은 초, 중, 종 측정값들을
   * 소재 데이터에 저장
   * param 1 :    List 파이썬 서버로부터 받은 json 데이터의
   *              측정값 리스트
   * return :     true(측정값 저장 성공)
   *              false(오류 검사 실패 시) 
   * auther :     John
   * date :       2024-12-26
   */
  bool writeValue(List values){
    if (checkList.length == values.length){
      int index = 0;
      if(measurements.containsKey(checkList[0])){
        if(measurements[checkList[0]]!.length < 3){
          for (String checkNum in checkList){
            measurements[checkNum]!.add(values[index++]);
          }
          return true;
        }
        else{
          logger.e('이미 초, 중, 종 모든 측정값이 저장됨.');
          return false;
        }
      }
      else{
        for(String checkNum in checkList){
          measurements[checkNum] = [];
          measurements[checkNum]!.add(values[index++]);
        }
        return true;
      }
    }
    else{
      logger.e('검사 항목 수와 실제 측정값의 수가 일치하지 않음.');
      return false;
    }
    
  }


  /**
   * 자주검사 체크시트 엑셀 파일에 값을 입력하기 위해
   * 특정 품목의 자주검사 일일 검사 데이터를 Json 형식의 데이터로 변환
   * return :     json 현재 데이터의 json 변환 데이터
   * auther :     John
   * date :       2024-12-27
   */
  dynamic toJson(){

    Map jsonDataMap = {
      'error_num' : getErrorCount(),
      'values' : measurements,
      'error_data' : getErrorData(),
    };

    // 각 검사항목 마지막에 평균값 저장
    for(String checkNum in measurements.keys){
      jsonDataMap['values'][checkNum]!.add(averageByCheckNum(checkNum));
    }

    return jsonDataMap;
  }


  /**
   * !! static method !!
   * 자주검사 체크시트 엑셀 파일에 값을 입력하기 위해
   * 특정 품목의 자주검사 1주일 검사 데이터를 Json 형식의 데이터로 변환
   * param 1 :    String 시작 날짜(보통 월요일이지만 공휴일일 경우도 있기 때문)
   * return :     json (시작 날짜부터 처음 나오는 토요일 까지의 데이터)
   *              false (실패 시)
   * auther :     John
   * date :       2024-12-27
   */
  static dynamic toJsonFromStartDateToSaturday(String startDateString){
    DateTime startDate = DateTime.parse(startDateString);
    DateTime firstSaturday = findNextSaturday(startDate);
    
    Map jsonDataMap = Map.from(Constants.JSON_DATA_MAP);
    bool isExist = false;

    for (String name in data.keys){
      for (int day=startDate.day; day<=firstSaturday.day; day++){
        String date = "${startDate.year}-${startDate.month}-${day}";
        
        if (data[name]!.containsKey(date)){
          var jsonData = data[name]![date]!.toJson();
            
          jsonDataMap[name][date] = jsonData;
          isExist = true;
        }
      }
    }
    
    if (!isExist){
      return false;
    }

    logger.i(jsonDataMap);

    return json.encode(jsonDataMap);
  }
  

  /**
   * !! static method !!
   * 특정 날짜에서부터 처음 나오는 토요일 찾기
   * param 1 :    String 시작 날짜
   * return :     Datetime 시작 날짜부터 처음 나오는 토요일
   * auther :     John
   * date :       2024-12-27
   */
  static DateTime findNextSaturday(DateTime date) {
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

}