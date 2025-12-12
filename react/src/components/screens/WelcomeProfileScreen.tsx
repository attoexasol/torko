import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { 
  Check, 
  ChevronRight, 
  User, 
  MapPin, 
  UserPlus, 
  MessageCircle, 
  Heart,
  X,
  CheckCircle2,
  Circle
} from 'lucide-react';

interface WelcomeProfileScreenProps {
  onComplete: () => void;
  onNavigate: (screen: string) => void;
}

interface SuggestedAction {
  id: string;
  titleBn: string;
  titleEn: string;
  descriptionBn: string;
  descriptionEn: string;
  icon: React.ElementType;
  completed: boolean;
  actionType: 'profile' | 'follow' | 'post' | 'explore';
}

export const WelcomeProfileScreen: React.FC<WelcomeProfileScreenProps> = ({ onComplete, onNavigate }) => {
  const { theme, language } = useApp();
  const isDark = theme === 'dark';

  // Get user data from localStorage
  const userProfile = typeof window !== 'undefined' 
    ? JSON.parse(localStorage.getItem('torko_user_profile') || '{}')
    : {};
  
  const userLocation = typeof window !== 'undefined'
    ? JSON.parse(localStorage.getItem('torko_user_location') || '{}')
    : {};

  // Load completion state from localStorage
  const [suggestedActions, setSuggestedActions] = useState<SuggestedAction[]>(() => {
    // Try to load saved progress
    const savedProgress = typeof window !== 'undefined' 
      ? localStorage.getItem('torko_welcome_progress')
      : null;
    
    const defaultActions = [
      {
        id: 'complete_profile',
        titleBn: 'প্রোফাইল সম্পূর্ণ করুন',
        titleEn: 'Complete Your Profile',
        descriptionBn: 'প্রোফাইল ছবি এবং বায়ো যোগ করুন',
        descriptionEn: 'Add profile picture and bio',
        icon: User,
        completed: false,
        actionType: 'profile' as const,
      },
      {
        id: 'find_community',
        titleBn: 'আপনার এলাকা খুঁজুন',
        titleEn: 'Find Your Community',
        descriptionBn: `${userLocation.districtBn || 'স্থানীয়'} এর মানুষদের সাথে যুক্ত হন`,
        descriptionEn: `Connect with people in ${userLocation.district || 'your area'}`,
        icon: MapPin,
        completed: true, // Already selected location
        actionType: 'explore' as const,
      },
      {
        id: 'follow_people',
        titleBn: 'গ্রুপ ফলো করুন',
        titleEn: 'Follow Group',
        descriptionBn: 'আপনার আগ্রহের গ্রুপে যোগ দিন',
        descriptionEn: 'Join groups that interest you',
        icon: UserPlus,
        completed: false,
        actionType: 'follow' as const,
      },
      {
        id: 'first_post',
        titleBn: 'প্রথম পোস্ট করুন',
        titleEn: 'Create Your First Post',
        descriptionBn: 'আপনার চিন্তা বা মতামত শেয়ার করুন',
        descriptionEn: 'Share your thoughts or opinion',
        icon: MessageCircle,
        completed: false,
        actionType: 'post' as const,
      },
    ];

    if (savedProgress) {
      try {
        const parsed = JSON.parse(savedProgress);
        // Merge saved progress with default actions
        return defaultActions.map(action => {
          const saved = parsed.find((p: any) => p.id === action.id);
          return saved ? { ...action, completed: saved.completed } : action;
        });
      } catch (e) {
        return defaultActions;
      }
    }
    
    return defaultActions;
  });

  const translations = {
    welcome: language === 'bn' ? 'স্বাগতম' : 'Welcome',
    welcomeName: language === 'bn' ? `স্বাগতম, ${userProfile.name}!` : `Welcome, ${userProfile.name}!`,
    subtitle: language === 'bn' 
      ? 'Torko তে আপনাকে স্বাগতম! চলুন শুরু করা যাক।'
      : 'Welcome to Torko! Let\'s get you started.',
    getStarted: language === 'bn' ? 'শুরু করুন' : 'Get Started',
    skip: language === 'bn' ? 'এড়িয়ে যান' : 'Skip',
    suggestedActions: language === 'bn' ? 'প্রস্তাবিত পদক্ষেপ' : 'Suggested Actions',
    completed: language === 'bn' ? 'সম্পন্ন' : 'Completed',
    skipModalTitle: language === 'bn' ? 'এখনই এড়িয়ে যেতে চান?' : 'Skip for now?',
    skipModalDescription: language === 'bn'
      ? 'এই পদক্ষেপগুলি আপনাকে Torko এর সবচেয়ে ভালো অভিজ্ঞতা পেতে সাহায্য করবে। আপনি পরে এগুলো করতে পারবেন।'
      : 'These steps will help you get the most out of Torko. You can complete them later from settings.',
    skipYes: language === 'bn' ? 'হ্যাঁ, এড়িয়ে যান' : 'Yes, Skip',
    skipNo: language === 'bn' ? 'না, ফিরে যান' : 'No, Go Back',
    location: language === 'bn' 
      ? `${userLocation.divisionBn}, ${userLocation.districtBn}`
      : `${userLocation.division}, ${userLocation.district}`,
    profileComplete: language === 'bn' ? 'প্রোফাইল সম্পূর্ণ' : 'Profile Complete',
    progress: language === 'bn' ? 'অগ্রগতি' : 'Progress',
  };

  const completedCount = suggestedActions.filter(action => action.completed).length;
  const totalCount = suggestedActions.length;
  const progressPercentage = (completedCount / totalCount) * 100;
  const allCompleted = completedCount === totalCount;

  // Reload progress from localStorage when component mounts or becomes visible
  useEffect(() => {
    const reloadProgress = () => {
      const savedProgress = localStorage.getItem('torko_welcome_progress');
      if (savedProgress) {
        try {
          const parsed = JSON.parse(savedProgress);
          setSuggestedActions(prevActions => 
            prevActions.map(action => {
              const saved = parsed.find((p: any) => p.id === action.id);
              return saved ? { ...action, completed: saved.completed } : action;
            })
          );
        } catch (e) {
          console.error('Error reloading progress:', e);
        }
      }
    };

    // Reload immediately on mount
    reloadProgress();

    // Set up interval to check for updates every 500ms when this screen is visible
    const interval = setInterval(reloadProgress, 500);
    
    return () => {
      clearInterval(interval);
    };
  }, []); // Empty dependency - only run on mount/unmount

  const handleActionClick = (action: SuggestedAction) => {
    if (action.completed) return;
    
    // Navigate to appropriate screen based on action type
    switch (action.actionType) {
      case 'profile':
        // Mark as navigating to profile
        if (typeof window !== 'undefined') {
          localStorage.setItem('torko_from_welcome', 'complete_profile');
        }
        onNavigate('profile');
        break;
      case 'follow':
        // Mark as navigating to follow people
        if (typeof window !== 'undefined') {
          localStorage.setItem('torko_from_welcome', 'follow_people');
        }
        onNavigate('localCommunity'); // Go to local community to find and follow people
        break;
      case 'post':
        // Mark as navigating to create post
        if (typeof window !== 'undefined') {
          localStorage.setItem('torko_from_welcome', 'first_post');
        }
        onNavigate('createPost');
        break;
      default:
        break;
    }
  };

  const handleGetStarted = () => {
    if (!allCompleted) return; // Don't allow if not all completed
    
    // Mark welcome screen as completed
    if (typeof window !== 'undefined') {
      localStorage.setItem('torko_welcome_completed', 'true');
    }
    onComplete();
  };

  const confirmSkip = () => {
    // Don't allow skip - Remove this functionality
    return;
  };

  return (
    <div className={`flex flex-col w-full h-screen ${
      isDark 
        ? 'bg-[#052029]' 
        : 'bg-gradient-to-br from-white via-[#f0fdf4] to-[#dcfce7]'
    }`}>
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="flex-shrink-0 px-4 sm:px-6 pt-8 sm:pt-10 pb-4"
      >
        {/* Welcome Message with Animation */}
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="text-center mb-6"
        >
          <motion.div
            animate={{ 
              scale: [1, 1.1, 1],
            }}
            transition={{ 
              duration: 2,
              repeat: Infinity,
              repeatDelay: 3
            }}
            className="text-4xl sm:text-5xl mb-4"
          >
            🎉
          </motion.div>
          <h1 className={`font-['Noto_Sans_Bengali',sans-serif] text-[24px] sm:text-[32px] mb-2 ${
            isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
          }`}>
            {translations.welcomeName}
          </h1>
          <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[14px] sm:text-[16px] ${
            isDark ? 'text-[#B8DED6]/70' : 'text-[#4d7c0f]'
          }`}>
            {translations.subtitle}
          </p>
        </motion.div>

        {/* User Info Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className={`rounded-2xl p-4 mb-4 ${
            isDark
              ? 'bg-[#0a2f3d] border border-[#0d3a4a]'
              : 'bg-white/70 backdrop-blur-sm border border-white/60'
          }`}
        >
          <div className="flex items-center gap-3">
            <div className={`w-14 h-14 rounded-full flex items-center justify-center ${
              isDark ? 'bg-[#d97757]' : 'bg-gradient-to-br from-[#dc2626] to-[#166534]'
            }`}>
              <User className="w-7 h-7 text-white" />
            </div>
            <div className="flex-1">
              <h3 className={`font-['Noto_Sans_Bengali',sans-serif] text-[16px] sm:text-[18px] ${
                isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
              }`}>
                {userProfile.name}
              </h3>
              <div className="flex items-center gap-1.5 mt-0.5">
                <MapPin className={`w-3.5 h-3.5 ${isDark ? 'text-[#B8DED6]/60' : 'text-[#4d7c0f]'}`} />
                <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[12px] sm:text-[14px] ${
                  isDark ? 'text-[#B8DED6]/60' : 'text-[#4d7c0f]'
                }`}>
                  {translations.location}
                </p>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Progress Bar */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.6 }}
          className="mb-4"
        >
          <div className="flex items-center justify-between mb-2">
            <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[13px] sm:text-[14px] ${
              isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
            }`}>
              {translations.progress}
            </p>
            <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[13px] sm:text-[14px] ${
              isDark ? 'text-[#d97757]' : 'text-[#dc2626]'
            }`}>
              {completedCount}/{totalCount}
            </p>
          </div>
          <div className={`w-full h-2.5 rounded-full overflow-hidden ${
            isDark ? 'bg-[#0a2f3d]' : 'bg-gray-200'
          }`}>
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${progressPercentage}%` }}
              transition={{ duration: 0.8, delay: 0.8 }}
              className={`h-full ${
                isDark 
                  ? 'bg-gradient-to-r from-[#d97757] to-[#B8DED6]'
                  : 'bg-gradient-to-r from-[#dc2626] to-[#166534]'
              }`}
            />
          </div>
        </motion.div>
      </motion.div>

      {/* Scrollable Content */}
      <div className="flex-1 overflow-y-auto px-4 sm:px-6 pb-4">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.8 }}
        >
          <h2 className={`font-['Noto_Sans_Bengali',sans-serif] text-[16px] sm:text-[18px] mb-3 ${
            isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
          }`}>
            {translations.suggestedActions}
          </h2>

          <div className="flex flex-col gap-3">
            {suggestedActions.map((action, index) => (
              <motion.button
                key={action.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.4, delay: 1 + (index * 0.1) }}
                onClick={() => handleActionClick(action)}
                disabled={action.completed}
                className={`relative p-4 rounded-2xl border-2 transition-all text-left ${
                  action.completed
                    ? (isDark 
                      ? 'bg-[#0a2f3d]/50 border-[#0d3a4a] opacity-60' 
                      : 'bg-white/40 border-white/40 opacity-60')
                    : (isDark
                      ? 'bg-[#0a2f3d] border-[#0d3a4a] hover:border-[#d97757] active:scale-[0.98]'
                      : 'bg-white/70 backdrop-blur-sm border-white/60 hover:border-[#166534] active:scale-[0.98]')
                }`}
              >
                <div className="flex items-start gap-3">
                  <div className={`flex-shrink-0 w-12 h-12 rounded-xl flex items-center justify-center ${
                    action.completed
                      ? (isDark ? 'bg-[#d97757]/20' : 'bg-[#166534]/20')
                      : (isDark ? 'bg-[#0d3a4a]' : 'bg-gradient-to-br from-[#dc2626]/10 to-[#166534]/10')
                  }`}>
                    <action.icon className={`w-6 h-6 ${
                      action.completed
                        ? (isDark ? 'text-[#d97757]' : 'text-[#166534]')
                        : (isDark ? 'text-[#B8DED6]' : 'text-[#4d7c0f]')
                    }`} />
                  </div>

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between mb-1">
                      <h3 className={`font-['Noto_Sans_Bengali',sans-serif] text-[15px] sm:text-[16px] ${
                        isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
                      }`}>
                        {language === 'bn' ? action.titleBn : action.titleEn}
                      </h3>
                      {action.completed && (
                        <motion.div
                          initial={{ scale: 0, rotate: -180 }}
                          animate={{ scale: 1, rotate: 0 }}
                          className={`flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center ${
                            isDark ? 'bg-[#d97757]' : 'bg-[#166534]'
                          }`}
                        >
                          <Check className="w-4 h-4 text-white" strokeWidth={3} />
                        </motion.div>
                      )}
                      {!action.completed && (
                        <ChevronRight className={`flex-shrink-0 w-5 h-5 ${
                          isDark ? 'text-[#B8DED6]/50' : 'text-[#4d7c0f]'
                        }`} />
                      )}
                    </div>
                    <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[13px] sm:text-[14px] ${
                      isDark ? 'text-[#B8DED6]/60' : 'text-[#4d7c0f]'
                    }`}>
                      {language === 'bn' ? action.descriptionBn : action.descriptionEn}
                    </p>
                  </div>
                </div>
              </motion.button>
            ))}
          </div>

          {/* Tips Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 1.4 }}
            className={`mt-6 p-4 rounded-2xl ${
              isDark
                ? 'bg-[#0d3a4a]/50 border border-[#104050]'
                : 'bg-gradient-to-br from-[#dc2626]/5 to-[#166534]/5 border border-white/40'
            }`}
          >
            <div className="flex items-start gap-3">
              <Heart className={`flex-shrink-0 w-5 h-5 mt-0.5 ${
                isDark ? 'text-[#d97757]' : 'text-[#dc2626]'
              }`} />
              <div>
                <h4 className={`font-['Noto_Sans_Bengali',sans-serif] text-[14px] sm:text-[15px] mb-1 ${
                  isDark ? 'text-[#B8DED6]' : 'text-[#166534]'
                }`}>
                  {language === 'bn' ? '💡 টিপস' : '💡 Quick Tip'}
                </h4>
                <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[12px] sm:text-[13px] leading-relaxed ${
                  isDark ? 'text-[#B8DED6]/70' : 'text-[#4d7c0f]'
                }`}>
                  {language === 'bn'
                    ? 'আপনার স্থানীয় কমিউনিটির সাথে সংযুক্ত হয়ে সেরা অভিজ্ঞতা পান। প্রতিদিন নতুন বন্ধু খুঁজুন এবং আকর্ষণীয় আলোচনায় অংশ নিন!'
                    : 'Get the best experience by connecting with your local community. Find new friends and join interesting discussions every day!'}
                </p>
              </div>
            </div>
          </motion.div>
        </motion.div>
      </div>

      {/* Bottom Actions */}
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
        <div className="flex flex-col gap-2.5 sm:gap-3">
          <motion.button
            onClick={handleGetStarted}
            disabled={!allCompleted}
            whileTap={allCompleted ? { scale: 0.98 } : undefined}
            className={`flex items-center justify-center gap-2.5 h-[50px] sm:h-[56px] rounded-full shadow-lg transition-all ${
              allCompleted
                ? (isDark 
                  ? 'bg-[#0d3a4a] border-2 border-[#d97757] text-white hover:bg-[#104050] cursor-pointer'
                  : 'bg-gradient-to-r from-[#dc2626] to-[#166534] text-white hover:opacity-90 cursor-pointer')
                : (isDark
                  ? 'bg-[#0a2f3d] border-2 border-[#0d3a4a] text-[#B8DED6]/40 cursor-not-allowed'
                  : 'bg-gray-200 border-2 border-gray-300 text-gray-400 cursor-not-allowed')
            }`}
          >
            <p className="font-['Noto_Sans_Bengali',sans-serif] text-[15px] sm:text-[16px]">
              {translations.getStarted}
            </p>
            <ChevronRight className="w-5 h-5" strokeWidth={2.5} />
          </motion.button>

          {/* Message when not all completed */}
          {!allCompleted && (
            <motion.p 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className={`text-center font-['Noto_Sans_Bengali',sans-serif] text-[12px] sm:text-[13px] ${
                isDark ? 'text-[#B8DED6]/60' : 'text-[#4d7c0f]/70'
              }`}
            >
              {language === 'bn' 
                ? 'সব ধাপ সম্পূর্ণ করুন এগিয়ে যেতে' 
                : 'Complete all steps to continue'}
            </motion.p>
          )}
        </div>
      </motion.div>
    </div>
  );
};