import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShippingAddressPage extends StatefulWidget {
  const ShippingAddressPage({super.key});

  @override
  State<ShippingAddressPage> createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
@override
void initState() {
  super.initState();
  _testAddressRead();
}

Future<void> _testAddressRead() async {
  final user = FirebaseAuth.instance.currentUser;

  print('================================');
  print('TESTING ADDRESS READ');
  print('UID: ${user?.uid}');
  print('================================');

  if (user == null) {
    print('USER IS NULL');
    return;
  }

  try {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .get();

    print('================================');
    print('ADDRESS READ SUCCESS');
    print('ADDRESS COUNT: ${result.docs.length}');
    print('================================');

    for (final doc in result.docs) {
      print('ADDRESS ID: ${doc.id}');
      print('ADDRESS DATA: ${doc.data()}');
    }
  } catch (e) {
    print('================================');
    print('ADDRESS READ ERROR: $e');
    print('================================');
  }
}
  String? selectedAddressId;

  @override
  Widget build(BuildContext context) {
   final user = _auth.currentUser;

debugPrint('==============================');
debugPrint('CURRENT USER UID: ${user?.uid}');
debugPrint('CURRENT USER EMAIL: ${user?.email}');
debugPrint('==============================');

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Shipping Addresses',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xffA73927),
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('addresses')
                  .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading addresses\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            final addresses = snapshot.data?.docs ?? [];

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAddressForm(context);
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Add New Address',
                        style: TextStyle(fontSize: 15.sp, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff006971),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  if (addresses.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 60.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 15.h),
                            Text(
                              'No shipping addresses',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Add an address for your orders',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final doc = addresses[index];

                          final data = doc.data() as Map<String, dynamic>;

                          return _addressCard(context, doc.id, data);
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _addressCard(
    BuildContext context,
    String addressId,
    Map<String, dynamic> data,
  ) {
    final bool isSelected = selectedAddressId == addressId;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAddressId = addressId;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isSelected ? const Color(0xffA73927) : const Color(0xffDFC0BA),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: addressId,
              groupValue: selectedAddressId,
              activeColor: const Color(0xffA73927),
              onChanged: (value) {
                setState(() {
                  selectedAddressId = value;
                });
              },
            ),

            SizedBox(width: 5.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: const Color(0xffA73927),
                        size: 20.sp,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          data['name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    data['phone'] ?? '',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  ),

                  SizedBox(height: 5.h),

                  Text(
                    data['address'] ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xff57423D),
                    ),
                  ),

                  SizedBox(height: 5.h),

                  Text(
                    '${data['city'] ?? ''}, '
                    '${data['state'] ?? ''} - '
                    '${data['pincode'] ?? ''}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xff57423D),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _showAddressForm(
                            context,
                            addressId: addressId,
                            existingData: data,
                          );
                        },
                        icon: Icon(Icons.edit, size: 17.sp),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xff006971),
                        ),
                      ),

                      TextButton.icon(
                        onPressed: () {
                          _deleteAddress(addressId);
                        },
                        icon: Icon(Icons.delete_outline, size: 17.sp),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressForm(
    BuildContext context, {
    String? addressId,
    Map<String, dynamic>? existingData,
  }) {
    final nameController = TextEditingController(
      text: existingData?['name'] ?? '',
    );

    final phoneController = TextEditingController(
      text: existingData?['phone'] ?? '',
    );

    final addressController = TextEditingController(
      text: existingData?['address'] ?? '',
    );

    final cityController = TextEditingController(
      text: existingData?['city'] ?? '',
    );

    final stateController = TextEditingController(
      text: existingData?['state'] ?? '',
    );

    final pincodeController = TextEditingController(
      text: existingData?['pincode'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 25.w,
            right: 25.w,
            top: 20.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                Text(
                  addressId == null ? 'Add New Address' : 'Edit Address',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20.h),

                _textField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                ),

                SizedBox(height: 12.h),

                _textField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 12.h),

                _textField(
                  controller: addressController,
                  label: 'Full Address',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),

                SizedBox(height: 12.h),

                _textField(
                  controller: cityController,
                  label: 'City',
                  icon: Icons.location_city,
                ),

                SizedBox(height: 12.h),

                _textField(
                  controller: stateController,
                  label: 'State',
                  icon: Icons.map_outlined,
                ),

                SizedBox(height: 12.h),

                _textField(
                  controller: pincodeController,
                  label: 'Pincode',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 25.h),

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty ||
                          phoneController.text.trim().isEmpty ||
                          addressController.text.trim().isEmpty ||
                          cityController.text.trim().isEmpty ||
                          stateController.text.trim().isEmpty ||
                          pincodeController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                          ),
                        );
                        return;
                      }

                      final user = _auth.currentUser;

                      if (user == null) return;

                      final addressData = {
                        'name': nameController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'address': addressController.text.trim(),
                        'city': cityController.text.trim(),
                        'state': stateController.text.trim(),
                        'pincode': pincodeController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      };

                      try {
                        if (addressId == null) {
                          await _firestore
                              .collection('users')
                              .doc(user.uid)
                              .collection('addresses')
                              .add(addressData);
                        } else {
                          await _firestore
                              .collection('users')
                              .doc(user.uid)
                              .collection('addresses')
                              .doc(addressId)
                              .update(addressData);
                        }

                        if (context.mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                addressId == null
                                    ? 'Address added successfully'
                                    : 'Address updated successfully',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save address: $e'),
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
                      addressId == null ? 'Save Address' : 'Update Address',
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xffA73927)),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xffA73927)),
        ),
      ),
    );
  }

  Future<void> _deleteAddress(String addressId) async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(addressId)
          .delete();

      if (selectedAddressId == addressId) {
        setState(() {
          selectedAddressId = null;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Address deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete address: $e')));
      }
    }
  }
}
