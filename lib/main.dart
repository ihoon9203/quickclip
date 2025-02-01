import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quick_clip/provider/analysis_provider.dart';
import 'package:quick_clip/utils/stylesheet.dart';
import 'package:quick_clip/view/home/home_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black, // navigation bar color
    statusBarColor: Colors.black, // status bar color
  ));
  runApp( 
    ChangeNotifierProvider(
      create: (_) => AnalysisProvider()..getRecords(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:Stylesheet.accentColor),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
