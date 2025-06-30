import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_app/custom_widgets/bar_column.dart';
import 'package:meal_app/custom_widgets/custom_widgets.dart';
import 'package:meal_app/providers/app_state_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppStateProvider>(context, listen: false).initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        if (appState.isLoading && appState.currentUser == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (appState.currentUser == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please create a user profile to continue.',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () => context.go('/profile'),
                    child: const Text('Create Profile'),
                  )
                ],
              ),
            ),
          );
        }

        final user = appState.currentUser!;
        final todayLog = appState.todayLog;
        final weeklyData = appState.weeklyCalorieData;
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: Drawer(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    context.go('/profile');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Weekly Summary'),
                  onTap: () {
                    context.go('/stats');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_drink),
                  title: const Text('Water Tracker'),
                  onTap: () {
                    // TODO: Implement Water Tracker page
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.import_export),
                  title: const Text('Export Data'),
                  onTap: () {
                    // TODO: Implement Export Data functionality
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 100,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: CustomWidgets(
                    imageHeight: 37.h,
                    imageWidth: 37.w,
                    height: 37.h,
                    width: 42.w,
                    imagePath: 'assets/Menu.png',
                    containerColor: const Color.fromARGB(158, 150, 139, 117),
                    boxShape: BoxShape.rectangle,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.only(left: 20.w, top: 0.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    color: const Color(0xFFFFB71C),
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
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: CustomWidgets(
                    imagePath: 'assets/Settings.png',
                    containerColor: const Color.fromARGB(158, 150, 139, 117),
                    boxShape: BoxShape.rectangle,
                    imageHeight: 37.h,
                    imageWidth: 37.w,
                    height: 37.h,
                    width: 42.w,
                  ),
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => appState.refreshAllData(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomContainer(
                      containerColor: const Color(0xFFFFB71C),
                      width: 380.w,
                      height: 128.h,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 10.h),
                          CustomContainer(
                            containerColor: const Color(0xFF38342C),
                            width: 300.w,
                            height: 29.h,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${todayLog?.totalCalories.round() ?? 0} Calories",
                                    style: TextStyle(
                                      fontFamily: 'Kanit',
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Image.asset('assets/Fire.png')
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildNutrientStat(
                                  'assets/Protein.png',
                                  '${todayLog?.totalProtein.round() ?? 0}g',
                                  'Protein'),
                              SizedBox(width: 15.w),
                              _buildNutrientStat(
                                  'assets/Carbs.png',
                                  '${todayLog?.totalCarbs.round() ?? 0}g',
                                  'Carbs'),
                              SizedBox(width: 15.w),
                              _buildNutrientStat(
                                  'assets/Carrot.png',
                                  '${todayLog?.totalNutrients.round() ?? 0}g',
                                  'Nutrients'),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: DailyIntakeIndicator(
                                    percentage: appState.todayCalorieProgress),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () {
                        context.go('/stats');
                      },
                      child: CustomContainer(
                        containerColor: Colors.blueAccent,
                        width: 380.w,
                        height: 122.h,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 38,
                              top: 28,
                              bottom: 18,
                              child: Container(width: 2, color: Colors.white),
                            ),
                            Positioned(
                              left: 38,
                              right: 12,
                              bottom: 18,
                              child: Container(height: 2, color: Colors.white),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                const Center(
                                  child: Text(
                                    "Weekly Overall Calorie Stat",
                                    style: TextStyle(
                                        fontFamily: "Kanit",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(left: 10, bottom: 15),
                                      child: Column(
                                        children: [
                                          Text("3200",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10)),
                                          SizedBox(height: 5),
                                          Text("2400",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10)),
                                          SizedBox(height: 5),
                                          Text("1600",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10)),
                                          SizedBox(height: 5),
                                          Text("800",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10)),
                                          SizedBox(height: 5),
                                          Text("0",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(7, (index) {
                                          final day = weekdays[index];
                                          final calories = weeklyData[day] ?? 0;
                                          final maxCalories =
                                              user.dailyCalorieGoal > 0
                                                  ? user.dailyCalorieGoal
                                                  : 3200;
                                          return barColumn(
                                            day: day,
                                            fill: (calories / maxCalories)
                                                .clamp(0.0, 1.0),
                                          );
                                        }),
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
                  ),
                  SizedBox(height: 16.h),
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
                                const Padding(
                                  padding: EdgeInsets.only(top: 5, left: 10),
                                  child: Text("Progress",
                                      style: TextStyle(
                                          fontFamily: "Kanit",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                SizedBox(height: 5.h),
                                _buildProgressRow("assets/Scale.png", 'Weight',
                                    '${user.currentWeight} -> ${user.targetWeight}'),
                                _buildProgressRow(
                                    "assets/Bottle of Water.png",
                                    'Water Intake',
                                    '${todayLog?.waterIntake ?? 0} L'),
                                _buildProgressRow(
                                    "assets/BMI.png",
                                    'Body Mass Index',
                                    user.bmi.toStringAsFixed(1)),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildSmallButton("Add Weight\nGoal",
                                          () => context.go('/profile')),
                                      SizedBox(width: 12.w),
                                      _buildSmallButton("Add Water\nLevel",
                                          () => context.go('/profile')),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: CustomContainer(
                            containerColor:
                                const Color.fromARGB(255, 144, 255, 18),
                            height: 129.h,
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0, left: 14),
                                  child: Text("Today Meal Summary",
                                      style: TextStyle(
                                          fontFamily: "Kanit",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset("assets/breakfast.png",
                                          width: 36, height: 54),
                                      Image.asset("assets/lunch.png",
                                          width: 36, height: 54),
                                      Image.asset("assets/dinner.png",
                                          width: 36, height: 54),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildXtraSmallButton("Breakfast",
                                          () => context.go('/add-meal')),
                                      _buildXtraSmallButton("Lunch",
                                          () => context.go('/add-meal')),
                                      _buildXtraSmallButton("Dinner",
                                          () => context.go('/add-meal')),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _buildLargeButton(
                      "Food Calorie Count", () => context.go('/calorie-count')),
                  _buildLargeButton("Suggest Meal Plan",
                      () => context.go('/meal-suggestions')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutrientStat(String imagePath, String text, String label) {
    return Column(
      children: [
        CustomWidgets(
          imagePath: imagePath,
          text: text,
          imageHeight: 15,
          imageWidth: 15,
          width: 55,
          height: 60,
          containerColor: const Color(0xFF38342C),
          boxShape: BoxShape.rectangle,
        ),
        SizedBox(height: 2.h),
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildProgressRow(String imagePath, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Row(
        children: [
          Image.asset(imagePath),
          SizedBox(width: 8.w),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontFamily: "Kanit",
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontFamily: "Kanit",
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildXtraSmallButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 50,
      height: 29,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: const Color.fromARGB(255, 233, 232, 232),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
              fontSize: 8,
              fontFamily: "Kanit",
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildSmallButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 59,
      height: 29,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: const Color.fromARGB(255, 233, 232, 232),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
              fontSize: 8,
              fontFamily: "Kanit",
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildLargeButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: CustomContainer(
        containerColor: const Color(0xFFFFB71C),
        width: 380.w,
        height: 51.h,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            splashColor: const Color.fromARGB(103, 0, 0, 0),
            child: Center(
              child: Text(
                text,
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
    );
  }
}
