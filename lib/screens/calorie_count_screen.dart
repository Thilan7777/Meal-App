import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/meal_model.dart';
import '../services/navigation_service.dart';

class CalorieCountScreen extends StatefulWidget {
  const CalorieCountScreen({super.key});

  @override
  State<CalorieCountScreen> createState() => _CalorieCountScreenState();
}

class _CalorieCountScreenState extends State<CalorieCountScreen> {
  final _mealNameController = TextEditingController();
  CalorieEstimate? _calorieEstimate;

  @override
  void dispose() {
    _mealNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Food Calorie Count',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationService.goHome(context),
        ),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Enter Meal Description'),
                SizedBox(height: 8.h),
                _buildMealNameInput(),
                SizedBox(height: 16.h),
                _buildEstimateButton(appState),
                SizedBox(height: 24.h),
                if (appState.isLoadingCalories)
                  const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFFB71C)))
                else if (_calorieEstimate != null)
                  _buildResultsCard(_calorieEstimate!),
                if (appState.errorMessage != null) _buildErrorWidget(appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        fontFamily: 'Kanit',
      ),
    );
  }

  Widget _buildMealNameInput() {
    return TextField(
      controller: _mealNameController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'e.g., 2 string hoppers, dhal curry, and sambol',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFF38342C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(16.w),
      ),
      maxLines: 3,
    );
  }

  Widget _buildEstimateButton(AppStateProvider appState) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: appState.isLoadingCalories ? null : _estimateCalories,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB71C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Estimate Calories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard(CalorieEstimate estimate) {
    return Card(
      color: const Color(0xFF38342C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimated Nutritional Value',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildNutrientRow('Calories', '${estimate.calories.round()} kcal'),
            _buildNutrientRow('Protein', '${estimate.protein.round()} g'),
            _buildNutrientRow('Carbs', '${estimate.carbs.round()} g'),
            _buildNutrientRow('Nutrients', '${estimate.nutrients.round()} g'),
            SizedBox(height: 12.h),
            Text(
              'Explanation:',
              style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            ),
            Text(
              estimate.explanation,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          Text(value,
              style: TextStyle(
                  color: const Color(0xFFFFB71C),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(AppStateProvider appState) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              appState.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => appState.clearError(),
          ),
        ],
      ),
    );
  }

  Future<void> _estimateCalories() async {
    if (_mealNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a meal description.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final estimate =
        await appState.estimateCalories(_mealNameController.text.trim());

    if (mounted) {
      setState(() {
        _calorieEstimate = estimate;
      });
    }
  }
}
