import React, { createContext, useContext, useState, useEffect } from 'react';
import { Notification } from '../NotificationBar';

type Language = 'bn' | 'en';
type Theme = 'light' | 'dark';

interface AppContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  theme: Theme;
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;
  toggleLanguage: () => void;
  t: (key: string) => string;
  showNotification: (notification: Omit<Notification, 'id'>) => void;
  notification: Notification | null;
  dismissNotification: (id: string) => void;
  openConversation: (name: string, color: string, initials: string, avatar?: string, isGroup?: boolean) => void;
  conversationData: ConversationData | null;
  closeConversation: () => void;
  startCall: (name: string, color: string, initials: string, isVideo: boolean, isIncoming?: boolean, isGroup?: boolean) => void;
  callData: CallData | null;
  endCall: () => void;
  hideBottomNav: boolean;
  setHideBottomNav: (hide: boolean) => void;
  openPostDetail: (postData: any) => void;
  postDetailData: any | null;
  closePostDetail: () => void;
  messageNotificationCount: number;
  resetMessageNotifications: () => void;
}

interface ConversationData {
  name: string;
  color: string;
  initials: string;
  avatar?: string;
  isGroup?: boolean;
}

interface CallData {
  name: string;
  color: string;
  initials: string;
  isVideo: boolean;
  isIncoming: boolean;
  isGroup?: boolean;
}

const translations: Record<string, Record<Language, string>> = {
  // App Name
  appName: { bn: 'তর্ক', en: 'Torko' },
  
  // Onboarding
  welcome: { bn: 'স্বাগতম', en: 'Welcome' },
  welcomeToTorko: { bn: 'তর্কে আপনাকে স্বাগতম', en: 'Welcome to Torko' },
  welcomeDescription: { bn: 'বাংলাদেশের প্রথম সোশ্যাল মিডিয়া প্ল্যাটফর্মে আপনাকে স্বাগতম', en: 'Welcome to Bangladesh\'s first social media platform' },
  getStarted: { bn: 'শুরু করুন', en: 'Get Started' },
  next: { bn: 'পরবর্তী', en: 'Next' },
  skip: { bn: 'এড়িয়ে যান', en: 'Skip' },
  
  // Auth
  back: { bn: 'ফিরে যান', en: 'Back' },
  phoneNumber: { bn: 'ফোন নম্বর', en: 'Phone Number' },
  enterPhone: { bn: 'আপনার নাম্বার দিন', en: 'Enter your number' },
  phoneNumberLabel: { bn: 'ফোন নাম্বার', en: 'Phone Number' },
  sendOTPDescription: { bn: 'আমরা আপনার ফোন নাম্বারে একটি OTP পাঠাব', en: 'We will send an OTP to your phone number' },
  sendOTP: { bn: 'OTP পাঠান', en: 'Send OTP' },
  continue: { bn: 'চালিয়ে যান', en: 'Continue' },
  verifyOTP: { bn: 'OTP যাচাই করুন', en: 'Verify OTP' },
  enterOTP: { bn: 'OTP কোড লিখুন', en: 'Enter OTP code' },
  otpSentTo: { bn: 'নাম্বারে পাঠানো কোড দিন', en: 'Enter code sent to' },
  verify: { bn: 'যাচাই করুন', en: 'Verify' },
  resendOTP: { bn: 'আবার পাঠান', en: 'Resend' },
  resendIn: { bn: 'পুনরায় পাঠান', en: 'Resend in' },
  didntGetCode: { bn: 'কোড পাননি?', en: 'Didn\'t get a code?' },
  invalidPhone: { bn: 'দয়া করে একটি বৈধ নাম্বার লিখুন।', en: 'Please enter a valid number.' },
  phoneExample: { bn: 'উদাহরণ: 1743-388365', en: 'Example: 1743-388365' },
  incorrectCode: { bn: 'ভুল কোড। আবার চেষ্টা করুন।', en: 'Incorrect code. Try again.' },
  otpResent: { bn: 'OTP পুনরায় পাঠানো হয়েছে', en: 'OTP resent successfully' },
  welcomeMessage: { bn: 'স্বাগতম! তর্কে আপনার যাত্রা শুরু হলো।', en: 'Welcome! Your journey on Torko begins.' },
  
  // Profile Data Onboarding
  completeProfile: { bn: 'প্রোফাইল সম্পূর্ণ করুন', en: 'Complete Your Profile' },
  completeProfileDesc: { bn: 'আপনার তথ্য দিয়ে শুরু করুন', en: 'Get started by adding your details' },
  fullName: { bn: 'পুরো নাম', en: 'Full Name' },
  enterFullName: { bn: 'আপনার নাম লিখুন', en: 'Enter your name' },
  dateOfBirth: { bn: 'জন্ম তারিখ', en: 'Date of Birth' },
  selectDate: { bn: 'তারিখ নির্বাচন করুন', en: 'Select date' },
  gender: { bn: 'লিঙ্গ', en: 'Gender' },
  selectGender: { bn: 'লিঙ্গ নির্বাচন করুন', en: 'Select gender' },
  male: { bn: 'পুরুষ', en: 'Male' },
  female: { bn: 'নারী', en: 'Female' },
  other: { bn: 'অন্যান্য', en: 'Other' },
  preferNotToSay: { bn: 'বলতে চাই না', en: 'Prefer not to say' },
  letsGo: { bn: 'চলুন শুরু করি', en: 'Let\'s Go' },
  
  // Cookie Notice
  cookiesAbout: { bn: 'কুকিজ সম্পর্কে:', en: 'About Cookies:' },
  cookiesDescription: { bn: 'আমরা আপনার অভিজ্ঞতা উন্নত করতে এবং সাইটের কার্যকারিতা বিশ্লেষণ করতে কুকিজ ব্যবহার করি। এই সেবা ব্যবহার করে, আপনি কুকিজ ব্যবহারে সম্মতি দিচ্ছেন।', en: 'We use cookies to improve your experience and analyze site functionality. By using this service, you consent to the use of cookies.' },
  acceptCookies: { bn: 'কুকিজ গ্রহণ করুন', en: 'Accept Cookies' },
  
  // Profile Setup
  setupProfile: { bn: 'প্রোফাইল সাজান', en: 'Setup Profile' },
  username: { bn: 'ব্যবহারকারীর নাম', en: 'Username' },
  enterUsername: { bn: 'আপনার নাম লিখুন', en: 'Enter your username' },
  bio: { bn: 'বায়ো', en: 'Bio' },
  enterBio: { bn: 'নিজের সম্পর্কে লিখুন', en: 'Tell us about yourself' },
  birthdate: { bn: 'জন্ম তারিখ', en: 'Birth Date' },
  selectBirthdate: { bn: 'জন্ম তারিখ নির্বাচন করুন', en: 'Select birth date' },
  agreeTermsPrefix: { bn: 'আমি', en: 'I agree to the' },
  terms: { bn: 'শর্তাবলী', en: 'Terms' },
  and: { bn: 'ও', en: 'and' },
  policy: { bn: 'নীতিমালা', en: 'Privacy Policy' },
  agreeTermsSuffix: { bn: 'মেনে নিচ্ছি', en: '' },
  uploadPhoto: { bn: 'ছবি আপলোড করুন', en: 'Upload Photo' },
  complete: { bn: 'সম্পন্ন করুন', en: 'Complete' },
  
  // Navigation
  home: { bn: 'হোম', en: 'Home' },
  communities: { bn: 'কমিউনিটি', en: 'Communities' },
  stages: { bn: 'স্টেজ', en: 'Stages' },
  messages: { bn: 'মেসেজ', en: 'Messages' },
  profile: { bn: 'প্রোফাইল', en: 'Profile' },
  explore: { bn: 'অন্বেষণ', en: 'Explore' },
  notifications: { bn: 'নোটিফিকেশন', en: 'Notifications' },
  settings: { bn: 'সেটিংস', en: 'Settings' },
  
  // Feed
  forYou: { bn: 'আপনার জন্য', en: 'For You' },
  following: { bn: 'ফলোয়িং', en: 'Following' },
  trending: { bn: 'ট্রেন্ডিং', en: 'Trending' },
  newPost: { bn: 'নতুন পোস্ট', en: 'New Post' },
  
  // Post Actions
  like: { bn: 'পছন্দ', en: 'Like' },
  comment: { bn: 'মন্তব্য', en: 'Comment' },
  share: { bn: 'শেয়ার', en: 'Share' },
  reactions: { bn: 'রিয়েকশন', en: 'reactions' },
  comments: { bn: 'মন্তব্য', en: 'comments' },
  shares: { bn: 'শেয়ার', en: 'shares' },
  follow: { bn: 'ফলো করুন', en: 'Follow' },
  following_action: { bn: 'ফলোয়িং', en: 'Following' },
  
  // Post Creation
  createPost: { bn: 'পোস্ট তৈরি করুন', en: 'Create Post' },
  whatsOnYourMind: { bn: 'আপনার মনে কি আছে?', en: 'What\'s on your mind?' },
  addPhoto: { bn: 'ছবি যোগ করুন', en: 'Add Photo' },
  addVideo: { bn: 'ভিডিও যোগ করুন', en: 'Add Video' },
  post: { bn: 'পোস্ট করুন', en: 'Post' },
  voiceToText: { bn: 'ভয়েস টু টেক্সট', en: 'Voice to Text' },
  newPostTitle: { bn: 'নতুন পোস্ট', en: 'New Post' },
  yourName: { bn: 'আপনার নাম', en: 'Your Name' },
  everyone: { bn: 'সবাই', en: 'Everyone' },
  community: { bn: 'কমিউনিটি', en: 'Community' },
  friends: { bn: 'বন্ধুরা', en: 'Friends' },
  anyoneCanSee: { bn: 'যে কেউ দেখতে পারবে', en: 'Anyone can see' },
  onlyYourCommunity: { bn: 'শুধু আপনার কমিউনিটি', en: 'Only your community' },
  onlyFriends: { bn: 'শুধু বন্ধুরা', en: 'Only friends' },
  category: { bn: 'বিষয়শ্রেণী', en: 'Category' },
  general: { bn: 'সাধারণ', en: 'General' },
  helpNeeded: { bn: 'সাহায্য চাই', en: 'Help Needed' },
  event: { bn: 'ইভেন্ট', en: 'Event' },
  forSale: { bn: 'বিক্রয়', en: 'For Sale' },
  news: { bn: 'খবর', en: 'News' },
  question: { bn: 'প্রশ্ন', en: 'Question' },
  location: { bn: 'অবস্থান', en: 'Location' },
  photo: { bn: 'ছবি', en: 'Photo' },
  privacy: { bn: 'গোপনীয়তা', en: 'Privacy' },
  public: { bn: 'সর্বজনীন', en: 'Public' },
  
  // Communities
  createCommunity: { bn: 'কমিউনিটি তৈরি করুন', en: 'Create Community' },
  joinCommunity: { bn: 'যোগ দিন', en: 'Join' },
  members: { bn: 'সদস্য', en: 'Members' },
  activeNow: { bn: 'এখন সক্রিয়', en: 'Active Now' },
  
  // Messages
  newMessage: { bn: 'নতুন মেসেজ', en: 'New Message' },
  typeMessage: { bn: 'মেসেজ লিখুন', en: 'Type a message' },
  voiceCall: { bn: 'ভয়েস কল', en: 'Voice Call' },
  videoCall: { bn: 'ভিডিও কল', en: 'Video Call' },
  
  // Profile
  posts: { bn: 'পোস্ট', en: 'Posts' },
  followers: { bn: 'ফলোয়ার', en: 'Followers' },
  saved: { bn: 'সংরক্ষিত', en: 'Saved' },
  editProfile: { bn: 'প্রোফাইল সম্পাদনা', en: 'Edit Profile' },
  
  // Settings
  accountSettings: { bn: 'অ্যাকাউন্ট সেটিংস', en: 'Account Settings' },
  privacySettings: { bn: 'গোপনীয়তা সেটিংস', en: 'Privacy Settings' },
  notificationSettings: { bn: 'নোটিফিকেশন সেটিংস', en: 'Notification Settings' },
  language: { bn: 'ভাষা', en: 'Language' },
  theme: { bn: 'থিম', en: 'Theme' },
  lightMode: { bn: 'লাইট মোড', en: 'Light Mode' },
  darkMode: { bn: 'ডার্ক মোড', en: 'Dark Mode' },
  logout: { bn: 'লগ আউট', en: 'Logout' },
  
  // Search
  search: { bn: 'খুঁজুন', en: 'Search' },
  searchPlaceholder: { bn: 'খুঁজুন...', en: 'Search...' },
  topCreators: { bn: 'জনপ্রিয় ক্রিয়েটর', en: 'Top Creators' },
  popularStages: { bn: 'জনপ্রিয় স্টেজ', en: 'Popular Stages' },
  
  // Notifications
  allNotifications: { bn: 'সব নোটিফিকেশন', en: 'All Notifications' },
  markAllRead: { bn: 'সব পড়া হয়েছে', en: 'Mark all as read' },
  
  // Time
  justNow: { bn: 'এখনই', en: 'Just now' },
  minutesAgo: { bn: 'মিনিট আগে', en: 'minutes ago' },
  minuteAgo: { bn: 'মিনিট আগে', en: 'minute ago' },
  hoursAgo: { bn: 'ঘণ্টা আগে', en: 'hours ago' },
  hourAgo: { bn: 'ঘণ্টা আগে', en: 'hour ago' },
  daysAgo: { bn: 'দিন আগে', en: 'days ago' },
  dayAgo: { bn: 'দিন আগে', en: 'day ago' },
  
  // Notification Actions
  likedYourPost: { bn: 'আপনার পোস্ট পছন্দ করেছে', en: 'liked your post' },
  likedYourComment: { bn: 'আপনার মন্তব্য পছন্দ করেছে', en: 'liked your comment' },
  commentedOnYourPost: { bn: 'আপনার পোস্টে মন্তব্য করেছে', en: 'commented on your post' },
  followedYou: { bn: 'আপনাকে ফলো করেছে', en: 'followed you' },
  stageLive: { bn: 'এর স্টেজ এখন লাইভ', en: 'stage is now live' },
  awesomePost: { bn: 'অসাধারণ পোস্ট!', en: 'Awesome post!' },
  nicePhoto: { bn: 'দারুণ ছবি!', en: 'Nice photo!' },
  agreed: { bn: 'একমত!', en: 'Agreed!' },
  
  // Localized Communities
  localCommunities: { bn: 'স্থানীয় কমিউনিটি', en: 'Localized Communities' },
  seeLocalCommunities: { bn: 'আপনার কাছাকাছি স্থানীয় কমিউনিটি দেখুন', en: 'See local communities near you' },
  allowLocationAccess: { bn: 'আপনার অঞ্চলে যোগদান এবং কাছাকাছি লোকজন খুঁজে পেতে লোকেশন অ্যাক্সেসের অনুমতি দিন', en: 'Allow location access to join your region and discover people nearby' },
  allowAccess: { bn: 'অ্যাক্সেসের অনুমতি দিন', en: 'Allow access' },
  notNow: { bn: 'এখন না', en: 'Not now' },
  changeInSettings: { bn: 'আপনি পরে সেটিংস > গোপনীয়তা থেকে এটি পরবর্তন করতে পারেন', en: 'You can change this later in Settings > Privacy' },
  beta: { bn: 'বেটা', en: 'BETA' },
  chooseRegion: { bn: 'অঞ্চল নির্বাচন করুন', en: 'Choose Region' },
  searchRegion: { bn: 'অঞ্চল বা জেলা খুঁজুন', en: 'Search region or district' },
  joinRegionCommunity: { bn: 'অঞ্চল কমিউনিটিতে যোগদান করুন', en: 'Join Region Community' },
  all: { bn: 'সব', en: 'All' },
  myDistrict: { bn: 'আমার জেলা', en: 'My District' },
  nearMe: { bn: 'আমার কাছে', en: 'Near me' },
  showMeNearby: { bn: 'আমাকে কাছাকাছি লোকেদের কাছে দেখান', en: 'Show me to people nearby' },
  nearbyHelp: { bn: 'চালু থাকলে, আপনার এলাকার লোকেরা আপনাকে খুঁজে পেতে পারে। আপনি যেকোনো সময় এটি বন্ধ করতে পারেন।', en: 'If on, people in your area can discover you. You can turn this off anytime.' },
  findFriendsNearMe: { bn: 'আমার কাছাকাছি বন্ধুদের খুঁজুন', en: 'Find Friends Near Me' },
  map: { bn: 'মানচিত্র', en: 'Map' },
  list: { bn: 'তালিকা', en: 'List' },
  
  // Regions
  dhaka: { bn: 'ঢাকা', en: 'Dhaka' },
  chittagong: { bn: 'চট্টগ্রাম', en: 'Chittagong' },
  khulna: { bn: 'খুলনা', en: 'Khulna' },
  rajshahi: { bn: 'রাজশাহী', en: 'Rajshahi' },
  sylhet: { bn: 'সিলেট', en: 'Sylhet' },
  barishal: { bn: 'বরিশাল', en: 'Barishal' },
  rangpur: { bn: 'রংপুর', en: 'Rangpur' },
  mymensingh: { bn: 'ময়মনসিংহ', en: 'Mymensingh' },
  
  // Officials & Marketplace
  officialAccounts: { bn: 'অফিসিয়াল অ্যাকাউন্ট', en: 'Official Accounts' },
  officialsDescription: { bn: 'শীঘ্রই, স্থানীয় কর্মকর্তারা কমিউনিটির সমস্যা সংগ্রহ করতে যোগদান করতে পারবেন', en: 'Soon, local officials can join to gather community issues' },
  learnMore: { bn: 'আরও জানুন', en: 'Learn more' },
  serviceMarketplace: { bn: 'সেবা মার্কেটপ্লেস', en: 'Local Services Marketplace' },
  marketplaceDescription: { bn: 'শীঘ্রই আসছে: আপনার এলাকায় সেবা খুঁজুন এবং দিন', en: 'Coming soon: find and offer services in your area' },
  previewCategories: { bn: 'ক্যাটাগরি প্রিভিউ', en: 'Preview categories' },
  youreIn: { bn: 'আপনি এখানে আছেন', en: 'You\'re in' },
  startPosting: { bn: 'আপনার চারপাশের লোকদের সাথে সংযোগ করতে পোস্ট করা শুরু করুন', en: 'Start posting to connect with people around you' },
};

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Initialize language from localStorage or default to 'bn'
  const [language, setLanguageState] = useState<Language>(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('torko_language');
      return (saved === 'bn' || saved === 'en') ? saved as Language : 'bn';
    }
    return 'bn';
  });

  // Initialize theme from localStorage or default to 'dark'
  const [theme, setThemeState] = useState<Theme>(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('torko_theme');
      return (saved === 'light' || saved === 'dark') ? saved as Theme : 'dark';
    }
    return 'dark';
  });

  const [notification, setNotification] = useState<Notification | null>(null);
  const [conversationData, setConversationData] = useState<ConversationData | null>(null);
  const [callData, setCallData] = useState<CallData | null>(null);
  const [hideBottomNav, setHideBottomNav] = useState(false);
  const [postDetailData, setPostDetailData] = useState<any | null>(null);
  const [messageNotificationCount, setMessageNotificationCount] = useState(5); // Demo: 5 unread messages

  // Persist language to localStorage when it changes
  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
    if (typeof window !== 'undefined') {
      localStorage.setItem('torko_language', lang);
    }
  };

  // Persist theme to localStorage when it changes
  const setTheme = (newTheme: Theme) => {
    setThemeState(newTheme);
    if (typeof window !== 'undefined') {
      localStorage.setItem('torko_theme', newTheme);
    }
  };

  useEffect(() => {
    const root = document.documentElement;
    if (theme === 'dark') {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
  }, [theme]);

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
  };

  const toggleLanguage = () => {
    const newLanguage = language === 'bn' ? 'en' : 'bn';
    setLanguage(newLanguage);
  };

  const t = (key: string): string => {
    return translations[key]?.[language] || key;
  };

  const showNotification = (notificationData: Omit<Notification, 'id'>) => {
    const newNotification: Notification = {
      ...notificationData,
      id: Date.now().toString(),
      duration: notificationData.duration ?? 5000, // Default 5 seconds
    };
    setNotification(newNotification);
  };

  const dismissNotification = (id: string) => {
    if (notification?.id === id) {
      setNotification(null);
    }
  };

  const openConversation = (name: string, color: string, initials: string, avatar?: string, isGroup?: boolean) => {
    setConversationData({ name, color, initials, avatar, isGroup });
  };

  const closeConversation = () => {
    setConversationData(null);
  };

  const startCall = (name: string, color: string, initials: string, isVideo: boolean, isIncoming?: boolean, isGroup?: boolean) => {
    setCallData({ name, color, initials, isVideo, isIncoming: isIncoming ?? false, isGroup });
  };

  const endCall = () => {
    setCallData(null);
  };

  const openPostDetail = (postData: any) => {
    setPostDetailData(postData);
  };

  const closePostDetail = () => {
    setPostDetailData(null);
  };

  const resetMessageNotifications = () => {
    setMessageNotificationCount(0);
  };

  return (
    <AppContext.Provider value={{ 
      language, 
      setLanguage, 
      theme, 
      setTheme, 
      toggleTheme, 
      toggleLanguage,
      t,
      showNotification,
      notification,
      dismissNotification,
      openConversation,
      conversationData,
      closeConversation,
      startCall,
      callData,
      endCall,
      hideBottomNav,
      setHideBottomNav,
      openPostDetail,
      postDetailData,
      closePostDetail,
      messageNotificationCount,
      resetMessageNotifications,
    }}>
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
};