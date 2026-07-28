import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_shop_project/ui/bottom_navigation_button.dart';
import 'package:pet_shop_project/ui/checkout.dart';
import 'package:pet_shop_project/ui/home_page.dart';
import 'package:pet_shop_project/ui/organic_grain.dart';
import 'package:pet_shop_project/ui/product_details.dart';
import 'package:pet_shop_project/ui/sign_in.dart';
import 'package:pet_shop_project/ui/sign_up.dart';
import 'package:pet_shop_project/ui/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pet_shop_project/firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const SignIn (),
      ),
    );
  }
}


