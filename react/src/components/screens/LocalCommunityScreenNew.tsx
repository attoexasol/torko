import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ChevronLeft, Search, MessageSquare, SlidersHorizontal, Plus, Users, Calendar, Newspaper, Briefcase, AlertTriangle, ShoppingBag, MapPin, Clock, Star, Share2, MessageCircle, Heart, Eye, X, Radio, MoreVertical, Settings, Flag, Bell, HelpCircle } from 'lucide-react';
import svgPaths from "../../imports/svg-64srki310g";
import imgFrame from "figma:asset/a6746284f9589fbc91a471b3324f42c0ddd746b7.png";
import { FilterModal } from '../FilterModal';
import { TorkoCommentsModal } from '../TorkoCommentsModal';
import { PostCard } from '../PostCard';
import { CreateGroupModal, CreateEventModal, CreateListingModal, CreateAlertModal, ContactSellerModal, ContactProModal, ViewProProfileModal, JoinAsProModal } from '../LocalCommunityModals';
import { CreateStageModal } from '../CreateStageModal';
import { GroupDetailView } from '../GroupDetailView';

interface LocalCommunityScreenNewProps {
  onNavigate: (screen: string) => void;
  language?: 'bn' | 'en';
  onScroll?: (showNav: boolean) => void;
  onStageCreate?: (stageData: any) => void;
}

export const LocalCommunityScreenNew: React.FC<LocalCommunityScreenNewProps> = ({
  onNavigate,
  language = 'bn',
  onScroll,
  onStageCreate
}) => {
  const [showHeader, setShowHeader] = useState(true);
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const lastScrollY = useRef(0);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [categoryViewTab, setCategoryViewTab] = useState<'stages' | 'groups'>('stages');
  const [selectedGroup, setSelectedGroup] = useState<any>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFilter, setSelectedFilter] = useState('all');
  const [activeTab, setActiveTab] = useState<'stages' | 'groups'>('stages');
  const [showSearchBar, setShowSearchBar] = useState(false);
  
  // Modal states
  const [isCreateGroupModalOpen, setIsCreateGroupModalOpen] = useState(false);
  const [isCreateStageModalOpen, setIsCreateStageModalOpen] = useState(false);
  const [isCreateEventModalOpen, setIsCreateEventModalOpen] = useState(false);
  const [isCreateListingModalOpen, setIsCreateListingModalOpen] = useState(false);
  const [isCreateAlertModalOpen, setIsCreateAlertModalOpen] = useState(false);
  const [isContactSellerModalOpen, setIsContactSellerModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState<any>(null);
  const [isContactProModalOpen, setIsContactProModalOpen] = useState(false);
  const [isViewProProfileModalOpen, setIsViewProProfileModalOpen] = useState(false);
  const [isJoinAsProModalOpen, setIsJoinAsProModalOpen] = useState(false);
  const [selectedPro, setSelectedPro] = useState<any>(null);
  
  // Track joined groups for welcome screen flow
  const [joinedGroupsCount, setJoinedGroupsCount] = useState(0);
  
  // Check if user came from welcome screen
  const fromWelcome = typeof window !== 'undefined' ? localStorage.getItem('torko_from_welcome') === 'follow_people' : false;
  
  // Stages state (moved from renderStagesView to fix hooks violation)
  const [joinedStages, setJoinedStages] = useState<{ [key: number]: boolean }>({});
  const [selectedStage, setSelectedStage] = useState<any>(null);
  const [showStageModal, setShowStageModal] = useState(false);
  
  // Menu state
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const menuButtonRef = useRef<HTMLButtonElement>(null);
  const menuRef = useRef<HTMLDivElement>(null);
  
  // Selected neighborhood state
  const [selectedNeighborhood, setSelectedNeighborhood] = useState<string | null>(null);
  
  // User's joined neighborhoods data
  const myNeighborhoods = [
    { 
      id: 1, 
      name: language === 'bn' ? 'বনানী' : 'Banani',
      nameEn: 'Banani',
      members: 12500,
      color: '#d6775c'
    },
    { 
      id: 2, 
      name: language === 'bn' ? 'গুলশান' : 'Gulshan',
      nameEn: 'Gulshan',
      members: 15200,
      color: '#B8DED6'
    },
    { 
      id: 3, 
      name: language === 'bn' ? 'ধানমন্ডি' : 'Dhanmondi',
      nameEn: 'Dhanmondi',
      members: 18400,
      color: '#7ba3d9'
    },
    { 
      id: 4, 
      name: language === 'bn' ? 'মিরপুর' : 'Mirpur',
      nameEn: 'Mirpur',
      members: 22100,
      color: '#e89b68'
    },
  ];
  
  // Close menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        isMenuOpen &&
        menuRef.current &&
        menuButtonRef.current &&
        !menuRef.current.contains(event.target as Node) &&
        !menuButtonRef.current.contains(event.target as Node)
      ) {
        setIsMenuOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isMenuOpen]);

  // Auto-switch to groups tab when coming from welcome screen
  useEffect(() => {
    if (fromWelcome) {
      setActiveTab('groups');
      console.log('📍 Coming from Welcome Screen - switched to Groups tab');
    }
  }, [fromWelcome]);

  // Debug: Log state changes for Next Step button
  useEffect(() => {
    console.log('🔍 Next Step Button Check:', {
      fromWelcome,
      joinedGroupsCount,
      shouldShow: fromWelcome && joinedGroupsCount > 0
    });
  }, [fromWelcome, joinedGroupsCount]);
  
  // Initial data for Groups
  const initialGroupsData = [
    {
      id: 1,
      name: language === 'bn' ? 'ঢাকা টেক কমিউনিটি' : 'Dhaka Tech Community',
      description: language === 'bn' ? 'প্রযুক্তি প্রেমীদের জন্য একটি গ্রুপ। প্রোগ্রামিং, ডিজাইন, স্টার্টআপ নিয়ে আলোচনা।' : 'A group for tech enthusiasts. Discuss programming, design, startups.',
      members: 2450,
      type: 'public',
      image: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800',
      isJoined: true,
    },
    {
      id: 2,
      name: language === 'bn' ? 'গুলশান মা ও শিশু গ্রুপ' : 'Gulshan Mom & Baby Group',
      description: language === 'bn' ? 'মায়েদের জন্য সাপোর্ট গ্রুপ। শিশু পালন, স্বাস্থ্য টিপস শেয়ার করুন।' : 'Support group for mothers. Share parenting tips and health advice.',
      members: 1820,
      type: 'private',
      image: 'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800',
      isJoined: false,
    },
    {
      id: 3,
      name: language === 'bn' ? 'চট্টগ্রাম ফুটবল ফ্যান্স' : 'Chittagong Football Fans',
      description: language === 'bn' ? 'ফুটবল প্রেমীদের আড্ডা। ম্যাচ আপডেট এবং খেলা নিয়ে আলোচনা।' : 'Football lovers hangout. Match updates and game discussions.',
      members: 3650,
      type: 'public',
      image: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=800',
      isJoined: true,
    },
    {
      id: 4,
      name: language === 'bn' ? 'বনানী বুক ক্লাব' : 'Banani Book Club',
      description: language === 'bn' ? 'বই প্রেমীদের মিলনমেলা। মাসিক বই পড়া এবং আলোচনা সভা।' : 'Book lovers meetup. Monthly book reading and discussion sessions.',
      members: 890,
      type: 'public',
      image: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=800',
      isJoined: false,
    },
  ];

  // Initial data for Events
  const initialEventsData = [
    {
      id: 1,
      title: language === 'bn' ? 'ঢাকা টেক মিটআপ ২০২৫' : 'Dhaka Tech Meetup 2025',
      description: language === 'bn' ? 'স্টার্টআপ এবং প্রযুক্তি নিয়ে নেটওয়ার্কিং ইভেন্ট। শীর্ষ উদ্যোক্তারা উপস্থিত থাকবেন।' : 'Networking event about startups and technology. Top entrepreneurs attending.',
      date: '2025-01-15',
      time: '6:00 PM',
      location: language === 'bn' ? 'বসুন্ধরা কনভেনশন সেন্টার, ঢাকা' : 'Bashundhara Convention Center, Dhaka',
      attendees: 350,
      image: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      isAttending: true,
    },
    {
      id: 2,
      title: language === 'bn' ? 'চট্টগ্রাম মিউজিক ফেস্টিভাল' : 'Chittagong Music Festival',
      description: language === 'bn' ? 'লাইভ সঙ্গীত পরিবেশনা। বাংলা এবং ইংরেজি গানের মিশ্রণ।' : 'Live music performances. Mix of Bangla and English songs.',
      date: '2025-01-20',
      time: '4:00 PM',
      location: language === 'bn' ? 'জালালাবাদ পার্ক, চট্টগ্রাম' : 'Jalalabad Park, Chittagong',
      attendees: 1200,
      image: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800',
      isAttending: false,
    },
    {
      id: 3,
      title: language === 'bn' ? 'স্থানীয় খাবার মেলা' : 'Local Food Fair',
      description: language === 'bn' ? 'ঐতিহ্যবাহী বাংলা খাবারের মেলা। পিঠা, পায়েস এবং আরও অনেক কিছু!' : 'Traditional Bangla food fair. Pithas, payesh and much more!',
      date: '2025-01-12',
      time: '10:00 AM',
      location: language === 'bn' ? 'ধানমন্ডি লেক, ঢাকা' : 'Dhanmondi Lake, Dhaka',
      attendees: 850,
      image: 'https://images.unsplash.com/photo-1606787366850-de6330128bfc?w=800',
      isAttending: true,
    },
  ];

  // Initial data for Stages - live audio rooms
  const initialStagesData = [
    {
      id: 1,
      title: language === 'bn' ? 'স্টার্টআপ সাফল্যের গোপন কথা' : 'Startup Success Secrets',
      host: language === 'bn' ? 'রিফাত হাসান' : 'Rifat Hassan',
      hostUsername: '@rifat_h',
      verified: true,
      listeners: language === 'bn' ? '২৩৪' : '234',
      category: language === 'bn' ? 'ব্যবসা' : 'Business',
      isLive: true,
      duration: language === 'bn' ? '৪৫ মিনিট' : '45 min',
      color: '#d6775c',
    },
    {
      id: 2,
      title: language === 'bn' ? 'AI এবং মেশিন লার্নিং এর ভবিষ্যৎ' : 'Future of AI and Machine Learning',
      host: language === 'bn' ? 'মেহেদী হাসান' : 'Mehedi Hasan',
      hostUsername: '@mehedi_tech',
      verified: true,
      listeners: language === 'bn' ? '৫৬৭' : '567',
      category: language === 'bn' ? 'প্রযুক্তি' : 'Technology',
      isLive: true,
      duration: language === 'bn' ? '১ ঘণ্টা' : '1 hour',
      color: '#B8DED6',
    },
    {
      id: 3,
      title: language === 'bn' ? 'বাংলা কবিতা পাঠ ও আলোচনা' : 'Bangla Poetry Reading & Discussion',
      host: language === 'bn' ? 'নুসরাত জাহান' : 'Nusrat Jahan',
      hostUsername: '@nusrat_writes',
      verified: false,
      listeners: language === 'bn' ? '১২৩' : '123',
      category: language === 'bn' ? 'সাহিত্য' : 'Literature',
      isLive: true,
      duration: language === 'bn' ? '৩০ মিনিট' : '30 min',
      color: '#d6775c',
    },
    {
      id: 4,
      title: language === 'bn' ? 'ডিজিটাল মার্কেটিং মাস্টারক্লাস' : 'Digital Marketing Masterclass',
      host: language === 'bn' ? 'সাবরিনা খান' : 'Sabrina Khan',
      hostUsername: '@sabrina_k',
      verified: false,
      listeners: language === 'bn' ? '৩৮৯' : '389',
      category: language === 'bn' ? 'মার্কেটিং' : 'Marketing',
      isLive: true,
      duration: language === 'bn' ? '২ ঘণ্টা' : '2 hours',
      color: '#000000',
    },
  ];

  // Initial data for Professionals
  const initialProfessionalsData = [
    {
      id: 1,
      name: language === 'bn' ? 'কামাল হোসেন' : 'Kamal Hossain',
      profession: language === 'bn' ? 'প্লাম্বার' : 'Plumber',
      experience: language === 'bn' ? '১৫ বছর' : '15 Years',
      rating: 4.8,
      reviews: 234,
      description: language === 'bn' ? 'বাসা-অফিসের সব ধরনের পানি ও নর্দমা সমস্যার সমাধান। ২৪/৭ সেবা উপলব্ধ।' : 'Solve all water and drainage problems at home-office. 24/7 service available.',
      phone: '01711223344',
      image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
      verified: true,
    },
    {
      id: 2,
      name: language === 'bn' ? 'আয়েশা সিদ্দিকা' : 'Ayesha Siddiqua',
      profession: language === 'bn' ? 'হোম টিউটর' : 'Home Tutor',
      experience: language === 'bn' ? '১০ বছর' : '10 Years',
      rating: 4.9,
      reviews: 456,
      description: language === 'bn' ? 'ক্লাস ১ থেকে ১২ পর্যন্ত সব বিষয়। বিশেষভাবে গণিত ও ইংরেজিতে দক্ষ।' : 'All subjects from class 1 to 12. Specialized in Math & English.',
      phone: '01811334455',
      image: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800',
      verified: true,
    },
    {
      id: 3,
      name: language === 'bn' ? 'রুবেল আহমেদ' : 'Rubel Ahmed',
      profession: language === 'bn' ? 'ইলেকট্রিশিয়ান' : 'Electrician',
      experience: language === 'bn' ? '১২ বছর' : '12 Years',
      rating: 4.7,
      reviews: 189,
      description: language === 'bn' ? 'বৈদ্যুতিক সমস্যা, ওয়্যারিং, ফ্যান-লাইট ইনস্টলেশন। দ্রুত সেবা।' : 'Electrical problems, wiring, fan-light installation. Fast service.',
      phone: '01922556677',
      image: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800',
      verified: true,
    },
  ];

  // Initial data for Alerts
  const initialAlertsData = [
    {
      id: 1,
      type: 'emergency',
      title: language === 'bn' ? 'জরুরি: রক্তের প্রয়োজন!' : 'Urgent: Blood Needed!',
      description: language === 'bn' ? 'B+ রক্তের গ্রুপ দরকার চট্টগ্রাম মেডিকেল কলেজ হাসপাতালে।' : 'B+ blood group required at Chittagong Medical College Hospital.',
      contact: '01712345678',
      location: language === 'bn' ? 'চট্টগ্রাম মেডিকেল কলেজ' : 'Chittagong Medical College',
      time: '2h',
      urgency: 'high',
    },
    {
      id: 2,
      type: 'warning',
      title: language === 'bn' ? 'সতর্কতা: ডেঙ্গু প্রতিরোধ' : 'Warning: Dengue Prevention',
      description: language === 'bn' ? 'এলাকায় ডেঙ্গুর প্রকোপ বাড়ছে। জমানো পানি পরিষ্কার করুন।' : 'Dengue outbreak increasing in area. Clean stagnant water.',
      contact: '999',
      location: language === 'bn' ? 'সিলেট এলাকা' : 'Sylhet Area',
      time: '1h',
      urgency: 'medium',
    },
    {
      id: 3,
      type: 'traffic',
      title: language === 'bn' ? 'ট্রাফিক অ্যালার্ট' : 'Traffic Alert',
      description: language === 'bn' ? 'মিরপুর রোডে ভারী যানজট। বিকল্প পথ ব্যবহার করুন।' : 'Heavy congestion on Mirpur Road. Use alternative routes.',
      contact: '333',
      location: language === 'bn' ? 'মিরপুর রোড, ঢাকা' : 'Mirpur Road, Dhaka',
      time: '4h',
      urgency: 'low',
    },
  ];

  // Initial data for Sales Items
  const initialSalesData = [
    {
      id: 1,
      title: language === 'bn' ? 'iPhone 13 Pro (ব্যবহৃত)' : 'iPhone 13 Pro (Used)',
      description: language === 'bn' ? 'চমৎকার অবস্থায়। ১ বছর ব্যবহৃত। সব এক্সেসরিজ সহ।' : 'Excellent condition. 1 year used. All accessories included.',
      price: language === 'bn' ? '৭৫,০০০ টাকা' : '75,000 BDT',
      negotiable: true,
      location: language === 'bn' ? 'ধানমন্ডি, ঢাকা' : 'Dhanmondi, Dhaka',
      contact: '01711223344',
      image: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800',
      condition: language === 'bn' ? 'ভালো' : 'Good',
      isFree: false,
    },
    {
      id: 2,
      title: language === 'bn' ? 'স্টাডি টেবিল (ফ্রি)' : 'Study Table (Free)',
      description: language === 'bn' ? 'কাঠের টেবিল। সরাতে হবে নিজে। ভালো অবস্থায় আছে।' : 'Wooden table. Must pickup yourself. Good condition.',
      price: language === 'bn' ? 'ফ্রি' : 'Free',
      negotiable: false,
      location: language === 'bn' ? 'বনানী, ঢাকা' : 'Banani, Dhaka',
      contact: '01822334455',
      image: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=800',
      condition: language === 'bn' ? 'ভালো' : 'Good',
      isFree: true,
    },
    {
      id: 3,
      title: language === 'bn' ? 'সাইকেল (প্রায় নতুন)' : 'Bicycle (Almost New)',
      description: language === 'bn' ? '২ মাস ব���যবহৃত। গিয়ার সিস্টেম সহ। চমৎকার অবস্থায়।' : '2 months used. With gear system. Excellent condition.',
      price: language === 'bn' ? '১৫,০০০ টাকা' : '15,000 BDT',
      negotiable: true,
      location: language === 'bn' ? 'চট্টগ্রাম' : 'Chittagong',
      contact: '01933445566',
      image: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=800',
      condition: language === 'bn' ? 'প্রায় নতুন' : 'Like New',
      isFree: false,
    },
  ];

  // Initial data for Neighbourhood Faves
  const initialNeighbourhoodData = [
    {
      id: 1,
      name: language === 'bn' ? 'সুলতান\'স ডাইনার' : 'Sultan\'s Diner',
      category: language === 'bn' ? 'রেস্তোরাঁ' : 'Restaurant',
      description: language === 'bn' ? 'সেরা বিরিয়ানি এবং কাবাব। পরিবারের সাথে খাওয়ার জন্য আদর্শ।' : 'Best biryani and kabab. Perfect for family dining.',
      rating: 4.7,
      reviews: 342,
      location: language === 'bn' ? 'গুলশান ২, ঢাকা' : 'Gulshan 2, Dhaka',
      image: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      priceRange: '$$',
    },
    {
      id: 2,
      name: language === 'bn' ? 'বুক হেভেন' : 'Book Heaven',
      category: language === 'bn' ? 'বইয়ের দোকান' : 'Bookstore',
      description: language === 'bn' ? 'বাংলা এবং ইংরেজি বইয়ের বিশাল সংগ্রহ। শান্ত পড়ার পরিবেশ।' : 'Huge collection of Bangla and English books. Peaceful reading environment.',
      rating: 4.9,
      reviews: 189,
      location: language === 'bn' ? 'ধানমন্ডি, ঢাকা' : 'Dhanmondi, Dhaka',
      image: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=800',
      priceRange: '$',
    },
    {
      id: 3,
      name: language === 'bn' ? 'ফিটনেস জোন জিম' : 'Fitness Zone Gym',
      category: language === 'bn' ? 'জিম' : 'Gym',
      description: language === 'bn' ? 'আধুনিক যন্ত্রপাতি সহ। প্রশিক্ষক এবং যোগ ক্লাস উপলব্ধ।' : 'Modern equipment. Trainer and yoga classes available.',
      rating: 4.6,
      reviews: 267,
      location: language === 'bn' ? 'বনানী, ঢাকা' : 'Banani, Dhaka',
      image: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
      priceRange: '$$',
    },
  ];

  // Initial data for News
  const initialNewsData = [
    {
      id: 1,
      title: language === 'bn' ? 'নতুন মেট্রো স্টেশন শীঘ্রই খোলা হবে' : 'New Metro Station Opening Soon',
      description: language === 'bn' ? 'গুলশান এলাকায় নতুন মেট্রো স্টেশন আগামী মাসে খোলা হবে। যাত্রীদের জন্য সুবিধা বাড়বে।' : 'New metro station in Gulshan area opening next month. Will increase convenience for commuters.',
      author: language === 'bn' ? 'ঢাকা ট্রিবিউন' : 'Dhaka Tribune',
      time: '3h',
      image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      category: language === 'bn' ? 'পরিবহন' : 'Transport',
      likes: 234,
      comments: 45,
    },
    {
      id: 2,
      title: language === 'bn' ? 'স্থানীয় পার্কে নতুন সুবিধা' : 'New Facilities at Local Park',
      description: language === 'bn' ? 'ধানমন্ডি লেকে শিশুদের খেলার নতুন এলাকা এবং হাঁটার পথ তৈরি করা হয়েছে।' : 'New children\'s play area and walking path created at Dhanmondi Lake.',
      author: language === 'bn' ? 'দ্য ডেইলি স্টার' : 'The Daily Star',
      time: '5h',
      image: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
      category: language === 'bn' ? 'কমিউনিটি' : 'Community',
      likes: 567,
      comments: 89,
    },
    {
      id: 3,
      title: language === 'bn' ? 'সপ্তাহান্তে স্বাস্থ্য ক্যাম্প' : 'Weekend Health Camp',
      description: language === 'bn' ? 'আগামী শুক্রবার গুলশান কমিউনিটি সেন্টারে ফ্রি স্বাস্থ্য পরীক্ষা ক্যাম্প অনুষ্ঠিত হবে।' : 'Free health checkup camp to be held this Friday at Gulshan Community Center.',
      author: language === 'bn' ? 'বিডিনিউজ২৪' : 'BDNews24',
      time: '1d',
      image: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800',
      category: language === 'bn' ? 'স্বাস্থ্য' : 'Health',
      likes: 892,
      comments: 134,
    },
  ];
  
  // Data states with initial values
  const [groups, setGroups] = useState<any[]>(initialGroupsData);
  const [stages, setStages] = useState<any[]>(initialStagesData);
  const [events, setEvents] = useState<any[]>(initialEventsData);
  const [professionals, setProfessionals] = useState<any[]>(initialProfessionalsData);
  const [alerts, setAlerts] = useState<any[]>(initialAlertsData);
  const [salesItems, setSalesItems] = useState<any[]>(initialSalesData);
  const [neighbourhoodFaves, setNeighbourhoodFaves] = useState<any[]>(initialNeighbourhoodData);
  const [newsItems, setNewsItems] = useState<any[]>(initialNewsData);

  // Stages data - live audio rooms
  const stagesData = [
    {
      id: 1,
      title: language === 'bn' ? 'স্টার্টআপ সাফল্যের গোপন কথা' : 'Startup Success Secrets',
      host: 'Rifat Hassan',
      hostUsername: '@rifat_h',
      verified: true,
      listeners: language === 'bn' ? '২৩৪' : '234',
      category: language === 'bn' ? 'ব্যবসা' : 'Business',
      isLive: true,
      duration: language === 'bn' ? '৪৫ মিনিট' : '45 min',
      color: '#d6775c',
    },
    {
      id: 2,
      title: language === 'bn' ? 'AI এবং মেশিন লার্নিং এর ভবিষ্যৎ' : 'Future of AI and Machine Learning',
      host: 'Mehedi Hasan',
      hostUsername: '@mehedi_tech',
      verified: true,
      listeners: language === 'bn' ? '৫৬৭' : '567',
      category: language === 'bn' ? 'প্রযুক্তি' : 'Technology',
      isLive: true,
      duration: language === 'bn' ? '১ ঘণ্টা' : '1 hour',
      color: '#B8DED6',
    },
    {
      id: 3,
      title: language === 'bn' ? 'বাংলা কবিতা পাঠ ও আলোচনা' : 'Bangla Poetry Reading & Discussion',
      host: 'Nusrat Jahan',
      hostUsername: '@nusrat_writes',
      verified: false,
      listeners: language === 'bn' ? '১২৩' : '123',
      category: language === 'bn' ? 'সাহিত্য' : 'Literature',
      isLive: true,
      duration: language === 'bn' ? '৩০ মিনিট' : '30 min',
      color: '#d6775c',
    },
  ];

  // Recommended groups data
  const recommendedGroupsData = [
    {
      id: 101,
      name: language === 'bn' ? 'বাংলাদেশ টেক কমিউনিটি' : 'Bangladesh Tech Community',
      description: language === 'bn' ? 'প্রযুক্তি প্রেমীদের জন্য একটি প্ল্যাটফর্ম যেখানে আমরা নতুন প্রযুক্তি, সফটওয়্যার ডেভেলপমেন্ট, এবং ডিজিটাল ট্রেন্ড নিয়ে আলোচনা করি।' : 'A platform for tech enthusiasts where we discuss new technology, software development, and digital trends.',
      members: language === 'bn' ? '২৫,৩০০' : '25,300',
      type: 'public' as const,
      image: 'https://images.unsplash.com/photo-1529209076408-5a115ec9f1c6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0ZWNobm9sb2d5JTIwY29tbXVuaXR5fGVufDF8fHx8MTc2NTEyODQ3OHww&ixlib=rb-4.1.0&q=80&w=1080',
    },
    {
      id: 102,
      name: language === 'bn' ? 'ঢাকা স্টার্টআপ হাব' : 'Dhaka Startup Hub',
      description: language === 'bn' ? 'স্টার্টআপ উদ্যোক্তা ও বিনিয়োগকারীদের নেটওয়ার্ক - ব্যবসায়িক পরামর্শ, ফান্ডিং সুযোগ, এবং সহযোগিতার জন্য।' : 'Network for startup entrepreneurs and investors - for business advice, funding opportunities, and collaboration.',
      members: language === 'bn' ? '১৮,৭০০' : '18,700',
      type: 'public' as const,
      image: 'https://images.unsplash.com/photo-1629787177096-9fbe3e2ef6f3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdGFydHVwJTIwYnVzaW5lc3N8ZW58MXx8fHwxNzY1MTI4NDc5fDA&ixlib=rb-4.1.0&q=80&w=1080',
    },
    {
      id: 103,
      name: language === 'bn' ? 'বাংলা সাহিত্য প্রেমী' : 'Bangla Literature Lovers',
      description: language === 'bn' ? 'বাংলা সাহিত্য নিয়ে আলোচনা ও শেয়ারিং - কবিতা, উপন্যাস, ছোটগল্প এবং সাহিত্যিক বিশ্লেষণ।' : 'Discussion and sharing about Bangla literature - poetry, novels, short stories and literary analysis.',
      members: language === 'bn' ? '১২,৫০০' : '12,500',
      type: 'public' as const,
      image: 'https://images.unsplash.com/photo-1695121435869-11f4791315b3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxib29rcyUyMGxpdGVyYXR1cmV8ZW58MXx8fHwxNzY1MTI4NDc5fDA&ixlib=rb-4.1.0&q=80&w=1080',
    },
  ];

  // State for joined communities
  const [joinedCommunities, setJoinedCommunities] = useState<{ [key: number]: boolean }>({});

  // Sample group posts data
  const groupPosts = [
    {
      id: 1,
      author: language === 'bn' ? 'ক্রিশ্চিয়ান রামিরেজ' : 'Christian Ramirez',
      community: language === 'bn' ? 'উড গ্রীন কমিউনিটি' : 'Wood Green Community',
      avatar: 'https://i.pravatar.cc/150?img=12',
      time: language === 'bn' ? '১ বছর' : '1y',
      content: language === 'bn' ? 'হ্যালো গেমাররা। ঢাকায় পাওয়া এই দুর্দান্ত গেমিং চ্যানেলটি দেখুন। কে কে খেলতে আগ্রহী?' : 'Hello gamers. Checkout this amazing gaming channel I found in Dhaka. Who wants to play?',
      verified: true,
      hasLink: true,
      likes: 1245,
      comments: 89,
    },
    {
      id: 2,
      author: language === 'bn' ? 'সারা আহমেদ' : 'Sarah Ahmed',
      community: language === 'bn' ? 'গুলশান কমিউনিটি' : 'Gulshan Community',
      avatar: 'https://i.pravatar.cc/150?img=5',
      time: language === 'bn' ? '২ দিন' : '2d',
      content: language === 'bn' ? 'আগামীকাল কে সন্ধ্যা ৭টায় বোর্ড গেম নাইটের জন্য প্রস্তুত? আমি কিছু নতুন গেম এনেছি! সবাইকে স্বাগতম।' : 'Who\'s ready for board game night tomorrow at 7pm? I\'ve got some new games! Everyone welcome.',
      verified: false,
      hasLink: false,
      likes: 567,
      comments: 42,
    },
    {
      id: 3,
      author: language === 'bn' ? 'মাইকেল চেন' : 'Michael Chen',
      community: language === 'bn' ? 'ধানমন্ডি কমিউনিটি' : 'Dhanmondi Community',
      avatar: 'https://i.pravatar.cc/150?img=8',
      time: language === 'bn' ? '৫ দিন' : '5d',
      content: language === 'bn' ? 'গতকালের গেম নাইট অসাধারণ ছিল! পরবর্তী সপ্তাহে আবার দেখা হবে। সবাইকে ধন্যবাদ!' : 'Last night\'s game session was awesome! See you all next week. Thanks everyone!',
      verified: true,
      hasLink: false,
      likes: 892,
      comments: 56,
    },
    {
      id: 4,
      author: language === 'bn' ? 'রাফি করিম' : 'Rafi Karim',
      community: language === 'bn' ? 'বনানী কমিউনিটি' : 'Banani Community',
      avatar: 'https://i.pravatar.cc/150?img=15',
      time: language === 'bn' ? '১ সপ্তাহ' : '1w',
      content: language === 'bn' ? 'কেউ কি ফুটবল খেলতে আগ্রহী? শুক্রবার বিকেলে গুলশান পার্কে খেলার পরিকল্পনা করছি।' : 'Anyone interested in playing football? Planning to play at Gulshan Park this Friday afternoon.',
      verified: false,
      hasLink: false,
      likes: 324,
      comments: 28,
    },
    {
      id: 5,
      author: language === 'bn' ? 'নিশাত তাসনিম' : 'Nishat Tasnim',
      community: language === 'bn' ? 'মিরপুর কমিউনিটি' : 'Mirpur Community',
      avatar: 'https://i.pravatar.cc/150?img=9',
      time: language === 'bn' ? '৩ দিন' : '3d',
      content: language === 'bn' ? 'আমাদের কমিউনিটি লাইব্রেরিতে নতুন বই এসেছে। যেকেউ বিনামূল্যে পড়তে পারবেন। সময়: সকাল ১০টা - বিকেল ৫টা।' : 'New books arrived at our community library. Anyone can read for free. Hours: 10am - 5pm.',
      verified: true,
      hasLink: false,
      likes: 678,
      comments: 34,
    },
  ];

  const t = {
    title: language === 'bn' ? 'স্থানীয় কমিউনিটি' : 'Local Community',
    stages: language === 'bn' ? 'স্টেজ' : 'Stages',
    groups: language === 'bn' ? 'গ্রুপ' : 'Groups',
    news: language === 'bn' ? 'খবর' : 'News',
    events: language === 'bn' ? 'ইভেন্ট' : 'Events',
    hirePro: language === 'bn' ? 'প্রফেশনাল হায়ার' : 'Hire a Pro',
    alerts: language === 'bn' ? 'সতর্কতা' : 'Alerts',
    forSale: language === 'bn' ? 'বিক্রয়ের জন্য' : 'For Sale',
    neighbourhoodFaves: language === 'bn' ? 'প্রিয় স্থান' : 'Neighbourhood Faves',
    sponsoredBy: language === 'bn' ? 'স্পন্সর করেছে' : 'Sponsored by',
    search: language === 'bn' ? 'খুঁজ��ন...' : 'Search...',
    createGroup: language === 'bn' ? 'গ্রুপ তৈরি করুন' : 'Create Group',
    createEvent: language === 'bn' ? 'ইভেন্ট তৈরি করুন' : 'Create Event',
    createNews: language === 'bn' ? 'খবর পোস্ট করুন' : 'Post News',
    createPro: language === 'bn' ? 'প্রো হিসেবে যোগ দিন' : 'Join as Pro',
    createAlert: language === 'bn' ? 'সতর্কতা পোস্ট করুন' : 'Post Alert',
    createListing: language === 'bn' ? 'বিজ্ঞাপন দিন' : 'Create Listing',
    members: language === 'bn' ? 'সদস্য' : 'Members',
    join: language === 'bn' ? 'যোগ দিন' : 'Join',
    joined: language === 'bn' ? 'যুক্ত' : 'Joined',
    private: language === 'bn' ? 'ব্যক্তি��ত' : 'Private',
    public: language === 'bn' ? 'পাবলিক' : 'Public',
    viewProfile: language === 'bn' ? 'প্রোফাইল দেখুন' : 'View Profile',
    contact: language === 'bn' ? 'যোগাযোগ করুন' : 'Contact',
    reviews: language === 'bn' ? 'রিভিউ' : 'Reviews',
    experience: language === 'bn' ? 'অভিজ্ঞতা' : 'Experience',
    free: language === 'bn' ? 'ফ্রি' : 'Free',
    negotiable: language === 'bn' ? 'দর নির্ধারণযোগ্য' : 'Negotiable',
    attending: language === 'bn' ? 'যাচ্ছি' : 'Attending',
    attend: language === 'bn' ? 'যোগ দিন' : 'Attend',
    attendees: language === 'bn' ? 'অংশগ্রহণকারী' : 'Attendees',
    likes: language === 'bn' ? 'পছন্দ' : 'Likes',
    comments: language === 'bn' ? 'মন্তব্য' : 'Comments',
    about: language === 'bn' ? 'সম্পর্কে' : 'About',
    anyoneCanJoin: language === 'bn' ? 'যে কেউ যোগ দিতে পারবে' : 'Anyone can join',
  };

  // Categories with images
  const categories = [
    {
      id: 'stages',
      name: t.stages,
      image: 'https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800',
      gradient: 'from-coral-900/70 to-coral-600/70',
    },
    {
      id: 'groups',
      name: t.groups,
      image: 'https://images.unsplash.com/photo-1552196563-55cd4e45efb3?w=800',
      gradient: 'from-green-900/70 to-green-600/70',
    },
  ];

  useEffect(() => {
    const currentRef = scrollContainerRef.current;
    if (currentRef) {
      currentRef.addEventListener('scroll', handleScroll);
    }
    return () => {
      if (currentRef) {
        currentRef.removeEventListener('scroll', handleScroll);
      }
    };
  }, [showHeader]);

  // Scroll to top when category changes
  useEffect(() => {
    if (selectedCategory && scrollContainerRef.current) {
      scrollContainerRef.current.scrollTo({ top: 0, behavior: 'smooth' });
    }
  }, [selectedCategory]);

  const handleScroll = () => {
    const currentRef = scrollContainerRef.current;
    if (currentRef) {
      const currentScrollY = currentRef.scrollTop;
      
      if (Math.abs(currentScrollY - lastScrollY.current) > 10) {
        const isScrollingDown = currentScrollY > lastScrollY.current;
        const shouldShowHeader = !isScrollingDown || currentScrollY < 50;
        
        setShowHeader(shouldShowHeader);
        
        if (onScroll) {
          onScroll(shouldShowHeader);
        }
        
        lastScrollY.current = currentScrollY;
      }
    }
  };

  // Render Stages View
  const renderStagesView = () => {
    return (
      <>
        <div className="space-y-4">
          {/* Create Button */}
          <div className="px-[20px]">
            <button
              className="w-full h-[48px] rounded-[12px] bg-[#d6775c] text-white flex items-center justify-center gap-2 hover:bg-[#c96647] transition-colors"
              onClick={() => {
                // Navigate to create stage screen
              }}
            >
              <Plus className="w-5 h-5" />
              <span className="font-['Roboto',sans-serif] font-medium" style={{ fontVariationSettings: "'wdth' 100" }}>
                {language === 'bn' ? 'স্টেজ তৈরি করুন' : 'Create Stage'}
              </span>
            </button>
          </div>

          {/* Stages List */}
          <div className="px-[20px] space-y-3">
            {(() => {
              const filteredStages = stages.filter(stage => {
                if (!searchQuery.trim()) return true;
                const query = searchQuery.toLowerCase();
                return (
                  stage.title.toLowerCase().includes(query) ||
                  stage.host.toLowerCase().includes(query) ||
                  stage.category.toLowerCase().includes(query)
                );
              });

              if (filteredStages.length === 0 && searchQuery.trim()) {
                return (
                  <div className="py-12 text-center">
                    <Search className="w-12 h-12 mx-auto mb-3 text-[#999999] opacity-30" />
                    <p className="text-[#999999] text-[14px]">
                      {language === 'bn' ? `"${searchQuery}" এর জন্য কোন স্টেজ পাওয়া যায়নি` : `No stages found for "${searchQuery}"`}
                    </p>
                  </div>
                );
              }

              return filteredStages.map((stage, index) => (
              <div
                key={stage.id}
                className="bg-neutral-50 dark:bg-[#0a2f3d] rounded-[10px] p-[16px] relative"
              >
                {/* Live Badge */}
                {stage.isLive && (
                  <div className="absolute top-[16px] right-[16px] flex items-center gap-[6px] bg-red-500 px-[10px] h-[24px] rounded-[12px]">
                    <div className="w-[8px] h-[8px] bg-white rounded-full animate-pulse" />
                    <span className="font-['Roboto',sans-serif] text-[11px] text-white font-medium" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {language === 'bn' ? 'লাইভ' : 'LIVE'}
                    </span>
                  </div>
                )}

                {/* Category Badge */}
                <div 
                  className="inline-flex items-center px-[12px] h-[26px] rounded-[13px] mb-[12px]"
                  style={{ backgroundColor: stage.color }}
                >
                  <span className="font-['Roboto',sans-serif] text-[11px] text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                    {stage.category}
                  </span>
                </div>

                {/* Title */}
                <h3 className="font-['Plus_Jakarta_Display',sans-serif] text-[16px] font-semibold text-[#0f1419] dark:text-white mb-[12px] pr-[80px]">
                  {stage.title}
                </h3>

                {/* Host Info */}
                <div className="flex items-center gap-[8px] mb-[12px]">
                  <div className="w-[32px] h-[32px] relative rounded-full overflow-hidden flex-shrink-0 bg-neutral-200 dark:bg-neutral-700" />
                  <div className="flex items-center gap-[4px]">
                    <span className="font-['Roboto',sans-serif] text-[14px] font-medium text-[#0f1419] dark:text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {stage.host}
                    </span>
                  </div>
                </div>

                {/* Stats */}
                <div className="flex items-center gap-[16px] mb-[12px]">
                  <div className="flex items-center gap-[6px]">
                    <Users className="w-[16px] h-[16px] text-[#9D9D9D]" />
                    <span className="font-['Roboto',sans-serif] text-[13px] text-[#536471] dark:text-[#8e8e8e]" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {stage.listeners} {language === 'bn' ? 'শ্রোতা' : 'listeners'}
                    </span>
                  </div>
                  <div className="flex items-center gap-[6px]">
                    <Clock className="w-[16px] h-[16px] text-[#9D9D9D]" />
                    <span className="font-['Roboto',sans-serif] text-[13px] text-[#536471] dark:text-[#8e8e8e]" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {stage.duration}
                    </span>
                  </div>
                </div>

                {/* Join Button */}
                <button
                  onClick={() => {
                    onNavigate('stageRoom');
                  }}
                  className="w-full h-[44px] rounded-[22px] bg-[#d6775c] text-white font-['Roboto',sans-serif] text-[15px] font-medium hover:bg-[#c96647] transition-all"
                  style={{ fontVariationSettings: "'wdth' 100" }}
                >
                  {language === 'bn' ? 'স্টেজে যোগ দিন' : 'Join Stage'}
                </button>
              </div>
            ));
            })()}
          </div>
        </div>
      </>
    );
  };

  // Render Groups View
  const renderGroupsView = () => (
    <div className="space-y-4">
      {/* Create Button */}
      <div className="px-[20px]">
        <button
          className="w-full h-[48px] rounded-[12px] bg-[#d6775c] text-white flex items-center justify-center gap-2 hover:bg-[#c96647] transition-colors"
          onClick={() => setIsCreateGroupModalOpen(true)}
        >
          <Plus className="w-5 h-5" />
          <span>{t.createGroup}</span>
        </button>
      </div>

      {/* Groups List */}
      <div className="space-y-3 px-[20px]">
        {(() => {
          const filteredGroups = groups.filter(group => {
            if (!searchQuery.trim()) return true;
            const query = searchQuery.toLowerCase();
            return (
              group.name.toLowerCase().includes(query) ||
              group.description.toLowerCase().includes(query)
            );
          });

          if (filteredGroups.length === 0 && searchQuery.trim()) {
            return (
              <div className="py-12 text-center">
                <Search className="w-12 h-12 mx-auto mb-3 text-[#999999] opacity-30" />
                <p className="text-[#999999] text-[14px]">
                  {language === 'bn' ? `"${searchQuery}" এর জন্য কোন গ্রুপ পাওয়া যায়নি` : `No groups found for "${searchQuery}"`}
                </p>
              </div>
            );
          }

          return filteredGroups.map((group) => (
          <div
            key={group.id}
            onClick={() => setSelectedGroup(group)}
            className="bg-white dark:bg-[#0a2f3d] rounded-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a] overflow-hidden cursor-pointer hover:border-[#d6775c] transition-colors"
          >
            <img src={group.image} alt={group.name} className="w-full h-[160px] object-cover" />
            <div className="p-4 space-y-3">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <h3 className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-[#0f1419] dark:text-white">
                      {group.name}
                    </h3>
                    <span className="px-2 py-0.5 rounded-full text-[11px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]">
                      {group.type === 'private' ? t.private : t.public}
                    </span>
                  </div>
                  <p className="text-[13px] text-[#555e67] dark:text-[#9e9e9e] line-clamp-2">
                    {group.description}
                  </p>
                </div>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-1 text-[13px] text-[#9D9D9D]">
                  <Users className="w-4 h-4" />
                  <span>{group.members.toLocaleString()} {t.members}</span>
                </div>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    const wasJoined = group.isJoined;
                    setGroups(groups.map(g => 
                      g.id === group.id ? { ...g, isJoined: !g.isJoined } : g
                    ));
                    // Track joined groups count
                    if (!wasJoined) {
                      setJoinedGroupsCount(prev => {
                        const newCount = prev + 1;
                        console.log('🎯 Joined group! Count:', newCount, 'fromWelcome:', fromWelcome);
                        return newCount;
                      });
                    } else {
                      setJoinedGroupsCount(prev => {
                        const newCount = Math.max(0, prev - 1);
                        console.log('❌ Left group! Count:', newCount);
                        return newCount;
                      });
                    }
                  }}
                  className={`px-4 py-2 rounded-[8px] text-[13px] font-['Roboto:SemiBold',sans-serif] transition-colors ${
                    group.isJoined
                      ? 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
                      : 'bg-[#d6775c] text-white hover:bg-[#c96647]'
                  }`}
                >
                  {group.isJoined ? t.joined : t.join}
                </button>
              </div>
            </div>
          </div>
        ));
        })()}
      </div>
    </div>
  );

  // Render Events View
  const renderEventsView = () => (
    <div className="space-y-4">
      {/* Create Button */}
      <div className="px-[20px]">
        <button
          className="w-full h-[48px] rounded-[12px] bg-[#d6775c] text-white flex items-center justify-center gap-2 hover:bg-[#c96647] transition-colors"
          onClick={() => setIsCreateEventModalOpen(true)}
        >
          <Plus className="w-5 h-5" />
          <span>{t.createEvent}</span>
        </button>
      </div>

      {/* Events List */}
      <div className="space-y-3 px-[20px]">
        {events.map((event) => (
          <div
            key={event.id}
            className="bg-white dark:bg-[#0a2f3d] rounded-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a] overflow-hidden"
          >
            <img src={event.image} alt={event.title} className="w-full h-[180px] object-cover" />
            <div className="p-4 space-y-3">
              <h3 className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-[#0f1419] dark:text-white">
                {event.title}
              </h3>
              <p className="text-[13px] text-[#555e67] dark:text-[#9e9e9e] line-clamp-2">
                {event.description}
              </p>
              <div className="space-y-2">
                <div className="flex items-center gap-2 text-[13px] text-[#555e67] dark:text-[#9e9e9e]">
                  <Calendar className="w-4 h-4 text-[#d6775c]" />
                  <span>{event.date} • {event.time}</span>
                </div>
                <div className="flex items-center gap-2 text-[13px] text-[#555e67] dark:text-[#9e9e9e]">
                  <MapPin className="w-4 h-4 text-[#d6775c]" />
                  <span>{event.location}</span>
                </div>
                <div className="flex items-center gap-2 text-[13px] text-[#9D9D9D]">
                  <Users className="w-4 h-4" />
                  <span>{event.attendees} {language === 'bn' ? 'অংশগ্রহণকারী' : 'Attendees'}</span>
                </div>
              </div>
              <button
                onClick={() => {
                  setEvents(events.map(e => 
                    e.id === event.id ? { ...e, isAttending: !e.isAttending } : e
                  ));
                }}
                className={`w-full h-[40px] rounded-[8px] text-[14px] font-['Roboto:SemiBold',sans-serif] transition-colors ${
                  event.isAttending
                    ? 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
                    : 'bg-[#d6775c] text-white hover:bg-[#c96647]'
                }`}
              >
                {event.isAttending ? (language === 'bn' ? 'যোগদান করছেন' : 'Attending') : (language === 'bn' ? 'যোগদান করুন' : 'Attend')}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  // Render Hire a Pro View
  const renderHireProView = () => (
    <div className="space-y-4">
      {/* Create Pro Account */}
      <div className="px-[20px]">
        <button 
          className="w-full h-[48px] rounded-[12px] bg-[#d6775c] text-white flex items-center justify-center gap-2 hover:bg-[#c96647] transition-colors"
          onClick={() => setIsJoinAsProModalOpen(true)}
        >
          <Plus className="w-5 h-5" />
          <span>{t.createPro}</span>
        </button>
      </div>

      {/* Professionals List */}
      <div className="space-y-3 px-[20px]">
        {professionals.map((pro) => (
          <div
            key={pro.id}
            className="bg-white dark:bg-[#0a2f3d] rounded-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a] p-4"
          >
            <div className="flex gap-3">
              <img src={pro.image} alt={pro.name} className="w-[80px] h-[80px] rounded-[12px] object-cover" />
              <div className="flex-1 space-y-2">
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <h3 className="font-['Roboto:SemiBold',sans-serif] text-[15px] text-[#0f1419] dark:text-white">
                      {pro.name}
                    </h3>
                    {pro.verified && (
                      <svg className="w-4 h-4 text-[#d6775c]" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                      </svg>
                    )}
                  </div>
                  <p className="text-[13px] text-[#d6775c] font-['Roboto:Medium',sans-serif]">
                    {pro.profession}
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <div className="flex items-center gap-1">
                    <Star className="w-4 h-4 fill-[#FFA500] text-[#FFA500]" />
                    <span className="text-[13px] text-[#0f1419] dark:text-white">{pro.rating}</span>
                  </div>
                  <span className="text-[13px] text-[#9D9D9D]">({pro.reviews} {t.reviews})</span>
                  <span className="text-[13px] text-[#9D9D9D]">• {pro.experience} {t.experience}</span>
                </div>
              </div>
            </div>
            <p className="text-[13px] text-[#555e67] dark:text-[#9e9e9e] mt-3 line-clamp-2">
              {pro.description}
            </p>
            <div className="flex gap-2 mt-3">
              <button 
                className="flex-1 h-[36px] rounded-[8px] bg-[#d6775c] text-white text-[13px] font-['Roboto:SemiBold',sans-serif] hover:bg-[#c96647] transition-colors"
                onClick={() => {
                  setSelectedPro(pro);
                  setIsContactProModalOpen(true);
                }}
              >
                {t.contact}
              </button>
              <button 
                className="flex-1 h-[36px] rounded-[8px] border border-[#CCCCCC] dark:border-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e] text-[13px] font-['Roboto:SemiBold',sans-serif] hover:bg-[#F5F5F5] dark:hover:bg-[#0d3a4a] transition-colors"
                onClick={() => {
                  setSelectedPro(pro);
                  setIsViewProProfileModalOpen(true);
                }}
              >
                {t.viewProfile}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  // Render Alerts View
  const renderAlertsView = () => {
    const filterTypes = [
      { id: 'all', label: language === 'bn' ? 'সব' : 'All' },
      { id: 'safety', label: language === 'bn' ? 'নিরাপত্তা' : 'Safety' },
      { id: 'outages', label: language === 'bn' ? 'বিদ্যুৎ' : 'Outages' },
      { id: 'weather', label: language === 'bn' ? 'আবহাওয়া' : 'Weather' },
      { id: 'fires', label: language === 'bn' ? 'অগ্নিকাণ্ড' : 'Fires' },
      { id: 'traffic', label: language === 'bn' ? 'যানজট' : 'Traffic' },
    ];

    return (
      <div className="fixed inset-0 top-[90px] bg-[#1a2332]">
        {/* Map Background */}
        <div className="absolute inset-0 bg-[#1a2332] overflow-hidden">
          {/* Map Grid Pattern */}
          <svg className="absolute inset-0 w-full h-full opacity-20" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
                <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#334155" strokeWidth="0.5"/>
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#grid)" />
          </svg>
          
          {/* Map Roads */}
          <svg className="absolute inset-0 w-full h-full opacity-30" viewBox="0 0 430 600" preserveAspectRatio="none">
            <path d="M 0,150 Q 150,200 300,150 T 430,200" stroke="#475569" strokeWidth="3" fill="none" opacity="0.6"/>
            <path d="M 150,0 L 180,600" stroke="#475569" strokeWidth="2.5" fill="none" opacity="0.5"/>
            <path d="M 100,100 Q 200,250 150,400 T 100,600" stroke="#475569" strokeWidth="2" fill="none" opacity="0.4"/>
            <path d="M 0,300 L 430,350" stroke="#475569" strokeWidth="2.5" fill="none" opacity="0.5"/>
          </svg>

          {/* Location Markers */}
          <div className="absolute top-[28%] left-[35%] w-[40px] h-[40px]">
            <div className="relative w-full h-full animate-pulse">
              <div className="absolute inset-0 bg-white/20 rounded-full"></div>
              <div className="absolute inset-[8px] bg-white rounded-full flex items-center justify-center">
                <AlertTriangle className="w-5 h-5 text-[#ff6b6b]" />
              </div>
            </div>
          </div>

          <div className="absolute top-[35%] left-[30%] w-[32px] h-[32px]">
            <div className="relative w-full h-full">
              <div className="absolute inset-0 bg-white/30 rounded-full"></div>
              <div className="absolute inset-[6px] bg-white rounded-full"></div>
            </div>
          </div>

          <div className="absolute top-[32%] left-[42%] w-[32px] h-[32px]">
            <div className="relative w-full h-full">
              <div className="absolute inset-0 bg-white/30 rounded-full"></div>
              <div className="absolute inset-[6px] bg-white rounded-full"></div>
            </div>
          </div>
        </div>

        {/* Map Controls */}
        <div className="absolute top-[20px] right-4 flex flex-col gap-2 z-20">
          <button className="w-[48px] h-[48px] rounded-[12px] bg-white/10 backdrop-blur-md border border-white/20 flex items-center justify-center">
            <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z" />
            </svg>
          </button>
          <button className="w-[48px] h-[48px] rounded-[12px] bg-white/10 backdrop-blur-md border border-white/20 flex items-center justify-center">
            <svg className="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          </button>
          <div className="px-3 py-2 rounded-[12px] bg-white/10 backdrop-blur-md border border-white/20 flex items-center gap-1">
            <svg className="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z" />
            </svg>
            <span className="text-white text-[12px]">10°C</span>
          </div>
        </div>

        {/* Bottom Sheet */}
        <motion.div
          initial={{ y: 100 }}
          animate={{ y: 0 }}
          className="absolute bottom-0 left-0 right-0 bg-[#0f1419] rounded-t-[24px] max-h-[65vh] overflow-hidden"
        >
          {/* Drag Handle */}
          <div className="flex justify-center pt-3 pb-2">
            <div className="w-[40px] h-[4px] bg-white/20 rounded-full"></div>
          </div>

          {/* Title */}
          <div className="px-5 pt-2 pb-4">
            <h2 className="text-white text-[20px] font-['Roboto:Bold',sans-serif]">
              {language === 'bn' ? 'গুলশান এলাকার সতর্কতা' : 'Alerts in Gulshan Area'}
            </h2>
          </div>

          {/* Filter Chips */}
          <div className="px-5 pb-4">
            <div className="flex gap-2 overflow-x-auto no-scrollbar">
              {filterTypes.map((filter) => (
                <button
                  key={filter.id}
                  onClick={() => setSelectedFilter(filter.id)}
                  className={`px-4 py-2 rounded-full text-[13px] whitespace-nowrap transition-all ${
                    selectedFilter === filter.id
                      ? 'bg-white text-[#0f1419] font-["Roboto:SemiBold",sans-serif]'
                      : 'bg-white/10 text-white/70 border border-white/20'
                  }`}
                >
                  {filter.label}
                </button>
              ))}
            </div>
          </div>

          {/* Alerts List */}
          <div className="px-5 pb-6 space-y-3 overflow-y-auto max-h-[40vh]">
            {alerts.map((alert) => (
              <div
                key={alert.id}
                className="bg-[#1a2332] rounded-[16px] p-4 border border-white/10"
              >
                <div className="flex items-start gap-3">
                  <div className={`w-[48px] h-[48px] rounded-full flex items-center justify-center flex-shrink-0 ${
                    alert.urgency === 'high'
                      ? 'bg-[#ff6b6b]'
                      : alert.urgency === 'medium'
                      ? 'bg-[#ffa500]'
                      : 'bg-[#4dabf7]'
                  }`}>
                    <AlertTriangle className="w-6 h-6 text-white" />
                  </div>
                  
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between mb-1">
                      <h3 className="text-white text-[15px] font-['Roboto:SemiBold',sans-serif]">
                        {alert.title}
                      </h3>
                    </div>
                    <p className="text-white/60 text-[12px] mb-2">
                      0.7 km {language === 'bn' ? 'দূরে' : 'away'} • {alert.time}
                    </p>
                    <p className="text-white/80 text-[13px] leading-relaxed mb-3">
                      {alert.description}
                    </p>
                    
                    <button className="w-full h-[40px] rounded-[10px] bg-white/10 border border-white/20 text-white/70 text-[13px] flex items-center justify-center gap-2 hover:bg-white/15 transition-colors">
                      <MessageCircle className="w-4 h-4" />
                      <span>{language === 'bn' ? 'এই সতর্কতা সম্পর্কে লিখুন' : 'Write about this alert'}</span>
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    );
  };

  // Render For Sale & Free View
  const renderSalesView = () => (
    <div className="space-y-4">
      {/* Create Listing */}
      <div className="px-[20px]">
        <button
          className="w-full h-[48px] rounded-[12px] bg-[#d6775c] text-white flex items-center justify-center gap-2 hover:bg-[#c96647] transition-colors"
          onClick={() => setIsCreateListingModalOpen(true)}
        >
          <Plus className="w-5 h-5" />
          <span>{t.createListing}</span>
        </button>
      </div>

      {/* Items List */}
      <div className="space-y-3 px-[20px]">
        {salesItems.map((item) => (
          <div
            key={item.id}
            className="bg-white dark:bg-[#0a2f3d] rounded-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a] overflow-hidden"
          >
            <div className="relative">
              <img src={item.image} alt={item.title} className="w-full h-[180px] object-cover" />
              {item.isFree && (
                <div className="absolute top-3 right-3 px-3 py-1 rounded-full bg-green-500 text-white text-[12px] font-['Roboto:SemiBold',sans-serif]">
                  {t.free}
                </div>
              )}
            </div>
            <div className="p-4 space-y-3">
              <div>
                <h3 className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-[#0f1419] dark:text-white mb-1">
                  {item.title}
                </h3>
                <div className="flex items-center gap-2 mb-2">
                  <span className="font-['Roboto:Bold',sans-serif] text-[18px] text-[#d6775c]">
                    {item.price}
                  </span>
                  {item.negotiable && (
                    <span className="text-[11px] text-[#9D9D9D]">({t.negotiable})</span>
                  )}
                </div>
                <p className="text-[13px] text-[#555e67] dark:text-[#9e9e9e] line-clamp-2">
                  {item.description}
                </p>
              </div>
              <div className="space-y-1">
                <div className="flex items-center gap-2 text-[12px] text-[#9D9D9D]">
                  <MapPin className="w-3.5 h-3.5" />
                  <span>{item.location}</span>
                </div>
                <div className="flex items-center gap-2 text-[12px] text-[#9D9D9D]">
                  <span>{language === 'bn' ? 'অবস্থা' : 'Condition'}: {item.condition}</span>
                </div>
              </div>
              <button
                className="w-full h-[40px] rounded-[8px] bg-[#d6775c] text-white text-[14px] font-['Roboto:SemiBold',sans-serif] hover:bg-[#c96647] transition-colors"
                onClick={() => {
                  setSelectedItem(item);
                  setIsContactSellerModalOpen(true);
                }}
              >
                {t.contact}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  // If a group is selected, show group detail view
  if (selectedGroup) {
    return (
      <GroupDetailView
        group={selectedGroup}
        language={language}
        onBack={() => setSelectedGroup(null)}
        posts={groupPosts}
        onNavigate={onNavigate}
      />
    );
  }

  // If a category is selected, render its specific view
  if (selectedCategory) {
    return (
      <>
      <div 
        ref={scrollContainerRef}
        className="h-screen bg-[#FAFAFA] dark:bg-[#052029] overflow-y-auto"
      >
        <div className="max-w-auto mx-auto bg-white dark:bg-[#052029] relative pb-20 min-h-full">
          {/* Header */}
          <motion.div 
            initial={{ y: 0 }}
            animate={{ y: showHeader ? 0 : -165 }}
            transition={{ type: 'spring', stiffness: 300, damping: 30 }}
            className="fixed top-0 left-0 right-0 z-10 max-w-[430px] mx-auto bg-white/95 dark:bg-[#052029]/95 backdrop-blur-md"
          >
            {/* Top Bar with Back and Message Button */}
            <div className="px-[20px] pt-[20px] pb-[16px] flex items-center justify-between border-b border-[#EBEBEB] dark:border-[#0d3a4a]">
              <button
                onClick={() => setSelectedCategory(null)}
                className="w-[36px] h-[36px] rounded-full bg-white dark:bg-[#0a2f3d] border border-[#CCCCCC] dark:border-[#0d3a4a] flex items-center justify-center"
              >
                <svg className="w-[8px] h-[14px]" viewBox="0 0 8 14" fill="none">
                  <path 
                    clipRule="evenodd" 
                    d={svgPaths.p195c4a00} 
                    fill="currentColor"
                    className="fill-[#0f1419] dark:fill-white"
                    fillRule="evenodd" 
                  />
                </svg>
              </button>

              <h1 className="font-['Plus_Jakarta_Display',sans-serif] text-[18px] font-semibold text-[#0f1419] dark:text-white">
                {categoryViewTab === 'stages' 
                  ? (language === 'bn' ? 'স্টেজ' : 'Stages')
                  : (language === 'bn' ? 'গ্রুপ' : 'Groups')
                }
              </h1>

              <button 
                onClick={() => onNavigate('messages')}
                className="w-[36px] h-[36px] rounded-full bg-[#d6775c] flex items-center justify-center hover:bg-[#c96647] transition-colors"
              >
                <MessageSquare className="w-[20px] h-[20px] text-white" />
              </button>
            </div>

            {/* Sliding Tab Bar */}
            <div className="px-[20px] pb-[16px]">
              <div 
                className="flex items-center gap-1 p-[5px] bg-[#fafafa] dark:bg-[#0d3a4a]"
                style={{ 
                  borderRadius: '15px',
                }}
              >
                <button
                  className="flex-1 flex flex-col items-center justify-center gap-1"
                  style={{ 
                    borderRadius: '10px',
                    fontSize: '13px',
                    fontWeight: '700',
                    height: '60px',
                    backgroundColor: categoryViewTab === 'stages' ? '#d6775c' : undefined,
                    letterSpacing: '-0.1px',
                    transition: 'all 0.3s ease-in-out',
                  }}
                  className={`flex-1 flex flex-col items-center justify-center gap-1 ${
                    categoryViewTab === 'stages' 
                      ? 'text-[#fafafa]' 
                      : 'text-[#9d9d9d] bg-[#FAFAFA] dark:bg-[#3a3a3a]'
                  }`}
                  onClick={() => setCategoryViewTab('stages')}
                >
                  <Radio className="w-[20px] h-[20px]" strokeWidth={1.5} />
                  {language === 'bn' ? 'স্টেজ' : 'Stages'}
                </button>
                <button
                  className="flex-1 flex flex-col items-center justify-center gap-1"
                  style={{ 
                    borderRadius: '10px',
                    fontSize: '13px',
                    fontWeight: '700',
                    height: '60px',
                    backgroundColor: categoryViewTab === 'groups' ? '#d6775c' : undefined,
                    letterSpacing: '-0.1px',
                    transition: 'all 0.3s ease-in-out',
                  }}
                  className={`flex-1 flex flex-col items-center justify-center gap-1 ${
                    categoryViewTab === 'groups' 
                      ? 'text-[#ffffff]' 
                      : 'text-[#9d9d9d] bg-[#FAFAFA] dark:bg-[#3a3a3a]'
                  }`}
                  onClick={() => setCategoryViewTab('groups')}
                >
                  <Users className="w-[20px] h-[20px]" strokeWidth={1.5} />
                  {language === 'bn' ? 'গ্রুপ' : 'Groups'}
                </button>
              </div>
            </div>
          </motion.div>

          {/* Content */}
          <div className="pt-[175px]">
            {categoryViewTab === 'stages' && renderStagesView()}
            {categoryViewTab === 'groups' && renderGroupsView()}
          </div>
        </div>
      </div>
      
      {/* Modals */}
      <CreateGroupModal
        isOpen={isCreateGroupModalOpen}
        onClose={() => setIsCreateGroupModalOpen(false)}
        onSubmit={(data) => {
          const newGroup = {
            id: groups.length + 1,
            ...data,
            members: 1,
            image: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800',
            isJoined: true,
          };
          setGroups([newGroup, ...groups]);
        }}
        language={language}
      />
      
      <CreateEventModal
        isOpen={isCreateEventModalOpen}
        onClose={() => setIsCreateEventModalOpen(false)}
        onSubmit={(data) => {
          const newEvent = {
            id: events.length + 1,
            ...data,
            attendees: 1,
            image: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
            isAttending: true,
          };
          setEvents([newEvent, ...events]);
        }}
        language={language}
      />
      
      <CreateListingModal
        isOpen={isCreateListingModalOpen}
        onClose={() => setIsCreateListingModalOpen(false)}
        onSubmit={(data) => {
          const newListing = {
            id: salesItems.length + 1,
            ...data,
            image: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800',
            contact: '01700000000',
          };
          setSalesItems([newListing, ...salesItems]);
        }}
        language={language}
      />
      
      <CreateAlertModal
        isOpen={isCreateAlertModalOpen}
        onClose={() => setIsCreateAlertModalOpen(false)}
        onSubmit={(data) => {
          const newAlert = {
            id: alerts.length + 1,
            ...data,
            type: 'custom',
            time: 'Just now',
          };
          setAlerts([newAlert, ...alerts]);
        }}
        language={language}
      />
      
      <ContactSellerModal
        isOpen={isContactSellerModalOpen}
        onClose={() => setIsContactSellerModalOpen(false)}
        itemTitle={selectedItem?.title || ''}
        sellerContact={selectedItem?.contact || ''}
        language={language}
      />
      
      <ContactProModal
        isOpen={isContactProModalOpen}
        onClose={() => setIsContactProModalOpen(false)}
        proName={selectedPro?.name || ''}
        proPhone={selectedPro?.phone || ''}
        proProfession={selectedPro?.profession || ''}
        language={language}
      />
      
      <ViewProProfileModal
        isOpen={isViewProProfileModalOpen}
        onClose={() => setIsViewProProfileModalOpen(false)}
        pro={selectedPro}
        language={language}
      />
      
      <JoinAsProModal
        isOpen={isJoinAsProModalOpen}
        onClose={() => setIsJoinAsProModalOpen(false)}
        onSubmit={(data) => {
          const newPro = {
            id: professionals.length + 1,
            ...data,
            image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
            verified: true,
          };
          setProfessionals([newPro, ...professionals]);
        }}
        language={language}
      />
      </>
    );
  }

  // Main category grid view
  return (
    <div 
      ref={scrollContainerRef}
      className="h-screen bg-[#FAFAFA] dark:bg-[#052029] overflow-y-auto"
    >
      <div className="max-w-auto mx-auto relative pb-20 min-h-full">
        
        {/* Header */}
        <motion.div 
          initial={{ y: 0 }}
          animate={{ y: showHeader ? 0 : -80 }}
          transition={{ type: 'spring', stiffness: 300, damping: 30 }}
          className="fixed top-0 left-0 right-0 z-10 max-w-[430px] mx-auto bg-white/95 dark:bg-[#052029]/95 backdrop-blur-md border-b border-[#EBEBEB] dark:border-[#0d3a4a]"
        >
          <div className="px-[20px] pt-[20px] pb-[16px]">
            {!showSearchBar ? (
              <div className="flex items-center justify-between">
                <button
                  onClick={() => onNavigate('home')}
                  className="w-[36px] h-[36px] rounded-full bg-[#F5F5F5] dark:bg-[#0a2f3d] border border-[#CCCCCC] dark:border-[#0d3a4a] flex items-center justify-center hover:bg-[#EBEBEB] dark:hover:bg-[#0d3a4a] transition-colors"
                >
                  <svg className="w-[8px] h-[14px]" viewBox="0 0 8 14" fill="none">
                    <path 
                      clipRule="evenodd" 
                      d={svgPaths.p195c4a00} 
                      fill="currentColor"
                      fillRule="evenodd"
                      className="fill-[#0f1419] dark:fill-white"
                    />
                  </svg>
                </button>

                <h1 className="font-['Plus_Jakarta_Display',sans-serif] text-[18px] font-semibold text-[#0f1419] dark:text-white">
                  {t.title}
                </h1>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setShowSearchBar(true)}
                    className="w-[36px] h-[36px] rounded-full bg-[#F5F5F5] dark:bg-[#0a2f3d] border border-[#CCCCCC] dark:border-[#0d3a4a] flex items-center justify-center hover:bg-[#EBEBEB] dark:hover:bg-[#0d3a4a] transition-colors"
                  >
                    <Search className="w-[18px] h-[18px] text-[#666666] dark:text-[#999999]" />
                  </button>
                  <div className="relative">
              <button 
                ref={menuButtonRef}
                onClick={() => setIsMenuOpen(!isMenuOpen)}
                className="w-[36px] h-[36px] rounded-full bg-[#d6775c] flex items-center justify-center hover:bg-[#c96647] transition-colors"
              >
                <MoreVertical className="w-[20px] h-[20px] text-white" />
              </button>
              
              {/* Dropdown Menu */}
              <AnimatePresence>
                {isMenuOpen && (
                  <motion.div
                    ref={menuRef}
                    initial={{ opacity: 0, scale: 0.95, y: -10 }}
                    animate={{ opacity: 1, scale: 1, y: 0 }}
                    exit={{ opacity: 0, scale: 0.95, y: -10 }}
                    transition={{ duration: 0.15 }}
                    className="absolute right-0 top-full mt-2 w-[200px] bg-white dark:bg-[#0a2f3d] rounded-[12px] shadow-lg border border-[#EBEBEB] dark:border-[#0d3a4a] overflow-hidden z-50"
                  >
                    <div className="py-1">
                      <button
                        onClick={() => {
                          setIsMenuOpen(false);
                          onNavigate('settings');
                        }}
                        className="w-full px-4 py-3 flex items-center gap-3 hover:bg-[#F5F5F5] dark:hover:bg-[#0d3a4a] transition-colors"
                      >
                        <Settings className="w-[18px] h-[18px] text-[#666666] dark:text-[#999999]" />
                        <span className="text-[14px] text-[#0f1419] dark:text-white">
                          {language === 'bn' ? 'সেটিংস' : 'Settings'}
                        </span>
                      </button>
                      
                      <button
                        onClick={() => {
                          setIsMenuOpen(false);
                          onNavigate('notifications');
                        }}
                        className="w-full px-4 py-3 flex items-center gap-3 hover:bg-[#F5F5F5] dark:hover:bg-[#2a2a2a] transition-colors"
                      >
                        <Bell className="w-[18px] h-[18px] text-[#666666] dark:text-[#999999]" />
                        <span className="text-[14px] text-[#0f1419] dark:text-white">
                          {language === 'bn' ? 'নোটিফিকেশন' : 'Notifications'}
                        </span>
                      </button>
                      
                      <button
                        onClick={() => {
                          setIsMenuOpen(false);
                          // Add help/support functionality here
                        }}
                        className="w-full px-4 py-3 flex items-center gap-3 hover:bg-[#F5F5F5] dark:hover:bg-[#2a2a2a] transition-colors"
                      >
                        <HelpCircle className="w-[18px] h-[18px] text-[#666666] dark:text-[#999999]" />
                        <span className="text-[14px] text-[#0f1419] dark:text-white">
                          {language === 'bn' ? 'সহায়তা' : 'Help'}
                        </span>
                      </button>
                      
                      <div className="border-t border-[#EBEBEB] dark:border-[#0d3a4a] my-1"></div>
                      
                      <button
                        onClick={() => {
                          setIsMenuOpen(false);
                          // Add report functionality here
                        }}
                        className="w-full px-4 py-3 flex items-center gap-3 hover:bg-[#F5F5F5] dark:hover:bg-[#2a2a2a] transition-colors"
                      >
                        <Flag className="w-[18px] h-[18px] text-[#ff3b30]" />
                        <span className="text-[14px] text-[#ff3b30]">
                          {language === 'bn' ? 'রিপোর্ট করুন' : 'Report Issue'}
                        </span>
                      </button>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
                  </div>
                </div>
              </div>
            ) : (
              <div className="flex items-center gap-2">
                <div className="flex-1 flex items-center gap-2 bg-[#F5F5F5] dark:bg-[#0d3a4a] border border-[#CCCCCC] dark:border-[#104050] rounded-full px-4 py-2">
                  <Search className="w-[18px] h-[18px] text-[#666666] dark:text-[#999999] flex-shrink-0" />
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder={language === 'bn' ? 'Stages এবং Groups খুঁজুন...' : 'Search Stages & Groups...'}
                    autoFocus
                    className="flex-1 bg-transparent border-none outline-none text-[#0f1419] dark:text-white text-[14px] placeholder:text-[#999999] dark:placeholder:text-[#666666]"
                  />
                  {searchQuery && (
                    <button
                      onClick={() => setSearchQuery('')}
                      className="w-[20px] h-[20px] flex items-center justify-center flex-shrink-0"
                    >
                      <X className="w-[16px] h-[16px] text-[#666666] dark:text-[#999999]" />
                    </button>
                  )}
                </div>
                <button
                  onClick={() => {
                    setShowSearchBar(false);
                    setSearchQuery('');
                  }}
                  className="text-[#d6775c] text-[14px] font-semibold whitespace-nowrap"
                >
                  {language === 'bn' ? 'বাতিল' : 'Cancel'}
                </button>
              </div>
            )}
          </div>
        </motion.div>

        {/* Sliding Tab Bar */}
        <motion.div 
          className="px-5 pt-3 pb-3 fixed left-0 right-0 z-9 max-w-[430px] mx-auto"
          initial={{ top: '88px' }}
          animate={{ 
            top: showHeader ? '88px' : '0px'
          }}
          transition={{ 
            duration: 0.25, 
            ease: showHeader ? 'easeIn' : 'easeOut'
          }}
        >
          <div 
            className="flex items-center gap-1 p-[5px] bg-[#fafafa] dark:bg-[#0d3a4a]"
            style={{ 
              borderRadius: '15px',
            }}
          >
            <button
              className="flex-1 flex flex-col items-center justify-center gap-1 transition-all duration-300"
              style={{ 
                borderRadius: '10px',
                fontSize: '13px',
                fontWeight: '700',
                height: '60px',
                backgroundColor: activeTab === 'stages' ? '#d6775c' : 'transparent',
                color: activeTab === 'stages' ? '#fafafa' : '#9d9d9d',
                letterSpacing: '-0.1px',
              }}
              onClick={() => setActiveTab('stages')}
            >
              <Radio className="w-[20px] h-[20px]" strokeWidth={1.5} />
              {language === 'bn' ? 'স্টেজ' : 'Stages'}
            </button>
            <button
              className="flex-1 flex flex-col items-center justify-center gap-1 transition-all duration-300"
              style={{ 
                borderRadius: '10px',
                fontSize: '13px',
                fontWeight: '700',
                height: '60px',
                backgroundColor: activeTab === 'groups' ? '#d6775c' : 'transparent',
                color: activeTab === 'groups' ? '#ffffff' : '#9d9d9d',
                letterSpacing: '-0.1px',
              }}
              onClick={() => setActiveTab('groups')}
            >
              <Users className="w-[20px] h-[20px]" strokeWidth={1.5} />
              {language === 'bn' ? 'গ্রুপ' : 'Groups'}
            </button>
          </div>
        </motion.div>

        {/* Stages Tab Content */}
        {activeTab === 'stages' && (
          <div 
            className="px-[16px] pb-6"
            style={{
              paddingTop: showHeader ? '165px' : '77px',
              transition: 'padding-top 0.3s ease-in-out',
            }}
          >
            <div className="flex items-center justify-between mb-[16px] mt-[20px] mr-[0px] ml-[0px]">
              <h2 className="font-['Plus_Jakarta_Display',sans-serif] text-[20px] font-semibold text-[#0f1419] dark:text-white">
                {language === 'bn' ? 'সরাসরি স্টেজ' : 'Live Stages'}
              </h2>
            </div>
          
          <div className="flex flex-col gap-[14px]">
            {stagesData.map((stage) => (
              <div
                key={stage.id}
                className="bg-neutral-50 dark:bg-[#0a2f3d] rounded-[10px] p-[16px] relative"
              >
                {/* Live Badge */}
                {stage.isLive && (
                  <div className="absolute top-[16px] right-[16px] flex items-center gap-[6px] bg-red-500 px-[10px] h-[24px] rounded-[12px]">
                    <div className="w-[8px] h-[8px] bg-white rounded-full animate-pulse" />
                    <span className="font-['Roboto',sans-serif] text-[11px] text-white font-medium" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {language === 'bn' ? 'লাইভ' : 'LIVE'}
                    </span>
                  </div>
                )}

                {/* Category Badge */}
                <div 
                  className="inline-flex items-center px-[12px] h-[26px] rounded-[13px] mb-[12px]"
                  style={{ backgroundColor: stage.color }}
                >
                  <span className="font-['Roboto',sans-serif] text-[11px] text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                    {stage.category}
                  </span>
                </div>

                {/* Title */}
                <h3 className="font-['Plus_Jakarta_Display',sans-serif] text-[16px] font-semibold text-[#0f1419] dark:text-white mb-[12px] pr-[80px]">
                  {stage.title}
                </h3>

                {/* Host Info */}
                <div className="flex items-center gap-[8px] mb-[12px]">
                  <div className="w-[32px] h-[32px] relative rounded-full overflow-hidden flex-shrink-0">
                    <img 
                      src={imgFrame} 
                      alt="" 
                      className="w-full h-full object-cover"
                    />
                  </div>
                  <div className="flex items-center gap-[4px]">
                    <span className="font-['Roboto',sans-serif] text-[14px] font-medium text-[#0f1419] dark:text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {stage.host}
                    </span>
                  </div>
                </div>

                {/* Stats */}
                <div className="flex items-center gap-[16px] mb-[12px]">
                  <div className="flex items-center gap-[6px]">
                    <svg className="w-[16px] h-[16px]" viewBox="0 0 24 24" fill="none">
                      <path d={svgPaths.p1b35f000} fill="#9D9D9D" />
                    </svg>
                    <span className="font-['Roboto',sans-serif] text-[13px] text-[#536471] dark:text-[#8e8e8e]" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {stage.listeners} {language === 'bn' ? 'শ্রোতা' : 'listeners'}
                    </span>
                  </div>
                  <div className="flex items-center gap-[6px]">
                    <svg className="w-[16px] h-[16px]" viewBox="0 0 24 24" fill="none">
                      <circle cx="12" cy="12" r="9" stroke="#9D9D9D" strokeWidth="2" fill="none"/>
                      <path d="M12 7v5l3 3" stroke="#9D9D9D" strokeWidth="2" strokeLinecap="round"/>
                    </svg>
                    <span className="font-['Roboto',sans-serif] text-[13px] text-[#536471] dark:text-[#8e8e8e]" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {stage.duration}
                    </span>
                  </div>
                </div>

                {/* Join Button */}
                <button
                  onClick={() => {
                    setSelectedStage(stage);
                    setShowStageModal(true);
                  }}
                  className="w-full h-[44px] rounded-[22px] bg-[#d6775c] text-white font-['Roboto',sans-serif] text-[15px] font-medium hover:bg-[#c96647] transition-all"
                  style={{ fontVariationSettings: "'wdth' 100" }}
                >
                  {language === 'bn' ? 'স্টেজে যোগ দিন' : 'Join Stage'}
                </button>
              </div>
            ))}
          </div>
        </div>
        )}

        {/* Groups Tab Content */}
        {activeTab === 'groups' && (
          <div 
            className="px-[16px] pb-[100px]"
            style={{
              paddingTop: showHeader ? '165px' : '77px',
              transition: 'padding-top 0.3s ease-in-out',
            }}
          >
            {/* My Local Communities Section */}

            <div className="flex items-center justify-between mb-[16px] mt-[20px] mr-[0px] ml-[0px]">
              <h2 className="font-['Plus_Jakarta_Display',sans-serif] text-[20px] font-semibold text-[#0f1419] dark:text-white">
                {language === 'bn' ? 'প্রস্তাবিত গ্রুপ' : 'Recommended Groups'}
              </h2>
            </div>
          
          <div className="flex flex-col gap-[14px] mt-[5px] mr-[0px] mb-[0px] ml-[0px]">
            {recommendedGroupsData.map((community) => (
              <div
                key={community.id}
                onClick={() => setSelectedGroup(community)}
                className="bg-white dark:bg-[#0a2f3d] rounded-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a] overflow-hidden cursor-pointer hover:border-[#d6775c] transition-colors"
              >
                <img src={community.image} alt={community.name} className="w-full h-[160px] object-cover" />
                <div className="p-4 space-y-3">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="font-['Roboto',sans-serif] text-[16px] font-semibold text-[#0f1419] dark:text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                          {community.name}
                        </h3>
                        <span className="px-2 py-0.5 rounded-full text-[11px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]">
                          {community.type === 'private' ? (language === 'bn' ? 'ব্যক্তিগত' : 'Private') : (language === 'bn' ? 'সার্বজনীন' : 'Public')}
                        </span>
                      </div>
                      <p className="text-[13px] text-[#555e67] dark:text-[#9e9e9e] line-clamp-2">
                        {community.description}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-1 text-[13px] text-[#9D9D9D]">
                      <Users className="w-4 h-4" />
                      <span>{community.members} {language === 'bn' ? 'সদস্য' : 'members'}</span>
                    </div>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        const wasJoined = joinedCommunities[community.id];
                        setJoinedCommunities(prev => ({
                          ...prev,
                          [community.id]: !prev[community.id]
                        }));
                        
                        // Track joined groups count for welcome screen flow
                        if (!wasJoined) {
                          setJoinedGroupsCount(prev => {
                            const newCount = prev + 1;
                            console.log('🎯 Joined recommended group! Count:', newCount, 'fromWelcome:', fromWelcome);
                            return newCount;
                          });
                        } else {
                          setJoinedGroupsCount(prev => {
                            const newCount = Math.max(0, prev - 1);
                            console.log('❌ Left recommended group! Count:', newCount);
                            return newCount;
                          });
                        }
                      }}
                      className={`px-4 py-2 rounded-[8px] text-[13px] font-['Roboto',sans-serif] font-semibold transition-colors ${
                        joinedCommunities[community.id]
                          ? 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
                          : 'bg-[#d6775c] text-white hover:bg-[#c96647]'
                      }`}
                      style={{ fontVariationSettings: "'wdth' 100" }}
                    >
                      {joinedCommunities[community.id] ? (language === 'bn' ? 'যুক্ত হয়েছে' : 'Joined') : (language === 'bn' ? 'যোগ দিন' : 'Join')}
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
        )}

        {/* Floating Action Button */}
        <AnimatePresence>
          {activeTab === 'groups' && (
            <motion.button
              initial={{ scale: 0, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0, opacity: 0 }}
              transition={{ type: 'spring', stiffness: 300, damping: 25 }}
              onClick={() => {
                console.log('FAB button clicked!');
                setIsCreateGroupModalOpen(true);
              }}
              className="fixed bottom-[100px] right-[20px] w-[56px] h-[56px] rounded-full bg-[#d6775c] shadow-lg flex items-center justify-center hover:bg-[#c96647] transition-colors z-20"
              style={{
                boxShadow: '0 4px 12px rgba(214, 119, 92, 0.4)',
              }}
              aria-label={language === 'bn' ? 'নতুন গ্রুপ তৈরি করুন' : 'Create new group'}
            >
              <Plus className="w-[24px] h-[24px] text-white" strokeWidth={2.5} />
            </motion.button>
          )}
          {activeTab === 'stages' && (
            <motion.button
              initial={{ scale: 0, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0, opacity: 0 }}
              transition={{ type: 'spring', stiffness: 300, damping: 25 }}
              onClick={() => {
                console.log('Stage FAB clicked!');
                setIsCreateStageModalOpen(true);
              }}
              className="fixed bottom-[100px] right-[20px] w-[56px] h-[56px] rounded-full bg-[#d6775c] shadow-lg flex items-center justify-center hover:bg-[#c96647] transition-colors z-20"
              style={{
                boxShadow: '0 4px 12px rgba(214, 119, 92, 0.4)',
              }}
              aria-label={language === 'bn' ? 'নতুন স্টেজ শুরু করুন' : 'Start new stage'}
            >
              <Radio className="w-[24px] h-[24px] text-white" strokeWidth={2} />
            </motion.button>
          )}
        </AnimatePresence>

        {/* Stage Join Modal */}
        <AnimatePresence>
          {showStageModal && selectedStage && (
            <>
              {/* Backdrop */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setShowStageModal(false)}
                className="fixed inset-0 bg-black/60 backdrop-blur-sm z-[110]"
              />

              {/* Stage Modal */}
              <motion.div
                initial={{ opacity: 0, scale: 0.9, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.9, y: 20 }}
                transition={{ type: 'spring', stiffness: 300, damping: 25 }}
                className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[90%] max-w-[380px] bg-white dark:bg-[#0a2f3d] rounded-[24px] shadow-2xl z-[111] overflow-hidden"
              >
                {/* Header with Gradient */}
                <div 
                  className="relative h-[120px] p-[20px] flex flex-col justify-end"
                  style={{ 
                    background: `linear-gradient(135deg, ${selectedStage.color} 0%, ${selectedStage.color === '#000000' ? '#2a2a2a' : selectedStage.color + 'dd'} 100%)` 
                  }}
                >
                  {/* Close Button */}
                  <button
                    onClick={() => setShowStageModal(false)}
                    className="absolute top-[16px] right-[16px] w-[32px] h-[32px] rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center hover:bg-white/30 transition-all"
                  >
                    <X className="w-[18px] h-[18px] text-white" />
                  </button>

                  {/* Live Badge */}
                  {selectedStage.isLive && (
                    <div className="absolute top-[16px] left-[16px] flex items-center gap-[6px] bg-red-500 px-[12px] h-[28px] rounded-[14px]">
                      <div className="w-[8px] h-[8px] bg-white rounded-full animate-pulse" />
                      <span className="font-['Roboto',sans-serif] text-[12px] text-white font-bold" style={{ fontVariationSettings: "'wdth' 100" }}>
                        {language === 'bn' ? 'লাইভ' : 'LIVE'}
                      </span>
                    </div>
                  )}

                  {/* Category */}
                  <div className="inline-flex items-center px-[12px] h-[26px] rounded-[13px] bg-white/20 backdrop-blur-sm w-fit">
                    <span className="font-['Roboto',sans-serif] text-[11px] text-white font-medium" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {selectedStage.category}
                    </span>
                  </div>
                </div>

                {/* Content */}
                <div className="p-[24px]">
                  {/* Title */}
                  <h2 className="font-['Plus_Jakarta_Display',sans-serif] text-[20px] font-bold text-[#0f1419] dark:text-white mb-[16px] leading-[26px]">
                    {selectedStage.title}
                  </h2>

                  {/* Host Info */}
                  <div className="flex items-center gap-[12px] mb-[20px] p-[12px] bg-neutral-50 dark:bg-[#0d3a4a] rounded-[12px]">
                    <div className="w-[48px] h-[48px] relative rounded-full overflow-hidden flex-shrink-0">
                      <img 
                        src={imgFrame} 
                        alt="" 
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-[4px] mb-[2px]">
                        <span className="font-['Roboto',sans-serif] text-[16px] font-bold text-[#0f1419] dark:text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                          {selectedStage.host}
                        </span>
                      </div>
                      <p className="font-['Roboto',sans-serif] text-[13px] text-[#536471] dark:text-[#9e9e9e]" style={{ fontVariationSettings: "'wdth' 100" }}>
                        {language === 'bn' ? 'হোস্ট' : 'Host'} • {selectedStage.hostUsername}
                      </p>
                    </div>
                  </div>

                  {/* Stats Grid */}
                  <div className="grid grid-cols-2 gap-[12px] mb-[24px]">
                    <div className="bg-neutral-50 dark:bg-[#0d3a4a] rounded-[12px] p-[16px]">
                      <div className="flex items-center gap-[8px] mb-[6px]">
                        <svg className="w-[20px] h-[20px]" viewBox="0 0 24 24" fill="none">
                          <path d={svgPaths.p1b35f000} fill="#d6775c" />
                        </svg>
                        <span className="font-['Plus_Jakarta_Display',sans-serif] text-[12px] text-[#536471] dark:text-[#9e9e9e] font-medium">
                          {language === 'bn' ? 'শ্রোতা' : 'Listeners'}
                        </span>
                      </div>
                      <p className="font-['Plus_Jakarta_Display',sans-serif] text-[24px] font-bold text-[#0f1419] dark:text-white">
                        {selectedStage.listeners}
                      </p>
                    </div>
                    <div className="bg-neutral-50 dark:bg-[#0d3a4a] rounded-[12px] p-[16px]">
                      <div className="flex items-center gap-[8px] mb-[6px]">
                        <svg className="w-[20px] h-[20px]" viewBox="0 0 24 24" fill="none">
                          <circle cx="12" cy="12" r="9" stroke="#d6775c" strokeWidth="2" fill="none"/>
                          <path d="M12 7v5l3 3" stroke="#d6775c" strokeWidth="2" strokeLinecap="round"/>
                        </svg>
                        <span className="font-['Plus_Jakarta_Display',sans-serif] text-[12px] text-[#536471] dark:text-[#9e9e9e] font-medium">
                          {language === 'bn' ? 'সময়' : 'Duration'}
                        </span>
                      </div>
                      <p className="font-['Plus_Jakarta_Display',sans-serif] text-[20px] font-bold text-[#0f1419] dark:text-white">
                        {selectedStage.duration}
                      </p>
                    </div>
                  </div>

                  {/* Info Text */}
                  <div className="bg-[#d6775c]/10 dark:bg-[#d6775c]/20 border border-transparent dark:border-[#d6775c]/30 rounded-[12px] p-[14px] mb-[20px]">
                    <p className="font-['Roboto',sans-serif] text-[13px] text-[#0f1419] dark:text-[#e8e8e8] leading-[19px]" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {language === 'bn' 
                        ? 'এই স্টেজে যোগ দিয়ে আপনি হোস্ট এবং অন্যান্য শ্রোতাদের সাথে লাইভ অডিও কথোপকথনে অংশ নিতে পারবেন। আপনার মাইক্রোফোন ডিফল্টভাবে বন্ধ থাকবে।'
                        : 'By joining this stage, you can participate in live audio conversation with the host and other listeners. Your microphone will be muted by default.'
                      }
                    </p>
                  </div>

                  {/* Action Buttons */}
                  <div className="flex gap-[12px]">
                    <button
                      onClick={() => setShowStageModal(false)}
                      className="flex-1 h-[50px] rounded-[25px] border-2 border-[#e6e6e6] dark:border-[#104050] bg-transparent dark:bg-transparent text-[#0f1419] dark:text-white font-['Roboto',sans-serif] text-[16px] font-medium hover:bg-neutral-50 dark:hover:bg-[#104050] transition-all"
                      style={{ fontVariationSettings: "'wdth' 100" }}
                    >
                      {language === 'bn' ? 'বাতিল' : 'Cancel'}
                    </button>
                    <button
                      onClick={() => {
                        setJoinedStages(prev => ({ ...prev, [selectedStage.id]: true }));
                        setShowStageModal(false);
                        // Navigate to stage room
                        onNavigate('stageRoom');
                      }}
                      className="flex-1 h-[50px] rounded-[25px] bg-[#d6775c] text-white font-['Roboto',sans-serif] text-[16px] font-bold hover:bg-[#c96647] transition-all shadow-lg"
                      style={{ fontVariationSettings: "'wdth' 100" }}
                    >
                      {language === 'bn' ? 'এখনই যোগ দিন' : 'Join Now'}
                    </button>
                  </div>
                </div>
              </motion.div>
            </>
          )}
        </AnimatePresence>

        {/* Modals */}
        <CreateGroupModal
          isOpen={isCreateGroupModalOpen}
          onClose={() => {
            console.log('Closing CreateGroupModal');
            setIsCreateGroupModalOpen(false);
          }}
          onSubmit={(data) => {
            const newGroup = {
              id: groups.length + 1,
              ...data,
              members: 1,
              image: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800',
              isJoined: true,
            };
            setGroups([newGroup, ...groups]);
          }}
          language={language}
        />

        <CreateStageModal
          isOpen={isCreateStageModalOpen}
          onClose={() => {
            console.log('Closing CreateStageModal');
            setIsCreateStageModalOpen(false);
          }}
          onSubmit={(data) => {
            const newStage = {
              id: stages.length + 1,
              ...data,
              host: language === 'bn' ? 'আপনি' : 'You',
              hostUsername: '@you',
              verified: false,
              listeners: '0',
              category: data.category,
              isLive: true,
              duration: '0 min',
              image: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800',
            };
            setStages([newStage, ...stages]);
            // Pass stage data to App
            if (onStageCreate) {
              onStageCreate(newStage);
            }
            // Navigate to stage room
            onNavigate('stageRoom');
          }}
          language={language}
        />
      </div>
      
      {/* Next Step Button - Only shown when from welcome screen and joined at least 1 group */}
      {fromWelcome && (
        <div className="fixed bottom-0 left-0 right-0 pb-[88px] px-4 bg-gradient-to-t from-[#FAFAFA] dark:from-[#052029] via-[#FAFAFA]/95 dark:via-[#052029]/95 to-transparent pt-4 pointer-events-none">
          <motion.button
            initial={{ opacity: 0, y: 20 }}
            animate={{ 
              opacity: 1, 
              y: 0,
              scale: joinedGroupsCount > 0 ? [1, 1.02, 1] : 1
            }}
            transition={{
              scale: { duration: 0.3, times: [0, 0.5, 1] }
            }}
            disabled={joinedGroupsCount === 0}
            onClick={() => {
              if (joinedGroupsCount === 0) return;
              
              console.log('🎉 Next Step clicked! Joined groups:', joinedGroupsCount);
              
              // Mark follow people task as complete
              const savedProgress = localStorage.getItem('torko_welcome_progress');
              
              if (savedProgress) {
                try {
                  const progress = JSON.parse(savedProgress);
                  const updatedProgress = progress.map((item: any) => 
                    item.id === 'follow_people' ? { ...item, completed: true } : item
                  );
                  localStorage.setItem('torko_welcome_progress', JSON.stringify(updatedProgress));
                  console.log('✅ Follow group completion saved:', updatedProgress);
                } catch (e) {
                  console.error('Error updating welcome progress:', e);
                }
              } else {
                // Create initial progress if doesn't exist
                const initialProgress = [
                  { id: 'complete_profile', completed: true },
                  { id: 'find_community', completed: true },
                  { id: 'follow_people', completed: true },
                  { id: 'first_post', completed: false },
                ];
                localStorage.setItem('torko_welcome_progress', JSON.stringify(initialProgress));
                console.log('✅ Created initial progress with follow group complete:', initialProgress);
              }
              
              // Clear the flag and navigate back to welcome screen
              localStorage.removeItem('torko_from_welcome');
              onNavigate('welcomeProfile');
            }}
            className={`w-full h-[52px] rounded-full text-white font-['Noto_Sans_Bengali',sans-serif] text-[16px] font-medium shadow-lg transition-all pointer-events-auto ${
              joinedGroupsCount > 0
                ? 'bg-gradient-to-r from-[#d97757] to-[#c96647] hover:from-[#c96647] hover:to-[#b85537]'
                : 'bg-gray-400 cursor-not-allowed opacity-50'
            }`}
          >
            <span className="flex items-center justify-center gap-2">
              {language === 'bn' ? 'পরবর্তী ধাপ' : 'Next Step'}
              {joinedGroupsCount > 0 && (
                <span className="px-2 py-0.5 rounded-full bg-white/20 text-[14px]">
                  {joinedGroupsCount}
                </span>
              )}
            </span>
          </motion.button>
          
          {/* Helper text */}
          {joinedGroupsCount === 0 && (
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="text-center text-[13px] text-[#9D9D9D] mt-3 pointer-events-none"
            >
              {language === 'bn' 
                ? 'পরবর্তী ধাপে যেতে অন্তত ১টি গ্রুপে যোগ দিন' 
                : 'Join at least 1 group to continue'}
            </motion.p>
          )}
        </div>
      )}
    </div>
  );
};