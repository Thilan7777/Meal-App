import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/app_state_provider.dart';
import 'services/database_service.dart';
import 'services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await DatabaseService.instance.database;
  final appState = AppStateProvider();
  await appState.initializeApp();

  runApp(ScreenUtilInit(
    designSize: Size(412, 732),
    minTextAdapt: true,
    builder: (context, child) {
      return ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Kanit',
          ),
          routerConfig: NavigationService.router,
        ),
      );
    },
  ));
}
