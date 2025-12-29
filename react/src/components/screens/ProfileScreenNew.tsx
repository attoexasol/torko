import React, { useState, useEffect, useRef } from 'react';
import { motion } from 'motion/react';
import svgPaths from "../../imports/svg-e9t7d0cim8";
import imgRectangle41864 from "figma:asset/42b72b8a79f3a110aa8f70956343252fbc8ff7c6.png";
import imgRectangle41912 from "figma:asset/fe7c11784d9ec9e69f69234f3091969616d60fd2.png";
import imgRectangle41869 from "figma:asset/9493d6ffcd7db36ee2ef4d7ccb8cc3720f7fd7db.png";
import imgPawelCzerwinski8UZPynIuRQUnsplash2 from "figma:asset/8fb677f541a8266f00e55fc543e55a475d028aef.png";
import { imgPawelCzerwinski8UZPynIuRQUnsplash1 } from "../../imports/svg-zcqpm";
import { ChevronLeft, Grid3x3, Settings } from 'lucide-react';
import { PostCard } from '../PostCard';
import { useApp } from '../contexts/AppContext';

interface ProfileScreenNewProps {
  onBack?: () => void;
  onNavigate?: (screen: string) => void;
  language?: 'bn' | 'en';
}

export const ProfileScreenNew: React.FC<ProfileScreenNewProps> = ({ 
  onBack,
  onNavigate,
  language = 'bn'
}) => {
  const { setHideBottomNav } = useApp();
  const [activeTab, setActiveTab] = useState<'post' | 'poll' | 'saved'>('post');
  const [likedPosts, setLikedPosts] = useState<Set<number>>(new Set());
  const [likedPolls, setLikedPolls] = useState<Set<number>>(new Set());
  const [likedSaved, setLikedSaved] = useState<Set<number>>(new Set());
  const [lastScrollY, setLastScrollY] = useState(0);
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  
  // Edit mode states
  const [isEditMode, setIsEditMode] = useState(false);
  const [editName, setEditName] = useState('Thomas R.');
  const [savedName, setSavedName] = useState('Thomas R.');
  const [profileImage, setProfileImage] = useState(imgRectangle41864);
  const [coverImage, setCoverImage] = useState(imgPawelCzerwinski8UZPynIuRQUnsplash2);
  const profileImageInputRef = useRef<HTMLInputElement>(null);
  const coverImageInputRef = useRef<HTMLInputElement>(null);

  const t = {
    profile: language === 'bn' ? 'প্রোফাইল' : 'Profile',
    edit: language === 'bn' ? 'সম্পাদনা' : 'Edit',
    save: language === 'bn' ? 'সংরক্ষণ করুন' : 'Save',
    cancel: language === 'bn' ? 'বাতিল' : 'Cancel',
    name: language === 'bn' ? 'নাম' : 'Name',
    changeProfilePhoto: language === 'bn' ? 'প্রোফাইল ছবি পরিবর্তন করুন' : 'Change Profile Photo',
    changeCoverPhoto: language === 'bn' ? 'কভার ছবি পরিবর্তন করুন' : 'Change Cover Photo',
  };

  // Sample user posts
  const userPosts = [
    {
      id: 1,
      author: 'Thomas R.',
      username: '@thomas_r',
      timestamp: language === 'bn' ? '২ ঘণ্টা আগে' : '2h ago',
      content: language === 'bn' 
        ? 'আজকের সূর্যাস্ত অসাধারণ ছিল! ঢাকার আকাশ কত সুন্দর হতে পারে তা দেখে অবাক হলাম।' 
        : 'The sunset today was amazing! I\'m amazed at how beautiful the Dhaka sky can be.',
      avatar: imgRectangle41864,
      image: imgPawelCzerwinski8UZPynIuRQUnsplash2,
      type: 'image' as const,
      likes: 234,
      comments: 45,
    },
    {
      id: 2,
      author: 'Thomas R.',
      username: '@thomas_r',
      timestamp: language === 'bn' ? '১ দিন আগে' : '1d ago',
      content: language === 'bn'
        ? 'নতুন প্রকল্পে কাজ শুরু করেছি। অনেক উত্তেজনাপূর্ণ সময় সামনে!'
        : 'Started working on a new project. Exciting times ahead!',
      avatar: imgRectangle41864,
      likes: 189,
      comments: 28,
    },
    {
      id: 3,
      author: 'Thomas R.',
      username: '@thomas_r',
      timestamp: language === 'bn' ? '৩ দিন আগে' : '3d ago',
      content: language === 'bn'
        ? 'আজ যা শিখলাম: ছোট পদক্ষেপগুলোই বড় পরিবর্তন আনে।'
        : 'Today I learned: Small steps lead to big changes.',
      avatar: imgRectangle41864,
      gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      type: 'gradient' as const,
      likes: 312,
      comments: 67,
    },
  ];

  // Sample poll posts
  const pollPosts = [
    {
      id: 101,
      author: 'Thomas R.',
      username: '@thomas_r',
      timestamp: language === 'bn' ? '৫ ঘণ্টা আগে' : '5h ago',
      content: language === 'bn'
        ? 'আপনার প্রিয় প্রোগ্রামিং ভাষা কোনটি?'
        : 'What is your favorite programming language?',
      avatar: imgRectangle41864,
      type: 'poll' as const,
      poll: {
        question: language === 'bn'
          ? 'আপনার প্রিয় প্রোগ্রামিং ভাষা কোনটি?'
          : 'What is your favorite programming language?',
        options: [
          { id: 1, text: 'JavaScript', votes: 156 },
          { id: 2, text: 'Python', votes: 234 },
          { id: 3, text: 'Java', votes: 89 },
          { id: 4, text: 'C++', votes: 67 },
        ],
        totalVotes: 546,
        endTime: language === 'bn' ? '১ দিন বাকি' : '1 day left',
        hasVoted: false,
      },
      likes: 156,
      comments: 89,
    },
    {
      id: 102,
      author: 'Thomas R.',
      username: '@thomas_r',
      timestamp: language === 'bn' ? '২ দিন আগে' : '2d ago',
      content: language === 'bn'
        ? 'সপ্তাহান্তে কোন কাজটি করতে চান?'
        : 'What do you want to do this weekend?',
      avatar: imgRectangle41864,
      type: 'poll' as const,
      poll: {
        question: language === 'bn'
          ? 'সপ্তাহান্তে কোন কাজটি করতে চান?'
          : 'What do you want to do this weekend?',
        options: [
          { id: 1, text: language === 'bn' ? 'বাইরে ঘুরতে যাওয়া' : 'Go outside', votes: 312 },
          { id: 2, text: language === 'bn' ? 'বই পড়া' : 'Read a book', votes: 189 },
          { id: 3, text: language === 'bn' ? 'মুভি দেখা' : 'Watch a movie', votes: 278 },
          { id: 4, text: language === 'bn' ? 'বন্ধুদের সাথে আড্ডা' : 'Hang out with friends', votes: 421 },
        ],
        totalVotes: 1200,
        endTime: language === 'bn' ? 'শেষ হয়েছে' : 'Ended',
        hasVoted: true,
        votedOptionId: 4,
      },
      likes: 203,
      comments: 124,
    },
    {
      id: 103,
      author: 'Thomas R.',
      username: '@thomas_r',
      timestamp: language === 'bn' ? '১ সপ্তাহ আগে' : '1w ago',
      content: language === 'bn'
        ? 'আপনি কোন সময়ে বেশি productive?'
        : 'When are you most productive?',
      avatar: imgRectangle41864,
      type: 'poll' as const,
      poll: {
        question: language === 'bn'
          ? 'আপনি কোন সময়ে বেশি productive?'
          : 'When are you most productive?',
        options: [
          { id: 1, text: language === 'bn' ? 'ভোর ৫-৮টা' : 'Early morning (5-8 AM)', votes: 267 },
          { id: 2, text: language === 'bn' ? 'সকাল ৮-১২টা' : 'Morning (8 AM-12 PM)', votes: 445 },
          { id: 3, text: language === 'bn' ? 'বিকাল ১-৫টা' : 'Afternoon (1-5 PM)', votes: 189 },
          { id: 4, text: language === 'bn' ? 'রাত ৮-১২টা' : 'Night (8 PM-12 AM)', votes: 312 },
        ],
        totalVotes: 1213,
        endTime: language === 'bn' ? 'শেষ হয়েছে' : 'Ended',
        hasVoted: true,
        votedOptionId: 2,
      },
      likes: 92,
      comments: 45,
    },
  ];

  // Sample saved posts (from other users)
  const savedPosts = [
    {
      id: 201,
      author: 'রাফি আহমেদ',
      username: '@rafi_ahmed',
      timestamp: language === 'bn' ? '১ ঘণ্টা আগে' : '1h ago',
      content: language === 'bn'
        ? 'প্রোডাক্টিভিটি টিপস: প্রতিদিন ৩টি গুরুত্বপূর্ণ কাজের লিস্ট তৈরি করুন এবং সকালেই সেগুলো শেষ করার চেষ্টা করুন।'
        : 'Productivity tips: Create a list of 3 important tasks every day and try to finish them in the morning.',
      avatar: imgRectangle41912,
      type: 'text' as const,
      likes: 445,
      comments: 78,
    },
    {
      id: 202,
      author: 'নাদিয়া রহমান',
      username: '@nadia_rahman',
      timestamp: language === 'bn' ? '৪ ঘণ্টা আগে' : '4h ago',
      content: language === 'bn'
        ? 'কক্সবাজারে সূর্যোদয়ের এই দৃশ্য সারাজীবন মনে থাকবে!'
        : 'This sunrise view at Cox\'s Bazar will stay in my memory forever!',
      avatar: imgRectangle41869,
      image: imgPawelCzerwinski8UZPynIuRQUnsplash2,
      type: 'image' as const,
      likes: 892,
      comments: 156,
    },
    {
      id: 203,
      author: 'সাকিব হাসান',
      username: '@sakib_hassan',
      timestamp: language === 'bn' ? '১ দিন আগে' : '1d ago',
      content: language === 'bn'
        ? 'জীবনে সফল হতে হলে প্রতিদিন একটু একটু করে এগিয়ে যেতে হবে। থেমে থাকলে পিছিয়ে যাওয়া ছাড়া কোনো উপায় নেই।'
        : 'To be successful in life, you have to move forward a little bit every day. If you stop, there is no other way but to fall behind.',
      avatar: imgRectangle41864,
      gradient: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
      type: 'gradient' as const,
      likes: 567,
      comments: 234,
    },
  ];

  const handleLike = (postId: number) => {
    setLikedPosts(prev => {
      const newSet = new Set(prev);
      if (newSet.has(postId)) {
        newSet.delete(postId);
      } else {
        newSet.add(postId);
      }
      return newSet;
    });
  };

  const handlePollLike = (postId: number) => {
    setLikedPolls(prev => {
      const newSet = new Set(prev);
      if (newSet.has(postId)) {
        newSet.delete(postId);
      } else {
        newSet.add(postId);
      }
      return newSet;
    });
  };

  const handleSavedLike = (postId: number) => {
    setLikedSaved(prev => {
      const newSet = new Set(prev);
      if (newSet.has(postId)) {
        newSet.delete(postId);
      } else {
        newSet.add(postId);
      }
      return newSet;
    });
  };

  const handleEditClick = () => {
    setIsEditMode(true);
    setEditName(savedName);
  };

  const handleSaveEdit = () => {
    setSavedName(editName);
    setIsEditMode(false);
  };

  const handleCancelEdit = () => {
    setEditName(savedName);
    setIsEditMode(false);
  };

  const handleProfileImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setProfileImage(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleCoverImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setCoverImage(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  // Detect scroll direction
  useEffect(() => {
    const scrollContainer = scrollContainerRef.current;
    if (!scrollContainer) return;

    const handleScroll = () => {
      const currentScrollY = scrollContainer.scrollTop;
      const scrollDelta = currentScrollY - lastScrollY;
      
      if (currentScrollY < 10) {
        // Always show bottom nav at top
        setHideBottomNav(false);
      } else if (scrollDelta > 15 && currentScrollY > 20) {
        // Scrolling down & past threshold - hide bottom nav
        setHideBottomNav(true);
      } else if (scrollDelta < -5) {
        // Scrolling up - show bottom nav
        setHideBottomNav(false);
      }
      
      setLastScrollY(currentScrollY);
    };

    scrollContainer.addEventListener('scroll', handleScroll, { passive: true });
    return () => scrollContainer.removeEventListener('scroll', handleScroll);
  }, [lastScrollY, setHideBottomNav]);

  return (
    <div className="h-screen bg-[#FAFAFA] dark:bg-[#052029] overflow-y-auto" ref={scrollContainerRef}>
      {/* Main Container - mimicking Figma's 428px width */}
      <div className="max-w-auto mx-auto bg-white dark:bg-[#052029] relative pb-20 min-h-full">
        
        {/* Rectangular Box Background Cover Image */}
        <div className="relative h-[240px] w-full overflow-hidden bg-[#F5F5F5] dark:bg-[#0a2f3d]">
          {/* Header Controls */}
          <div className="absolute top-[20px] left-0 right-0 flex items-center justify-between px-[20px] z-10">
            <button
              onClick={onBack}
              className="w-[40px] h-[40px] rounded-full bg-[rgba(0,0,0,0.05)] dark:bg-[rgba(255,255,255,0.1)] backdrop-blur-sm flex items-center justify-center hover:bg-[rgba(0,0,0,0.1)] dark:hover:bg-[rgba(255,255,255,0.2)] transition-colors"
            >
              <ChevronLeft className="w-[24px] h-[24px] text-[#0f1419] dark:text-white" />
            </button>
            
            <span className="font-['Roboto',sans-serif] text-[18px] font-semibold text-[#0f1419] dark:text-white">
              {t.profile}
            </span>

            <button 
              onClick={() => onNavigate?.('settings')}
              className="w-[40px] h-[40px] rounded-full bg-[rgba(0,0,0,0.05)] dark:bg-[rgba(255,255,255,0.1)] backdrop-blur-sm flex items-center justify-center hover:bg-[rgba(0,0,0,0.1)] dark:hover:bg-[rgba(255,255,255,0.2)] transition-colors"
            >
              <Settings className="w-[20px] h-[20px] text-[#0f1419] dark:text-white" />
            </button>
          </div>
        </div>

        {/* White Profile Card Overlay */}
        <div className="relative mx-[20px] -mt-[90px] z-20 mb-[24px]">
          <div className="bg-white dark:bg-[#0a2f3d] border-[1px] border-[#EAEAEA] dark:border-[#0d3a4a] rounded-[33px] pb-[24px] pt-[23px] px-[20px]">
            
            {/* Profile Picture - Centered */}
            <div className="flex justify-center -mt-[85px] mb-[16px]">
              <div className="relative">
                {/* Outer border with coral color */}
                <div className="w-[95px] h-[95px] bg-[#C4C4C4] border-[3px] border-[#008001] drop-shadow-[0_2px_10px_rgba(0,0,0,0.45)] rounded-full p-[3px] outline outline-5 outline-white">
                  <div className="w-full h-full rounded-full overflow-hidden">
                    <img 
                      src={profileImage} 
                      alt="Profile" 
                      className="w-full h-full object-cover scale-[2] translate-x-[-60%] translate-y-[-1.5%]"
                    />
                  </div>
                  
                  {/* Profile Image Camera Button - Only in Edit Mode */}
                  {isEditMode && (
                    <motion.button
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      onClick={() => profileImageInputRef.current?.click()}
                      className="absolute inset-0 w-full h-full rounded-full bg-[rgba(0,0,0,0.5)] backdrop-blur-sm flex items-center justify-center hover:bg-[rgba(0,0,0,0.6)] transition-all"
                    >
                      <svg className="w-[24px] h-[24px]" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                        <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" />
                        <circle cx="12" cy="13" r="4" />
                      </svg>
                    </motion.button>
                  )}
                </div>
                
                {/* Hidden file input for profile image */}
                <input
                  ref={profileImageInputRef}
                  type="file"
                  accept="image/*"
                  onChange={handleProfileImageChange}
                  className="hidden"
                />
                
                {/* Edit button - coral background */}
                <button 
                  onClick={handleEditClick}
                  className="absolute bottom-0 left-[175px] top-[80px] w-[28px] h-[28px] rounded-full bg-[#ff7a51] flex items-center justify-center shadow-lg hover:bg-[#ff6640] transition-colors"
                >
                  <svg className="w-[14px] h-[14px]" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                  </svg>
                </button>
              </div>
            </div>

            {/* Name */}
            <div className="text-center mb-[8px]">
              {isEditMode ? (
                <input
                  type="text"
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  className="w-full text-center font-['Plus_Jakarta_Display',sans-serif] text-[20px] font-bold text-[#0f1419] dark:text-white bg-transparent border-b-2 border-[#d6775c] focus:outline-none px-4"
                  placeholder={t.name}
                />
              ) : (
                <h2 className="font-['Plus_Jakarta_Display',sans-serif] text-[20px] font-bold text-[#0f1419] dark:text-white">
                  {savedName}
                </h2>
              )}
            </div>

            {/* Edit Mode Buttons */}
            {isEditMode && (
              <motion.div 
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="flex gap-[12px] mb-[20px] px-[20px]"
              >
                <button
                  onClick={handleCancelEdit}
                  className="flex-1 h-[40px] rounded-[10px] bg-[#f0f0f0] dark:bg-[#0d3a4a] text-[#333] dark:text-white font-['Roboto',sans-serif] font-medium hover:bg-[#e0e0e0] dark:hover:bg-[#104050] transition-colors"
                >
                  {t.cancel}
                </button>
                <button
                  onClick={handleSaveEdit}
                  className="flex-1 h-[40px] rounded-[10px] bg-[#d6775c] text-white font-['Roboto',sans-serif] font-medium hover:bg-[#c5664b] transition-colors"
                >
                  {t.save}
                </button>
              </motion.div>
            )}

            {/* Stats */}
            <div className="flex items-center justify-center gap-[32px] mb-[24px]">
              {/* Posts */}
              <div className="flex flex-col items-center">
                <p className="font-['Plus_Jakarta_Display',sans-serif] text-[15px] font-bold text-[#0f1419] dark:text-white">
                  54
                </p>
                <p className="font-['Plus_Jakarta_Display',sans-serif] text-[13px] text-[#536471] dark:text-[#8e8e8e]">
                  Posts
                </p>
              </div>

              {/* Neighbours */}
              <div className="flex flex-col items-center">
                <p className="font-['Plus_Jakarta_Display',sans-serif] text-[16px] font-bold text-[#0f1419] dark:text-white">
                  834
                </p>
                <p className="font-['Plus_Jakarta_Display',sans-serif] text-[13px] text-[#536471] dark:text-[#8e8e8e]">
                  {language === 'bn' ? 'প্রতিবেশী' : 'Neighbours'}
                </p>
              </div>

              {/* Following */}
              <div className="flex flex-col items-center">
                <p className="font-['Plus_Jakarta_Display',sans-serif] text-[16px] text-[#0f1419] dark:text-white font-normal font-bold">
                  162
                </p>
                <p className="font-['Plus_Jakarta_Display',sans-serif] text-[13px] text-[#536471] dark:text-[#8e8e8e]">
                  Following
                </p>
              </div>
            </div>

            {/* Tabs - Post, Poll, Saved */}
            <div className="relative bg-neutral-50 dark:bg-[#0a2f3d] h-[65px] rounded-[15px] flex items-center justify-between px-[8px]">
              {/* Active Tab Background */}
              <motion.div
                className="absolute bg-[#d6775c] h-[53px] rounded-[10px]"
                initial={false}
                animate={{
                  left: activeTab === 'post' ? '8px' : activeTab === 'poll' ? 'calc(33.33% + 2px)' : 'calc(66.66% - 2px)',
                  width: activeTab === 'post' ? 'calc(33.33% - 8px)' : activeTab === 'poll' ? 'calc(33.33% - 4px)' : 'calc(33.33% - 8px)',
                }}
                transition={{ type: 'spring', stiffness: 300, damping: 30 }}
              />

              {/* Post Tab */}
              <button
                onClick={() => setActiveTab('post')}
                className="relative z-10 flex-1 flex flex-col items-center justify-center gap-[4px] h-[53px]"
              >
                <svg className="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="none">
                  <path 
                    d={svgPaths.p526480} 
                    fill={activeTab === 'post' ? 'white' : '#9D9D9D'} 
                  />
                </svg>
                <span 
                  className={`font-['Roboto',sans-serif] text-[11px] font-bold tracking-[-0.1px] ${
                    activeTab === 'post' ? 'text-white' : 'text-[#9d9d9d]'
                  }`}
                  style={{ fontVariationSettings: "'wdth' 100" }}
                >
                  Post
                </span>
              </button>

              {/* Poll Tab */}
              <button
                onClick={() => setActiveTab('poll')}
                className="relative z-10 flex-1 flex flex-col items-center justify-center gap-[4px] h-[53px]"
              >
                <svg className="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="none" stroke={activeTab === 'poll' ? 'white' : '#9D9D9D'} strokeWidth="2">
                  <path d={svgPaths.p1bfd2e80} strokeLinecap="round" strokeLinejoin="round" />
                </svg>
                <span 
                  className={`font-['Roboto',sans-serif] text-[11px] font-bold tracking-[-0.1px] ${
                    activeTab === 'poll' ? 'text-white' : 'text-[#9d9d9d]'
                  }`}
                  style={{ fontVariationSettings: "'wdth' 100" }}
                >
                  Poll
                </span>
              </button>

              {/* Saved Tab */}
              <button
                onClick={() => setActiveTab('saved')}
                className="relative z-10 flex-1 flex flex-col items-center justify-center gap-[4px] h-[53px]"
              >
                <svg className="w-[16px] h-[16px]" viewBox="0 0 19 19" fill="none" stroke={activeTab === 'saved' ? 'white' : '#9D9D9D'} strokeWidth="2">
                  <path d="M4.66667 1V5.58333H12" strokeLinecap="round" strokeLinejoin="round" />
                  <path d={svgPaths.pee5e680} strokeLinecap="round" strokeLinejoin="round" />
                  <path d={svgPaths.p3a667a80} strokeLinecap="round" strokeLinejoin="round" />
                </svg>
                <span 
                  className={`font-['Roboto',sans-serif] text-[11px] font-bold tracking-[-0.1px] ${
                    activeTab === 'saved' ? 'text-white' : 'text-[#9d9d9d]'
                  }`}
                  style={{ fontVariationSettings: "'wdth' 100" }}
                >
                  Saved
                </span>
              </button>
            </div>
          </div>
        </div>

        {/* Post Cards */}
        <div className="p-[0px] space-y-[14px]">
          {activeTab === 'post' && userPosts.map((post, index) => (
            <div
              key={post.id}
            >
              <PostCard
                author={post.author}
                username={post.username}
                timestamp={post.timestamp}
                content={post.content}
                avatar={post.avatar}
                image={post.image}
                type={post.type}
                gradient={post.gradient}
                likes={post.likes}
                comments={post.comments}
                isLiked={likedPosts.has(post.id)}
                onLike={() => handleLike(post.id)}
                language={language}
              />
            </div>
          ))}
          
          {activeTab === 'poll' && pollPosts.map((post, index) => (
            <div
              key={post.id}
            >
              <PostCard
                author={post.author}
                username={post.username}
                timestamp={post.timestamp}
                content={post.content}
                avatar={post.avatar}
                type={post.type}
                poll={post.poll}
                gradient={post.gradient}
                likes={post.likes}
                comments={post.comments}
                isLiked={likedPolls.has(post.id)}
                onLike={() => handlePollLike(post.id)}
                language={language}
              />
            </div>
          ))}
          
          {activeTab === 'saved' && savedPosts.map((post, index) => (
            <div
              key={post.id}
            >
              <PostCard
                author={post.author}
                username={post.username}
                timestamp={post.timestamp}
                content={post.content}
                avatar={post.avatar}
                image={post.image}
                type={post.type}
                gradient={post.gradient}
                likes={post.likes}
                comments={post.comments}
                isLiked={likedSaved.has(post.id)}
                onLike={() => handleSavedLike(post.id)}
                language={language}
              />
            </div>
          ))}
        </div>
        
      </div>
    </div>
  );
};