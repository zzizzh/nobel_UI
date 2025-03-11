import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_novel_i_r_i_s3/app_state.dart';
import 'package:test_novel_i_r_i_s3/utils/app_logger.dart';
import '../utils/functions.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({super.key});
  static var logger = AppLogger.instance;
  @override
  Align build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 16.0),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            // await saveExcelFile(mapData: toJsonFromStartDateToWeek(FFAppState().CurrentDate));
            sendJsonData();
            await showDialog(
              context: context,
              builder: (alertDialogContext) {
                return AlertDialog(
                  title: const Text('저장',  style: TextStyle(fontWeight: FontWeight.bold, ),),
                  content: const Text('엑셀파일로 저장되었습니다.',  style: TextStyle(fontWeight: FontWeight.w500, ),),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF08018C), // 버튼 배경색
                      ),
                      onPressed: () => Navigator.pop(alertDialogContext),
                      child: const Text(
                        'Ok',
                        style: TextStyle(color: Colors.white), // 버튼 텍스트 색상
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(
            Icons.file_download_outlined,
            color: Color(0xFF08018C),
            size: 40.0,
          ),
        ),
      ),
    );
  }


  Future<void> sendJsonData() async {
    String host = '127.0.0.1';
    int port = 12345;
    try {
      // 소켓 연결
      if (FFAppState().socket == null){
        FFAppState().socket = await Socket.connect('127.0.0.1', 12345);
      }
      Socket socket = FFAppState().socket!;

      logger.i('서버에 연결됨: $host:$port');

      dynamic jsonData = toJsonFromStartDateToWeek(FFAppState().CurrentDate);

      // JSON 데이터를 문자열로 변환 후 전송
      String jsonString = jsonEncode(jsonData);
      socket.write(jsonString);
      logger.i('데이터 전송 완료: $jsonString');

      
    } catch (e) {
      logger.e('소켓 오류 발생\n $e');
    }
  }

}