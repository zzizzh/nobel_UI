
// ignore_for_file: slash_for_doc_comments

import 'dart:convert';
import 'dart:io';

import '../utils/app_logger.dart';
import '../utils/const.dart';

class Data{

  /**
   * 전체 데이터
   * 소재 이름 - 날짜 : 측정값 데이터(소재명, 데이터)
   * auther :     John
   * date :       2024-12-27
   */
  static dynamic data = Map.from(Constants.JSON_DATA_MAP);
  static List dateList = [];

  static var logger = AppLogger.instance; // 로그 출력용

  late String date;                              // 검사 일자
  late String name;                              // 소재 이름(ex: MS-015)
  late List<double> referenceValues;             // 측정 기준값
  late List<double> errors;                      // 오차
  List<double> manageErrors = [];                // 관리 오차
  late List<String> checkList;                   // 검사 항목 번호
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
  Data.fromServer(var jsonData){
    List params = Constants.getDataParams(jsonData['name']);

    checkList = params[2];
    referenceValues = params[1];

    if (checkList.length == jsonData['values'].length){
      name = params[0];
      errors = params[3];

      if (name == 'MS-014' || name == 'MS-015'){
          manageErrors = params[4];
      } 
      
      List values = jsonData['values'];
      date = jsonData['date'];

      writeValue(values);
      
      data[name]![date] = this; 
    }
    else{
      logger.e('검사 항목 수와 실제 데이터의 수가 일치하지 않음.');
    }
  }

  Data(this.date, this.name, this.measurements){
    List params = Constants.getDataParams(name);

    checkList = params[2];
    referenceValues = params[1];
    errors = params[3];
    
    if (name == 'MS-014' || name == 'MS-015'){
        manageErrors = params[4];
    }
    data[name]![date] = this; 
    
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    
    return Data(json['date'], json['name'], json['measurements']);
  }

  Map<String, dynamic> toJson(){
    return {
      'date' : date,
      'name' : name,
      'measurements' : measurements
    };
  }


  /**
   * 모든 측정값 데이터
   * key :        검사 항목
   * List[0~2] :  초 중 종 측정값
   * auther :     John
   * date :       2024-12-26
   */
  dynamic measurements = {}; 


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

    result =  result/valueList.length;

    return ((result * 10000).roundToDouble()) / 10000;
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



  // UI에서 값을 표시하기 위한 함수
  
  String getValue(String checkNum, int index){
    if (measurements.containsKey(checkNum)){
      if(measurements[checkNum]!.length > index){
        return measurements[checkNum]![index].toString();
      }
    }
    return '';
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


  //TODO
  bool writeValueByKeyboard(String checkNum, int index){

    

    return false;
  }

  /**
   * 자주검사 체크시트 엑셀 파일에 값을 입력하기 위해
   * 특정 품목의 자주검사 일일 검사 데이터를 Json 형식의 데이터로 변환
   * return :     json 현재 데이터의 json 변환 데이터
   * auther :     John
   * date :       2024-12-27
   */
  dynamic toJsonForExcel(){

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
}