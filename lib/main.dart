import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/config.dart';
import 'common/di/injection.dart';
import 'data/repositories/app_repository.dart';
import 'env.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Configurations().setConfigurationValues(environment);

  if (!kIsWeb) {
    unawaited(SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]));
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
  }

  await Injection.inject();

  runZonedGuarded(() {
    runApp(const App());
  }, (error, stackTrace) {
    //! send record to firebase crashlytics or issue tools
  });
}
