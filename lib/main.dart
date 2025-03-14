import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'data/nobel_data.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'utils/const.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  loadJsonFileWithDefaults();

  WidgetsFlutterBinding.ensureInitialized();
  // 🚀 Window Manager 초기화
  await windowManager.ensureInitialized();

  // 🖥️ 윈도우 앱을 전체화면 + 상태창 숨김 설정
  // 🖥️ Windows 앱을 전체화면 + 제목 표시줄 제거 설정
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setFullScreen(true); // 전체화면 모드
    // await windowManager.setAlwaysOnTop(true); // 항상 화면 위에 표시
    await windowManager.setResizable(false); // 창 크기 조절 불가
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden, windowButtonVisibility: false); // 제목 표시줄 제거
  });

  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await FlutterFlowTheme.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}



void loadJsonFileWithDefaults() async {
  try {
    File file = File(Constants.dataPath);
    if (await file.exists()) {
      String jsonString = await file.readAsString();
      
      Measurements.data = loadNestedMapFromFile(jsonString);
    }
    file = File(Constants.dateListPath);
    if (await file.exists()){
      String jsonString = await file.readAsString();
      Measurements.dateList = loadListFromFile(jsonString);
    } 
    else {
      print('파일이 존재하지 않아 기본값을 사용합니다.');
      return;
    }
  } catch (e) {
    print('JSON 파일 읽기 중 오류 발생: $e');
    return;
  }
}

List loadListFromFile(String jsonString){
  final jsonMap = jsonDecode(jsonString);

  return jsonMap['dateList'];
}

dynamic loadNestedMapFromFile(String jsonString) {
  // JSON 문자열 => Map<String, dynamic>
  final jsonMap = jsonDecode(jsonString);

  // 중첩된 Map<String, dynamic> => Map<String, Map<String, MyClass>>
  Map data = jsonMap.map((outerKey, innerMap) {
    return MapEntry(
      outerKey,
      (innerMap as Map<String, dynamic>).map(
        (innerKey, value) => MapEntry(innerKey, Measurements.fromJson(value)),
      ),
    );
  });

  for (String name in Constants.names){
    for(String date in data[name].keys){
      for(String checkNum in data[name][date].measurements.keys){
        data[name][date].measurements[checkNum].removeLast();
      }
    }
  }
  return data;
}


class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale? _locale;

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  Process? externalProcess = null;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    WidgetsBinding.instance.addObserver(this);
    // _maybeStartExternalProgram();
  }

  // 외부 프로그램이 실행 중인지 확인하는 함수 (Windows 전용)
  Future<bool> isProgramRunning(String processName) async {
    // tasklist 명령어 실행
    ProcessResult result = await Process.run('tasklist', []);
    if (result.exitCode == 0) {
      String output = result.stdout.toString().toLowerCase();
      return output.contains(processName.toLowerCase());
    }
    return false;
  }

  // 외부 프로그램 실행 여부 체크 후 실행
  Future<void> _maybeStartExternalProgram() async {
    const String processName = 'server.exe'; // 확인할 실행 파일 이름
    bool alreadyRunning = await isProgramRunning(processName);

    if (alreadyRunning) {
      print('$processName 이(가) 이미 실행 중입니다. 새로 시작하지 않습니다.');
      return;
    }

    // 실행할 프로그램의 전체 경로 (경로는 환경에 맞게 수정)
    String programPath = r'C:\nobel\server.exe';
    try {
      externalProcess = await Process.start(programPath, []);
      print('외부 프로그램 실행됨: PID ${externalProcess!.pid}');
    } catch (e) {
      print('프로그램 실행 중 오류 발생: $e');
    }
  }

  // 앱 종료 전 외부 프로그램 종료 시도
  Future<void> _stopExternalProgram() async {
    if (externalProcess != null) {
      bool result = externalProcess!.kill();
      print(result ? '외부 프로그램 종료 요청 성공' : '외부 프로그램 종료 요청 실패');
    }
  }

  @override
  void dispose() {
    _stopExternalProgram();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // // 앱 라이프사이클 변경 감지 (선택 사항)
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.detached ||
  //       state == AppLifecycleState.inactive) {
  //     _stopExternalProgram();
  //   }
  // }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TestNovelIRIS3',
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('ko'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
