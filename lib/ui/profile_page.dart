import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_shop_project/ui/order_history_page.dart';
import 'package:pet_shop_project/ui/payment_methods_page.dart';
import 'package:pet_shop_project/ui/shipping_address_page.dart';

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
      debugPrint('Looking for document: users/${user.uid}');
      debugPrint('Document exists: ${userDoc.exists}');
      debugPrint('Data: ${userDoc.data()}');

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
  Future<void> _showEditProfileDialog() async {
  final user = _auth.currentUser;

  if (user == null) {
    return;
  }

  final nameController = TextEditingController(
    text: userData?['name']?.toString() ?? '',
  );

  final phoneController = TextEditingController(
    text: userData?['phone']?.toString() ?? '',
  );

  final addressController = TextEditingController(
    text: userData?['address']?.toString() ?? '',
  );

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25.r),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 25.w,
          right: 25.w,
          top: 20.h,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP HANDLE
              Center(
                child: Container(
                  width: 45.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // TITLE
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: const Color(0xffA73927),
                    size: 25.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 25.h),

              // NAME
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xffA73927),
                  ),
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(
                      color: Color(0xffA73927),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              // EMAIL - READ ONLY
              TextField(
                controller: TextEditingController(
                  text: user.email ?? '',
                ),
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.grey,
                  ),
                  labelText: 'Email',
                  suffixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              // PHONE
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xffA73927),
                  ),
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(
                      color: Color(0xffA73927),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              // ADDRESS
              TextField(
                controller: addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.home_outlined,
                    color: Color(0xffA73927),
                  ),
                  labelText: 'Address',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(
                      color: Color(0xffA73927),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 25.h),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () async {
                    final name =
                        nameController.text.trim();

                    final phone =
                        phoneController.text.trim();

                    final address =
                        addressController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter your name',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await _firestore
                          .collection('users')
                          .doc(user.uid)
                          .update({
                        'name': name,
                        'phone': phone,
                        'address': address,
                      });

                      // Update local data immediately
                      setState(() {
                        userData = {
                          ...?userData,
                          'name': name,
                          'phone': phone,
                          'address': address,
                        };
                      });

                      if (context.mounted) {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Profile updated successfully',
                            ),
                            backgroundColor:
                                Color(0xff006971),
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint(
                        'PROFILE UPDATE ERROR: $e',
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to update profile: $e',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xffA73927),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15.r),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      );
    },
  );

  nameController.dispose();
  phoneController.dispose();
  addressController.dispose();
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
              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Flexible(
      child: Text(
        userData?['name'] ?? 'No name',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 24.sp,
          color: const Color(0xff1B1C1C),
        ),
      ),
    ),

    SizedBox(width: 8.w),

    IconButton(
      onPressed: () {
        _showEditProfileDialog();
      },
      icon: Icon(
        Icons.edit_outlined,
        color: const Color(0xff006971),
        size: 22.sp,
      ),
    ),
  ],
),

Text(
  userData?['address'] ?? 'No address',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.sp,
    color: const Color(0xff57423D),
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
                      profileTile(
                        icon: Icons.history,
                        title: 'Order History',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderHistoryPage(),
                            ),
                          );
                        },
                      ),
                      Divider(color: const Color.fromARGB(73, 158, 158, 158)),
                      profileTile(
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentMethodsPage(),
                            ),
                          );
                        },
                      ),
                      Divider(color: const Color.fromARGB(73, 158, 158, 158)),
                      profileTile(
                        icon: Icons.local_shipping_outlined,
                        title: 'Shipping Addresses',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShippingAddressPage(),
                            ),
                          );
                        },
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

  Widget profileTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xffA73927), size: 22.sp),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: const Color(0xff1B1C1C),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_sharp, color: Colors.grey),
      onTap: onTap,
    );
  }
}
