import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import 'location_onboarding_controller.dart';

class District {
  final String id;
  final String nameBn;
  final String nameEn;
  final List<String> upazilas;

  District({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.upazilas,
  });
}

class Division {
  final String id;
  final String nameBn;
  final String nameEn;
  final List<District> districts;

  Division({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.districts,
  });
}

class LocationOnboardingView extends StatefulWidget {
  const LocationOnboardingView({super.key});

  @override
  State<LocationOnboardingView> createState() => _LocationOnboardingViewState();
}

class _LocationOnboardingViewState extends State<LocationOnboardingView> {
  final appController = Get.find<AppController>();
  final searchController = TextEditingController();
  late final LocationOnboardingController apiController;

  String step = 'division'; // 'division', 'district', 'upazila'
  Division? selectedDivision;
  District? selectedDistrict;
  String? selectedUpazila;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    apiController = Get.put(LocationOnboardingController());
  }

  // Complete Bangladesh data: 8 Divisions, 64 Districts, 495 Upazilas
  final List<Division> divisionsData = [
    Division(
      id: 'dhaka',
      nameBn: 'ঢাকা',
      nameEn: 'Dhaka',
      districts: [
        District(id: 'dhaka', nameBn: 'ঢাকা', nameEn: 'Dhaka', upazilas: ['ধানমন্ডি', 'গুলশান', 'মিরপুর', 'উত্তরা', 'মোহাম্মদপুর', 'বনানী', 'বসুন্ধরা', 'মতিঝিল', 'রমনা', 'তেজগাঁও', 'শ্যামলী', 'খিলগাঁও', 'যাত্রাবাড়ী', 'সাভার', 'দোহার', 'কেরাণীগঞ্জ', 'নবাবগঞ্জ', 'ধামরাই']),
        District(id: 'gazipur', nameBn: 'গাজীপুর', nameEn: 'Gazipur', upazilas: ['গাজীপুর সদর', 'কালিয়াকৈর', 'কাপাসিয়া', 'শ্রীপুর', 'টঙ্গী']),
        District(id: 'narayanganj', nameBn: 'নারায়ণগঞ্জ', nameEn: 'Narayanganj', upazilas: ['নারায়ণগঞ্জ সদর', 'বন্দর', 'রূপগঞ্জ', 'সোনারগাঁও', 'আড়াইহাজার', 'ফতুল্লা']),
        District(id: 'manikganj', nameBn: 'মানিকগঞ্জ', nameEn: 'Manikganj', upazilas: ['মানিকগঞ্জ সদর', 'সিংগাইর', 'শিবালয়', 'সাটুরিয়া', 'ঘিওর', 'দৌলতপুর', 'হরিরামপুর']),
        District(id: 'munshiganj', nameBn: 'মুন্সিগঞ্জ', nameEn: 'Munshiganj', upazilas: ['মুন্সিগঞ্জ সদর', 'লৌহজং', 'সিরাজদিখান', 'শ্রীনগর', 'টংগীবাড়ী', 'গজারিয়া']),
        District(id: 'narsingdi', nameBn: 'নরসিংদী', nameEn: 'Narsingdi', upazilas: ['নরসিংদী সদর', 'বেলাবো', 'মনোহরদী', 'পলাশ', 'রায়পুরা', 'শিবপুর']),
        District(id: 'tangail', nameBn: 'টাঙ্গাইল', nameEn: 'Tangail', upazilas: ['টাঙ্গাইল সদর', 'মির্জাপুর', 'গোপালপুর', 'মধুপুর', 'ঘাটাইল', 'কালিহাতী', 'দেলদুয়ার', 'ভুয়াপুর', 'নাগরপুর', 'বাসাইল', 'সখিপুর', 'ধনবাড়ী']),
        District(id: 'kishoreganj', nameBn: 'কিশোরগঞ্জ', nameEn: 'Kishoreganj', upazilas: ['কিশোরগঞ্জ সদর', 'ভৈরব', 'কটিয়াদী', 'পাকুন্দিয়া', 'কুলিয়ারচর', 'হোসেনপুর', 'ইটনা', 'করিমগঞ্জ', 'তাড়াইল', 'নিকলী', 'মিটামইন', 'অষ্টগ্রাম', 'বাজিতপুর']),
        District(id: 'faridpur', nameBn: 'ফরিদপুর', nameEn: 'Faridpur', upazilas: ['ফরিদপুর সদর', 'আলফাডাঙ্গা', 'বোয়ালমারী', 'সদরপুর', 'নগরকান্দা', 'ভাঙ্গা', 'চরভদ্রাসন', 'মধুখালী', 'সালথা']),
        District(id: 'rajbari', nameBn: 'রাজবাড়ী', nameEn: 'Rajbari', upazilas: ['রাজবাড়ী সদর', 'গোয়ালন্দ', 'পাংশা', 'বালিয়াকান্দি', 'কালুখালী']),
        District(id: 'madaripur', nameBn: 'মাদারীপুর', nameEn: 'Madaripur', upazilas: ['মাদারীপুর সদর', 'শিবচর', 'কালকিনি', 'রাজৈর']),
        District(id: 'gopalganj', nameBn: 'গোপালগঞ্জ', nameEn: 'Gopalganj', upazilas: ['গোপালগঞ্জ সদর', 'কাশিয়ানী', 'টুংগীপাড়া', 'কোটালীপাড়া', 'মুকসুদপুর']),
        District(id: 'shariatpur', nameBn: 'শরীয়তপুর', nameEn: 'Shariatpur', upazilas: ['শরীয়তপুর সদর', 'নড়িয়া', 'জাজিরা', 'গোসাইরহাট', 'ভেদরগঞ্জ', 'ডামুড়্যা']),
      ],
    ),
    Division(
      id: 'chittagong',
      nameBn: 'চট্টগ্রাম',
      nameEn: 'Chittagong',
      districts: [
        District(id: 'chittagong', nameBn: 'চট্টগ্রাম', nameEn: 'Chittagong', upazilas: ['পাহাড়তলী', 'কোতোয়ালী', 'পাঁচলাইশ', 'আগ্রাবাদ', 'খুলশী', 'বায়েজিদ বোস্তামী', 'চান্দগাঁও', 'ডাবল মুরিং', 'হালিশহর', 'পতেঙ্গা', 'সীতাকুণ্ড', 'মীরসরাই', 'ফটিকছড়ি', 'রাঙ্গুনিয়া', 'রাউজান', 'সন্দ্বীপ', 'বাঁশখালী', 'বোয়ালখালী', 'আনোয়ারা', 'চন্দনাইশ', 'সাতকানিয়া', 'লোহাগাড়া', 'পটিয়া']),
        District(id: 'coxsbazar', nameBn: 'কক্সবাজার', nameEn: "Cox's Bazar", upazilas: ['কক্সবাজার সদর', 'চকরিয়া', 'রামু', 'উখিয়া', 'টেকনাফ', 'মহেশখালী', 'পেকুয়া', 'কুতুবদিয়া']),
        District(id: 'comilla', nameBn: 'কুমিল্লা', nameEn: 'Comilla', upazilas: ['কুমিল্লা সদর', 'দাউদকান্দি', 'চান্দিনা', 'বুড়িচং', 'ব্রাহ্মণপাড়া', 'হোমনা', 'তিতাস', 'মুরাদনগর', 'দেবিদ্বার', 'লাকসাম', 'নাঙ্গলকোট', 'মেঘনা', 'চৌদ্দগ্রাম', 'বরুড়া', 'মনোহরগঞ্জ', 'আদর্শ সদর', 'লালমাই']),
        District(id: 'feni', nameBn: 'ফেনী', nameEn: 'Feni', upazilas: ['ফেনী সদর', 'দাগনভূঁইয়া', 'পরশুরাম', 'ফুলগাজী', 'ছাগলনাইয়া', 'সোনাগাজী']),
        District(id: 'brahmanbaria', nameBn: 'ব্রাহ্মণবাড়িয়া', nameEn: 'Brahmanbaria', upazilas: ['ব্রাহ্মণবাড়িয়া সদর', 'কসবা', 'নাসিরনগর', 'সরাইল', 'আশুগঞ্জ', 'আখাউড়া', 'নবীনগর', 'বাঞ্ছারামপুর', 'বিজয়নগর']),
        District(id: 'rangamati', nameBn: 'রাঙ্গামাটি', nameEn: 'Rangamati', upazilas: ['রাঙ্গামাটি সদর', 'কাপ্তাই', 'কাউখালী', 'বাঘাইছড়ি', 'বরকল', 'লংগদু', 'রাজস্থলী', 'বিলাইছড়ি', 'জুরাছড়ি', 'নানিয়ারচর']),
        District(id: 'bandarban', nameBn: 'বান্দরবান', nameEn: 'Bandarban', upazilas: ['বান্দরবান সদর', 'আলীকদম', 'নাইক্ষ্যংছড়ি', 'রোয়াংছড়ি', 'রুমা', 'থানচি', 'লামা']),
        District(id: 'khagrachari', nameBn: 'খাগড়াছড়ি', nameEn: 'Khagrachari', upazilas: ['খাগড়াছড়ি সদর', 'দীঘিনালা', 'পঞ্চহরি', 'লক্ষীছড়ি', 'মহালছড়ি', 'মানিকছড়ি', 'রামগড়', 'মাটিরাঙ্গা', 'গুইমারা']),
        District(id: 'noakhali', nameBn: 'নোয়াখালী', nameEn: 'Noakhali', upazilas: ['নোয়াখালী সদর', 'সেনবাগ', 'চাটখিল', 'বেগমগঞ্জ', 'সোনাইমুড়ি', 'হাতিয়া', 'সুবর্ণচর', 'কোম্পানীগঞ্জ', 'কবিরহাট']),
        District(id: 'lakshmipur', nameBn: 'লক্ষ্মীপুর', nameEn: 'Lakshmipur', upazilas: ['লক্ষ্মীপুর সদর', 'রায়পুর', 'রামগতি', 'রামগঞ্জ', 'কমলনগর']),
        District(id: 'chandpur', nameBn: 'চাঁদপুর', nameEn: 'Chandpur', upazilas: ['চাঁদপুর সদর', 'ফরিদগঞ্জ', 'হাইমচর', 'হাজীগঞ্জ', 'কচুয়া', 'মতলব উত্তর', 'মতলব দক্ষিণ', 'শাহরাস্তি']),
      ],
    ),
    Division(
      id: 'rajshahi',
      nameBn: 'রাজশাহী',
      nameEn: 'Rajshahi',
      districts: [
        District(id: 'rajshahi', nameBn: 'রাজশাহী', nameEn: 'Rajshahi', upazilas: ['রাজশাহী সদর', 'বোয়ালিয়া', 'মতিহার', 'শাহ মখদুম', 'পবা', 'দুর্গাপুর', 'মোহনপুর', 'চারঘাট', 'পুঠিয়া', 'বাঘা', 'গোদাগাড়ী', 'তানোর']),
        District(id: 'natore', nameBn: 'নাটোর', nameEn: 'Natore', upazilas: ['নাটোর সদর', 'বড়াইগ্রাম', 'গুরুদাসপুর', 'লালপুর', 'সিংড়া', 'নলডাঙ্গা', 'বাগাতিপাড়া']),
        District(id: 'naogaon', nameBn: 'নওগাঁ', nameEn: 'Naogaon', upazilas: ['নওগাঁ সদর', 'পত্নীতলা', 'আত্রাই', 'রাণীনগর', 'নিয়ামতপুর', 'মান্দা', 'মহাদেবপুর', 'ধামইরহাট', 'বদলগাছী', 'পোরশা', 'সাপাহার']),
        District(id: 'chapainawabganj', nameBn: 'চাঁপাইনবাবগঞ্জ', nameEn: 'Chapainawabganj', upazilas: ['চাঁপাইনবাবগঞ্জ সদর', 'গোমস্তাপুর', 'নাচোল', 'ভোলাহাট', 'শিবগঞ্জ']),
        District(id: 'pabna', nameBn: 'পাবনা', nameEn: 'Pabna', upazilas: ['পাবনা সদর', 'ঈশ্বরদী', 'চাটমোহর', 'সাঁথিয়া', 'ভাঙ্গুড়া', 'ফরিদপুর', 'বেড়া', 'আটঘরিয়া', 'সুজানগর']),
        District(id: 'sirajganj', nameBn: 'সিরাজগঞ্জ', nameEn: 'Sirajganj', upazilas: ['সিরাজগঞ্জ সদর', 'বেলকুচি', 'কামারখন্দ', 'শাহজাদপুর', 'তাড়াশ', 'উল্লাপাড়া', 'কাজিপুর', 'রায়গঞ্জ', 'চৌহালী']),
        District(id: 'bogra', nameBn: 'বগুড়া', nameEn: 'Bogra', upazilas: ['বগুড়া সদর', 'শেরপুর', 'শাজাহানপুর', 'আদমদিঘি', 'কাহালু', 'নন্দীগ্রাম', 'সারিয়াকান্দি', 'সোনাতলা', 'ধুনট', 'গাবতলী', 'দুপচাঁচিয়া', 'শিবগঞ্জ']),
        District(id: 'joypurhat', nameBn: 'জয়পুরহাট', nameEn: 'Joypurhat', upazilas: ['জয়পুরহাট সদর', 'আক্কেলপুর', 'কালাই', 'খেতলাল', 'পাঁচবিবি']),
      ],
    ),
    Division(
      id: 'khulna',
      nameBn: 'খুলনা',
      nameEn: 'Khulna',
      districts: [
        District(id: 'khulna', nameBn: 'খুলনা', nameEn: 'Khulna', upazilas: ['খুলনা সদর', 'ডুমুরিয়া', 'ফুলতলা', 'দিঘলিয়া', 'কয়রা', 'তেরখাদা', 'বটিয়াঘাটা', 'দাকোপ', 'পাইকগাছা']),
        District(id: 'jessore', nameBn: 'যশোর', nameEn: 'Jessore', upazilas: ['যশোর সদর', 'ঝিকরগাছা', 'শার্শা', 'চৌগাছা', 'মণিরামপুর', 'অভয়নগর', 'বাঘারপাড়া', 'কেশবপুর']),
        District(id: 'satkhira', nameBn: 'সাতক্ষীরা', nameEn: 'Satkhira', upazilas: ['সাতক্ষীরা সদর', 'কলারোয়া', 'তালা', 'দেবহাটা', 'শ্যামনগর', 'আশাশুনি', 'কালিগঞ্জ']),
        District(id: 'bagerhat', nameBn: 'বাগেরহাট', nameEn: 'Bagerhat', upazilas: ['বাগেরহাট সদর', 'চিতলমারী', 'ফকিরহাট', 'কচুয়া', 'মোল্লাহাট', 'মোংলা', 'মোড়েলগঞ্জ', 'রামপাল', 'শরণখোলা']),
        District(id: 'jhenaidah', nameBn: 'ঝিনাইদহ', nameEn: 'Jhenaidah', upazilas: ['ঝিনাইদহ সদর', 'শৈলকুপা', 'হরিণাকুণ্ডু', 'কালীগঞ্জ', 'কোটচাঁদপুর', 'মহেশপুর']),
        District(id: 'magura', nameBn: 'মাগুরা', nameEn: 'Magura', upazilas: ['মাগুরা সদর', 'মহমুদপুর', 'শালিখা', 'শ্রীপুর']),
        District(id: 'narail', nameBn: 'নড়াইল', nameEn: 'Narail', upazilas: ['নড়াইল সদর', 'লোহাগড়া', 'কালিয়া']),
        District(id: 'chuadanga', nameBn: 'চুয়াডাঙ্গা', nameEn: 'Chuadanga', upazilas: ['চুয়াডাঙ্গা সদর', 'আলমডাঙ্গা', 'দামুড়হুদা', 'জীবননগর']),
        District(id: 'kushtia', nameBn: 'কুষ্টিয়া', nameEn: 'Kushtia', upazilas: ['কুষ্টিয়া সদর', 'কুমারখালী', 'খোকসা', 'দৌলতপুর', 'মিরপুর', 'ভেড়ামারা']),
        District(id: 'meherpur', nameBn: 'মেহেরপুর', nameEn: 'Meherpur', upazilas: ['মেহেরপুর সদর', 'মুজিবনগর', 'গাংনী']),
      ],
    ),
    Division(
      id: 'sylhet',
      nameBn: 'সিলেট',
      nameEn: 'Sylhet',
      districts: [
        District(id: 'sylhet', nameBn: 'সিলেট', nameEn: 'Sylhet', upazilas: ['সিলেট সদর', 'জকিগঞ্জ', 'কানাইঘাট', 'বিয়ানীবাজার', 'গোয়াইনঘাট', 'কোম্পানীগঞ্জ', 'ফেঞ্চুগঞ্জ', 'গোলাপগঞ্জ', 'জৈন্তাপুর', 'বালাগঞ্জ', 'দক্ষিণ সুরমা', 'ওসমানী নগর']),
        District(id: 'moulvibazar', nameBn: 'মৌলভীবাজার', nameEn: 'Moulvibazar', upazilas: ['মৌলভীবাজার সদর', 'শ্রীমঙ্গল', 'কমলগঞ্জ', 'কুলাউড়া', 'রাজনগর', 'বড়লেখা', 'জুড়ী']),
        District(id: 'habiganj', nameBn: 'হবিগঞ্জ', nameEn: 'Habiganj', upazilas: ['হবিগঞ্জ সদর', 'বাহুবল', 'চুনারুঘাট', 'মাধবপুর', 'নবীগঞ্জ', 'লাখাই', 'আজমিরীগঞ্জ', 'বানিয়াচং']),
        District(id: 'sunamganj', nameBn: 'সুনামগঞ্জ', nameEn: 'Sunamganj', upazilas: ['সুনামগঞ্জ সদর', 'ছাতক', 'জগন্নাথপুর', 'দোয়ারাবাজার', 'তাহিরপুর', 'বিশ্বম্ভরপুর', 'ধর্মপাশা', 'মধ্যনগর', 'জামালগঞ্জ', 'শাল্লা', 'দিরাই']),
      ],
    ),
    Division(
      id: 'barisal',
      nameBn: 'বরিশাল',
      nameEn: 'Barisal',
      districts: [
        District(id: 'barisal', nameBn: 'বরিশাল', nameEn: 'Barisal', upazilas: ['বরিশাল সদর', 'বাবুগঞ্জ', 'বাকেরগঞ্জ', 'উজিরপুর', 'মেহেন্দিগঞ্জ', 'মুলাদী', 'হিজলা', 'গৌরনদী', 'আগৈলঝাড়া', 'বানারীপাড়া']),
        District(id: 'patuakhali', nameBn: 'পটুয়াখালী', nameEn: 'Patuakhali', upazilas: ['পটুয়াখালী সদর', 'গলাচিপা', 'দুমকি', 'কলাপাড়া', 'মির্জাগঞ্জ', 'বাউফল', 'দাসমিনা', 'রাঙ্গাবালী']),
        District(id: 'barguna', nameBn: 'বরগুনা', nameEn: 'Barguna', upazilas: ['বরগুনা সদর', 'আমতলী', 'পাথরঘাটা', 'বামনা', 'বেতাগী', 'তালতলি']),
        District(id: 'bhola', nameBn: 'ভোলা', nameEn: 'Bhola', upazilas: ['ভোলা সদর', 'বোরহানউদ্দিন', 'চরফ্যাশন', 'দৌলতখান', 'মনপুরা', 'তজুমদ্দিন', 'লালমোহন']),
        District(id: 'pirojpur', nameBn: 'পিরোজপুর', nameEn: 'Pirojpur', upazilas: ['পিরোজপুর সদর', 'নাজিরপুর', 'কাউখালী', 'ভান্ডারিয়া', 'মঠবাড়ীয়া', 'নেছারাবাদ', 'ইন্দুরকানী']),
        District(id: 'jhalokati', nameBn: 'ঝালকাঠি', nameEn: 'Jhalokati', upazilas: ['ঝালকাঠি সদর', 'রাজাপুর', 'নলছিটি', 'কাঠালিয়া']),
      ],
    ),
    Division(
      id: 'rangpur',
      nameBn: 'রংপুর',
      nameEn: 'Rangpur',
      districts: [
        District(id: 'rangpur', nameBn: 'রংপুর', nameEn: 'Rangpur', upazilas: ['রংপুর সদর', 'মিঠাপুকুর', 'বদরগঞ্জ', 'গঙ্গাচড়া', 'পীরগঞ্জ', 'কাউনিয়া', 'তারাগঞ্জ', 'পীরগাছা']),
        District(id: 'dinajpur', nameBn: 'দিনাজপুর', nameEn: 'Dinajpur', upazilas: ['দিনাজপুর সদর', 'বীরগঞ্জ', 'ঘোড়াঘাট', 'নবাবগঞ্জ', 'পার্বতীপুর', 'ফুলবাড়ী', 'হাকিমপুর', 'খানসামা', 'কাহারোল', 'বিরামপুর', 'চিরিরবন্দর', 'বোচাগঞ্জ', 'বিরল']),
        District(id: 'gaibandha', nameBn: 'গাইবান্ধা', nameEn: 'Gaibandha', upazilas: ['গাইবান্ধা সদর', 'গোবিন্দগঞ্জ', 'পলাশবাড়ী', 'সাদুল্যাপুর', 'সাঘাটা', 'ফুলছড়ি', 'সুন্দরগঞ্জ']),
        District(id: 'kurigram', nameBn: 'কুড়িগ্রাম', nameEn: 'Kurigram', upazilas: ['কুড়িগ্রাম সদর', 'উলিপুর', 'নাগেশ্বরী', 'ভুরুঙ্গামারী', 'ফুলবাড়ী', 'রাজারহাট', 'রাজিবপুর', 'রৌমারী', 'চররাজিবপুর']),
        District(id: 'lalmonirhat', nameBn: 'লালমনিরহাট', nameEn: 'Lalmonirhat', upazilas: ['লালমনিরহাট সদর', 'আদিতমারী', 'কালীগঞ্জ', 'হাতীবান্ধা', 'পাটগ্রাম']),
        District(id: 'nilphamari', nameBn: 'নীলফামারী', nameEn: 'Nilphamari', upazilas: ['নীলফামারী সদর', 'সৈয়দপুর', 'জলঢাকা', 'কিশোরগঞ্জ', 'ডোমার', 'ডিমলা']),
        District(id: 'panchagarh', nameBn: 'পঞ্চগড়', nameEn: 'Panchagarh', upazilas: ['পঞ্চগড় সদর', 'দেবীগঞ্জ', 'বোদা', 'আটোয়ারী', 'তেঁতুলিয়া']),
        District(id: 'thakurgaon', nameBn: 'ঠাকুরগাঁও', nameEn: 'Thakurgaon', upazilas: ['ঠাকুরগাঁও সদর', 'পীরগঞ্জ', 'রাণীশংকৈল', 'হরিপুর', 'বালিয়াডাঙ্গী']),
      ],
    ),
    Division(
      id: 'mymensingh',
      nameBn: 'ময়মনসিংহ',
      nameEn: 'Mymensingh',
      districts: [
        District(id: 'mymensingh', nameBn: 'ময়মনসিংহ', nameEn: 'Mymensingh', upazilas: ['ময়মনসিংহ সদর', 'মুক্তাগাছা', 'গৌরীপুর', 'ভালুকা', 'ত্রিশাল', 'ধোবাউড়া', 'ফুলবাড়ীয়া', 'গফরগাঁও', 'ঈশ্বরগঞ্জ', 'নান্দাইল', 'তারাকান্দা', 'হালুয়াঘাট', 'ফুলপুর']),
        District(id: 'jamalpur', nameBn: 'জামালপুর', nameEn: 'Jamalpur', upazilas: ['জামালপুর সদর', 'মেলান্দহ', 'ইসলামপুর', 'দেওয়ানগঞ্জ', 'মাদারগঞ্জ', 'বকশীগঞ্জ', 'সরিষাবাড়ী']),
        District(id: 'netrokona', nameBn: 'নেত্রকোনা', nameEn: 'Netrokona', upazilas: ['নেত্রকোনা সদর', 'আটপাড়া', 'বারহাট্টা', 'দুর্গাপুর', 'খালিয়াজুরী', 'কেন্দুয়া', 'মদন', 'মোহনগঞ্জ', 'পূর্বধলা', 'কলমাকান্দা']),
        District(id: 'sherpur', nameBn: 'শেরপুর', nameEn: 'Sherpur', upazilas: ['শেরপুর সদর', 'নালিতাবাড়ী', 'শ্রীবরদী', 'নকলা', 'ঝিনাইগাতী']),
      ],
    ),
  ];

  bool get isFormValid => selectedDivision != null && selectedDistrict != null && selectedUpazila != null;

  List<District> get filteredDistricts {
    if (selectedDivision == null) return [];
    if (searchQuery.isEmpty) return selectedDivision!.districts;
    return selectedDivision!.districts.where((district) =>
        district.nameBn.contains(searchQuery) ||
        district.nameEn.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  List<String> get filteredUpazilas {
    if (selectedDistrict == null) return [];
    if (searchQuery.isEmpty) return selectedDistrict!.upazilas;
    return selectedDistrict!.upazilas.where((upazila) =>
        upazila.contains(searchQuery)
    ).toList();
  }

  void handleDivisionSelect(Division division) {
    setState(() {
      selectedDivision = division;
      selectedDistrict = null;
      selectedUpazila = null;
      step = 'district';
      searchQuery = '';
      searchController.clear();
    });
    // Update controller state
    apiController.setDivision(division.nameEn, division.nameBn);
  }

  void handleDistrictSelect(District district) {
    setState(() {
      selectedDistrict = district;
      selectedUpazila = null;
      step = 'upazila';
      searchQuery = '';
      searchController.clear();
    });
    // Update controller state
    apiController.setDistrict(district.nameEn, district.nameBn);
  }

  void handleUpazilaSelect(String upazila) {
    setState(() {
      selectedUpazila = upazila;
    });
    // Update controller state
    apiController.setUpazila(upazila);
  }




  /// Handle complete - calls update_users API via controller
  Future<void> handleComplete() async {
    if (isFormValid) {
      await apiController.handleSubmit();
    }
  }

  /// Skip location and navigate to profile
  void handleChangeLater() {
    apiController.handleSkip();
  }

Widget _buildFeatureRow({
  required IconData icon,
  required String text,
  required bool isDark,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.lightPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: AppColors.lightPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 14,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

  void handleBackStep() {
    setState(() {
      if (step == 'upazila') {
        step = 'district';
        selectedUpazila = null;
        searchQuery = '';
        searchController.clear();
      } else if (step == 'district') {
        step = 'division';
        selectedDistrict = null;
        selectedUpazila = null;
        searchQuery = '';
        searchController.clear();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = appController.isDarkMode;
      final language = appController.language;
      final isBn = language == AppLanguage.bn;

      return Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : const Color(0xFFF0FDF4),
        body: Container(
          decoration: isDark
              ? null
              : const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Color(0xFFF0FDF4),
                      Color(0xFFDCFCE7),
                    ],
                  ),
                ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(isDark, isBn),

                // Progress & Breadcrumb
                _buildProgressAndBreadcrumb(isDark, isBn),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStepContent(isDark, isBn),
                  ),
                ),

                // Bottom Actions
                _buildBottomActions(isDark, isBn),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(bool isDark, bool isBn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn ? 'আপনার এলাকা নির্বাচন করুন' : 'Select Your Location',
            style: TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBn
                ? 'স্থানীয় আপডেট পেতে আপনার পছন্দের এলাকা বেছে নিন'
                : 'Choose your preferred area to get local updates',
            style: TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 12,
              color: isDark
                  ? AppColors.darkSecondary.withValues(alpha: 0.7)
                  : const Color(0xFF4d7c0f),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isBn ? '৮ বিভাগ • ৬৪ জেলা • ৪৯৫ উপজেলা' : '8 Divisions • 64 Districts • 495 Upazilas',
            style: TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 10,
              color: isDark ? AppColors.darkPrimary : const Color(0xFF166534),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressAndBreadcrumb(bool isDark, bool isBn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Progress Indicator
          Row(
            children: [
              _buildProgressBar(true, isDark),
              const SizedBox(width: 8),
              _buildProgressBar(step == 'district' || step == 'upazila', isDark),
              const SizedBox(width: 8),
              _buildProgressBar(step == 'upazila', isDark),
            ],
          ),
          const SizedBox(height: 8),

          // Breadcrumb & Back Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (step != 'division')
                GestureDetector(
                  onTap: handleBackStep,
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF0d3a4a) : Colors.white.withValues(alpha: 0.6),
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
                    ),
                  ),
                ),

              // Breadcrumb items
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (selectedDivision != null) ...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              step = 'division';
                              selectedDistrict = null;
                              selectedUpazila = null;
                              searchQuery = '';
                              searchController.clear();
                            });
                          },
                          child: _buildBreadcrumbChip(
                            isBn ? selectedDivision!.nameBn : selectedDivision!.nameEn,
                            isDark,
                          ),
                        ),
                        if (selectedDistrict != null) ...[
                          Icon(
                            Icons.chevron_right,
                            size: 12,
                            color: isDark
                                ? AppColors.darkSecondary.withValues(alpha: 0.5)
                                : const Color(0xFF4d7c0f),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                step = 'district';
                                selectedUpazila = null;
                                searchQuery = '';
                                searchController.clear();
                              });
                            },
                            child: _buildBreadcrumbChip(
                              isBn ? selectedDistrict!.nameBn : selectedDistrict!.nameEn,
                              isDark,
                            ),
                          ),
                        ],
                        if (selectedUpazila != null) ...[
                          Icon(
                            Icons.chevron_right,
                            size: 12,
                            color: isDark
                                ? AppColors.darkSecondary.withValues(alpha: 0.5)
                                : const Color(0xFF4d7c0f),
                          ),
                          _buildBreadcrumbChip(selectedUpazila!, isDark),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbChip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF0d3a4a) : Colors.white.withValues(alpha: 0.6),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'NotoSansBengali',
          fontSize: 11,
          color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool active, bool isDark) {
    return Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: active
              ? (isDark ? AppColors.darkPrimary : const Color(0xFF166534))
              : (isDark ? const Color(0xFF0a2f3d) : const Color(0xFF166534).withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isDark, bool isBn) {
    if (step == 'division') {
      return _buildDivisionGrid(isDark, isBn);
    } else if (step == 'district') {
      return _buildDistrictContent(isDark, isBn);
    } else {
      return _buildUpazilaContent(isDark, isBn);
    }
  }

  Widget _buildSearchBar(bool isDark, bool isBn) {
    return Container(
    //  margin: const EdgeInsets.only(bottom: 12),
      //padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF0d3a4a) : Colors.white.withValues(alpha: 0.6),
        ),
      ),
      child: TextField(
        controller: searchController,
        style: TextStyle(
          fontFamily: 'NotoSansBengali',
          fontSize: 14,
          color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
        ),
        decoration: InputDecoration(
          hintText: isBn ? 'খুঁজুন...' : 'Search...',
          hintStyle: TextStyle(
            fontFamily: 'NotoSansBengali',
            fontSize: 14,
            color: isDark
                ? AppColors.darkSecondary.withValues(alpha: 0.5)
                : const Color(0xFF4d7c0f).withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildDivisionGrid(bool isDark, bool isBn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${isBn ? 'বিভাগ নির্বাচন করুন' : 'Select Division'} (${isBn ? '৮টি বিভাগ' : '8 Divisions'})',
            style: TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 13,
              color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: divisionsData.length,
          itemBuilder: (context, index) {
            final division = divisionsData[index];
            final isSelected = selectedDivision?.id == division.id;

            return GestureDetector(
              onTap: () => handleDivisionSelect(division),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0a2f3d) : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? AppColors.darkPrimary : const Color(0xFFdc2626))
                        : (isDark ? const Color(0xFF0d3a4a) : Colors.white.withValues(alpha: 0.6)),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: isSelected
                              ? (isDark ? AppColors.darkPrimary : const Color(0xFFdc2626))
                              : (isDark ? AppColors.darkSecondary : const Color(0xFF4d7c0f)),
                          size: 20,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isBn ? division.nameBn : division.nameEn,
                          style: TextStyle(
                            fontFamily: 'NotoSansBengali',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${division.districts.length} ${isBn ? 'জেলা' : 'districts'}',
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkSecondary.withValues(alpha: 0.7)
                                : const Color(0xFF4d7c0f),
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkPrimary : const Color(0xFFdc2626),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDistrictContent(bool isDark, bool isBn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(isDark, isBn),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${isBn ? 'জেলা নির্বাচন করুন' : 'Select District'} (${filteredDistricts.length} ${isBn ? 'টি জেলা' : 'districts'})',
            style: TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 13,
              color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filteredDistricts.length,
          itemBuilder: (context, index) {
            final district = filteredDistricts[index];
            final isSelected = selectedDistrict?.id == district.id;

            return GestureDetector(
              onTap: () => handleDistrictSelect(district),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0a2f3d) : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? AppColors.darkPrimary : const Color(0xFFdc2626))
                        : (isDark ? const Color(0xFF0d3a4a) : Colors.white.withValues(alpha: 0.6)),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: isSelected
                              ? (isDark ? AppColors.darkPrimary : const Color(0xFFdc2626))
                              : (isDark ? AppColors.darkSecondary : const Color(0xFF4d7c0f)),
                          size: 20,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isBn ? district.nameBn : district.nameEn,
                          style: TextStyle(
                            fontFamily: 'NotoSansBengali',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${district.upazilas.length} ${isBn ? 'উপজেলা' : 'upazilas'}',
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkSecondary.withValues(alpha: 0.7)
                                : const Color(0xFF4d7c0f),
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkPrimary : const Color(0xFFdc2626),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUpazilaContent(bool isDark, bool isBn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(isDark, isBn),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${isBn ? 'উপজেলা নির্বাচন করুন' : 'Select Upazila'} (${filteredUpazilas.length} ${isBn ? 'টি উপজেলা' : 'upazilas'})',
            style: TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 13,
              color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
            ),
          ),
        ),
        ...filteredUpazilas.map((upazila) {
          final isSelected = selectedUpazila == upazila;

          return GestureDetector(
            onTap: () => handleUpazilaSelect(upazila),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0a2f3d) : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimary : const Color(0xFFdc2626))
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
                            ? (isDark ? AppColors.darkPrimary : const Color(0xFFdc2626))
                            : (isDark ? AppColors.darkSecondary : const Color(0xFF4d7c0f)),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        upazila,
                        style: TextStyle(
                          fontFamily: 'NotoSansBengali',
                          fontSize: 14,
                          color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkPrimary : const Color(0xFFdc2626),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomActions(bool isDark, bool isBn) {
    return Obx(() {
      final isLoading = apiController.isLoading.value;
      final canSubmit = isFormValid && !isLoading;
      
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.darkBackground.withValues(alpha: 0),
                    AppColors.darkBackground.withValues(alpha: 0.95),
                    AppColors.darkBackground,
                  ]
                : [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white,
                  ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: canSubmit ? handleComplete : null,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: canSubmit
                      ? (isDark ? const Color(0xFF0d3a4a) : null)
                      : (isDark ? const Color(0xFF0a2f3d) : Colors.grey[300]),
                  gradient: canSubmit && !isDark
                      ? const LinearGradient(colors: [Color(0xFFdc2626), Color(0xFF166534)])
                      : null,
                  borderRadius: BorderRadius.circular(25),
                  border: canSubmit && isDark
                      ? Border.all(color: AppColors.darkPrimary, width: 2)
                      : null,
                  boxShadow: canSubmit
                      ? [
                          BoxShadow(
                            color: isDark
                                ? AppColors.darkPrimary.withValues(alpha: 0.3)
                                : const Color(0xFF166534).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else ...[
                      Text(
                        isBn ? 'এগিয়ে যান' : 'Continue',
                        style: const TextStyle(
                          fontFamily: 'NotoSansBengali',
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: isLoading ? null : handleChangeLater,
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF0d3a4a)
                        : const Color(0xFF166534).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    isBn ? 'পরে পরিবর্তন করুন' : 'Change Later',
                    style: TextStyle(
                      fontFamily: 'NotoSansBengali',
                      color: isDark ? AppColors.darkSecondary : const Color(0xFF166534),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
