import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/app_state_provider.dart';
import '../services/navigation_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for user data
  final _nameController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _dailyCalorieGoalController = TextEditingController();
  final _dailyWaterGoalController = TextEditingController();

  // Controllers for daily updates
  final _todayWeightController = TextEditingController();
  final _waterIntakeController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isEditing = false;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final user = appState.currentUser;
    final todayLog = appState.todayLog;

    if (user != null) {
      _nameController.text = user.name;
      _currentWeightController.text = user.currentWeight.toString();
      _targetWeightController.text = user.targetWeight.toString();
      _heightController.text = user.height.toString();
      _ageController.text = user.age.toString();
      _dailyCalorieGoalController.text = user.dailyCalorieGoal.toString();
      _dailyWaterGoalController.text = user.dailyWaterGoal.toString();
      _selectedGender = user.gender;
      _profileImagePath = user.profileImagePath;
    }

    if (todayLog != null) {
      _waterIntakeController.text = todayLog.waterIntake.toString();
      if (todayLog.weight != null) {
        _todayWeightController.text = todayLog.weight.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _dailyCalorieGoalController.dispose();
    _dailyWaterGoalController.dispose();
    _todayWeightController.dispose();
    _waterIntakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
            ),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          if (appState.currentUser == null) {
            return _buildCreateProfileForm(appState);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Summary Card
                  _buildProfileSummaryCard(appState),
                  SizedBox(height: 24.h),

                  // Daily Updates Section
                  _buildDailyUpdatesSection(appState),
                  SizedBox(height: 24.h),

                  // Profile Details Section
                  if (_isEditing) _buildProfileDetailsForm(),

                  // BMI Information
                  _buildBMICard(appState),
                  SizedBox(height: 24.h),

                  // Goals Section
                  _buildGoalsSection(appState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateProfileForm(AppStateProvider appState) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Your Profile',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kanit',
              ),
            ),
            SizedBox(height: 24.h),
            _buildTextField('Name', _nameController, required: true),
            SizedBox(height: 16.h),
            _buildGenderSelector(),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                    child: _buildTextField('Age', _ageController,
                        isNumber: true, required: true)),
                SizedBox(width: 12.w),
                Expanded(
                    child: _buildTextField('Height (cm)', _heightController,
                        isNumber: true, required: true)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        'Current Weight (kg)', _currentWeightController,
                        isNumber: true, required: true)),
                SizedBox(width: 12.w),
                Expanded(
                    child: _buildTextField(
                        'Target Weight (kg)', _targetWeightController,
                        isNumber: true, required: true)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        'Daily Calorie Goal', _dailyCalorieGoalController,
                        isNumber: true, required: true)),
                SizedBox(width: 12.w),
                Expanded(
                    child: _buildTextField(
                        'Daily Water Goal (L)', _dailyWaterGoalController,
                        isNumber: true, required: true)),
              ],
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: appState.isLoading ? null : _createProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB71C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: appState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Create Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummaryCard(AppStateProvider appState) {
    final user = appState.currentUser!;
    final imagePath = _isEditing ? _profileImagePath : user.profileImagePath;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB71C), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          if (_isEditing)
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 40.r,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                    size: 40, color: Colors.white, Icons.add_photo_alternate),
              ),
            )
          else
            CircleAvatar(
              radius: 40.r,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage:
                  (imagePath != null && File(imagePath).existsSync())
                      ? FileImage(File(imagePath))
                      : null,
              child: (imagePath == null || !File(imagePath).existsSync())
                  ? Icon(Icons.person, size: 40.sp, color: Colors.white)
                  : null,
            ),
          SizedBox(height: 16.h),
          Text(
            user.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfileStat('Age', '${user.age}'),
              _buildProfileStat('Height', '${user.height.round()}cm'),
              _buildProfileStat('Weight', '${user.currentWeight.round()}kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
            fontFamily: 'Kanit',
          ),
        ),
      ],
    );
  }

  Widget _buildDailyUpdatesSection(AppStateProvider appState) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Color.fromARGB(239, 43, 175, 252)
            : const Color(0xFF38342C),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Updates',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
          ),
          SizedBox(height: 16.h),

          // Water Intake Update
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Water Intake (L)',
                  _waterIntakeController,
                  isNumber: true,
                ),
              ),
              SizedBox(width: 12.w),
              ElevatedButton(
                onPressed: _updateWaterIntake,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child:
                    const Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Weight Update
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Today\'s Weight (kg)',
                  _todayWeightController,
                  isNumber: true,
                ),
              ),
              SizedBox(width: 12.w),
              ElevatedButton(
                onPressed: _updateTodayWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child:
                    const Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsForm() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF38342C),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
          ),
          SizedBox(height: 16.h),
          _buildTextField('Name', _nameController, required: true),
          SizedBox(height: 12.h),
          _buildGenderSelector(),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _buildTextField('Age', _ageController,
                      isNumber: true, required: true)),
              SizedBox(width: 12.w),
              Expanded(
                  child: _buildTextField('Height (cm)', _heightController,
                      isNumber: true, required: true)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                      'Current Weight (kg)', _currentWeightController,
                      isNumber: true, required: true)),
              SizedBox(width: 12.w),
              Expanded(
                  child: _buildTextField(
                      'Target Weight (kg)', _targetWeightController,
                      isNumber: true, required: true)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                      'Daily Calorie Goal', _dailyCalorieGoalController,
                      isNumber: true, required: true)),
              SizedBox(width: 12.w),
              Expanded(
                  child: _buildTextField(
                      'Daily Water Goal (L)', _dailyWaterGoalController,
                      isNumber: true, required: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard(AppStateProvider appState) {
    final bmi = appState.currentBMI;
    final category = appState.bmiCategory;

    Color bmiColor = Colors.green;
    if (bmi < 18.5) {
      bmiColor = Colors.blue;
    } else if (bmi >= 25 && bmi < 30)
      bmiColor = Colors.orange;
    else if (bmi >= 30) bmiColor = Colors.red;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bmiColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: bmiColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.monitor_weight, color: bmiColor, size: 40.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Body Mass Index',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                  ),
                ),
                Text(
                  '${bmi.toStringAsFixed(1)} - $category',
                  style: TextStyle(
                    color: bmiColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(AppStateProvider appState) {
    final user = appState.currentUser!;
    final weightDiff = user.currentWeight - user.targetWeight;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.purpleAccent.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Goals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGoalItem(
                'Weight Goal',
                '${weightDiff > 0 ? '-' : '+'}${weightDiff.abs().toStringAsFixed(1)}kg',
                weightDiff > 0 ? 'to lose' : 'to gain',
              ),
              _buildGoalItem(
                'Daily Calories',
                '${user.dailyCalorieGoal.round()}',
                'kcal target',
              ),
              _buildGoalItem(
                'Daily Water',
                '${user.dailyWaterGoal}',
                'liters target',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String title, String value, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
            fontFamily: 'Kanit',
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10.sp,
            fontFamily: 'Kanit',
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(12.w),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              if (isNumber && double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title:
                    const Text('Male', style: TextStyle(color: Colors.white)),
                value: 'Male',
                groupValue: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value!),
                activeColor: const Color(0xFFFFB71C),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title:
                    const Text('Female', style: TextStyle(color: Colors.white)),
                value: 'Female',
                groupValue: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value!),
                activeColor: const Color(0xFFFFB71C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);

    await appState.createUser(
      name: _nameController.text.trim(),
      currentWeight: double.parse(_currentWeightController.text),
      targetWeight: double.parse(_targetWeightController.text),
      height: double.parse(_heightController.text),
      age: int.parse(_ageController.text),
      gender: _selectedGender,
      dailyCalorieGoal: double.parse(_dailyCalorieGoalController.text),
      dailyWaterGoal: double.parse(_dailyWaterGoalController.text),
      profileImagePath: _profileImagePath,
    );

    if (appState.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  //Image picker
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImagePath = picked.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final currentUser = appState.currentUser!;

    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      profileImagePath: _profileImagePath,
      currentWeight: double.parse(_currentWeightController.text),
      targetWeight: double.parse(_targetWeightController.text),
      height: double.parse(_heightController.text),
      age: int.parse(_ageController.text),
      gender: _selectedGender,
      dailyCalorieGoal: double.parse(_dailyCalorieGoalController.text),
      dailyWaterGoal: double.parse(_dailyWaterGoalController.text),
    );

    await appState.updateUser(updatedUser);

    if (appState.errorMessage == null) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _updateWaterIntake() async {
    final waterText = _waterIntakeController.text.trim();
    if (waterText.isEmpty) return;

    final water = double.tryParse(waterText);
    if (water == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid water amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await appState.updateWaterIntake(water);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Water intake updated!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _updateTodayWeight() async {
    final weightText = _todayWeightController.text.trim();
    if (weightText.isEmpty) return;

    final weight = double.tryParse(weightText);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await appState.updateTodayWeight(weight);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weight updated!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
