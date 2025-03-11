import 'package:test_novel_i_r_i_s3/utils/app_logger.dart';
import 'package:test_novel_i_r_i_s3/widgets/IndexedText.dart';
import 'package:test_novel_i_r_i_s3/widgets/downloadButton.dart';

import '../data/nobel_data.dart';
import '../utils/const.dart';
import '../utils/functions.dart';
import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'month_management_model.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

class MonthManagementPage extends StatefulWidget {
  // 1️⃣ 생성자에 필수 매개변수 추가
  const MonthManagementPage({
    super.key,
    required this.name,
    required this.checkNum,
    required this.month,
    required this.jsonMap,
  });

  // 2️⃣ 매개변수 선언
  final String name;
  final int checkNum;
  final int month;
  final dynamic jsonMap;

  @override
  State<MonthManagementPage> createState() => _MonthManagementPage();
}

class _MonthManagementPage extends State<MonthManagementPage> with TickerProviderStateMixin {
  late MonthManagementModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int tabIndex = 0;
  bool _isConnected = false;
  static var logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();

    _model = createModel(context, () => MonthManagementModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    IndexedText.initState();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 💡 필수 매개변수 출력 예제
            Row(
              children: [
                Text('노밸 오토모티브'),
                Text('8월 xbar-R 관리도 및 Cpk 현황'),
              ]
            ),
            Row(
              children: [
                Column(
                  children: [
                    Text('1. 부품 현황'),
                    Table(
                      
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
