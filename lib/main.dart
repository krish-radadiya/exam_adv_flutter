import 'package:exam_adv_flutter/screens/auctionpage/views/aucton_screen.dart';
import 'package:exam_adv_flutter/screens/homescreen/views/homescreen.dart';
import 'package:exam_adv_flutter/screens/splashscreen/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    getPages: [
      GetPage(
        name: '/splash',
        page: () => const Splashscreen(),
      ),
      GetPage(
        name: '/',
        page: () => Homescreen(
          userId: '',
        ),
      ),
      GetPage(
        name: '/auction',
        page: () => FavoriteScreen(
          userId: '',
        ),
      )
    ],
  ));
}
