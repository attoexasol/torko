import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { ArrowRight, MapPin, ChevronRight, Check, X } from 'lucide-react';

interface LocationOnboardingScreenProps {
  onComplete: () => void;
}

type District = {
  id: string;
  nameBn: string;
  nameEn: string;
  upazilas: string[];
};

type Division = {
  id: string;
  nameBn: string;
  nameEn: string;
  districts: District[];
};

export const LocationOnboardingScreen: React.FC<LocationOnboardingScreenProps> = ({ onComplete }) => {
  const { theme, language } = useApp();
  const isDark = theme === 'dark';
  
  const [selectedDivision, setSelectedDivision] = useState<Division | null>(null);
  const [selectedDistrict, setSelectedDistrict] = useState<District | null>(null);
  const [selectedUpazila, setSelectedUpazila] = useState<string | null>(null);
  const [step, setStep] = useState<'division' | 'district' | 'upazila'>('division');
  const [searchQuery, setSearchQuery] = useState('');

  // Complete Bangladesh data: 8 Divisions, 64 Districts, 495 Upazilas
  const divisionsData: Division[] = [
    {
      id: 'dhaka',
      nameBn: 'ঢাকা',
      nameEn: 'Dhaka',
      districts: [
        { id: 'dhaka', nameBn: 'ঢাকা', nameEn: 'Dhaka', upazilas: ['ধানমন্ডি', 'গুলশান', 'মিরপুর', 'উত্তরা', 'মোহাম্মদপুর', 'বনানী', 'বসুন্ধরা', 'মতিঝিল', 'রমনা', 'তেজগাঁও', 'শ্যামলী', 'খিলগাঁও', 'যাত্রাবাড়ী', 'সাভার', 'দোহার', 'কেরাণীগঞ্জ', 'নবাবগঞ্জ', 'ধামরাই'] },
        { id: 'gazipur', nameBn: 'গাজীপুর', nameEn: 'Gazipur', upazilas: ['গাজীপুর সদর', 'কালিয়াকৈর', 'কাপাসিয়া', 'শ্রীপুর', 'টঙ্গী'] },
        { id: 'narayanganj', nameBn: 'নারায়ণগঞ্জ', nameEn: 'Narayanganj', upazilas: ['নারায়ণগঞ্জ সদর', 'বন্দর', 'রূপগঞ্জ', 'সোনারগাঁও', 'আড়াইহাজার', 'ফতুল্লা'] },
        { id: 'manikganj', nameBn: 'মানিকগঞ্জ', nameEn: 'Manikganj', upazilas: ['মানিকগঞ্জ সদর', 'সিংগাইর', 'শিবালয়', 'সাটুরিয়া', 'ঘিওর', 'দৌলতপুর', 'হরিরামপুর'] },
        { id: 'munshiganj', nameBn: 'মুন্সিগঞ্জ', nameEn: 'Munshiganj', upazilas: ['মুন্সিগঞ্জ সদর', 'লৌহজং', 'সিরাজদিখান', 'শ্রীনগর', 'টংগীবাড়ী', 'গজারিয়া'] },
        { id: 'narsingdi', nameBn: 'নরসিংদী', nameEn: 'Narsingdi', upazilas: ['নরসিংদী সদর', 'বেলাবো', 'মনোহরদী', 'পলাশ', 'রায়পুরা', 'শিবপুর'] },
        { id: 'tangail', nameBn: 'টাঙ্গাইল', nameEn: 'Tangail', upazilas: ['টাঙ্গাইল সদর', 'মির্জাপুর', 'গোপালপুর', 'মধুপুর', 'ঘাটাইল', 'কালিহাতী', 'দেলদুয়ার', 'ভুয়াপুর', 'নাগরপুর', 'বাসাইল', 'সখিপুর', 'ধনবাড়ী'] },
        { id: 'kishoreganj', nameBn: 'কিশোরগঞ্জ', nameEn: 'Kishoreganj', upazilas: ['কিশোরগঞ্জ সদর', 'ভৈরব', 'কটিয়াদী', 'পাকুন্দিয়া', 'কুলিয়ারচর', 'হোসেনপুর', 'ইটনা', 'করিমগঞ্জ', 'তাড়াইল', 'নিকলী', 'মিটামইন', 'অষ্টগ্রাম', 'বাজিতপুর'] },
        { id: 'faridpur', nameBn: 'ফরিদপুর', nameEn: 'Faridpur', upazilas: ['ফরিদপুর সদর', 'আলফাডাঙ্গা', 'বোয়ালমারী', 'সদরপুর', 'নগরকান্দা', 'ভাঙ্গা', 'চরভদ্রাসন', 'মধুখালী', 'সালথা'] },
        { id: 'rajbari', nameBn: 'রাজবাড়ী', nameEn: 'Rajbari', upazilas: ['রাজবাড়ী সদর', 'গোয়ালন্দ', 'পাংশা', 'বালিয়াকান্দি', 'কালুখালী'] },
        { id: 'madaripur', nameBn: 'মাদারীপুর', nameEn: 'Madaripur', upazilas: ['মাদারীপুর সদর', 'শিবচর', 'কালকিনি', 'রাজৈর'] },
        { id: 'gopalganj', nameBn: 'গোপালগঞ্জ', nameEn: 'Gopalganj', upazilas: ['গোপালগঞ্জ সদর', 'কাশিয়ানী', 'টুংগীপাড়া', 'কোটালীপাড়া', 'মুকসুদপুর'] },
        { id: 'shariatpur', nameBn: 'শরীয়তপুর', nameEn: 'Shariatpur', upazilas: ['শরীয়তপুর সদর', 'নড়িয়া', 'জাজিরা', 'গোসাইরহাট', 'ভেদরগঞ্জ', 'ডামুড়্যা'] },
      ],
    },
    {
      id: 'chittagong',
      nameBn: 'চট্টগ্রাম',
      nameEn: 'Chittagong',
      districts: [
        { id: 'chittagong', nameBn: 'চট্টগ্রাম', nameEn: 'Chittagong', upazilas: ['পাহাড়তলী', 'কোতোয়ালী', 'পাঁচলাইশ', 'আগ্রাবাদ', 'খুলশী', 'বায়েজিদ বোস্তামী', 'চান্দগাঁও', 'ডাবল মুরিং', 'হালিশহর', 'পতেঙ্গা', 'সীতাকুণ্ড', 'মীরসরাই', 'ফটিকছড়ি', 'রাঙ্গুনিয়া', 'রাউজান', 'সন্দ্বীপ', 'বাঁশখালী', 'বোয়ালখালী', 'আনোয়ারা', 'চন্দনাইশ', 'সাতকানিয়া', 'লোহাগাড়া', 'পটিয়া'] },
        { id: 'coxsbazar', nameBn: 'কক্সবাজার', nameEn: "Cox's Bazar", upazilas: ['কক্সবাজার সদর', 'চকরিয়া', 'রামু', 'উখিয়া', 'টেকনাফ', 'মহেশখালী', 'পেকুয়া', 'কুতুবদিয়া'] },
        { id: 'comilla', nameBn: 'কুমিল্লা', nameEn: 'Comilla', upazilas: ['কুমিল্লা সদর', 'দাউদকান্দি', 'চান্দিনা', 'বুড়িচং', 'ব্রাহ্মণপাড়া', 'হোমনা', 'তিতাস', 'মুরাদনগর', 'দেবিদ্বার', 'লাকসাম', 'নাঙ্গলকোট', 'মেঘনা', 'চৌদ্দগ্রাম', 'বরুড়া', 'মনোহরগঞ্জ', 'আদর্শ সদর', 'লালমাই'] },
        { id: 'feni', nameBn: 'ফেনী', nameEn: 'Feni', upazilas: ['ফেনী সদর', 'দাগনভূঁইয়া', 'পরশুরাম', 'ফুলগাজী', 'ছাগলনাইয়া', 'সোনাগাজী'] },
        { id: 'brahmanbaria', nameBn: 'ব্রাহ্মণবাড়িয়া', nameEn: 'Brahmanbaria', upazilas: ['ব্রাহ্মণবাড়িয়া সদর', 'কসবা', 'নাসিরনগর', 'সরাইল', 'আশুগঞ্জ', 'আখাউড়া', 'নবীনগর', 'বাঞ্ছারামপুর', 'বিজয়নগর'] },
        { id: 'rangamati', nameBn: 'রাঙ্গামাটি', nameEn: 'Rangamati', upazilas: ['রাঙ্গামাটি সদর', 'কাপ্তাই', 'কাউখালী', 'বাঘাইছড়ি', 'বরকল', 'লংগদু', 'রাজস্থলী', 'বিলাইছড়ি', 'জুরাছড়ি', 'নানিয়ারচর'] },
        { id: 'bandarban', nameBn: 'বান্দরবান', nameEn: 'Bandarban', upazilas: ['বান্দরবান সদর', 'আলীকদম', 'নাইক্ষ্যংছড়ি', 'রোয়াংছড়ি', 'রুমা', 'থানচি', 'লামা'] },
        { id: 'khagrachari', nameBn: 'খাগড়াছড়ি', nameEn: 'Khagrachari', upazilas: ['খাগড়াছড়ি সদর', 'দীঘিনালা', 'পঞ্চহরি', 'লক্ষীছড়ি', 'মহালছড়ি', 'মানিকছড়ি', 'রামগড়', 'মাটিরাঙ্গা', 'গুইমারা'] },
        { id: 'noakhali', nameBn: 'নোয়াখালী', nameEn: 'Noakhali', upazilas: ['নোয়াখালী সদর', 'সেনবাগ', 'চাটখিল', 'বেগমগঞ্জ', 'সোনাইমুড়ি', 'হাতিয়া', 'সুবর্ণচর', 'কোম্পানীগঞ্জ', 'কবিরহাট'] },
        { id: 'lakshmipur', nameBn: 'লক্ষ্মীপুর', nameEn: 'Lakshmipur', upazilas: ['লক্ষ্মীপুর সদর', 'রায়পুর', 'রামগতি', 'রামগঞ্জ', 'কমলনগর'] },
        { id: 'chandpur', nameBn: 'চাঁদপুর', nameEn: 'Chandpur', upazilas: ['চাঁদপুর সদর', 'ফরিদগঞ্জ', 'হাইমচর', 'হাজীগঞ্জ', 'কচুয়া', 'মতলব উত্তর', 'মতলব দক্ষিণ', 'শাহরাস্তি'] },
      ],
    },
    {
      id: 'rajshahi',
      nameBn: 'রাজশাহী',
      nameEn: 'Rajshahi',
      districts: [
        { id: 'rajshahi', nameBn: 'রাজশাহী', nameEn: 'Rajshahi', upazilas: ['রাজশাহী সদর', 'বোয়ালিয়া', 'মতিহার', 'শাহ মখদুম', 'পবা', 'দুর্গাপুর', 'মোহনপুর', 'চারঘাট', 'পুঠিয়া', 'বাঘা', 'গোদাগাড়ী', 'তানোর'] },
        { id: 'natore', nameBn: 'নাটোর', nameEn: 'Natore', upazilas: ['নাটোর সদর', 'বড়াইগ্রাম', 'গুরুদাসপুর', 'লালপুর', 'সিংড়া', 'নলডাঙ্গা', 'বাগাতিপাড়া'] },
        { id: 'naogaon', nameBn: 'নওগাঁ', nameEn: 'Naogaon', upazilas: ['নওগাঁ সদর', 'পত্নীতলা', 'আত্রাই', 'রাণীনগর', 'নিয়ামতপুর', 'মান্দা', 'মহাদেবপুর', 'ধামইরহাট', 'বদলগাছী', 'পোরশা', 'সাপাহার'] },
        { id: 'chapainawabganj', nameBn: 'চাঁপাইনবাবগঞ্জ', nameEn: 'Chapainawabganj', upazilas: ['চাঁপাইনবাবগঞ্জ সদর', 'গোমস্তাপুর', 'নাচোল', 'ভোলাহাট', 'শিবগঞ্জ'] },
        { id: 'pabna', nameBn: 'পাবনা', nameEn: 'Pabna', upazilas: ['পাবনা সদর', 'ঈশ্বরদী', 'চাটমোহর', 'সাঁথিয়া', 'ভাঙ্গুড়া', 'ফরিদপুর', 'বেড়া', 'আটঘরিয়া', 'সুজানগর'] },
        { id: 'sirajganj', nameBn: 'সিরাজগঞ্জ', nameEn: 'Sirajganj', upazilas: ['সিরাজগঞ্জ সদর', 'বেলকুচি', 'কামারখন্দ', 'শাহজাদপুর', 'তাড়াশ', 'উল্লাপাড়া', 'কাজিপুর', 'রায়গঞ্জ', 'চৌহালী'] },
        { id: 'bogra', nameBn: 'বগুড়া', nameEn: 'Bogra', upazilas: ['বগুড়া সদর', 'শেরপুর', 'শাজাহানপুর', 'আদমদিঘি', 'কাহালু', 'নন্দীগ্রাম', 'সারিয়াকান্দি', 'সোনাতলা', 'ধুনট', 'গাবতলী', 'দুপচাঁচিয়া', 'শিবগঞ্জ'] },
        { id: 'joypurhat', nameBn: 'জয়পুরহাট', nameEn: 'Joypurhat', upazilas: ['জয়পুরহাট সদর', 'আক্কেলপুর', 'কালাই', 'খেতলাল', 'পাঁচবিবি'] },
      ],
    },
    {
      id: 'khulna',
      nameBn: 'খুলনা',
      nameEn: 'Khulna',
      districts: [
        { id: 'khulna', nameBn: 'খুলনা', nameEn: 'Khulna', upazilas: ['খুলনা সদর', 'ডুমুরিয়া', 'ফুলতলা', 'দিঘলিয়া', 'কয়রা', 'তেরখাদা', 'বটিয়াঘাটা', 'দাকোপ', 'পাইকগাছা'] },
        { id: 'jessore', nameBn: 'যশোর', nameEn: 'Jessore', upazilas: ['যশোর সদর', 'ঝিকরগাছা', 'শার্শা', 'চৌগাছা', 'মণিরামপুর', 'অভয়নগর', 'বাঘারপাড়া', 'কেশবপুর'] },
        { id: 'satkhira', nameBn: 'সাতক্ষীরা', nameEn: 'Satkhira', upazilas: ['সাতক্ষীরা সদর', 'কলারোয়া', 'তালা', 'দেবহাটা', 'শ্যামনগর', 'আশাশুনি', 'কালিগঞ্জ'] },
        { id: 'bagerhat', nameBn: 'বাগেরহাট', nameEn: 'Bagerhat', upazilas: ['বাগেরহাট সদর', 'চিতলমারী', 'ফকিরহাট', 'কচুয়া', 'মোল্লাহাট', 'মোংলা', 'মোড়েলগঞ্জ', 'রামপাল', 'শরণখোলা'] },
        { id: 'jhenaidah', nameBn: 'ঝিনাইদহ', nameEn: 'Jhenaidah', upazilas: ['ঝিনাইদহ সদর', 'শৈলকুপা', 'হরিণাকুণ্ডু', 'কালীগঞ্জ', 'কোটচাঁদপুর', 'মহেশপুর'] },
        { id: 'magura', nameBn: 'মাগুরা', nameEn: 'Magura', upazilas: ['মাগুরা সদর', 'মহমুদপুর', 'শালিখা', 'শ্রীপুর'] },
        { id: 'narail', nameBn: 'নড়াইল', nameEn: 'Narail', upazilas: ['নড়াইল সদর', 'লোহাগড়া', 'কালিয়া'] },
        { id: 'chuadanga', nameBn: 'চুয়াডাঙ্গা', nameEn: 'Chuadanga', upazilas: ['চুয়াডাঙ্গা সদর', 'আলমডাঙ্গা', 'দামুড়হুদা', 'জীবননগর'] },
        { id: 'kushtia', nameBn: 'কুষ্টিয়া', nameEn: 'Kushtia', upazilas: ['কুষ্টিয়া সদর', 'কুমারখালী', 'খোকসা', 'দৌলতপুর', 'মিরপুর', 'ভেড়ামারা'] },
        { id: 'meherpur', nameBn: 'মেহেরপুর', nameEn: 'Meherpur', upazilas: ['মেহেরপুর সদর', 'মুজিবনগর', 'গাংনী'] },
      ],
    },
    {
      id: 'sylhet',
      nameBn: 'সিলেট',
      nameEn: 'Sylhet',
      districts: [
        { id: 'sylhet', nameBn: 'সিলেট', nameEn: 'Sylhet', upazilas: ['সিলেট সদর', 'জকিগঞ্জ', 'কানাইঘাট', 'বিয়ানীবাজার', 'গোয়াইনঘাট', 'কোম্পানীগঞ্জ', 'ফেঞ্চুগঞ্জ', 'গোলাপগঞ্জ', 'জৈন্তাপুর', 'বালাগঞ্জ', 'দক্ষিণ সুরমা', 'ওসমানী নগর'] },
        { id: 'moulvibazar', nameBn: 'মৌলভীবাজার', nameEn: 'Moulvibazar', upazilas: ['মৌলভীবাজার সদর', 'শ্রীমঙ্গল', 'কমলগঞ্জ', 'কুলাউড়া', 'রাজনগর', 'বড়লেখা', 'জুড়ী'] },
        { id: 'habiganj', nameBn: 'হবিগঞ্জ', nameEn: 'Habiganj', upazilas: ['হবিগঞ্জ সদর', 'বাহুবল', 'চুনারুঘাট', 'মাধবপুর', 'নবীগঞ্জ', 'লাখাই', 'আজমিরীগঞ্জ', 'বানিয়াচং'] },
        { id: 'sunamganj', nameBn: 'সুনামগঞ্জ', nameEn: 'Sunamganj', upazilas: ['সুনামগঞ্জ সদর', 'ছাতক', 'জগন্নাথপুর', 'দোয়ারাবাজার', 'তাহিরপুর', 'বিশ্বম্ভরপুর', 'ধর্মপাশা', 'মধ্যনগর', 'জামালগঞ্জ', 'শাল্লা', 'দিরাই'] },
      ],
    },
    {
      id: 'barisal',
      nameBn: 'বরিশাল',
      nameEn: 'Barisal',
      districts: [
        { id: 'barisal', nameBn: 'বরিশাল', nameEn: 'Barisal', upazilas: ['বরিশাল সদর', 'বাবুগঞ্জ', 'বাকেরগঞ্জ', 'উজিরপুর', 'মেহেন্দিগঞ্জ', 'মুলাদী', 'হিজলা', 'গৌরনদী', 'আগৈলঝাড়া', 'বানারীপাড়া'] },
        { id: 'patuakhali', nameBn: 'পটুয়াখালী', nameEn: 'Patuakhali', upazilas: ['পটুয়াখালী সদর', 'গলাচিপা', 'দুমকি', 'কলাপাড়া', 'মির্জাগঞ্জ', 'বাউফল', 'দাসমিনা', 'রাঙ্গাবালী'] },
        { id: 'barguna', nameBn: 'বরগুনা', nameEn: 'Barguna', upazilas: ['বরগুনা সদর', 'আমতলী', 'পাথরঘাটা', 'বামনা', 'বেতাগী', 'তালতলি'] },
        { id: 'bhola', nameBn: 'ভোলা', nameEn: 'Bhola', upazilas: ['ভোলা সদর', 'বোরহানউদ্দিন', 'চরফ্যাশন', 'দৌলতখান', 'মনপুরা', 'তজুমদ্দিন', 'লালমোহন'] },
        { id: 'pirojpur', nameBn: 'পিরোজপুর', nameEn: 'Pirojpur', upazilas: ['পিরোজপুর সদর', 'নাজিরপুর', 'কাউখালী', 'ভান্ডারিয়া', 'মঠবাড়ীয়া', 'নেছারাবাদ', 'ইন্দুরকানী'] },
        { id: 'jhalokati', nameBn: 'ঝালকাঠি', nameEn: 'Jhalokati', upazilas: ['ঝালকাঠি সদর', 'রাজাপুর', 'নলছিটি', 'কাঠালিয়া'] },
      ],
    },
    {
      id: 'rangpur',
      nameBn: 'রংপুর',
      nameEn: 'Rangpur',
      districts: [
        { id: 'rangpur', nameBn: 'রংপুর', nameEn: 'Rangpur', upazilas: ['রংপুর সদর', 'মিঠাপুকুর', 'বদরগঞ্জ', 'গঙ্গাচড়া', 'পীরগঞ্জ', 'কাউনিয়া', 'তারাগঞ্জ', 'পীরগাছা'] },
        { id: 'dinajpur', nameBn: 'দিনাজপুর', nameEn: 'Dinajpur', upazilas: ['দিনাজপুর সদর', 'বীরগঞ্জ', 'ঘোড়াঘাট', 'নবাবগঞ্জ', 'পার্বতীপুর', 'ফুলবাড়ী', 'হাকিমপুর', 'খানসামা', 'কাহারোল', 'বিরামপুর', 'চিরিরবন্দর', 'বোচাগঞ্জ', 'বিরল'] },
        { id: 'gaibandha', nameBn: 'গাইবান্ধা', nameEn: 'Gaibandha', upazilas: ['গাইবান্ধা সদর', 'গোবিন্দগঞ্জ', 'পলাশবাড়ী', 'সাদুল্যাপুর', 'সাঘাটা', 'ফুলছড়ি', 'সুন্দরগঞ্জ'] },
        { id: 'kurigram', nameBn: 'কুড়িগ্রাম', nameEn: 'Kurigram', upazilas: ['কুড়িগ্রাম সদর', 'উলিপুর', 'নাগেশ্বরী', 'ভুরুঙ্গামারী', 'ফুলবাড়ী', 'রাজারহাট', 'রাজিবপুর', 'রৌমারী', 'চররাজিবপুর'] },
        { id: 'lalmonirhat', nameBn: 'লালমনিরহাট', nameEn: 'Lalmonirhat', upazilas: ['লালমনিরহাট সদর', 'আদিতমারী', 'কালীগঞ্জ', 'হাতীবান্ধা', 'পাটগ্রাম'] },
        { id: 'nilphamari', nameBn: 'নীলফামারী', nameEn: 'Nilphamari', upazilas: ['নীলফামারী সদর', 'সৈয়দপুর', 'জলঢাকা', 'কিশোরগঞ্জ', 'ডোমার', 'ডিমলা'] },
        { id: 'panchagarh', nameBn: 'পঞ্চগড়', nameEn: 'Panchagarh', upazilas: ['পঞ্চগড় সদর', 'দেবীগঞ্জ', 'বোদা', 'আটোয়ারী', 'তেঁতুলিয়া'] },
        { id: 'thakurgaon', nameBn: 'ঠাকুরগাঁও', nameEn: 'Thakurgaon', upazilas: ['ঠাকুরগাঁও সদর', 'পীরগঞ্জ', 'রাণীশংকৈল', 'হরিপুর', 'বালিয়াডাঙ্গী'] },
      ],
    },
    {
      id: 'mymensingh',
      nameBn: 'ময়মনসিংহ',
      nameEn: 'Mymensingh',
      districts: [
        { id: 'mymensingh', nameBn: 'ময়মনসিংহ', nameEn: 'Mymensingh', upazilas: ['ময়মনসিংহ সদর', 'মুক্তাগাছা', 'গৌরীপুর', 'ভালুকা', 'ত্রিশাল', 'ধোবাউড়া', 'ফুলবাড়ীয়া', 'গফরগাঁও', 'ঈশ্বরগঞ্জ', 'নান্দাইল', 'তারাকান্দা', 'হালুয়াঘাট', 'ফুলপুর'] },
        { id: 'jamalpur', nameBn: 'জামালপুর', nameEn: 'Jamalpur', upazilas: ['জামালপুর সদর', 'মেলান্দহ', 'ইসলামপুর', 'দেওয়ানগঞ্জ', 'মাদারগঞ্জ', 'বকশীগঞ্জ', 'সরিষাবাড়ী'] },
        { id: 'netrokona', nameBn: 'নেত্রকোনা', nameEn: 'Netrokona', upazilas: ['নেত্রকোনা সদর', 'আটপাড়া', 'বারহাট্টা', 'দুর্গাপুর', 'খালিয়াজুরী', 'কেন্দুয়া', 'মদন', 'মোহনগঞ্জ', 'পূর্বধলা', 'কলমাকান্দা'] },
        { id: 'sherpur', nameBn: 'শেরপুর', nameEn: 'Sherpur', upazilas: ['শেরপুর সদর', 'নালিতাবাড়ী', 'শ্রীবরদী', 'নকলা', 'ঝিনাইগাতী'] },
      ],
    },
  ];

  const translations = {
    title: language === 'bn' ? 'আপনার এলাকা নির্বাচন করুন' : 'Select Your Location',
    subtitle: language === 'bn' ? 'স্থানীয় আপডেট পেতে আপনার পছন্দের এলাকা বেছে নিন' : 'Choose your preferred area to get local updates',
    continue: language === 'bn' ? 'এগিয়ে যান' : 'Continue',
    changeLater: language === 'bn' ? 'পরে পরিবর্তন করুন' : 'Change Later',
    selectDivision: language === 'bn' ? 'বিভাগ নির্বাচন করুন' : 'Select Division',
    selectDistrict: language === 'bn' ? 'জেলা নির্বাচন করুন' : 'Select District',
    selectUpazila: language === 'bn' ? 'উপজেলা নির্বাচন করুন' : 'Select Upazila',
    totalDivisions: language === 'bn' ? '৮টি বিভাগ' : '8 Divisions',
    search: language === 'bn' ? 'খুঁজুন...' : 'Search...',
  };

  const handleDivisionSelect = (division: Division) => {
    setSelectedDivision(division);
    setSelectedDistrict(null);
    setSelectedUpazila(null);
    setStep('district');
    setSearchQuery('');
  };

  const handleDistrictSelect = (district: District) => {
    setSelectedDistrict(district);
    setSelectedUpazila(null);
    setStep('upazila');
    setSearchQuery('');
  };

  const handleUpazilaSelect = (upazila: string) => {
    setSelectedUpazila(upazila);
  };

  const handleComplete = () => {
    if (selectedDivision && selectedDistrict && selectedUpazila) {
      if (typeof window !== 'undefined') {
        localStorage.setItem('torko_user_location', JSON.stringify({
          division: selectedDivision.nameEn,
          divisionBn: selectedDivision.nameBn,
          district: selectedDistrict.nameEn,
          districtBn: selectedDistrict.nameBn,
          upazila: selectedUpazila,
        }));
      }
      onComplete();
    }
  };

  const handleChangeLater = () => {
    onComplete();
  };

  const handleBackStep = () => {
    if (step === 'upazila') {
      setStep('district');
      setSelectedUpazila(null);
      setSearchQuery('');
    } else if (step === 'district') {
      setStep('division');
      setSelectedDistrict(null);
      setSelectedUpazila(null);
      setSearchQuery('');
    }
  };

  const isFormValid = selectedDivision && selectedDistrict && selectedUpazila;

  // Filter data based on search
  const filteredDistricts = selectedDivision?.districts.filter((district) =>
    district.nameBn.includes(searchQuery) || district.nameEn.toLowerCase().includes(searchQuery.toLowerCase())
  ) || [];

  const filteredUpazilas = selectedDistrict?.upazilas.filter((upazila) =>
    upazila.includes(searchQuery)
  ) || [];

  return (
    <div className={`flex flex-col w-full h-screen ${
      isDark 
        ? 'bg-[#052029]' 
        : 'bg-gradient-to-br from-white via-[#f0fdf4] to-[#dcfce7]'
    }`}>
      {/* Top Section - Fixed Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="flex-shrink-0 px-4 sm:px-6 pt-6 sm:pt-8 pb-2 sm:pb-3"
      >
        <h1 className={`font-['Noto_Sans_Bengali',sans-serif] text-[22px] sm:text-[28px] leading-tight ${
          isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
        }`}>
          {translations.title}
        </h1>
        <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[12px] sm:text-[14px] leading-snug mt-1.5 ${
          isDark ? 'text-[#B8DED6]/70' : 'text-[#4d7c0f]'
        }`}>
          {translations.subtitle}
        </p>
        <div className={`mt-1 font-['Noto_Sans_Bengali',sans-serif] text-[10px] sm:text-[11px] ${
          isDark ? 'text-[#d97757]' : 'text-[#166534]'
        }`}>
          {language === 'bn' ? '৮ বিভাগ • ৬৪ জেলা • ৪৯৫ উপজেলা' : '8 Divisions • 64 Districts • 495 Upazilas'}
        </div>
      </motion.div>

      {/* Progress & Breadcrumb - Fixed */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="flex-shrink-0 px-4 sm:px-6 py-2"
      >
        {/* Progress Indicator */}
        <div className="flex items-center gap-2 mb-2">
          <div className={`flex-1 h-[3px] rounded-full transition-all duration-300 ${
            step === 'division' || step === 'district' || step === 'upazila'
              ? isDark ? 'bg-[#d97757]' : 'bg-[#166534]'
              : isDark ? 'bg-[#0a2f3d]' : 'bg-[#166534]/20'
          }`} />
          <div className={`flex-1 h-[3px] rounded-full transition-all duration-300 ${
            step === 'district' || step === 'upazila'
              ? isDark ? 'bg-[#d97757]' : 'bg-[#166534]'
              : isDark ? 'bg-[#0a2f3d]' : 'bg-[#166534]/20'
          }`} />
          <div className={`flex-1 h-[3px] rounded-full transition-all duration-300 ${
            step === 'upazila'
              ? isDark ? 'bg-[#d97757]' : 'bg-[#166534]'
              : isDark ? 'bg-[#0a2f3d]' : 'bg-[#166534]/20'
          }`} />
        </div>

        {/* Breadcrumb & Back Button */}
        <div className="flex items-start gap-1.5 sm:gap-2 min-h-[32px]">
          {step !== 'division' && (
            <button
              onClick={handleBackStep}
              className={`flex-shrink-0 flex items-center justify-center w-7 h-7 sm:w-8 sm:h-8 rounded-lg transition-all ${
                isDark 
                  ? 'bg-[#0a2f3d] border border-[#0d3a4a] text-[#B8DED6] hover:bg-[#0d3a4a]'
                  : 'bg-white shadow-md border border-white/60 text-[#166534] hover:bg-gray-50'
              }`}
            >
              <X className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
            </button>
          )}
          
          <div className="flex items-center gap-1 sm:gap-1.5 flex-wrap flex-1 min-w-0">
            {selectedDivision && (
              <>
                <button
                  onClick={() => {
                    setStep('division');
                    setSelectedDistrict(null);
                    setSelectedUpazila(null);
                  }}
                  className={`flex-shrink-0 px-2 sm:px-2.5 py-1 sm:py-1.5 rounded-lg transition-all ${
                    isDark
                      ? 'bg-[#0a2f3d] border border-[#0d3a4a] text-[#B8DED6] hover:bg-[#0d3a4a]'
                      : 'bg-white shadow-md border border-white/60 text-[#166534] hover:bg-gray-50'
                  }`}
                >
                  <span className="font-['Noto_Sans_Bengali',sans-serif] text-[10px] sm:text-[11px] whitespace-nowrap">
                    {language === 'bn' ? selectedDivision.nameBn : selectedDivision.nameEn}
                  </span>
                </button>
                {selectedDistrict && (
                  <ChevronRight className={`flex-shrink-0 w-2.5 h-2.5 sm:w-3 sm:h-3 ${isDark ? 'text-[#B8DED6]/50' : 'text-[#4d7c0f]'}`} />
                )}
              </>
            )}
            {selectedDistrict && (
              <>
                <button
                  onClick={() => {
                    setStep('district');
                    setSelectedUpazila(null);
                  }}
                  className={`flex-shrink-0 px-2 sm:px-2.5 py-1 sm:py-1.5 rounded-lg transition-all ${
                    isDark
                      ? 'bg-[#0a2f3d] border border-[#0d3a4a] text-[#B8DED6] hover:bg-[#0d3a4a]'
                      : 'bg-white shadow-md border border-white/60 text-[#166534] hover:bg-gray-50'
                  }`}
                >
                  <span className="font-['Noto_Sans_Bengali',sans-serif] text-[10px] sm:text-[11px] whitespace-nowrap">
                    {language === 'bn' ? selectedDistrict.nameBn : selectedDistrict.nameEn}
                  </span>
                </button>
                {selectedUpazila && (
                  <ChevronRight className={`flex-shrink-0 w-2.5 h-2.5 sm:w-3 sm:h-3 ${isDark ? 'text-[#B8DED6]/50' : 'text-[#4d7c0f]'}`} />
                )}
              </>
            )}
            {selectedUpazila && (
              <div className={`flex-shrink-0 px-2 sm:px-2.5 py-1 sm:py-1.5 rounded-lg ${
                isDark
                  ? 'bg-[#0a2f3d] border border-[#0d3a4a] text-[#B8DED6]'
                  : 'bg-white shadow-md border border-white/60 text-[#166534]'
              }`}>
                <span className="font-['Noto_Sans_Bengali',sans-serif] text-[10px] sm:text-[11px] whitespace-nowrap">
                  {selectedUpazila}
                </span>
              </div>
            )}
          </div>
        </div>
      </motion.div>

      {/* Main Content Area - Scrollable */}
      <div className="flex-1 overflow-y-auto px-4 sm:px-6 pb-2">
        <AnimatePresence mode="wait">
          {/* Division Selection */}
          {step === 'division' && (
            <motion.div
              key="division"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              transition={{ duration: 0.3 }}
              className="flex flex-col gap-3"
            >
              <h3 className={`font-['Noto_Sans_Bengali',sans-serif] text-[13px] sm:text-[14px] mb-0.5 ${
                isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
              }`}>
                {translations.selectDivision} <span className={isDark ? 'text-[#B8DED6]/70' : 'text-[#4d7c0f]'}>({translations.totalDivisions})</span>
              </h3>
              <div className="grid grid-cols-2 gap-2.5 sm:gap-3 pb-2">
                {divisionsData.map((division) => (
                  <button
                    key={division.id}
                    onClick={() => handleDivisionSelect(division)}
                    className={`relative p-3 sm:p-4 rounded-2xl border-2 transition-all ${
                      selectedDivision?.id === division.id
                        ? (isDark 
                          ? 'bg-[#0a2f3d] border-[#d97757]' 
                          : 'bg-gradient-to-br from-[#dc2626]/10 to-[#166534]/20 border-[#dc2626]')
                        : (isDark
                          ? 'bg-[#0a2f3d] border-[#0d3a4a] hover:border-[#104050]'
                          : 'bg-white/70 backdrop-blur-sm border-white/60 hover:border-[#166534]/40')
                    }`}
                  >
                    <div className="flex flex-col gap-1.5 sm:gap-2">
                      <MapPin className={`w-4 h-4 sm:w-5 sm:h-5 ${
                        selectedDivision?.id === division.id 
                          ? (isDark ? 'text-[#d97757]' : 'text-[#dc2626]')
                          : (isDark ? 'text-[#B8DED6]' : 'text-[#4d7c0f]')
                      }`} />
                      <span className={`font-['Noto_Sans_Bengali',sans-serif] text-[14px] sm:text-[16px] text-left ${
                        isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
                      }`}>
                        {language === 'bn' ? division.nameBn : division.nameEn}
                      </span>
                      <span className={`font-['Noto_Sans',sans-serif] text-[11px] sm:text-[12px] text-left ${
                        isDark ? 'text-[#B8DED6]/70' : 'text-[#4d7c0f]'
                      }`}>
                        {division.districts.length} {language === 'bn' ? 'জেলা' : 'districts'}
                      </span>
                    </div>
                    {selectedDivision?.id === division.id && (
                      <motion.div
                        initial={{ scale: 0, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        className={`absolute top-2 right-2 sm:top-3 sm:right-3 flex items-center justify-center rounded-full w-5 h-5 sm:w-[22px] sm:h-[22px] ${
                          isDark ? 'bg-[#d97757]' : 'bg-[#dc2626]'
                        }`}
                      >
                        <Check className="w-3 h-3 sm:w-3.5 sm:h-3.5 text-white" strokeWidth={3} />
                      </motion.div>
                    )}
                  </button>
                ))}
              </div>
            </motion.div>
          )}

          {/* District Selection */}
          {step === 'district' && selectedDivision && (
            <motion.div
              key="district"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              transition={{ duration: 0.3 }}
              className="flex flex-col gap-3"
            >
              {/* Search Bar */}
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder={translations.search}
                className={`w-full px-3 sm:px-4 py-2.5 sm:py-3 rounded-xl border transition-all font-['Noto_Sans_Bengali',sans-serif] text-[14px] sm:text-[15px] ${
                  isDark
                    ? 'bg-[#0a2f3d] border-[#0d3a4a] text-[#B8DED6] placeholder-[#B8DED6]/50 focus:border-[#d97757]'
                    : 'bg-white/70 backdrop-blur-sm border-white/60 text-[#166534] placeholder-[#4d7c0f]/50 focus:border-[#166534]'
                } outline-none`}
              />

              <h3 className={`font-['Noto_Sans_Bengali',sans-serif] text-[13px] sm:text-[14px] ${
                isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
              }`}>
                {translations.selectDistrict} <span className={isDark ? 'text-[#B8DED6]/70' : 'text-[#4d7c0f]'}>
                  ({filteredDistricts.length} {language === 'bn' ? 'টি জেলা' : 'districts'})
                </span>
              </h3>
              <div className="grid grid-cols-2 gap-2.5 sm:gap-3 pb-2">
                {filteredDistricts.map((district) => (
                  <button
                    key={district.id}
                    onClick={() => handleDistrictSelect(district)}
                    className={`relative p-3 sm:p-4 rounded-2xl border-2 transition-all ${
                      selectedDistrict?.id === district.id
                        ? (isDark 
                          ? 'bg-[#0a2f3d] border-[#d97757]' 
                          : 'bg-gradient-to-br from-[#dc2626]/10 to-[#166534]/20 border-[#dc2626]')
                        : (isDark
                          ? 'bg-[#0a2f3d] border-[#0d3a4a] hover:border-[#104050]'
                          : 'bg-white/70 backdrop-blur-sm border-white/60 hover:border-[#166534]/40')
                    }`}
                  >
                    <div className="flex flex-col gap-1.5 sm:gap-2">
                      <MapPin className={`w-4 h-4 sm:w-5 sm:h-5 ${
                        selectedDistrict?.id === district.id 
                          ? (isDark ? 'text-[#d97757]' : 'text-[#dc2626]')
                          : (isDark ? 'text-[#B8DED6]' : 'text-[#4d7c0f]')
                      }`} />
                      <span className={`font-['Noto_Sans_Bengali',sans-serif] text-[14px] sm:text-[16px] text-left ${
                        isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
                      }`}>
                        {language === 'bn' ? district.nameBn : district.nameEn}
                      </span>
                      <span className={`font-['Noto_Sans',sans-serif] text-[11px] sm:text-[12px] text-left ${
                        isDark ? 'text-[#B8DED6]/70' : 'text-[#4d7c0f]'
                      }`}>
                        {district.upazilas.length} {language === 'bn' ? 'উপজেলা' : 'upazilas'}
                      </span>
                    </div>
                    {selectedDistrict?.id === district.id && (
                      <motion.div
                        initial={{ scale: 0, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        className={`absolute top-2 right-2 sm:top-3 sm:right-3 flex items-center justify-center rounded-full w-5 h-5 sm:w-[22px] sm:h-[22px] ${
                          isDark ? 'bg-[#d97757]' : 'bg-[#dc2626]'
                        }`}
                      >
                        <Check className="w-3 h-3 sm:w-3.5 sm:h-3.5 text-white" strokeWidth={3} />
                      </motion.div>
                    )}
                  </button>
                ))}
              </div>
            </motion.div>
          )}

          {/* Upazila Selection */}
          {step === 'upazila' && selectedDistrict && (
            <motion.div
              key="upazila"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              transition={{ duration: 0.3 }}
              className="flex flex-col gap-2.5 sm:gap-3"
            >
              {/* Search Bar */}
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder={translations.search}
                className={`w-full px-3 sm:px-4 py-2.5 sm:py-3 rounded-xl border transition-all font-['Noto_Sans_Bengali',sans-serif] text-[14px] sm:text-[15px] ${
                  isDark
                    ? 'bg-[#0a2f3d] border-[#0d3a4a] text-[#B8DED6] placeholder-[#B8DED6]/50 focus:border-[#d97757]'
                    : 'bg-white/70 backdrop-blur-sm border-white/60 text-[#166534] placeholder-[#4d7c0f]/50 focus:border-[#166534]'
                } outline-none`}
              />

              <h3 className={`font-['Noto_Sans_Bengali',sans-serif] text-[13px] sm:text-[14px] ${
                isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
              }`}>
                {translations.selectUpazila} <span className={isDark ? 'text-[#B8DED6]/70' : 'text-[#4d7c0f]'}>
                  ({filteredUpazilas.length} {language === 'bn' ? 'টি উপজেলা' : 'upazilas'})
                </span>
              </h3>
              <div className="pb-2">
                {filteredUpazilas.map((upazila, index) => (
                  <button
                    key={index}
                    onClick={() => handleUpazilaSelect(upazila)}
                    className={`relative flex items-center justify-between w-full p-3 sm:p-4 rounded-2xl border-2 transition-all mb-2 ${
                      selectedUpazila === upazila
                        ? (isDark 
                          ? 'bg-[#0a2f3d] border-[#d97757]' 
                          : 'bg-gradient-to-br from-[#dc2626]/10 to-[#166534]/20 border-[#dc2626]')
                        : (isDark
                          ? 'bg-[#0a2f3d] border-[#0d3a4a] hover:border-[#104050]'
                          : 'bg-white/70 backdrop-blur-sm border-white/60 hover:border-[#166534]/40')
                    }`}
                  >
                    <div className="flex items-center gap-2.5 sm:gap-3">
                      <MapPin className={`w-4 h-4 sm:w-5 sm:h-5 ${
                        selectedUpazila === upazila 
                          ? (isDark ? 'text-[#d97757]' : 'text-[#dc2626]')
                          : (isDark ? 'text-[#B8DED6]' : 'text-[#4d7c0f]')
                      }`} />
                      <span className={`font-['Noto_Sans_Bengali',sans-serif] text-[14px] sm:text-[16px] ${
                        isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
                      }`}>
                        {upazila}
                      </span>
                    </div>
                    {selectedUpazila === upazila && (
                      <motion.div
                        initial={{ scale: 0, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        className={`flex items-center justify-center rounded-full w-5 h-5 sm:w-[22px] sm:h-[22px] ${
                          isDark ? 'bg-[#d97757]' : 'bg-[#dc2626]'
                        }`}
                      >
                        <Check className="w-3 h-3 sm:w-3.5 sm:h-3.5 text-white" strokeWidth={3} />
                      </motion.div>
                    )}
                  </button>
                ))}
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Bottom Section - Fixed */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.3 }}
        className={`flex-shrink-0 px-4 sm:px-6 pb-6 sm:pb-8 pt-3 sm:pt-4 ${
          isDark 
            ? 'bg-gradient-to-t from-[#052029] via-[#052029]/95 to-transparent'
            : 'bg-gradient-to-t from-white via-white/95 to-transparent'
        }`}
      >
        {/* Action Buttons */}
        <div className="flex flex-col gap-2.5 sm:gap-3">
          <motion.button
            onClick={handleComplete}
            disabled={!isFormValid}
            whileTap={isFormValid ? { scale: 0.98 } : {}}
            className={`flex items-center justify-center gap-2.5 sm:gap-3 h-[50px] sm:h-[56px] rounded-full shadow-lg transition-all ${
              isFormValid
                ? (isDark 
                  ? 'bg-[#0d3a4a] border-2 border-[#d97757]' 
                  : 'bg-gradient-to-r from-[#dc2626] to-[#166534]')
                : (isDark ? 'bg-[#0a2f3d] cursor-not-allowed' : 'bg-gray-300 cursor-not-allowed')
            }`}
          >
            <p className="font-['Noto_Sans_Bengali',sans-serif] text-[15px] sm:text-[16px] text-white">
              {translations.continue}
            </p>
            <ArrowRight className="w-4.5 h-4.5 sm:w-5 sm:h-5 text-white" strokeWidth={2.5} />
          </motion.button>

          <button
            onClick={handleChangeLater}
            className={`h-[44px] sm:h-[48px] rounded-full border-2 transition-all ${
              isDark
                ? 'bg-transparent border-[#0d3a4a] text-[#B8DED6] hover:bg-[#0a2f3d]'
                : 'bg-transparent border-[#166534]/30 text-[#166534] hover:bg-[#166534]/5'
            }`}
          >
            <p className="font-['Noto_Sans_Bengali',sans-serif] text-[14px] sm:text-[15px]">
              {translations.changeLater}
            </p>
          </button>
        </div>
      </motion.div>
    </div>
  );
};