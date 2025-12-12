import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ChevronLeft, Search, MessageSquare, X, Users } from 'lucide-react';
import svgPaths from "../../imports/svg-2cw8age933";
import imgFrame from "figma:asset/a6746284f9589fbc91a471b3324f42c0ddd746b7.png";
import imgRectangle41864 from "figma:asset/42b72b8a79f3a110aa8f70956343252fbc8ff7c6.png";

interface ExploreScreenNewProps {
  onNavigate: (screen: string) => void;
  language?: 'bn' | 'en';
  onScroll?: (showNav: boolean) => void;
  defaultTab?: 'stages' | 'groups';
}

export const ExploreScreenNew: React.FC<ExploreScreenNewProps> = ({ 
  onNavigate,
  language = 'bn',
  onScroll,
  defaultTab = 'stages'
}) => {
  const [activeTab, setActiveTab] = useState<'stages' | 'groups'>(defaultTab);
  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [showHeader, setShowHeader] = useState(true);
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const lastScrollY = useRef(0);

  const t = {
    explore: language === 'bn' ? 'এক্সপ্লোর' : 'Explore',
    trending: language === 'bn' ? 'ট্রেন্ডিং' : 'Trending',
    people: language === 'bn' ? 'মানুষ' : 'People',
    community: language === 'bn' ? 'কমিউনিটি' : 'Community',
    stages: language === 'bn' ? 'স্টেজ' : 'Stages',
    trendingHashtags: language === 'bn' ? 'ট্রেন্ডিং হ্যাশট্যাগ' : 'Trending Hashtags',
    posts: language === 'bn' ? 'পোস্ট' : 'Posts',
    searchPlaceholder: language === 'bn' ? 'খুঁজুন...' : 'Search...',
    cancel: language === 'bn' ? 'বাতিল' : 'Cancel',
    recentSearches: language === 'bn' ? 'সাম্প্রতিক অনুসন্ধান' : 'Recent Searches',
    noResults: language === 'bn' ? 'কোন ফলাফল পাওয়া যায়নি' : 'No results found',
    verified: language === 'bn' ? 'যাচাইকৃত' : 'Verified',
    growth: language === 'bn' ? 'বৃদ্ধি' : 'Growth',
  };

  // Trending hashtags data
  const trendingHashtags = [
    {
      id: 1,
      author: 'Mask Of Dual…',
      username: '@Maskofdual…',
      verified: true,
      time: language === 'bn' ? '৩ ঘণ্টা' : '3h',
      content: 'Aiming to be the best truth always results in suppression of others regardless if they know they are wrong or not.',
      posts: language === 'bn' ? '২৩৪ পোস্ট' : '234 Posts',
      growth: '25%',
      bgColor: '#d6775c', // Coral color
    },
    {
      id: 2,
      author: 'Jung Taekwoon',
      username: '@JungTaek…',
      verified: true,
      time: language === 'bn' ? '৫ ঘণ্টা' : '5h',
      content: 'সামাজিক মিডিয়া আমাদের সংযুক্ত করার কথা, কিন্তু প্রকৃতপক্ষে এটি কি আমাদের আরও বিভক্ত করছে না?',
      posts: language === 'bn' ? '১৮৯ পোস্ট' : '189 Posts',
      growth: '18%',
      bgColor: '#d6775c',
    },
    {
      id: 3,
      author: 'Rahman Chowdhury',
      username: '@Rahman_C',
      verified: true,
      time: language === 'bn' ? '৮ ঘণ্টা' : '8h',
      content: 'আমাদের স্থানীয় কমিউনিটি শক্তিশালী করতে হলে প্রথমে আমাদের নিজেদের মধ্যে বিশ্বাস তৈরি করতে হবে।',
      posts: language === 'bn' ? '৩৫৬ পোস্ট' : '356 Posts',
      growth: '32%',
      bgColor: '#000000', // Black for third item
    },
    {
      id: 4,
      author: 'Sadia Akter',
      username: '@SadiaAk…',
      verified: false,
      time: language === 'bn' ? '১২ ঘণ্টা' : '12h',
      content: 'আজকের দিনে শিক্ষা শুধু বইয়ের মধ্যে সীমাবদ্ধ নয়। প্রযুক্তি ব্যবহার করে আমরা অনেক কিছু শিখতে পারি।',
      posts: language === 'bn' ? '১৪৫ পোস্ট' : '145 Posts',
      growth: '15%',
      bgColor: '#d6775c',
    },
    {
      id: 5,
      author: 'Tech Insights BD',
      username: '@TechBD',
      verified: true,
      time: language === 'bn' ? '১৫ ঘণ্টা' : '15h',
      content: 'The future of technology in Bangladesh is bright. We need to invest more in digital infrastructure and education.',
      posts: language === 'bn' ? '৪৮৯ পোস্ট' : '489 Posts',
      growth: '42%',
      bgColor: '#d6775c',
    },
    {
      id: 6,
      author: 'Nishat Rahman',
      username: '@Nishat_R',
      verified: true,
      time: language === 'bn' ? '১৮ ঘণ্টা' : '18h',
      content: 'বাংলাদেশের তরুণ প্রজন্ম স্বপ্ন দেখছে বড় কিছু করার। আমাদের তাদের সঠিক দিকনির্দেশনা দেওয়া উচিত।',
      posts: language === 'bn' ? '২৬৭ পোস্ট' : '267 Posts',
      growth: '28%',
      bgColor: '#000000',
    },
    {
      id: 7,
      author: 'Karim Hossain',
      username: '@KarimH',
      verified: false,
      time: language === 'bn' ? '২০ ঘণ্টা' : '20h',
      content: 'Climate change is real and we need to act now. Our small efforts can make a big difference for future generations.',
      posts: language === 'bn' ? '১৯৮ পোস্ট' : '198 Posts',
      growth: '22%',
      bgColor: '#d6775c',
    },
    {
      id: 8,
      author: 'Fatema Begum',
      username: '@FatemaBgm',
      verified: true,
      time: language === 'bn' ? '২২ ঘণ্টা' : '22h',
      content: 'নারী ক্ষমতায়ন শুধু একটি স্লোগান নয়, এটি আমাদের সমাজের প্রগতির জন্য অপরিহার্য।',
      posts: language === 'bn' ? '৫৬৭ পোস্ট' : '567 Posts',
      growth: '38%',
      bgColor: '#d6775c',
    },
  ];

  // People data - suggested users to follow
  const peopleData = [
    {
      id: 1,
      name: 'Tasnim Ahmed',
      username: '@tasnim_ahmed',
      bio: language === 'bn' ? 'প্রযুক্তি উৎসাহী | সফটওয়্যার ডেভেলপার | বাংলাদেশ থেকে' : 'Tech Enthusiast | Software Developer | From Bangladesh',
      verified: true,
      followers: language === 'bn' ? '১২.৫ হাজার' : '12.5K',
      isFollowing: false,
    },
    {
      id: 2,
      name: 'Rifat Hassan',
      username: '@rifat_h',
      bio: language === 'bn' ? 'ডিজিটাল মার্কেটার | স্টার্টআপ পরামর্শদাতা' : 'Digital Marketer | Startup Consultant',
      verified: true,
      followers: language === 'bn' ? '৮.৩ হাজার' : '8.3K',
      isFollowing: false,
    },
    {
      id: 3,
      name: 'Nusrat Jahan',
      username: '@nusrat_writes',
      bio: language === 'bn' ? 'লেখক ও কবি | বই প্রেমী | ভ্রমণপিয়াসী' : 'Writer & Poet | Book Lover | Travel Enthusiast',
      verified: false,
      followers: language === 'bn' ? '৫.৭ হাজার' : '5.7K',
      isFollowing: false,
    },
    {
      id: 4,
      name: 'Mehedi Hasan',
      username: '@mehedi_tech',
      bio: language === 'bn' ? 'AI রিসার্চার | মেশিন লার্নিং | ঢাকা বিশ্ববিদ্যালয়' : 'AI Researcher | Machine Learning | Dhaka University',
      verified: true,
      followers: language === 'bn' ? '১৫.২ হাজার' : '15.2K',
      isFollowing: false,
    },
    {
      id: 5,
      name: 'Sabrina Khan',
      username: '@sabrina_k',
      bio: language === 'bn' ? 'গ্রাফিক ডিজাইনার | ব্র্যান্ডিং বিশেষজ্ঞ' : 'Graphic Designer | Branding Specialist',
      verified: false,
      followers: language === 'bn' ? '৬.৯ হাজার' : '6.9K',
      isFollowing: false,
    },
    {
      id: 6,
      name: 'Fahim Rahman',
      username: '@fahim_tech',
      bio: language === 'bn' ? 'ফুল স্ট্যাক ডেভেলপার | ওপেন সোর্স অবদানকারী' : 'Full Stack Developer | Open Source Contributor',
      verified: true,
      followers: language === 'bn' ? '১০.১ হাজার' : '10.1K',
      isFollowing: false,
    },
  ];

  // Community data - communities to join
  const communityData = [
    {
      id: 1,
      name: language === 'bn' ? 'বাংলাদেশ টেক কমিউনিটি' : 'Bangladesh Tech Community',
      description: language === 'bn' ? 'প্রযুক্তি প্রেমীদের জন্য একটি প্ল্যাটফর্ম যেখানে আমরা নতুন প্রযুক্তি, সফটওয়্যার ডেভেলপমেন্ট, এবং ডিজিটাল ট্রেন্ড নিয়ে আলোচনা করি।' : 'A platform for tech enthusiasts where we discuss new technology, software development, and digital trends.',
      members: language === 'bn' ? '২৫,৩০০' : '25,300',
      posts: language === 'bn' ? '১.২ হাজার' : '1.2K',
      category: language === 'bn' ? 'প্রযুক্তি' : 'Technology',
      type: 'public' as const,
      isJoined: false,
      image: 'https://images.unsplash.com/photo-1529209076408-5a115ec9f1c6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0ZWNobm9sb2d5JTIwY29tbXVuaXR5fGVufDF8fHx8MTc2NTEyODQ3OHww&ixlib=rb-4.1.0&q=80&w=1080',
    },
    {
      id: 2,
      name: language === 'bn' ? 'ঢাকা স্টার্টআপ হাব' : 'Dhaka Startup Hub',
      description: language === 'bn' ? 'স্টার্টআপ উদ্যোক্তা ও বিনিয়োগকারীদের নেটওয়ার্ক - ব্যবসায়িক পরামর্শ, ফান্ডিং সুযোগ, এবং সহযোগিতার জন্য।' : 'Network for startup entrepreneurs and investors - for business advice, funding opportunities, and collaboration.',
      members: language === 'bn' ? '১৮,৭০০' : '18,700',
      posts: language === 'bn' ? '৯৫০' : '950',
      category: language === 'bn' ? 'ব্যবসা' : 'Business',
      type: 'public' as const,
      isJoined: false,
      image: 'https://images.unsplash.com/photo-1629787177096-9fbe3e2ef6f3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdGFydHVwJTIwYnVzaW5lc3N8ZW58MXx8fHwxNzY1MTI4NDc5fDA&ixlib=rb-4.1.0&q=80&w=1080',
    },
    {
      id: 3,
      name: language === 'bn' ? 'বাংলা সাহিত্য প্রেমী' : 'Bangla Literature Lovers',
      description: language === 'bn' ? 'বাংলা সাহিত্য নিয়ে আলোচনা ও শেয়ারিং - কবিতা, উপন্যাস, ছোটগল্প এবং সাহিত্যিক বিশ্লেষণ।' : 'Discussion and sharing about Bangla literature - poetry, novels, short stories and literary analysis.',
      members: language === 'bn' ? '১২,৫০০' : '12,500',
      posts: language === 'bn' ? '৭৮০' : '780',
      category: language === 'bn' ? 'সাহিত্য' : 'Literature',
      type: 'public' as const,
      isJoined: false,
      image: 'https://images.unsplash.com/photo-1695121435869-11f4791315b3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxib29rcyUyMGxpdGVyYXR1cmV8ZW58MXx8fHwxNzY1MTI4NDc5fDA&ixlib=rb-4.1.0&q=80&w=1080',
    },
  ];

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
    {
      id: 4,
      title: language === 'bn' ? 'ডিজিটাল মার্কেটিং মাস্টারক্লাস' : 'Digital Marketing Masterclass',
      host: 'Sabrina Khan',
      hostUsername: '@sabrina_k',
      verified: false,
      listeners: language === 'bn' ? '৩৮৯' : '389',
      category: language === 'bn' ? 'মার্কেটিং' : 'Marketing',
      isLive: true,
      duration: language === 'bn' ? '২ ঘণ্টা' : '2 hours',
      color: '#000000',
    },
  ];

  const [followingStates, setFollowingStates] = useState<{ [key: number]: boolean }>({});
  const [joinedCommunities, setJoinedCommunities] = useState<{ [key: number]: boolean }>({});
  const [joinedStages, setJoinedStages] = useState<{ [key: number]: boolean }>({});
  const [selectedStage, setSelectedStage] = useState<any>(null);
  const [showStageModal, setShowStageModal] = useState(false);

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

  const handleScroll = () => {
    const currentRef = scrollContainerRef.current;
    if (currentRef) {
      const currentScrollY = currentRef.scrollTop;
      
      // Only trigger if scroll is more than 10px
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

  return (
    <div 
      ref={scrollContainerRef}
      className="h-screen bg-[#FAFAFA] dark:bg-[#052029] overflow-y-auto"
      style={{ WebkitOverflowScrolling: 'touch' }}
    >
      <div className="max-w-auto mx-auto bg-white dark:bg-[#052029] relative pb-20 min-h-full">
        
        {/* Header */}
        <motion.div 
          initial={{ y: 0 }}
          animate={{ y: showHeader ? 0 : -80 }}
          transition={{ type: 'spring', stiffness: 300, damping: 30 }}
          className="fixed top-0 left-0 right-0 px-[20px] pt-[20px] pb-[16px] flex items-center justify-between z-10 max-w-[430px] mx-auto bg-white/95 dark:bg-[#052029]/95 backdrop-blur-md"
        >
          <button
            onClick={() => onNavigate('home')}
            className="w-[36px] h-[36px] rounded-full bg-white border border-[#CCCCCC] flex items-center justify-center"
          >
            <svg className="w-[8px] h-[14px]" viewBox="0 0 8 14" fill="none">
              <path 
                clipRule="evenodd" 
                d={svgPaths.p195c4a00} 
                fill="black" 
                fillRule="evenodd" 
              />
            </svg>
          </button>

          <h1 className="font-['Plus_Jakarta_Display',sans-serif] text-[18px] font-semibold text-[#0f1419] dark:text-white">
            {t.stages}
          </h1>

          <div className="flex items-center gap-[12px]">
            <button 
              onClick={() => setIsSearchOpen(true)}
              className="w-[36px] h-[36px] rounded-full bg-white border border-[#CCCCCC] flex items-center justify-center hover:bg-neutral-50 transition-colors"
            >
              <Search className="w-[20px] h-[20px] text-[#9D9D9D]" />
            </button>
            <button 
              onClick={() => onNavigate('messages')}
              className="w-[36px] h-[36px] rounded-full bg-[#d6775c] flex items-center justify-center hover:bg-[#c96647] transition-colors"
            >
              <MessageSquare className="w-[20px] h-[20px] text-white" />
            </button>
          </div>
        </motion.div>

        {/* Section Title */}
        <div className="absolute top-[80px] left-[19px] right-[19px]">
          <h2 className="font-['Plus_Jakarta_Display',sans-serif] text-[20px] font-semibold text-[#0f1419] dark:text-white mb-3">
            {language === 'bn' ? 'আবিষ্কার করুন' : 'Discover'}
          </h2>
          
          {/* Tabs */}
          <div className="flex gap-2">
            <button
              onClick={() => setActiveTab('stages')}
              className={`px-4 py-2 rounded-[20px] font-['Roboto',sans-serif] text-[14px] font-medium transition-all ${
                activeTab === 'stages'
                  ? 'bg-[#d6775c] text-white'
                  : 'bg-neutral-100 dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
              }`}
              style={{ fontVariationSettings: "'wdth' 100" }}
            >
              {language === 'bn' ? 'স্টেজ' : 'Stages'}
            </button>
            <button
              onClick={() => setActiveTab('groups')}
              className={`px-4 py-2 rounded-[20px] font-['Roboto',sans-serif] text-[14px] font-medium transition-all ${
                activeTab === 'groups'
                  ? 'bg-[#d6775c] text-white'
                  : 'bg-neutral-100 dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
              }`}
              style={{ fontVariationSettings: "'wdth' 100" }}
            >
              {language === 'bn' ? 'গ্রুপ' : 'Groups'}
            </button>
          </div>
        </div>

        {/* Content Area - Recommended Sections */}
        <div className="absolute top-[170px] left-0 right-0 flex flex-col gap-[24px] pb-[80px]">
          
          {/* Stages Tab Content */}
          {activeTab === 'stages' && (
            <div className="px-[19px]">
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
                        {stage.verified && (
                          <svg className="w-[14px] h-[14px]" viewBox="0 0 15 15" fill="none">
                            <path d={svgPaths.p28359cf0} fill="#1D9BF0" />
                          </svg>
                        )}
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
            <div className="px-[19px]">
              <div className="flex flex-col gap-[14px]">
                {communityData.map((community) => (
                  <div
                    key={community.id}
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
                            setJoinedCommunities(prev => ({
                              ...prev,
                              [community.id]: !prev[community.id]
                            }));
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
        </div>
      </div>

      {/* Search Modal */}
      <AnimatePresence>
        {isSearchOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsSearchOpen(false)}
              className="fixed inset-0 bg-black/50 backdrop-blur-sm z-[100]"
            />

            {/* Search Modal */}
            <motion.div
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ type: 'spring', stiffness: 300, damping: 30 }}
              className="fixed top-0 left-0 right-0 bg-white dark:bg-[#0a2f3d] rounded-b-[20px] shadow-2xl z-[101] max-w-[430px] mx-auto"
            >
              {/* Search Header */}
              <div className="p-[20px] pb-[16px]">
                <div className="flex items-center gap-[12px] mb-[16px]">
                  <button
                    onClick={() => setIsSearchOpen(false)}
                    className="w-[36px] h-[36px] rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center hover:bg-neutral-200 dark:hover:bg-neutral-700 transition-colors"
                  >
                    <X className="w-[20px] h-[20px] text-[#0f1419] dark:text-white" />
                  </button>

                  <div className="flex-1 relative">
                    <Search className="absolute left-[14px] top-1/2 -translate-y-1/2 w-[18px] h-[18px] text-[#9D9D9D]" />
                    <input
                      type="text"
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      placeholder={t.searchPlaceholder}
                      autoFocus
                      className="w-full h-[48px] pl-[44px] pr-[16px] bg-neutral-100 dark:bg-neutral-800 rounded-[24px] font-['Plus_Jakarta_Display',sans-serif] text-[15px] text-[#0f1419] dark:text-white placeholder:text-[#9D9D9D] outline-none focus:ring-2 focus:ring-[#d6775c] transition-all"
                    />
                  </div>
                </div>
              </div>

              {/* Search Results */}
              <div className="max-h-[500px] overflow-y-auto pb-[20px]">
                {searchQuery.length === 0 ? (
                  // Recent Searches / Suggestions
                  <div className="px-[20px]">
                    <h3 className="font-['Plus_Jakarta_Display',sans-serif] text-[16px] font-semibold text-[#0f1419] dark:text-white mb-[12px]">
                      {t.recentSearches}
                    </h3>
                    {trendingHashtags.slice(0, 3).map((item) => (
                      <motion.div
                        key={item.id}
                        whileHover={{ backgroundColor: 'rgba(0,0,0,0.03)' }}
                        className="flex items-center gap-[12px] p-[12px] rounded-[12px] cursor-pointer"
                        onClick={() => {
                          setSearchQuery(item.author);
                        }}
                      >
                        <Search className="w-[18px] h-[18px] text-[#9D9D9D]" />
                        <div className="flex-1">
                          <p className="font-['Plus_Jakarta_Display',sans-serif] text-[15px] text-[#0f1419] dark:text-white">
                            {item.author}
                          </p>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                ) : (
                  // Search Results
                  <div className="px-[20px]">
                    {trendingHashtags
                      .filter(
                        (item) =>
                          item.author.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          item.content.toLowerCase().includes(searchQuery.toLowerCase())
                      )
                      .map((result) => (
                        <motion.div
                          key={result.id}
                          initial={{ opacity: 0, y: 10 }}
                          animate={{ opacity: 1, y: 0 }}
                          className="flex items-start gap-[12px] p-[12px] rounded-[12px] hover:bg-neutral-50 dark:hover:bg-neutral-800 cursor-pointer mb-[8px]"
                        >
                          <div className="w-[40px] h-[40px] relative rounded-full overflow-hidden flex-shrink-0">
                            <img 
                              src={imgFrame} 
                              alt="" 
                              className="w-full h-full object-cover"
                            />
                          </div>
                          <div className="flex-1">
                            <div className="flex items-center gap-[4px] mb-[4px]">
                              <span className="font-['Roboto',sans-serif] text-[14px] font-bold text-[#0f1419] dark:text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                                {result.author}
                              </span>
                              {result.verified && (
                                <svg className="w-[14px] h-[14px]" viewBox="0 0 15 15" fill="none">
                                  <path d={svgPaths.p28359cf0} fill="#1D9BF0" />
                                </svg>
                              )}
                            </div>
                            <p className="font-['Roboto',sans-serif] text-[13px] text-[#536471] dark:text-[#8e8e8e]" style={{ fontVariationSettings: "'wdth' 100" }}>
                              {result.username}
                            </p>
                            <p className="font-['Roboto',sans-serif] text-[13px] text-[#0f1419] dark:text-white mt-[6px] line-clamp-2" style={{ fontVariationSettings: "'wdth' 100" }}>
                              {result.content}
                            </p>
                          </div>
                        </motion.div>
                      ))}
                    {trendingHashtags.filter(
                      (item) =>
                        item.author.toLowerCase().includes(searchQuery.toLowerCase()) ||
                        item.content.toLowerCase().includes(searchQuery.toLowerCase())
                    ).length === 0 && (
                      <div className="text-center py-[40px]">
                        <Search className="w-[48px] h-[48px] text-[#9D9D9D] mx-auto mb-[12px] opacity-30" />
                        <p className="font-['Plus_Jakarta_Display',sans-serif] text-[15px] text-[#9D9D9D]">
                          {t.noResults}
                        </p>
                      </div>
                    )}
                  </div>
                )}
              </div>
            </motion.div>
          </>
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
                <div className="flex items-center gap-[12px] mb-[20px] p-[12px] bg-neutral-50 dark:bg-neutral-800 rounded-[12px]">
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
                      {selectedStage.verified && (
                        <svg className="w-[16px] h-[16px]" viewBox="0 0 15 15" fill="none">
                          <path d={svgPaths.p28359cf0} fill="#1D9BF0" />
                        </svg>
                      )}
                    </div>
                    <p className="font-['Roboto',sans-serif] text-[13px] text-[#536471] dark:text-[#8e8e8e]" style={{ fontVariationSettings: "'wdth' 100" }}>
                      {language === 'bn' ? 'হোস্ট' : 'Host'} • {selectedStage.hostUsername}
                    </p>
                  </div>
                </div>

                {/* Stats Grid */}
                <div className="grid grid-cols-2 gap-[12px] mb-[24px]">
                  <div className="bg-neutral-50 dark:bg-neutral-800 rounded-[12px] p-[16px]">
                    <div className="flex items-center gap-[8px] mb-[6px]">
                      <svg className="w-[20px] h-[20px]" viewBox="0 0 24 24" fill="none">
                        <path d={svgPaths.p1b35f000} fill="#d6775c" />
                      </svg>
                      <span className="font-['Plus_Jakarta_Display',sans-serif] text-[12px] text-[#536471] dark:text-[#8e8e8e] font-medium">
                        {language === 'bn' ? 'শ্রোতা' : 'Listeners'}
                      </span>
                    </div>
                    <p className="font-['Plus_Jakarta_Display',sans-serif] text-[24px] font-bold text-[#0f1419] dark:text-white">
                      {selectedStage.listeners}
                    </p>
                  </div>
                  <div className="bg-neutral-50 dark:bg-neutral-800 rounded-[12px] p-[16px]">
                    <div className="flex items-center gap-[8px] mb-[6px]">
                      <svg className="w-[20px] h-[20px]" viewBox="0 0 24 24" fill="none">
                        <circle cx="12" cy="12" r="9" stroke="#d6775c" strokeWidth="2" fill="none"/>
                        <path d="M12 7v5l3 3" stroke="#d6775c" strokeWidth="2" strokeLinecap="round"/>
                      </svg>
                      <span className="font-['Plus_Jakarta_Display',sans-serif] text-[12px] text-[#536471] dark:text-[#8e8e8e] font-medium">
                        {language === 'bn' ? 'সময়' : 'Duration'}
                      </span>
                    </div>
                    <p className="font-['Plus_Jakarta_Display',sans-serif] text-[20px] font-bold text-[#0f1419] dark:text-white">
                      {selectedStage.duration}
                    </p>
                  </div>
                </div>

                {/* Info Text */}
                <div className="bg-[#d6775c]/10 dark:bg-[#d6775c]/20 rounded-[12px] p-[14px] mb-[20px]">
                  <p className="font-['Roboto',sans-serif] text-[13px] text-[#0f1419] dark:text-white leading-[19px]" style={{ fontVariationSettings: "'wdth' 100" }}>
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
                    className="flex-1 h-[50px] rounded-[25px] border-2 border-[#e6e6e6] dark:border-[#0d3a4a] text-[#0f1419] dark:text-white font-['Roboto',sans-serif] text-[16px] font-medium hover:bg-neutral-50 dark:hover:bg-neutral-800 transition-all"
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
    </div>
  );
};