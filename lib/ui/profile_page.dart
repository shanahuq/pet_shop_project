import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      debugPrint('Current UID: ${user.uid}');
      debugPrint('User document exists: ${userDoc.exists}');
      debugPrint('User data: ${userDoc.data()}');

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        debugPrint('User document does not exist');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user is logged in')));
    }
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 20.r,
            child: ClipOval(child: Image.asset('assets/pets_parent.png')),
          ),
        ),
        title: Text(
          'PetLife',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28.sp,
            color: Color(0xffA73927),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 40.w),
            child: Icon(Icons.notifications_none, color: Color(0xffA73927)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(height: 50.h),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 45.r,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/pets_parent2.png',
                            fit: BoxFit.cover,
                            height: 110.h,
                            width: 110.w,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -8.h,
                        child: Container(
                          height: 25.h,
                          width: 84.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Color(0xff006971),
                          ),
                          child: Center(
                            child: Text(
                              'Pet Parent',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  userData?['name'] ?? 'No name',

                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24.sp,
                    color: Color(0xff1B1C1C),
                  ),
                ),
                Text(
                  userData?['address'] ?? 'No address',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: Color(0xff57423D),
                  ),
                ),
                SizedBox(height: 45.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Pets',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                        color: Color(0xff1B1C1C),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Add New',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: Color(0xff006971),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 220.h,
                      width: 170.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: Colors.white,
                        border: Border.all(color: Color(0xffDFC0BA)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15.h),
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: Image.asset(
                                  'assets/health_ok.png',
                                  fit: BoxFit.cover,
                                  height: 133.h,
                                  width: 133.w,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Buddy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                    color: Color(0xff1B1C1C),
                                  ),
                                ),
                                Container(
                                  height: 20.h,
                                  width: 65.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.r),
                                    color: Color(0xffFFDAD4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Health OK',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10.sp,
                                        color: Color(0xff862112),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Golden Retriever',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                                color: Color(0xff57423D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 220.h,
                      width: 170.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: Colors.white,
                        border: Border.all(color: Color(0xffDFC0BA)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15.h),
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: Image.asset(
                                  'assets/vaccinated_pet.png',
                                  fit: BoxFit.cover,
                                  height: 133.h,
                                  width: 133.w,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Luna',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                    color: Color(0xff1B1C1C),
                                  ),
                                ),
                                Container(
                                  height: 20.h,
                                  width: 65.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.r),
                                    color: Color(0xff93EEF9),
                                  ),
                                  child: Center(
                                    child: Text(
                                      ' Vaccinated',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10.sp,
                                        color: Color(0xff862112),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Siamese Cat',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                                color: Color(0xff57423D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Container(
                  width: 350.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      profileTile(icon: Icons.history, title: 'Order History'),
                      Divider(color: const Color.fromARGB(73, 158, 158, 158)),
                      profileTile(
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                      ),
                      Divider(color: const Color.fromARGB(73, 158, 158, 158)),
                      profileTile(
                        icon: Icons.local_shipping_outlined,
                        title: 'Shipping Addresses',
                      ),
                      Divider(color: const Color.fromARGB(73, 158, 158, 158)),
                      profileTile(
                        icon: Icons.health_and_safety,
                        title: 'Pet Health Records',
                      ),
                      Divider(color: const Color.fromARGB(73, 158, 158, 158)),
                      profileTile(icon: Icons.settings, title: 'Settings'),
                      Divider(color: const Color.fromARGB(73, 158, 158, 158)),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 2,
                    side: BorderSide(color: Color(0xffBA1A1A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 100.w,
                      vertical: 10.h,
                    ),
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: Color(0xffBA1A1A),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profileTile({required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon, color: Color(0xffA73927), size: 22.sp),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: Color(0xff1B1C1C),
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_sharp, color: Colors.grey),
      onTap: () {},
    );
  }
}
