import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'data/nobel_data.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';
import 'utils/const.dart';

void main() async {
  loadJsonFileWithDefaults();
  WidgetsFlutterBinding.ensureInitialized();
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
  return jsonMap.map((outerKey, innerMap) {
    return MapEntry(
      outerKey,
      (innerMap as Map<String, dynamic>).map(
        (innerKey, value) => MapEntry(innerKey, Measurements.fromJson(value)),
      ),
    );
  });
}


class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

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
