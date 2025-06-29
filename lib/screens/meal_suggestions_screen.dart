import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/meal_model.dart';
import '../services/navigation_service.dart';

class MealSuggestionsScreen extends StatefulWidget {
  const MealSuggestionsScreen({super.key});

  @override
  State<MealSuggestionsScreen> createState() => _MealSuggestionsScreenState();
}

class _MealSuggestionsScreenState extends State<MealSuggestionsScreen> {
  MealType _selectedMealType = MealType.breakfast;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Meal Suggestions',
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
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Select Meal Type'),
                SizedBox(height: 8.h),
                _buildMealTypeSelector(),
                SizedBox(height: 16.h),
                _buildGenerateButton(appState),
                SizedBox(height: 24.h),
                if (appState.isLoadingSuggestions)
                  const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFFB71C)))
                else if (appState.mealSuggestions.isNotEmpty)
                  Expanded(child: _buildSuggestionsList(appState))
                else
                  const Center(
                    child: Text(
                      'No suggestions yet. Generate some!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
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

  Widget _buildMealTypeSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF38342C),
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

  Widget _buildGenerateButton(AppStateProvider appState) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: appState.isLoadingSuggestions
            ? null
            : () => appState.generateMealSuggestions(_selectedMealType),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB71C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Generate Suggestions',
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

  Widget _buildSuggestionsList(AppStateProvider appState) {
    return ListView.builder(
      itemCount: appState.mealSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = appState.mealSuggestions[index];
        return Card(
          color: const Color(0xFF38342C),
          margin: EdgeInsets.symmetric(vertical: 8.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${suggestion.estimatedCalories.round()} kcal',
                  style: TextStyle(
                    color: const Color(0xFFFFB71C),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildDetailRow(
                    'Ingredients:', suggestion.ingredients.join(', ')),
                _buildDetailRow('Preparation:', suggestion.preparation),
                _buildDetailRow('Reasoning:', suggestion.reasoning),
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      appState.addMealFromSuggestion(suggestion);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Meal added from suggestion!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF968B75),
                    ),
                    child: const Text('Add to My Meals'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
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
}
