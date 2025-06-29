import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meal_app/custom_widgets/bar_column.dart';
import 'package:meal_app/custom_widgets/custom_widgets.dart';
import 'package:meal_app/services/navigation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Colors.black,
          title: Row(
            children: [
              CustomWidgets(
                imageHeight: 37.h,
                imageWidth: 37.w,
                height: 37.h,
                width: 42.w,
                imagePath: 'assets/Menu.png',
                containerColor: Color(0xFF968B75),
                boxShape: BoxShape.rectangle,
              ),
              Spacer(), // reduce width
              Container(
                padding: EdgeInsets.only(left: 20.w, top: 0.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color: Color(0xFFFFB71C),
                ),
                height: 40.h,
                width: 162.w,
                child: Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "CalorieCam",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w400,
                          fontSize: 24.sp),
                    ),
                  ),
                ),
              ),
              Spacer(), // reduce width
              CustomWidgets(
                imagePath: 'assets/Settings.png',
                containerColor: Color(0xFF968B75),
                boxShape: BoxShape.rectangle,
                imageHeight: 37.h,
                imageWidth: 37.w,
                height: 37.h,
                width: 42.w,
              ),
            ],
          ),
        ),
//Making the Body section.............

        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 16),
              child: CustomContainer(
                containerColor: Color(0xFFFFB71C),
                width: 380.w,
                height: 128.h,
                child: ClipRect(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 10.h,
                      ),
                      CustomContainer(
                        containerColor: Color(0xFF38342C),
                        width: 300.w,
                        height: 29.h,
                        child: Padding(
                          padding: EdgeInsets.only(left: 30.w),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              children: [
                                Text(
                                  "1750 Calories",
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.w,
                                ),
                                Image.asset('assets/Fire.png')
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 38.w),
                            child: Column(
                              children: [
                                CustomWidgets(
                                    imagePath: 'assets/Protein.png',
                                    text: '120g',
                                    imageHeight: 15,
                                    imageWidth: 15,
                                    width: 55,
                                    alignment: Alignment(0, -0.4),
                                    height: 60,
                                    containerColor: Color(0xFF38342C),
                                    boxShape: BoxShape.rectangle),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'Protein',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 15.w,
                          ),
                          Column(
                            children: [
                              CustomWidgets(
                                  imagePath: 'assets/Carbs.png',
                                  text: '50g',
                                  imageHeight: 15,
                                  imageWidth: 15,
                                  width: 55,
                                  height: 60,
                                  alignment: Alignment(0, -0.6),
                                  containerColor: Color(0xFF38342C),
                                  progressColor:
                                      const Color.fromARGB(255, 144, 255, 18),
                                  boxShape: BoxShape.rectangle),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                'Carbs',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 15.w,
                          ),
                          Column(
                            children: [
                              CustomWidgets(
                                imagePath: 'assets/Carrot.png',
                                text: '8g',
                                imageHeight: 15,
                                imageWidth: 15,
                                width: 55,
                                height: 60,
                                progressColor:
                                    const Color.fromARGB(255, 240, 2, 168),
                                containerColor: Color(0xFF38342C),
                                boxShape: BoxShape.rectangle,
                                alignment: Alignment(0, -0.6),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                'Nutrients',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          //Progress indicator UI
                          Padding(
                            padding: const EdgeInsets.only(left: 20, bottom: 0),
                            child: DailyIntakeIndicator(percentage: 0.7),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            //blue color container.............
            Padding(
              padding: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 16),
              child: CustomContainer(
                containerColor: Colors.blueAccent,
                width: 380.w,
                height: 122.h,
                child: Stack(
                  children: [
                    // Y-axis (vertical white line)
                    Positioned(
                      left: 38, // aligns with Y-axis labels
                      top: 28,
                      bottom: 18,
                      child: Container(
                        width: 2,
                        color: Colors.white,
                      ),
                    ),
                    // X-axis (horizontal white line)
                    Positioned(
                      left: 38,
                      right: 12,
                      bottom: 18,
                      child: Container(
                        height: 2,
                        color: Colors.white,
                      ),
                    ),
                    // Chart content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2),
                        Center(
                          child: Text(
                            "Weekly Overall Calorie Stat",
                            style: TextStyle(
                              fontFamily: "Kanit",
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Y-axis labels
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 15),
                              child: Column(
                                children: [
                                  Text("3200",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                  SizedBox(height: 5),
                                  Text("2400",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                  SizedBox(height: 5),
                                  Text("1600",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                  SizedBox(height: 5),
                                  Text("800",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                  SizedBox(height: 5),
                                  Text("0",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            // Bar chart
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  barColumn(day: "Mon", fill: 0.7),
                                  barColumn(day: "Tue", fill: 0.5),
                                  barColumn(day: "Wed", fill: 0.8),
                                  barColumn(day: "Thu", fill: 0.4),
                                  barColumn(day: "Fri", fill: 1.0),
                                  barColumn(day: "Sat", fill: 0.75),
                                  barColumn(day: "Sun", fill: 0.65),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //purple container
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: CustomContainer(
                      containerColor: Colors.purpleAccent,
                      height: 129.h,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, left: 55),
                                child: Text("Progress",
                                    style: TextStyle(
                                        fontFamily: "Kanit",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Row(
                              children: [
                                Image.asset("assets/Scale.png"),
                                Spacer(
                                  flex: 10,
                                ),
                                Text(
                                  'Weight',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Kanit",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Spacer(),
                                Text("90Kg",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "Kanit",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Icon(
                                    color: Colors.white,
                                    Icons.arrow_right_alt_rounded),
                                Spacer(),
                                Text("70Kg",
                                    style: TextStyle(
                                        fontFamily: "Kanit",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Row(
                              children: [
                                Image.asset("assets/Bottle of Water.png"),
                                Spacer(),
                                Text(
                                  'Water Intake',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Kanit",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Spacer(),
                                Text("3 Litres",
                                    style: TextStyle(
                                        fontFamily: "Kanit",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 7, right: 8),
                            child: Row(
                              children: [
                                Image.asset("assets/BMI.png"),
                                Spacer(),
                                Text(
                                  'Body Mass Index',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Kanit",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Spacer(),
                                Text("20.5",
                                    style: TextStyle(
                                        fontFamily: "Kanit",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                          //Purple Container Buttons
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 18, top: 12),
                                child: SizedBox(
                                  width: 59,
                                  height: 29,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Color.fromARGB(
                                              255, 233, 232, 232)),
                                      onPressed: () {},
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        "Add weight\nGoal",
                                        style: TextStyle(
                                            fontSize: 8,
                                            fontFamily: "Kanit",
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                      )),
                                ),
                              ),
                              //water level button
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 12),
                                child: SizedBox(
                                  width: 59,
                                  height: 29,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Color.fromARGB(
                                              255, 233, 232, 232)),
                                      onPressed: () {},
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        "Add Today Water\nLevel",
                                        style: TextStyle(
                                            fontSize: 8,
                                            fontFamily: "Kanit",
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                      )),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                //green container
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: CustomContainer(
                      containerColor: const Color.fromARGB(255, 144, 255, 18),
                      height: 129.h,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5.0, left: 14),
                                child: Text("Today Meal Summory",
                                    style: TextStyle(
                                        fontFamily: "Kanit",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              //images of meals

                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(
                                    width: 36,
                                    height: 54,
                                    "assets/breakfast.png"),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/lunch.png"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/dinner.png"),
                              ),
                            ],
                          ),
                          //buttons green container
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 5),
                                child: SizedBox(
                                  width: 42,
                                  height: 29,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Color.fromARGB(
                                              255, 233, 232, 232)),
                                      onPressed: () {},
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        "Breakfast",
                                        style: TextStyle(
                                            fontSize: 8,
                                            fontFamily: "Kanit",
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black),
                                      )),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, top: 5, right: 5),
                                child: SizedBox(
                                  width: 42,
                                  height: 29,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Color.fromARGB(
                                              255, 233, 232, 232)),
                                      onPressed: () {},
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        "Lunch",
                                        style: TextStyle(
                                            fontSize: 8,
                                            fontFamily: "Kanit",
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black),
                                      )),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 5),
                                child: SizedBox(
                                  width: 42,
                                  height: 29,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Color.fromARGB(
                                              255, 233, 232, 232)),
                                      onPressed: () {},
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        "Dinner",
                                        style: TextStyle(
                                            fontSize: 8,
                                            fontFamily: "Kanit",
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black),
                                      )),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            //button 1
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: CustomContainer(
                containerColor: Color(0xFFFFB71C),
                width: 380.w,
                height: 51.h,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(14),
                    splashColor: Color.fromARGB(103, 0, 0, 0),
                    child: Center(
                      child: Text(
                        "Food Calaorie Count",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //button 2
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomContainer(
                  containerColor: Color(0xFFFFB71C),
                  width: 380.w,
                  height: 51.h,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      splashColor: Color(0x33000000),
                      onTap: () {
                        //button action
                      },
                      child: Center(
                        child: Text(
                          "Suggest Meal Plan",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  )),
            ),
          ],
        ));
  }
}
