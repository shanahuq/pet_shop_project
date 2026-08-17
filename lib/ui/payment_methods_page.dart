import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  String? selectedMethod;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'PhonePe',
      'subtitle': 'Pay using PhonePe UPI',
      'icon': Icons.phone_android,
      'color': const Color(0xff5F259F),
    },
    {
      'name': 'Google Pay',
      'subtitle': 'Pay using Google Pay',
      'icon': Icons.g_mobiledata,
      'color': Colors.black,
    },
    {
      'name': 'Paytm',
      'subtitle': 'Pay using Paytm UPI',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xff00AEEF),
    },
    {
      'name': 'BHIM',
      'subtitle': 'Pay using BHIM UPI',
      'icon': Icons.currency_rupee,
      'color': const Color(0xff006971),
    },
    {
      'name': 'Amazon Pay',
      'subtitle': 'Pay using Amazon Pay UPI',
      'icon': Icons.shopping_cart_outlined,
      'color': Colors.orange,
    },
    {
      'name': 'Cash On Delivery',
      'subtitle': 'Pay using Cash On Delivery',
      'icon': Icons.payment_outlined,
      'color': Colors.brown,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Payment Methods',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: const Color(0xffA73927),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              Text(
                'Choose your payment method',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff1B1C1C),
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                'Select a UPI app to make your payment',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xff57423D),
                ),
              ),

              SizedBox(height: 25.h),

              Expanded(
                child: ListView.builder(
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    final payment = paymentMethods[index];

                    final bool isSelected = selectedMethod == payment['name'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMethod = payment['name'];
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
                                isSelected
                                    ? const Color(0xff006971)
                                    : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // PAYMENT APP ICON
                            Container(
                              height: 55.h,
                              width: 55.w,
                              decoration: BoxDecoration(
                                color: payment['color'].withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                payment['icon'],
                                color: payment['color'],
                                size: 30.sp,
                              ),
                            ),

                            SizedBox(width: 15.w),

                            // PAYMENT DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payment['name'],
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  SizedBox(height: 5.h),

                                  Text(
                                    payment['subtitle'],
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // RADIO BUTTON
                            Radio<String>(
                              value: payment['name'],
                              groupValue: selectedMethod,
                              activeColor: const Color(0xff006971),
                              onChanged: (value) {
                                setState(() {
                                  selectedMethod = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 10.h),

              // CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  onPressed:
                      selectedMethod == null
                          ? null
                          : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedMethod selected'),
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffA73927),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
