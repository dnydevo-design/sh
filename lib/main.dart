import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_dependencies.dart';
import 'app/fast_share_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  final preferences = await SharedPreferences.getInstance();
  runApp(FastShareApp(dependencies: AppDependencies(preferences)));
}
