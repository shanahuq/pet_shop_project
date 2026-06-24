import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 150.h),
            Center(
              child: Image.asset(
                'assets/Paw Print Icon (Using exact string from system logic).png',
                height: 80.h,
                width: 80.w,
              ),
            ),
            Text(
              'PetLife',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20.sp,
                color: Color(0xffffA73927),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'PREMIUM PET CARE',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 10.sp,
                color: Color(0xffff605E59),
              ),
            ),
            SizedBox(height: 250.h),
            Image.asset(
              'assets/beautiful-happy-reddish-havanese-puppy-dog-sitting-frontal-looking-camera-isolated-white-background-46868560.webp',
              height: 180,
              width: 180,
            ),
            SizedBox(height: 10.h),
            Text(
              '"Made with love for your furry friends"',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: Color(0xffff57423D),
              ),
            ),
            SizedBox(height: 60.h),
            Container(
              height: 5.h,
              width: 50.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                color: Color(0xffF27059),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
