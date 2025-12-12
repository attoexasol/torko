import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class LocationOnboardingView extends StatefulWidget {
  const LocationOnboardingView({super.key});

  @override
  State<LocationOnboardingView> createState() => _LocationOnboardingViewState();
}

class _LocationOnboardingViewState extends State<LocationOnboardingView> {
  final appController = Get.find<AppController>();
  
  String step = 'division'; // 'division', 'district', 'upazila'
  Map<String, dynamic>? selectedDivision;
  Map<String, dynamic>? selectedDistrict;
  String? selectedUpazila;
  String searchQuery = '';
  
  // Bangladesh divisions data
  final List<Map<String, dynamic>> divisionsData = [
    {
      'id': 'dhaka',
      'nameBn': 'ঢাকা',
      'nameEn': 'Dhaka',
      'districts': [
        {'id': 'dhaka', 'nameBn': 'ঢাকা', 'nameEn': 'Dhaka', 'upazilas': ['ধানমন্ডি', 'গুলশান', 'মিরপুর', 'উত্তরা', 'মোহাম্মদপুর', 'বনানী']},
        {'id': 'gazipur', 'nameBn': 'গাজীপুর', 'nameEn': 'Gazipur', 'upazilas': ['গাজীপুর সদর', 'কালিয়াকৈর', 'কাপাসিয়া', 'শ্রীপুর', 'টঙ্গী']},
        {'id': 'narayanganj', 'nameBn': 'নারায়ণগঞ্জ', 'nameEn': 'Narayanganj', 'upazilas': ['নারায়ণগঞ্জ সদর', 'বন্দর', 'রূপগঞ্জ', 'সোনারগাঁও']},
      ],
    },
    {
      'id': 'chittagong',
      'nameBn': 'চট্টগ্রাম',
      'nameEn': 'Chittagong',
      'districts': [
        {'id': 'chittagong', 'nameBn': 'চট্টগ্রাম', 'nameEn': 'Chittagong', 'upazilas': ['পাহাড়তলী', 'কোতোয়ালী', 'পাঁচলাইশ', 'আগ্রাবাদ']},
        {'id': 'coxsbazar', 'nameBn': 'কক্সবাজার', 'nameEn': "Cox's Bazar", 'upazilas': ['কক্সবাজার সদর', 'চকরিয়া', 'রামু', 'উখিয়া', 'টেকনাফ']},
      ],
    },
    {
      'id': 'sylhet',
      'nameBn': 'সিলেট',
      'nameEn': 'Sylhet',
      'districts': [
        {'id': 'sylhet', 'nameBn': 'সিলেট', 'nameEn': 'Sylhet', 'upazilas': ['সিলেট সদর', 'জকিগঞ্জ', 'কানাইঘাট', 'বিয়ানীবাজার']},
      ],
    },
    {
      'id': 'khulna',
      'nameBn': 'খুলনা',
      'nameEn': 'Khulna',
      'districts': [
        {'id': 'khulna', 'nameBn': 'খুলনা', 'nameEn': 'Khulna', 'upazilas': ['খুলনা সদর', 'ডুমুরিয়া', 'ফুলতলা', 'দিঘলিয়া']},
      ],
    },
    {
      'id': 'rajshahi',
      'nameBn': 'রাজশাহী',
      'nameEn': 'Rajshahi',
      'districts': [
        {'id': 'rajshahi', 'nameBn': 'রাজশাহী', 'nameEn': 'Rajshahi', 'upazilas': ['রাজশাহী সদর', 'বোয়ালিয়া', 'মতিহার', 'শাহ মখদুম']},
      ],
    },
    {
      'id': 'barisal',
      'nameBn': 'বরিশাল',
      'nameEn': 'Barisal',
      'districts': [
        {'id': 'barisal', 'nameBn': 'বরিশাল', 'nameEn': 'Barisal', 'upazilas': ['বরিশাল সদর', 'বাবুগঞ্জ', 'বাকেরগঞ্জ', 'উজিরপুর']},
      ],
    },
    {
      'id': 'rangpur',
      'nameBn': 'রংপুর',
      'nameEn': 'Rangpur',
      'districts': [
        {'id': 'rangpur', 'nameBn': 'রংপুর', 'nameEn': 'Rangpur', 'upazilas': ['রংপুর সদর', 'মিঠাপুকুর', 'বদরগঞ্জ', 'গঙ্গাচড়া']},
      ],
    },
    {
      'id': 'mymensingh',
      'nameBn': 'ময়মনসিংহ',
      'nameEn': 'Mymensingh',
      'districts': [
        {'id': 'mymensingh', 'nameBn': 'ময়মনসিংহ', 'nameEn': 'Mymensingh', 'upazilas': ['ময়মনসিংহ সদর', 'মুক্তাগাছা', 'গৌরীপুর', 'ভালুকা']},
      ],
    },
  ];

  bool get isFormValid => selectedDivision != null && selectedDistrict != null && selectedUpazila != null;

  Future<void> handleComplete() async {
    if (isFormValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('torko_user_location', '''
        {"division": "${selectedDivision!['nameEn']}", "district": "${selectedDistrict!['nameEn']}", "upazila": "$selectedUpazila"}
      ''');
      Get.offNamed(AppRoutes.welcomeProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      
      return Scaffold(
        backgroundColor: isDark 
            ? AppColors.darkBackground 
            : const Color(0xFFF0FDF4),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == AppLanguage.bn ? 'আপনার এলাকা নির্বাচন করুন' : 'Select Your Location',
                      style: TextStyle(
                        color: isDark ? AppColors.lightSecondary : const Color(0xFF166534),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      language == AppLanguage.bn 
                          ? 'স্থানীয় আপডেট পেতে আপনার পছন্দের এলাকা বেছে নিন' 
                          : 'Choose your preferred area to get local updates',
                      style: TextStyle(
                        color: isDark ? AppColors.lightSecondary.withValues(alpha: 0.7) : const Color(0xFF4d7c0f),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      language == AppLanguage.bn ? '৮ বিভাগ • ৬৪ জেলা • ৪৯৫ উপজেলা' : '8 Divisions • 64 Districts • 495 Upazilas',
                      style: TextStyle(
                        color: isDark ? AppColors.lightPrimary : const Color(0xFF166534),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildProgressBar(true, isDark),
                    const SizedBox(width: 8),
                    _buildProgressBar(step == 'district' || step == 'upazila', isDark),
                    const SizedBox(width: 8),
                    _buildProgressBar(step == 'upazila', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Breadcrumb
              if (selectedDivision != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (step != 'division')
                        GestureDetector(
                          onTap: () => setState(() {
                            step = 'division';
                            selectedDistrict = null;
                            selectedUpazila = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF0d3a4a) : Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Text(
                              language == AppLanguage.bn ? selectedDivision!['nameBn'] : selectedDivision!['nameEn'],
                              style: TextStyle(
                                color: isDark ? AppColors.lightSecondary : const Color(0xFF166534),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      if (selectedDistrict != null) ...[
                        Icon(Icons.chevron_right, size: 12, color: isDark ? AppColors.lightSecondary.withValues(alpha: 0.5) : const Color(0xFF4d7c0f)),
                        GestureDetector(
                          onTap: () => setState(() {
                            step = 'district';
                            selectedUpazila = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              language == AppLanguage.bn ? selectedDistrict!['nameBn'] : selectedDistrict!['nameEn'],
                              style: TextStyle(
                                color: isDark ? AppColors.lightSecondary : const Color(0xFF166534),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (selectedUpazila != null) ...[
                        Icon(Icons.chevron_right, size: 12, color: isDark ? AppColors.lightSecondary.withValues(alpha: 0.5) : const Color(0xFF4d7c0f)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedUpazila!,
                            style: TextStyle(
                              color: isDark ? AppColors.lightSecondary : const Color(0xFF166534),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildStepContent(isDark, language),
                ),
              ),
              
              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: isFormValid ? handleComplete : null,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isFormValid
                              ? (isDark ? const Color(0xFF0d3a4a) : null)
                              : (isDark ? const Color(0xFF0a2f3d) : Colors.grey[300]),
                          gradient: isFormValid && !isDark
                              ? const LinearGradient(colors: [Color(0xFFdc2626), Color(0xFF166534)])
                              : null,
                          borderRadius: BorderRadius.circular(25),
                          border: isFormValid && isDark
                              ? Border.all(color: AppColors.lightPrimary, width: 2)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              language == AppLanguage.bn ? 'এগিয়ে যান' : 'Continue',
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Get.offNamed(AppRoutes.welcomeProfile),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFF166534).withValues(alpha: 0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            language == AppLanguage.bn ? 'পরে পরিবর্তন করুন' : 'Change Later',
                            style: TextStyle(
                              color: isDark ? AppColors.lightSecondary : const Color(0xFF166534),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProgressBar(bool active, bool isDark) {
    return Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: active
              ? (isDark ? AppColors.lightPrimary : const Color(0xFF166534))
              : (isDark ? const Color(0xFF0a2f3d) : const Color(0xFF166534).withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isDark, AppLanguage language) {
    if (step == 'division') {
      return _buildDivisionGrid(isDark, language);
    } else if (step == 'district') {
      return _buildDistrictGrid(isDark, language);
    } else {
      return _buildUpazilaList(isDark);
    }
  }

  Widget _buildDivisionGrid(bool isDark, AppLanguage language) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: divisionsData.length,
      itemBuilder: (context, index) {
        final division = divisionsData[index];
        final isSelected = selectedDivision?['id'] == division['id'];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDivision = division;
              selectedDistrict = null;
              selectedUpazila = null;
              step = 'district';
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0a2f3d) : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColors.lightPrimary : const Color(0xFFdc2626))
                    : (isDark ? const Color(0xFF0d3a4a) : Colors.white.withValues(alpha: 0.6)),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: isSelected
                          ? (isDark ? AppColors.lightPrimary : const Color(0xFFdc2626))
                          : (isDark ? AppColors.lightSecondary : const Color(0xFF4d7c0f)),
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      language == AppLanguage.bn ? division['nameBn'] : division['nameEn'],
                      style: TextStyle(
                        color: isDark ? AppColors.lightSecondary : const Color(0xFF166534),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(division['districts'] as List).length} ${language == AppLanguage.bn ? 'জেলা' : 'districts'}',
                      style: TextStyle(
                        color: isDark ? AppColors.lightSecondary.withValues(alpha: 0.7) : const Color(0xFF4d7c0f),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.lightPrimary : const Color(0xFFdc2626),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDistrictGrid(bool isDark, AppLanguage language) {
    final districts = selectedDivision!['districts'] as List;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: districts.length,
      itemBuilder: (context, index) {
        final district = districts[index];
        final isSelected = selectedDistrict?['id'] == district['id'];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDistrict = district;
              selectedUpazila = null;
              step = 'upazila';
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0a2f3d) : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColors.lightPrimary : const Color(0xFFdc2626))
                    : (isDark ? const Color(0xFF0d3a4a) : Colors.white.withValues(alpha: 0.6)),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: isSelected
                          ? (isDark ? AppColors.lightPrimary : const Color(0xFFdc2626))
                          : (isDark ? AppColors.lightSecondary : const Color(0xFF4d7c0f)),
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      language == AppLanguage.bn ? district['nameBn'] : district['nameEn'],
                      style: TextStyle(
                        color: isDark ? AppColors.lightSecondary : const Color(0xFF166534),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(district['upazilas'] as List).length} ${language == AppLanguage.bn ? 'উপজেলা' : 'upazilas'}',
                      style: TextStyle(
                        color: isDark ? AppColors.lightSecondary.withValues(alpha: 0.7) : const Color(0xFF4d7c0f),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.lightPrimary : const Color(0xFFdc2626),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpazilaList(bool isDark) {
    final upazilas = selectedDistrict!['upazilas'] as List;
    
    return Column(
      children: upazilas.map((upazila) {
        final isSelected = selectedUpazila == upazila;
        
        return GestureDetector(
          onTap: () => setState(() => selectedUpazila = upazila),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0a2f3d) : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColors.lightPrimary : const Color(0xFFdc2626))
                    : (isDark ? const Color(0xFF0d3a4a) : Colors.white.withValues(alpha: 0.6)),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: isSelected
                          ? (isDark ? AppColors.lightPrimary : const Color(0xFFdc2626))
                          : (isDark ? AppColors.lightSecondary : const Color(0xFF4d7c0f)),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      upazila,
                      style: TextStyle(
                        color: isDark ? AppColors.lightSecondary : const Color(0xFF166534),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.lightPrimary : const Color(0xFFdc2626),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
