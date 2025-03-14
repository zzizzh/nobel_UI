
import 'package:flutter/material.dart';
import 'package:test_novel_i_r_i_s3/app_state.dart';
import 'package:test_novel_i_r_i_s3/utils/app_logger.dart';
import '../utils/functions.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({super.key, required this.type});
  static var logger = AppLogger.instance;
  final String type;

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
            sendJsonData(type);
            FFAppState().setIsLoading(true);
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


}