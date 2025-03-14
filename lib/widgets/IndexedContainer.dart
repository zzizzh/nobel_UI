// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../utils/app_logger.dart';
import '../utils/const.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class IndexedContainer extends StatelessWidget {
  static final Map<String, int> _indexCounter = {
    'MS-010': 1,
    'MS-011': 1,
    'MS-012': 1,
    'MS-013': 1,
    'MS-014': 1,  // MS-014는 1부터 시작
    'MS-015': 1,  // MS-015는 1부터 시작
  };

  late String index;
  late String text;

  static final Map<String, IndexedContainer> textMap = {};
  static int indexNameIndex = 0;
  static int codeListIndex = 0;
  static int passIndex = 0;
  static var logger = AppLogger.instance;
  double scaleFactor;

  IndexedContainer({super.key, required this.scaleFactor}){
    index = _generateText();
    text = index.split("/")[1];

    textMap[index] = this;
  }

  static void initState(){
    indexNameIndex = 0;
    codeListIndex = 0;
    passIndex = 0;
    for (String key in _indexCounter.keys){
      _indexCounter[key] = 1;
    }
  }

  static String _generateText() {
    // MS 코드 순서 리스트
    final msCodeList = ['MS-010', 'MS-011', 'MS-012', 'MS-013', 'MS-014', 'MS-015'];
    final passIndexList = [3, 3, 3, 4, 3, 2, 3, 4, 2, 3, 5, -1];
    // 각 MS 코드에 대해 자동으로 텍스트 생성

    int number = _indexCounter[msCodeList[codeListIndex]]!;
    if (number > _getMaxIndexForMSCode(msCodeList[codeListIndex])){
      codeListIndex++;
      if (codeListIndex == 6){
        initState();
      }
      number = _indexCounter[msCodeList[codeListIndex]]!;
      if(codeListIndex > 5){
        logger.e('이미 모든 인덱스를 생성함.');
      }
    }
    String generatedText = "${msCodeList[codeListIndex]}/${Constants.indexNames[indexNameIndex]}$number";
    indexNameIndex++;
    if (indexNameIndex == 3){
      // if (number + 1 != passIndexList[passIndex]){
      //   _indexCounter[msCodeList[codeListIndex]] = number+1;
      // }
      // else{
      //   _indexCounter[msCodeList[codeListIndex]] = number+2;
      //   passIndex++;
      // }

      while (number + 1 == passIndexList[passIndex]){
        number += 1;
        passIndex++;
      }
      _indexCounter[msCodeList[codeListIndex]] = number + 1;
      indexNameIndex%=3;
    }
    
    // 임시로 하나의 텍스트 반환 (첫 번째 생성된 텍스트)
    return generatedText;
  }

  // 각 MS 코드에 대해 최대 인덱스 값 반환
  static int _getMaxIndexForMSCode(String msCode) {
    switch (msCode) {
      case 'MS-014':
        return 8;
      case 'MS-015':
        return 9;
      default:
        return 6;  // MS-010, MS-011, MS-012, MS-013은 최대 6
    }
  }

  @override
  Widget build(BuildContext context) {
    // 생성된 텍스트를 Text 위젯으로 반환
    return Container(
      width: MediaQuery.sizeOf(
                  context)
              .width *
          0.07,
      height: MediaQuery.sizeOf(
                  context)
              .height *
          0.04,
      decoration:
          BoxDecoration(
        color: FlutterFlowTheme.of(
                context)
            .secondaryBackground,
        border: Border
            .all(
          color: Color(
              0x80000000),
        ),
      ),
      child: Align(
        alignment:
            AlignmentDirectional(
                0.0,
                0.0),
        child: Text(
          text,
          style: FlutterFlowTheme.of(
                  context)
              .bodyMedium
              .override(
                fontFamily:
                    'Inter',
                fontSize:
                    27.0 * scaleFactor,
                letterSpacing:
                    0.0,
                fontWeight:
                    FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
