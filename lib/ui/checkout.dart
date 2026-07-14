import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  int selectedStep = 1;
  int selectedPayment = 1;
  int selectedMethod = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back)),
        title: Text('Checkout', style: TextStyle(fontSize: 14.sp)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 150.w),
            child: Text(
              'PetLife',
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xffA73927),
              ),
            ),
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
                SizedBox(height: 15.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStep = 1;
                        });
                      },
                      child: CircleAvatar(
                        radius: 15.r,
                        backgroundColor:
                            selectedStep == 1
                                ? Color(0xffA73927)
                                : Color(0xff9A9791),
                        child: Text('1', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: 220.w,
                        child: Divider(color: Color(0xffDFC0BA)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStep = 2;
                        });
                      },
                      child: CircleAvatar(
                        radius: 15.r,
                        backgroundColor:
                            selectedStep == 2
                                ? Color(0xffA73927)
                                : Color(0xff9A9791),
                        child: Text('2', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          color:
                              selectedStep == 2
                                  ? Color(0xffA73927)
                                  : Color(0xff9A9791),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: Color(0xff1B1C1C),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Change',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: Color(0xff006971),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Container(
                  height: 120.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Color(0xffDFC0BA)),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20.w, bottom: 35.h),
                        child: Container(
                          height: 42.h,
                          width: 32.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Color(0xff93EEF9),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: Color(0xff006D76),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Padding(
                        padding: EdgeInsets.only(top: 15.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Home - Sarah Jenkins',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                            Text(
                              '42 Golden Retriever Lane, Apt 4B',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                color: Color(0xff57423D),
                              ),
                            ),
                            Text(
                              'Sunnyside, NY 11104',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                color: Color(0xff57423D),
                              ),
                            ),
                            Text(
                              '+1 (555) 123-4567',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                color: Color(0xff57423D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Delivery Method',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      color: Color(0xff1B1C1C),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPayment = 1;
                    });
                  },
                  child: Container(
                    height: 75.h,
                    width: 350.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color:
                          selectedPayment == 1
                              ? Color.fromARGB(32, 218, 212, 51)
                              : Colors.white,

                      border: Border.all(
                        color:
                            selectedPayment == 1
                                ? Color(0xffA73927)
                                : Color(0xffDFC0BA),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w, bottom: 5.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: Color(0xff57423D),
                          ),
                          // SizedBox(width: 15.w),
                          Padding(
                            padding: EdgeInsets.only(top: 10.h, right: 26.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Standard Shipping',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    color: Color(0xff1B1C1C),
                                  ),
                                ),
                                Text(
                                  'Arrives in 3-5 business days',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.sp,
                                    color: Color(0xff57423D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: Text(
                              'Free',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                color: Color(0xffA73927),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPayment = 2;
                    });
                  },
                  child: Container(
                    height: 75.h,
                    width: 350.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color:
                          selectedPayment == 2
                              ? Color.fromARGB(32, 218, 212, 51)
                              : Colors.white,
                      border: Border.all(
                        color:
                            selectedPayment == 2
                                ? Color(0xffA73927)
                                : Color(0xffDFC0BA),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.w, bottom: 5.h),
                          child: Icon(
                            Icons.flash_on_outlined,
                            color: Color(0xff57423D),
                            size: 30.sp,
                          ),
                        ),
                        // SizedBox(width: 10.w),
                        Padding(
                          padding: EdgeInsets.only(top: 10.h, right: 40.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Express Shipping',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: Color(0xff1B1C1C),
                                ),
                              ),
                              Text(
                                'Arrives tomorrow by 6PM',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  color: Color(0xff57423D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 15.w),
                          child: Text(
                            '\$12.99',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: Color(0xffA73927),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payment Method',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      color: Color(0xff1B1C1C),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMethod = 1;
                        });
                      },
                      child: Container(
                        height: 95.h,
                        width: 170.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          color:
                              selectedMethod == 1
                                  ? Color.fromARGB(32, 218, 212, 51)
                                  : Colors.white,
                          border: Border.all(
                            color:
                                selectedMethod == 1
                                    ? Color(0xffA73927)
                                    : Color(0xffDFC0BA),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_membership_outlined,
                              color: Color(0xff57423D),
                            ),
                            Text(
                              'Credit Card',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMethod = 2;
                        });
                      },
                      child: Container(
                        height: 95.h,
                        width: 170.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          color:
                              selectedMethod == 2
                                  ? Color.fromARGB(32, 218, 212, 51)
                                  : Colors.white,
                          border: Border.all(
                            color:
                                selectedMethod == 2
                                    ? Color(0xffA73927)
                                    : Color(0xffDFC0BA),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.apps_outlined,
                                  color: Color(0xff1B1C1C),
                                ),
                                Text(
                                  'Pay',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp,
                                    color: Color(0xff1B1C1C),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Apple Pay',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                if (selectedMethod == 1)
                  Container(
                    height: 175.h,
                    width: 350.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Color(0xffDFC0BA)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Card Number',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                                color: Color(0xff57423D),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xffF0EDED),
                              prefix: Icon(
                                Icons.credit_card,
                                color: Color(0xff57423D),
                              ),
                              hintText: '0000 0000 0000 0000',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expiry Date',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: Color(0xff57423D),
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    TextField(
                                      keyboardType: TextInputType.datetime,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Color(0xffF0EDED),
                                        hintText: 'MM/YY',
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 15.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CVV',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: Color(0xff57423D),
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    TextField(
                                      obscureText: true,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Color(0xffF0EDED),
                                        hintText: '*****',
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (selectedMethod == 2)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      'Apple Pay will be used during checkout.',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                SizedBox(height: 20.h),
                Container(
                  height: 210.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: Color(0xffEAE7E7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15.h),
                        Text(
                          'Order Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.sp,
                            color: Color(0xff1B1C1C),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Subtotal (3 items)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  color: Color(0xff57423D),
                                ),
                              ),
                            ),
                            Text(
                              '\$84.50',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                            SizedBox(height: 6.h),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Shipping',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  color: Color(0xff57423D),
                                ),
                              ),
                            ),
                            Text(
                              'Free',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: Color(0xff006971),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Tax',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  color: Color(0xff57423D),
                                ),
                              ),
                            ),
                            Text(
                              '\$6.76',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Divider(color: Color(0xffA73927)),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.sp,
                                  color: Color(0xff1B1C1C),
                                ),
                              ),
                            ),
                            Text(
                              '\$91.26',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20.sp,
                                color: Color(0xffA73927),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.lock_outline),
                    ),
                    Text(
                      'Secure SSL Encryption • PetLife Protection Guarantee',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: Color(0xff57423D),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: 350.w,
                  height: 56.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffA73927),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm Purchase',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
