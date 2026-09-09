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

  // ============================================================
  // LOAD USER DATA
  // ============================================================

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      debugPrint('Current UID: ${user.uid}');
      debugPrint('Looking for document: users/${user.uid}');
      debugPrint('Document exists: ${userDoc.exists}');
      debugPrint('Data: ${userDoc.data()}');

      if (!mounted) return;

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

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (sheetContext) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final bool isLandscape = orientation == Orientation.landscape;

            return Padding(
              padding: EdgeInsets.only(
                left: isLandscape ? 40.w : 25.w,
                right: isLandscape ? 40.w : 25.w,
                top: 20.h,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20.h,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(sheetContext).size.height *
                      (isLandscape ? 0.95 : 0.9),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // HANDLE
                      // ==================================================
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

                      // ==================================================
                      // TITLE
                      // ==================================================
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
                              fontSize: isLandscape ? 19.sp : 21.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // ==================================================
                      // NAME
                      // ==================================================
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

                      // ==================================================
                      // EMAIL
                      // ==================================================
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

                      // ==================================================
                      // PHONE
                      // ==================================================
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

                      // ==================================================
                      // ADDRESS
                      // ==================================================
                      TextField(
                        controller: addressController,
                        maxLines: isLandscape ? 2 : 3,
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

                      SizedBox(height: 20.h),

                      // ==================================================
                      // SAVE BUTTON
                      // ==================================================
                      SizedBox(
                        width: double.infinity,
                        height: isLandscape ? 48.h : 52.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();

                            final phone = phoneController.text.trim();

                            final address = addressController.text.trim();

                            if (name.isEmpty) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your name'),
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

                              if (!mounted) return;

                              setState(() {
                                userData = {
                                  ...?userData,
                                  'name': name,
                                  'phone': phone,
                                  'address': address,
                                };
                              });

                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Profile updated successfully',
                                    ),
                                    backgroundColor: Color(0xff006971),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('PROFILE UPDATE ERROR: $e');

                              if (sheetContext.mounted) {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
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
                            backgroundColor: const Color(0xffA73927),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: isLandscape ? 14.sp : 16.sp,
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
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    // ============================================================
    // LOADING
    // ============================================================

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ============================================================
    // NO USER
    // ============================================================

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user is logged in')));
    }

    return Scaffold(
      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        elevation: 0,

        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: CircleAvatar(
            radius: 20.r,
            child: ClipOval(
              child: Image.asset('assets/pets_parent.png', fit: BoxFit.cover),
            ),
          ),
        ),

        title: Text(
          'PetLife',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28.sp,
            color: const Color(0xffA73927),
          ),
        ),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Icon(
              Icons.notifications_none,
              color: const Color(0xffA73927),
              size: 27.sp,
            ),
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final bool isLandscape = orientation == Orientation.landscape;

            return LayoutBuilder(
              builder: (context, constraints) {
                final double screenWidth = constraints.maxWidth;

                // ==================================================
                // RESPONSIVE HORIZONTAL PADDING
                // ==================================================

                final double horizontalPadding =
                    isLandscape ? (screenWidth > 800 ? 70.w : 35.w) : 30.w;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isLandscape ? 20.h : 10.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ==================================================
                      // PROFILE SECTION
                      // ==================================================
                      SizedBox(height: isLandscape ? 20.h : 40.h),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // PROFILE CIRCLE + IMAGE
                            CircleAvatar(
                              radius: isLandscape ? 65.r : 45.r,
                              backgroundColor: Colors.grey.shade200,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/pets_parent2.png',
                                  fit: BoxFit.cover,
                                  width: isLandscape ? 145.w : 110.w,
                                  height: isLandscape ? 145.w : 110.w,
                                ),
                              ),
                            ),

                            // PET PARENT BADGE
                            // PET PARENT BADGE
                            Positioned(
                              bottom: isLandscape ? -10.h : -8.h,
                              child: Container(
                                height: isLandscape ? 32.h : 25.h,
                                width: isLandscape ? 115.w : 84.w,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscape ? 12.w : 8.w,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  color: const Color(0xff006971),
                                ),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Pet Parent',
                                      maxLines: 1,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: isLandscape ? 12.sp : 12.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isLandscape ? 18.h : 25.h),

                      // ==================================================
                      // NAME + EDIT BUTTON
                      // ==================================================
                      // ==================================================
                      // NAME + ADDRESS
                      // ==================================================
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // NAME + EDIT BUTTON
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    userData?['name']?.toString() ?? 'No name',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isLandscape ? 20.sp : 24.sp,
                                      color: const Color(0xff1B1C1C),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 5.w),

                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  onPressed: _showEditProfileDialog,
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: const Color(0xff006971),
                                    size: isLandscape ? 19.sp : 22.sp,
                                  ),
                                ),
                              ],
                            ),

                            // ADDRESS
                            Text(
                              userData?['address']?.toString() ?? 'No address',
                              maxLines: isLandscape ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: isLandscape ? 12.sp : 14.sp,
                                color: const Color(0xff57423D),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isLandscape ? 30.h : 45.h),

                      // ==================================================
                      // MY PETS HEADER
                      // ==================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Pets',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isLandscape ? 18.sp : 20.sp,
                              color: const Color(0xff1B1C1C),
                            ),
                          ),

                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Add New',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isLandscape ? 11.sp : 12.sp,
                                color: const Color(0xff006971),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isLandscape ? 5.h : 10.h),

                      // PET CARDS
                      // ==================================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _petCard(
                              image: 'assets/health_ok.png',
                              name: 'Buddy',
                              breed: 'Golden Retriever',
                              status: 'Health OK',
                              statusColor: const Color(0xffFFDAD4),
                              statusTextColor: const Color(0xff862112),
                              isLandscape: isLandscape,
                            ),
                          ),

                          SizedBox(width: isLandscape ? 12.w : 15.w),

                          Expanded(
                            child: _petCard(
                              image: 'assets/vaccinated_pet.png',
                              name: 'Luna',
                              breed: 'Siamese Cat',
                              status: 'Vaccinated',
                              statusColor: const Color(0xff93EEF9),
                              statusTextColor: const Color(0xff862112),
                              isLandscape: isLandscape,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isLandscape ? 25.h : 30.h),

                      // ==================================================
                      // PROFILE OPTIONS
                      // ==================================================
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
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

                            _divider(),

                            profileTile(
                              icon: Icons.payment_outlined,
                              title: 'Payment Methods',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const PaymentMethodsPage(),
                                  ),
                                );
                              },
                            ),

                            _divider(),

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

                            _divider(),

                            profileTile(
                              icon: Icons.health_and_safety,
                              title: 'Pet Health Records',
                            ),

                            _divider(),

                            profileTile(
                              icon: Icons.settings,
                              title: 'Settings',
                            ),

                            _divider(),
                          ],
                        ),
                      ),

                      SizedBox(height: isLandscape ? 20.h : 20.h),

                      // ==================================================
                      // LOGOUT BUTTON
                      // ==================================================
                      // ==================================================
                      // LOGOUT BUTTON
                      // ==================================================
                      Center(
                        child: SizedBox(
                          width: isLandscape ? screenWidth * 0.55 : 230.w,
                          height: isLandscape ? 58.h : 50.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 2,
                              side: const BorderSide(
                                color: Color(0xffBA1A1A),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            child: Text(
                              'Log Out',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: isLandscape ? 13.sp : 13.sp,
                                color: const Color(0xffBA1A1A),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isLandscape ? 30.h : 30.h),

                      SizedBox(height: isLandscape ? 20.h : 30.h),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // PET CARD
  // ============================================================

  Widget _petCard({
    required String image,
    required String name,
    required String breed,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required bool isLandscape,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        border: Border.all(color: const Color(0xffDFC0BA)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLandscape ? 8.w : 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // PET IMAGE
            // ==================================================
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),

            SizedBox(height: isLandscape ? 5.h : 7.h),

            // ==================================================
            // NAME + STATUS
            // ==================================================
            // ==================================================
            // NAME + STATUS
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // PET NAME
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: isLandscape ? 14.sp : 16.sp,
                      color: const Color(0xff1B1C1C),
                    ),
                  ),
                ),

                SizedBox(width: isLandscape ? 6.w : 4.w),

                // STATUS BADGE
                Container(
                  constraints: BoxConstraints(
                    minWidth: isLandscape ? 58.w : 65.w,
                    maxWidth: isLandscape ? 90.w : 100.w,
                  ),
                  height: isLandscape ? 22.h : 20.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 7.w : 7.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: statusColor,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        status,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isLandscape ? 9.sp : 10.sp,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // ==================================================
            // BREED
            // ==================================================
            Text(
              breed,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: isLandscape ? 10.sp : 12.sp,
                color: const Color(0xff57423D),
              ),
            ),

            SizedBox(height: isLandscape ? 5.h : 8.h),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return const Divider(height: 1, color: Color.fromARGB(73, 158, 158, 158));
  }

  // ============================================================
  // PROFILE TILE
  // ============================================================

  Widget profileTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 2.h),

      leading: Icon(icon, color: const Color(0xffA73927), size: 22.sp),

      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: const Color(0xff1B1C1C),
        ),
      ),

      trailing: Icon(
        Icons.arrow_forward_ios_sharp,
        color: Colors.grey,
        size: 17.sp,
      ),

      onTap: onTap,
    );
  }
}
