import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/meal_model.dart';
import '../services/navigation_service.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mealNameController = TextEditingController();
  MealType _selectedMealType = MealType.breakfast;
  bool _useAIEstimation = true;

  // Manual entry controllers
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _nutrientsController = TextEditingController();

  @override
  void dispose() {
    _mealNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _nutrientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Add Meal',
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Type Selection
                  _buildSectionTitle('Meal Type'),
                  SizedBox(height: 8.h),
                  _buildMealTypeSelector(),
                  SizedBox(height: 24.h),

                  // Meal Name Input
                  _buildSectionTitle('Meal Description'),
                  SizedBox(height: 8.h),
                  _buildMealNameInput(),
                  SizedBox(height: 24.h),

                  // AI Estimation Toggle
                  _buildAIToggle(),
                  SizedBox(height: 16.h),

                  // Manual Entry (if AI disabled)
                  if (!_useAIEstimation) ...[
                    _buildSectionTitle('Nutritional Information'),
                    SizedBox(height: 8.h),
                    _buildManualEntryFields(),
                    SizedBox(height: 24.h),
                  ],

                  // Add Meal Button
                  _buildAddMealButton(appState),
                  SizedBox(height: 16.h),

                  // Loading indicator
                  if (appState.isLoadingCalories)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Color(0xFFFFB71C)),
                          SizedBox(height: 8),
                          Text(
                            'Analyzing meal...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                  // Error message
                  if (appState.errorMessage != null)
                    Container(
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
                    ),
                ],
              ),
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
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        fontFamily: 'Kanit',
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.greenAccent.withOpacity(1)
            : const Color(0xFF38342C),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: MealType.values.map((type) {
          final isSelected = _selectedMealType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMealType = type),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFFFB71C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  type.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMealNameInput() {
    return TextFormField(
      controller: _mealNameController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'e.g., Rice and curry, String hoppers with dhal',
        hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.grey[400]),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.light
            ? Colors.purpleAccent.withOpacity(0.5)
            : Color(0xFF38342C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(16.w),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a meal description';
        }
        return null;
      },
      maxLines: 2,
    );
  }

  Widget _buildAIToggle() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.blue.withOpacity(0.7)
            : Color(0xFF38342C),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: _useAIEstimation ? const Color(0xFFFFB71C) : Colors.grey,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Calorie Estimation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Let AI estimate nutritional values',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _useAIEstimation,
            onChanged: (value) => setState(() => _useAIEstimation = value),
            activeColor: const Color(0xFFFFB71C),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntryFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildNutrientField(
                    'Calories', _caloriesController, 'kcal')),
            SizedBox(width: 12.w),
            Expanded(
                child: _buildNutrientField('Protein', _proteinController, 'g')),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
                child: _buildNutrientField('Carbs', _carbsController, 'g')),
            SizedBox(width: 12.w),
            Expanded(
                child: _buildNutrientField(
                    'Nutrients', _nutrientsController, 'g')),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientField(
      String label, TextEditingController controller, String unit) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        suffixText: unit,
        suffixStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF38342C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(12.w),
      ),
      validator: !_useAIEstimation
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              if (double.tryParse(value) == null) {
                return 'Invalid number';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildAddMealButton(AppStateProvider appState) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: appState.isLoadingCalories ? null : _addMeal,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB71C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Add Meal',
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

  Future<void> _addMeal() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);

    if (_useAIEstimation) {
      await appState.addMeal(
        name: _mealNameController.text.trim(),
        mealType: _selectedMealType,
      );
    } else {
      await appState.addMeal(
        name: _mealNameController.text.trim(),
        mealType: _selectedMealType,
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        nutrients: double.parse(_nutrientsController.text),
      );
    }

    if (appState.errorMessage == null) {
      // Success - clear form and show success message
      _mealNameController.clear();
      _caloriesController.clear();
      _proteinController.clear();
      _carbsController.clear();
      _nutrientsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
