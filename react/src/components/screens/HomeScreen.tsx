import React, { useState, useEffect, useRef } from 'react';
import { motion, useScroll, useTransform, AnimatePresence } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';
import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '../ui/tabs';
import { Separator } from '../ui/separator';
import { Heart, MessageCircle, Share2, MoreHorizontal, Plus, Flame, Bell, Play, Pause, Volume2, VolumeX, Radio, Users, Hash, TrendingUp, Bookmark, Flag, EyeOff, Link2, UserPlus, UserMinus, Trash2 } from 'lucide-react';
import { ScrollZoomImage } from '../ScrollZoomImage';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '../ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '../ui/dialog';
import { HomeHeader } from '../HomeHeader';
import { PostCard } from '../PostCard';
import profileImage1 from "figma:asset/f45ddf851e4fd13afc02b4be3ef3d9788f2750ee.png";
import profileImage2 from "figma:asset/424f8c91e98391cafb48a5e6469d4fb624985e0d.png";

interface Post {
  id: string;
  author: string;
  authorAvatar: string;
  groupName?: string; // Group/Community name (optional - undefined for personal posts)
  location?: string; // User's location (division, district, upazila)
  timestamp: string;
  hoursAgo: number;
  content: string;
  image?: string;
  video?: string;
  images?: string[]; // Multiple images
  videos?: string[]; // Multiple videos
  type: 'text' | 'image' | 'video' | 'gradient' | 'multiImage' | 'multiVideo' | 'poll';
  gradient?: string;
  poll?: {
    question: string;
    options: { id: number; text: string; votes: number }[];
    totalVotes: number;
    endTime?: string;
    hasVoted?: boolean;
    votedOptionId?: number;
  };
  likes: number;
  comments: number;
  shares: number;
  isLiked: boolean;
}

interface CommentReaction {
  emoji: string;
  count: number;
  reacted: boolean;
}

interface Comment {
  id: string;
  author: string;
  authorInitial: string;
  avatarColor: string;
  content: string;
  timestamp: string;
  likes: number;
  isLiked: boolean;
  reactions: CommentReaction[];
  replies?: Comment[];
  replyingTo?: string;
}

// Gradient backgrounds like Facebook
const gradients = [
  'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
  'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
  'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
  'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
  'linear-gradient(135deg, #30cfd0 0%, #330867 100%)',
  'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)',
  'linear-gradient(135deg, #ff9a56 0%, #ff6a88 100%)',
  'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)',
  'linear-gradient(135deg, #ff6e7f 0%, #bfe9ff 100%)',
  'linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%)',
  'linear-gradient(135deg, #f77062 0%, #fe5196 100%)',
];

// Authors (Bangla and English names)
const authors = [
  'Sarah Johnson', 'Michael Chen', 'Emma Williams', 'David Rodriguez', 'Lisa Anderson',
  'James Park', 'Sophia Martinez', 'আবদুল কাদের', 'নাজমুল হাসান', 'তানিয়া আফরিন',
  'Emily Brown', 'Christopher Lee', 'Isabella Garcia', 'Matthew Harris', 'Ava Thompson',
  'Ryan White', 'Mia Robinson', 'Kevin Walker', 'Charlotte Hall', 'Brandon Scott',
  'Daniel Kim', 'সাবিহা আক্তার', 'Olivia Taylor', 'শাহরিয়ার কবির', 'Robert Lewis'
];

// Groups/Communities for posts (Bangla and English)
const groups = [
  'ঢাকা ফুড লাভার্স', 'Tech Community BD', 'বই পড়ুয়া', 'Travel Bangladesh',
  'গুলশান কমিউনিটি', 'Photography BD', 'বাংলাদেশ স্টার্টআপ', 'Fitness Enthusiasts',
  'বনানী রেসিডেন্টস', 'Dhaka Bikers', 'ভ্রমণপিপাসু', 'Coding Ninjas BD',
  'রান্নাঘর', 'Dhaka University Alumni', 'বাংলা সাহিত্য', 'Sports Lovers BD',
  'মিরপুর কমিউনিটি', 'Digital Marketing BD', 'আর্ট এন্ড ক্রাফট', 'Entrepreneurs BD',
  'মগবাজার ইয়ুথ', 'Gaming Community', 'সংগীত প্রেমী', 'Nature Lovers BD',
  'উত্তরা ফ্যামিলিজ'
];

// Author avatars matching the authors array
const authorAvatars = [
  profileImage1, // Sarah Johnson
  profileImage2, // Michael Chen
  'https://images.unsplash.com/photo-1609091289242-735df7a2207a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Emma Williams
  'https://images.unsplash.com/photo-1741484179101-be16307578db?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // David Rodriguez
  'https://images.unsplash.com/photo-1649589244330-09ca58e4fa64?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Lisa Anderson
  'https://images.unsplash.com/flagged/photo-1596479042555-9265a7fa7983?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // James Park
  'https://images.unsplash.com/photo-1679507655428-ab3d50356bac?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Sophia Martinez
  'https://images.unsplash.com/photo-1633177188754-980c2a6b6266?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Daniel Kim
  'https://images.unsplash.com/photo-1573497019418-b400bb3ab074?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Olivia Taylor
  'https://images.unsplash.com/photo-1619193597120-1d1edb42e34b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Robert Lewis
  'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Emily Brown
  'https://images.unsplash.com/photo-1602024290243-cb6c7609dd6b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Christopher Lee
  'https://images.unsplash.com/photo-1594318223885-20dc4b889f9e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Isabella Garcia
  'https://images.unsplash.com/photo-1723537742563-15c3d351dbf2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Matthew Harris
  'https://images.unsplash.com/photo-1644313720910-9a2520bbd28f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Ava Thompson
  'https://images.unsplash.com/photo-1621788455015-e48161cb187b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Ryan White
  'https://images.unsplash.com/photo-1705830337569-47a1a24b0ad2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Mia Robinson
  'https://images.unsplash.com/photo-1680540692052-79fde1108370?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Kevin Walker
  'https://images.unsplash.com/photo-1752650736067-f063e0af420c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Charlotte Hall
  'https://images.unsplash.com/photo-1581065178047-8ee15951ede6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400', // Brandon Scott
];

// Content for text/gradient posts (Bangla, English, and Mixed)
const textContents = [
  'আজকের দিনটা সত্যিই অসাধারণ ছিল!',
  'জীবনে স্বপ্ন দেখতে কখনো ভুলে যেও না।',
  'পরিবার এবং বন্ধুরাই সবচেয়ে বড় সম্পদ।',
  'প্রতিটি সূর্যোদয়ের সাথে আসে নতুন আশা।',
  'কঠোর পরিশ্রমই সফলতার চাবিকাঠি।',
  'ভালোবাসা পৃথিবীকে বদলে দিতে পারে।',
  'শিক্ষাই জাতির মেরুদণ্ড।',
  'স্বপ্নকে বাস্তবে পরিণত করো।',
  'এই মুহূর্তটা আর কখনো ফিরে আসবে না।',
  'ধৈর্য এবং বিশ্বাসই সফলতার চাবি।',
  'প্রতিদিন নিয়ে আসে নতুন সম্ভাবনা।',
  'পরিবর্তন শুরু হয় নিজের থেকে।',
  'হাসি দিয়ে সব সমস্যার সমাধান করা যায়।',
  'কখনো হাল ছেড়ে দিও না!',
  'প্রকৃতির কাছে ফিরে গেলে মন শান্ত হয়।',
  'বই পড়া মনকে সমৃদ্ধ করে।',
  'সততাই সর্বোত্তম নীতি।',
  'সময়ই সবচেয়ে মূল্যবান সম্পদ।',
  'একসাথে থাকলে সবকিছু সম্ভব।',
  'আত্মবিশ্বাসই সফলতার প্রথম ধাপ।',
  'Today was amazing! এত ভালো লাগলো',
  'Finally completed my project! অনেক কষ্ট করতে হয়েছে',
  'Weekend vibes with friends! মজা করলাম অনেক',
  'New cafe discover করলাম Dhanmondi তে, must try!',
  'Just finished reading this book! অসাধারণ ছিল',
  'Morning walk করে এলাম, feeling refreshed',
  'Trying new recipe today! দেখি কেমন হয়',
  'Late night coding session, coffee লাগবে',
  'Monsoon season এসে গেছে finally!',
  'Weekend plan করছি friends দের সাথে',
  'Gym যাওয়া start করলাম আবার',
  'New playlist বানালাম, music therapy চলছে',
  'Coffee without friends is boring! miss you guys',
  'Study break নিয়ে একটু chill করছি',
  'Traffic jam এ আটকে আছি, typical Dhaka',
  'Movie দেখে এলাম, ekdom moja!',
  'Productive day ছিল আজকের, feeling good',
  'Rain এ ভিজে এলাম, nostalgia হচ্ছে',
  'New year new goals! এবার পারবোই',
  'Family time is the best time!',
];

// Generate 100 posts
const generatePosts = (): Post[] => {
  const posts: Post[] = [];
  
  const images = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    'https://images.unsplash.com/photo-1617634667039-8e4cb277ab46?w=800',
    'https://images.unsplash.com/photo-1551982932-22e28394fbb7?w=800',
    'https://images.unsplash.com/photo-1617121346253-43ef95179ac9?w=800',
    'https://images.unsplash.com/photo-1732825605764-e98ebc7d987c?w=800',
    'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=800',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
    'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
  ];

  const videos = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
  ];

  const contentTemplates = [
    'আজকের সূর্যাস্ত সত্যিই অসাধারণ ছিল! দৃশ্যটা হৃদয় ভরিয়ে দিয়েছে।',
    'ঢাকার রাস্তায় বৃষ্টির দৃশ্য সবার সাথে শেয়ার করছি।',
    'সুন্দরবনের এক অপূর্ব প্রাকৃতিক দৃশ্য। বাংলাদেশের গর্ব!',
    'রমজান মাসে ইফতারের বিশেষ রেসিপি দেখুন!',
    'পাহাড়ি এলাকায় ভ্রমণের কিছু মুহূর্ত। অবিশ্বাস্য সৌন্দর্য!',
    'নতুন প্রযুক্তি নিয়ে কাজ করছি। অনেক উত্তেজিত!',
    'বইমেলায় নতুন বই কিনেছি। পড়ার জন্য অপেক্ষা করছি!',
    'ক্রিকেট ম্যাচের কিছু হাইলাইটস! চমৎকার পারফরম্যান্স।',
    'গ্রামে বেড়াতে গিয়েছিলাম। কী শান্ত পরিবেশ!',
    'নতুন রেস্তোরাঁয় ডিনার করলাম। খাবার দারুণ ছিল!',
    'Cox\'s Bazar এ sunset দেখছি, breathtaking view!',
    'Gulshan Lake এ morning walk, so peaceful!',
    'Street food hunting in Old Dhaka! মজা লাগছে',
    'New coffee shop discover করলাম Banani তে, loved it!',
    'Pohela Boishakh celebration! সবাইকে শুভেচ্ছা',
    'Victory Day parade দেখে এলাম, proud moment!',
    'Rooftop party with squad! Perfect weather আজকে',
    'Trying new Bengali restaurant, authentic taste!',
    'Road trip to Sajek Valley! Adventure starts',
    'Book fair এ গিয়েছিলাম, so many books to buy!',
    'Morning tea at Jheel Park, refreshing start!',
    'Cricket match দেখছি stadium এ, exciting!',
    'New year celebration with family! Best time',
    'Rickshaw ride in puran Dhaka, nostalgic feels!',
    'Hatirjheel এ cycling করছি, good exercise!',
  ];

  // Bangladesh locations (Division, District, Upazila format)
  const locations = [
    'ঢাকা, ধানমন্ডি',
    'ঢাকা, গুলশান',
    'ঢাকা, মিরপুর',
    'ঢাকা, উত্তরা',
    'ঢাকা, মগবাজার',
    'চট্টগ্রাম, পাঁচলাইশ',
    'চট্টগ্রাম, আগ্রাবাদ',
    'সিলেট, জিন্দাবাজার',
    'খুলনা, খুলনা সদর',
    'রাজশাহী, রাজপাড়া',
    'বরিশাল, বন্দর',
    'রংপুর, কারমাইকেল',
    'ময়মনসিংহ, মসজিদ মার্কেট',
    'Dhaka, Dhanmondi',
    'Dhaka, Gulshan',
    'Chattogram, Nasirabad',
    'Sylhet, Zindabazar',
    'Rajshahi, Shaheb Bazar',
  ];

  for (let i = 1; i <= 100; i++) {
    const authorIndex = (i - 1) % authors.length;
    const author = authors[authorIndex];
    const randomHours = Math.floor(Math.random() * 24) + 1;
    
    // Determine post type - including multi-image posts
    const rand = Math.random();
    let type: 'text' | 'image' | 'video' | 'gradient' | 'multiImage' | 'multiVideo' | 'poll';
    let content: string;
    let image: string | undefined;
    let video: string | undefined;
    let imagesArray: string[] | undefined;
    let videosArray: string[] | undefined;
    let gradient: string | undefined;
    let poll: Post['poll'] | undefined;

    if (rand < 0.2) {
      // Gradient text post
      type = 'gradient';
      content = textContents[i % textContents.length];
      gradient = gradients[i % gradients.length];
    } else if (rand < 0.35) {
      // Single image post
      type = 'image';
      content = contentTemplates[i % contentTemplates.length];
      image = images[i % images.length];
    } else if (rand < 0.6) {
      // Multiple images post (2-10 images)
      type = 'multiImage';
      content = contentTemplates[i % contentTemplates.length];
      const numImages = Math.floor(Math.random() * 9) + 2; // 2 to 10 images
      imagesArray = [];
      for (let j = 0; j < numImages; j++) {
        imagesArray.push(images[(i + j) % images.length]);
      }
    } else if (rand < 0.7) {
      // Single video post
      type = 'video';
      content = contentTemplates[i % contentTemplates.length];
      video = videos[i % videos.length];
    } else if (rand < 0.8) {
      // Multiple videos post (2-4 videos)
      type = 'multiVideo';
      content = contentTemplates[i % contentTemplates.length];
      const numVideos = Math.floor(Math.random() * 3) + 2; // 2 to 4 videos
      videosArray = [];
      for (let j = 0; j < numVideos; j++) {
        videosArray.push(videos[(i + j) % videos.length]);
      }
    } else if (rand < 0.9) {
      // Poll post
      type = 'poll';
      content = contentTemplates[i % contentTemplates.length];
      poll = {
        question: 'What is your favorite color?',
        options: [
          { id: 1, text: 'Red', votes: Math.floor(Math.random() * 100) },
          { id: 2, text: 'Blue', votes: Math.floor(Math.random() * 100) },
          { id: 3, text: 'Green', votes: Math.floor(Math.random() * 100) },
          { id: 4, text: 'Yellow', votes: Math.floor(Math.random() * 100) },
        ],
        totalVotes: Math.floor(Math.random() * 400) + 100,
        endTime: new Date(Date.now() + Math.floor(Math.random() * 86400000)).toISOString(),
        hasVoted: Math.random() > 0.5,
        votedOptionId: Math.random() > 0.5 ? Math.floor(Math.random() * 4) + 1 : undefined,
      };
    } else {
      // Regular text post
      type = 'text';
      content = contentTemplates[i % contentTemplates.length] + ' ' + textContents[i % textContents.length];
    }

    posts.push({
      id: `${i}`,
      author: author, // Keep the actual author/user name
      authorAvatar: authorAvatars[authorIndex],
      groupName: Math.random() > 0.4 ? groups[i % groups.length] : undefined, // 60% group posts, 40% personal posts
      location: locations[i % locations.length], // All posts have location
      timestamp: `${randomHours} hours ago`,
      hoursAgo: randomHours,
      content,
      image,
      video,
      images: imagesArray,
      videos: videosArray,
      type,
      gradient,
      poll,
      likes: Math.floor(Math.random() * 2000) + 50,
      comments: Math.floor(Math.random() * 300) + 10,
      shares: Math.floor(Math.random() * 150) + 5,
      isLiked: Math.random() > 0.7,
    });
  }

  return posts;
};

const mockPosts: Post[] = generatePosts();

interface HomeScreenProps {
  onNavigate: (screen: string) => void;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({ onNavigate }) => {
  const { language, openConversation, setHideBottomNav, showNotification, openPostDetail } = useApp();
  const [posts, setPosts] = useState(mockPosts);
  const [activeTab, setActiveTab] = useState<'forYou' | 'following' | 'trending'>('forYou');
  const [playingVideo, setPlayingVideo] = useState<string | null>(null);
  const [unmutedVideos, setUnmutedVideos] = useState<Set<string>>(new Set()); // Track unmuted videos (default is muted)
  const [manuallyPausedVideos, setManuallyPausedVideos] = useState<Set<string>>(new Set()); // Track manually paused videos
  const [videoProgress, setVideoProgress] = useState<Map<string, number>>(new Map()); // Track video progress (0-100)
  const [videoDurations, setVideoDurations] = useState<Map<string, number>>(new Map()); // Track video durations in seconds
  const [videoCurrentTimes, setVideoCurrentTimes] = useState<Map<string, number>>(new Map()); // Track current time in seconds
  const videoRefs = useRef<Map<string, HTMLVideoElement>>(new Map());
  const playPromises = useRef<Map<string, Promise<void> | null>>(new Map());
  const [showHeader, setShowHeader] = useState(true);
  const [lastScrollY, setLastScrollY] = useState(0);
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const [savedPosts, setSavedPosts] = useState<Set<string>>(new Set());
  const [hiddenPosts, setHiddenPosts] = useState<Set<string>>(new Set());
  const [followingUsers, setFollowingUsers] = useState<Set<string>>(new Set(['Michael Chen', 'David Rodriguez', 'James Park', 'Olivia Taylor', 'Robert Lewis'])); // Default following users
  const [openMenuPostId, setOpenMenuPostId] = useState<string | null>(null);

  // Report dialog state
  const [reportDialogOpen, setReportDialogOpen] = useState(false);
  const [reportingPostId, setReportingPostId] = useState<string | null>(null);
  const [reportStep, setReportStep] = useState<1 | 2 | 3>(1);
  const [reportReason, setReportReason] = useState<string>('');
  const [reportSubReason, setReportSubReason] = useState<string>('');

  // Report reasons with sub-reasons
  const reportReasons = {
    spam: {
      label: language === 'bn' ? 'স্প্যাম' : 'Spam',
      subReasons: [
        { id: 'fake', label: language === 'bn' ? 'জাল বা প্রতারণামূলক' : 'Fake or fraudulent' },
        { id: 'scam', label: language === 'bn' ? 'স্ক্যাম বা প্রতারণা' : 'Scam or deception' },
        { id: 'repetitive', label: language === 'bn' ? 'পুনরাবৃত্তিমূলক কন্টেন্ট' : 'Repetitive content' },
      ]
    },
    harassment: {
      label: language === 'bn' ? 'হয়রানি' : 'Harassment',
      subReasons: [
        { id: 'bullying', label: language === 'bn' ? 'বুলিং বা হুমকি' : 'Bullying or threatening' },
        { id: 'hate_speech', label: language === 'bn' ? 'ঘৃণামূলক বক্তব্য' : 'Hate speech' },
        { id: 'personal_attack', label: language === 'bn' ? 'ব্যক্তিগত আক্রমণ' : 'Personal attack' },
      ]
    },
    violence: {
      label: language === 'bn' ? 'সহিংসতা' : 'Violence',
      subReasons: [
        { id: 'graphic', label: language === 'bn' ? 'গ্রাফিক কন্টেন্ট' : 'Graphic content' },
        { id: 'threats', label: language === 'bn' ? 'হুমকি বা বিপদ' : 'Threats or danger' },
        { id: 'self_harm', label: language === 'bn' ? 'আত্মক্ষতি' : 'Self-harm' },
      ]
    },
    misinformation: {
      label: language === 'bn' ? 'মিথ্যা তথ্য' : 'Misinformation',
      subReasons: [
        { id: 'false_news', label: language === 'bn' ? 'মিথ্যা খবর' : 'False news' },
        { id: 'misleading', label: language === 'bn' ? 'বিভ্রান্তিকর' : 'Misleading' },
        { id: 'impersonation', label: language === 'bn' ? 'ছদ্মবেশ' : 'Impersonation' },
      ]
    },
    inappropriate: {
      label: language === 'bn' ? 'অনুপযুক্ত কন্টেন্ট' : 'Inappropriate content',
      subReasons: [
        { id: 'sexual', label: language === 'bn' ? 'যৌন কন্টেন্ট' : 'Sexual content' },
        { id: 'nudity', label: language === 'bn' ? 'নগ্নতা' : 'Nudity' },
        { id: 'offensive', label: language === 'bn' ? 'আপত্তিজনক' : 'Offensive' },
      ]
    },
    other: {
      label: language === 'bn' ? 'অন্যান্য' : 'Other',
      subReasons: [
        { id: 'copyright', label: language === 'bn' ? 'কপিরাইট লঙ্ঘন' : 'Copyright violation' },
        { id: 'privacy', label: language === 'bn' ? 'গোপনীয়তা লঙ্ঘন' : 'Privacy violation' },
        { id: 'something_else', label: language === 'bn' ? 'অন্য কিছু' : 'Something else' },
      ]
    },
  };

  const handleReportSubmit = () => {
    setReportDialogOpen(false);
    // Reset state
    setReportStep(1);
    setReportReason('');
    setReportSubReason('');
    setReportingPostId(null);
    
    showNotification && showNotification({
      type: 'success',
      message: language === 'bn' ? 'আপনার রিপোর্ট  েওযা হয়েছে। ধন্যবাদ!' : 'Your report has been submitted. Thank you!',
      duration: 3000
    });
  };

  const handleReportCancel = () => {
    setReportDialogOpen(false);
    setReportStep(1);
    setReportReason('');
    setReportSubReason('');
    setReportingPostId(null);
  };

  // Comment handlers
  const handleOpenComments = (postId: string) => {
    // Find the post
    const post = posts.find(p => p.id === postId);
    if (!post) return;

    // Always use PostWithComments for all post types
    openPostDetail(post);
  };

  // Detect scroll direction (X.com style)
  useEffect(() => {
    const scrollContainer = scrollContainerRef.current;
    if (!scrollContainer) return;

    const handleScroll = () => {
      const currentScrollY = scrollContainer.scrollTop;
      const scrollDelta = currentScrollY - lastScrollY;
      
      if (currentScrollY < 10) {
        // Always show header and bottom nav at top
        setShowHeader(true);
        setHideBottomNav(false);
      } else if (scrollDelta > 15 && currentScrollY > 20) {
        // Scrolling down & past threshold (15-20px sensitivity) - hide header and bottom nav
        setShowHeader(false);
        setHideBottomNav(true);
      } else if (scrollDelta < -5) {
        // Scrolling up (even slightly) - show header and bottom nav
        setShowHeader(true);
        setHideBottomNav(false);
      }
      
      setLastScrollY(currentScrollY);
    };

    scrollContainer.addEventListener('scroll', handleScroll, { passive: true });
    return () => scrollContainer.removeEventListener('scroll', handleScroll);
  }, [lastScrollY, setHideBottomNav]);

  // Auto-play videos when they enter viewport
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(async (entry) => {
          const videoElement = entry.target as HTMLVideoElement;
          const videoId = videoElement.dataset.postId;
          
          if (!videoId) return;

          if (entry.isIntersecting && entry.intersectionRatio >= 0.5) {
            // Video is at least 50% visible - play it (only if not manually paused)
            if (!manuallyPausedVideos.has(videoId)) {
              setPlayingVideo(videoId);
              
              try {
                // Wait for any existing play promise to complete first
                const existingPromise = playPromises.current.get(videoId);
                if (existingPromise) {
                  await existingPromise.catch(() => {}); // Ignore errors from previous attempts
                }
                
                // Now start playing
                const playPromise = videoElement.play();
                if (playPromise !== undefined) {
                  playPromises.current.set(videoId, playPromise);
                  await playPromise;
                  playPromises.current.set(videoId, null);
                }
              } catch (error: any) {
                // Silently handle autoplay errors
                if (error.name !== 'AbortError') {
                  console.debug('Video autoplay prevented:', error.name);
                }
              }
            }
          } else {
            // Video is not visible enough - pause it and clear manual pause state
            if (playingVideo === videoId) {
              setPlayingVideo(null);
              
              // Remove from manually paused when video leaves viewport
              if (manuallyPausedVideos.has(videoId)) {
                const newSet = new Set(manuallyPausedVideos);
                newSet.delete(videoId);
                setManuallyPausedVideos(newSet);
              }
              
              try {
                // Wait for any play promise to complete before pausing
                const existingPromise = playPromises.current.get(videoId);
                if (existingPromise) {
                  await existingPromise.catch(() => {}); // Ignore errors
                }
                
                // Now pause safely
                if (!videoElement.paused) {
                  videoElement.pause();
                }
                playPromises.current.set(videoId, null);
              } catch (error) {
                // Silently handle pause errors
              }
            }
          }
        });
      },
      {
        threshold: [0, 0.5, 1], // Trigger at 0%, 50%, and 100% visibility
        rootMargin: '0px',
      }
    );

    // Observe all video elements
    videoRefs.current.forEach((video) => {
      if (video) {
        observer.observe(video);
      }
    });

    return () => {
      // Cleanup observer
      videoRefs.current.forEach((video) => {
        if (video) {
          observer.unobserve(video);
        }
      });
    };
  }, [posts, playingVideo, manuallyPausedVideos]); // Re-run when posts, playingVideo, or manuallyPausedVideos changes

  const handleLike = (postId: string) => {
    setPosts(posts.map(post => 
      post.id === postId 
        ? { ...post, isLiked: !post.isLiked, likes: post.isLiked ? post.likes - 1 : post.likes + 1 }
        : post
    ));
  };

  const toggleVideoPlay = (postId: string) => {
    const video = videoRefs.current.get(postId);
    if (!video) return;

    if (playingVideo === postId) {
      // Pause the video
      setPlayingVideo(null);
      if (!video.paused) {
        video.pause();
      }
      // Mark as manually paused
      const newSet = new Set(manuallyPausedVideos);
      newSet.add(postId);
      setManuallyPausedVideos(newSet);
    } else {
      // Play the video
      setPlayingVideo(postId);
      const playPromise = video.play();
      if (playPromise !== undefined) {
        playPromises.current.set(postId, playPromise);
        playPromise.catch((error) => {
          if (error.name !== 'AbortError') {
            console.debug('Video play prevented:', error.name);
          }
        });
      }
      // Remove from manually paused
      const newSet = new Set(manuallyPausedVideos);
      newSet.delete(postId);
      setManuallyPausedVideos(newSet);
    }
  };

  const toggleVideoMute = (postId: string) => {
    const newUnmuted = new Set(unmutedVideos);
    if (newUnmuted.has(postId)) {
      newUnmuted.delete(postId);
    } else {
      newUnmuted.add(postId);
    }
    setUnmutedVideos(newUnmuted);
  };

  // Filter/sort posts based on active tab
  const getFilteredPosts = () => {
    switch (activeTab) {
      case 'following':
        // Simulate "following" - show posts from specific authors
        const followingAuthors = Array.from(followingUsers);
        return posts.filter(post => followingAuthors.includes(post.author));
      
      case 'trending':
        // Sort by engagement (likes + comments)
        return [...posts].sort((a, b) => {
          const engagementA = a.likes + a.comments;
          const engagementB = b.likes + b.comments;
          return engagementB - engagementA;
        });
      
      case 'forYou':
      default:
        // Default feed - all posts in original order
        return posts;
    }
  };

  const filteredPosts = getFilteredPosts();

  // Video time update handler
  const handleVideoTimeUpdate = (postId: string, video: HTMLVideoElement) => {
    const progress = (video.currentTime / video.duration) * 100;
    setVideoProgress(new Map(videoProgress.set(postId, progress)));
    setVideoCurrentTimes(new Map(videoCurrentTimes.set(postId, video.currentTime)));
  };

  // Video metadata loaded handler
  const handleVideoLoadedMetadata = (postId: string, video: HTMLVideoElement) => {
    setVideoDurations(new Map(videoDurations.set(postId, video.duration)));
  };

  // Video seek handler
  const handleVideoSeek = (postId: string, percentage: number) => {
    const video = videoRefs.current.get(postId);
    if (!video || !video.duration) return;
    
    const newTime = (percentage / 100) * video.duration;
    video.currentTime = newTime;
    setVideoProgress(new Map(videoProgress.set(postId, percentage)));
    setVideoCurrentTimes(new Map(videoCurrentTimes.set(postId, newTime)));
  };

  // Format time display (MM:SS)
  const formatTime = (seconds: number): string => {
    if (isNaN(seconds)) return '0:00';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  // Format timestamp based on language
  const formatTimestamp = (hoursAgo: number): string => {
    if (language === 'bn') {
      return `${hoursAgo}ঘ`; // "9ঘ" format
    } else {
      return `${hoursAgo}h`; // "9h" format
    }
  };

  // Post menu handlers
  const handleSavePost = (postId: string) => {
    const newSaved = new Set(savedPosts);
    if (newSaved.has(postId)) {
      newSaved.delete(postId);
      showNotification && showNotification({
        type: 'info',
        message: language === 'bn' ? 'পোস্ট আনসেভ করা হয়েছে' : 'Post unsaved',
        duration: 2000
      });
    } else {
      newSaved.add(postId);
      showNotification && showNotification({
        type: 'success',
        message: language === 'bn' ? 'পোস্ট সেভ করা হয়েছে' : 'Post saved',
        duration: 2000
      });
    }
    setSavedPosts(newSaved);
  };

  const handleHidePost = (postId: string) => {
    const newHidden = new Set(hiddenPosts);
    newHidden.add(postId);
    setHiddenPosts(newHidden);
    showNotification && showNotification({
      type: 'info',
      message: language === 'bn' ? 'পোস্ট লুকানো হয়েছে' : 'Post hidden',
      duration: 2000
    });
  };

  const handleFollowUser = (author: string) => {
    const newFollowing = new Set(followingUsers);
    if (newFollowing.has(author)) {
      newFollowing.delete(author);
      showNotification && showNotification({
        type: 'info',
        message: language === 'bn' ? `${author} কে আনফলো করা হয়েছে` : `Unfollowed ${author}`,
        duration: 2000
      });
    } else {
      newFollowing.add(author);
      showNotification && showNotification({
        type: 'success',
        message: language === 'bn' ? `${author} কে ফলো করা হয়েছে` : `Following ${author}`,
        duration: 2000
      });
    }
    setFollowingUsers(newFollowing);
  };

  const handleReportPost = (postId: string) => {
    setReportingPostId(postId);
    setReportDialogOpen(true);
  };

  const handleCopyLink = (postId: string) => {
    const link = `https://torko.app/post/${postId}`;
    
    // Try modern Clipboard API first
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(link)
        .then(() => {
          showNotification && showNotification({
            type: 'success',
            message: language === 'bn' ? 'লিংক কপি করা হয়েছে' : 'Link copied',
            duration: 2000
          });
        })
        .catch(() => {
          // Fallback to older method if Clipboard API fails
          fallbackCopyTextToClipboard(link);
        });
    } else {
      // Fallback for browsers that don't support Clipboard API
      fallbackCopyTextToClipboard(link);
    }
  };

  // Fallback method for copying text
  const fallbackCopyTextToClipboard = (text: string) => {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    textArea.style.position = 'fixed';
    textArea.style.top = '0';
    textArea.style.left = '0';
    textArea.style.width = '2em';
    textArea.style.height = '2em';
    textArea.style.padding = '0';
    textArea.style.border = 'none';
    textArea.style.outline = 'none';
    textArea.style.boxShadow = 'none';
    textArea.style.background = 'transparent';
    textArea.style.opacity = '0';
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    
    try {
      const successful = document.execCommand('copy');
      if (successful) {
        showNotification && showNotification({
          type: 'success',
          message: language === 'bn' ? 'লিংক কপি করা হয়েছে' : 'Link copied',
          duration: 2000
        });
      } else {
        showNotification && showNotification({
          type: 'error',
          message: language === 'bn' ? 'লিংক কপি করতে ব্যর্থ' : 'Failed to copy link',
          duration: 2000
        });
      }
    } catch (err) {
      showNotification && showNotification({
        type: 'error',
        message: language === 'bn' ? 'লিংক কপি করতে ব্যর্থ' : 'Failed to copy link',
        duration: 2000
      });
    }
    
    document.body.removeChild(textArea);
  };

  const sidebarItems = [
    {
      category: language === 'bn' ? 'স্টেজ' : 'Stage',
      items: [
        { icon: Flame, label: language === 'bn' ? 'ট্রেন্ডিং' : 'Trending', active: true },
        { icon: Radio, label: language === 'bn' ? 'আবিষ্কার করুন' : 'Discover', active: false },
      ]
    },
    {
      category: language === 'bn' ? 'স্ানীয় কমিউনিটি' : 'Local Communities',
      items: [
        { icon: Users, label: language === 'bn' ? 'ঢাকা টেক' : 'Dhaka Tech', active: false },
        { icon: Hash, label: language === 'bn' ? 'বাংলা সাহিত্য' : 'Bengali Literature', active: false },
        { icon: TrendingUp, label: language === 'bn' ? 'স্টার্টআপ BD' : 'Startup BD', active: false },
      ]
    },
  ];

  return (
    <div className="fixed inset-0 bg-background flex">
      {/* Sidebar */}
      <aside 
        className="hidden lg:flex flex-col border-r border-border/40 bg-muted/20"
        style={{ width: '260px' }}
      >
        <div className="p-6">
          <h2 
            className="mb-6 text-foreground"
            style={{
              fontSize: '20px',
              fontWeight: '700',
              lineHeight: '1.3'
            }}
          >
            {language === 'bn' ? 'নেভিগেশন' : 'Navigation'}
          </h2>

          <div className="space-y-6">
            {sidebarItems.map((section, sectionIndex) => (
              <div key={sectionIndex}>
                {/* Section Title */}
                <h3 
                  className="mb-3 text-muted-foreground"
                  style={{
                    fontSize: '14px',
                    fontWeight: '600',
                    lineHeight: '1.4',
                    opacity: '0.7'
                  }}
                >
                  {section.category}
                </h3>

                {/* Section Items */}
                <div className="space-y-1">
                  {section.items.map((item, itemIndex) => (
                    <button
                      key={itemIndex}
                      className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all ${
                        item.active
                          ? 'bg-accent/10 text-accent'
                          : 'text-foreground hover:bg-muted/50'
                      }`}
                    >
                      <item.icon 
                        className={item.active ? 'text-accent' : 'text-muted-foreground'}
                        style={{ width: '20px', height: '20px' }}
                      />
                      <span
                        style={{
                          fontSize: '15px',
                          fontWeight: item.active ? '500' : '400',
                          lineHeight: '1.4'
                        }}
                      >
                        {item.label}
                      </span>
                    </button>
                  ))}
                </div>

                {/* Divider between sections */}
                {sectionIndex < sidebarItems.length - 1 && (
                  <Separator className="mt-4" style={{ opacity: '0.4' }} />
                )}
              </div>
            ))}
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Status Bar Strip (X.com style) - Always visible */}
        <motion.div 
          className="bg-background border-b border-border/40 absolute top-0 left-0 right-0 z-20"
          initial={{ height: '32px', opacity: 0 }}
          animate={{ 
            height: showHeader ? '0px' : '12px',
            opacity: showHeader ? 0 : 0.7
          }}
          transition={{ 
            duration: 0.25, 
            ease: showHeader ? 'easeIn' : 'easeOut'
          }}
          style={{
            boxShadow: showHeader ? 'none' : '0 1px 3px rgba(0, 0, 0, 0.06)',
          }}
        />

        {/* Header */}
        <motion.div 
          className="absolute top-0 left-0 right-0 z-10"
          initial={{ y: 0, opacity: 1 }}
          animate={{ 
            y: showHeader ? 0 : -60,
            opacity: showHeader ? 1 : 0.7
          }}
          transition={{ 
            duration: 0.25, 
            ease: showHeader ? 'easeIn' : 'easeOut'
          }}
        >
          <HomeHeader onNavigate={onNavigate} />
        </motion.div>

        {/* Feed */}
        <motion.div 
          className="flex-1 overflow-y-auto pb-20" 
          ref={scrollContainerRef}
          initial={{ paddingTop: '60px' }}
          animate={{ paddingTop: showHeader ? '60px' : '12px' }}
          transition={{ 
            duration: 0.25, 
            ease: showHeader ? 'easeIn' : 'easeOut'
          }}
        >
          <div className="w-full max-w-[600px] bg-white dark:bg-[#052029] px-[0px] pt-[30px] pr-[0px] pb-[0px] pl-[0px] m-[0px] space-y-[0px]">
            {filteredPosts.map((post, index) => (
              <div key={post.id} className="relative">
                <div>
                  <PostCard
                    author={post.author}
                    username={`@${post.author.replace(/\s+/g, '').toLowerCase()}`}
                    groupName={post.groupName}
                    location={!post.groupName ? post.location : undefined}
                    verified={true}
                    timestamp={formatTimestamp(post.hoursAgo)}
                    content={post.content}
                    avatar={post.authorAvatar}
                    image={post.image}
                    video={post.video}
                    images={post.images}
                    videos={post.videos}
                    type={post.type}
                    gradient={post.gradient}
                    poll={post.poll}
                    likes={post.likes}
                    comments={post.comments}
                    isLiked={post.isLiked}
                    onLike={() => handleLike(post.id)}
                    onComment={() => handleOpenComments(post.id)}
                    onShare={() => console.log('Share post:', post.id)}
                    onMenuClick={() => setOpenMenuPostId(post.id)}
                    language={language}
                  />
                </div>
                
                {/* Dropdown Menu for Post Options - Outside motion.div */}
                <DropdownMenu open={openMenuPostId === post.id} onOpenChange={(open) => !open && setOpenMenuPostId(null)}>
                  <DropdownMenuTrigger asChild>
                    <button className="hidden" />
                  </DropdownMenuTrigger>
                  
                  <DropdownMenuContent align="end" className="w-56">
                    <DropdownMenuItem
                      className="flex items-center gap-2 cursor-pointer"
                      onClick={() => handleSavePost(post.id)}
                    >
                      {savedPosts.has(post.id) ? (
                        <Bookmark className="w-4 h-4 fill-accent text-accent" />
                      ) : (
                        <Bookmark className="w-4 h-4" />
                      )}
                      <span style={{ fontSize: '14px', fontWeight: '500' }}>
                        {savedPosts.has(post.id)
                          ? language === 'bn' ? 'আনসেভ করুন' : 'Unsave'
                          : language === 'bn' ? 'সেভ করুন' : 'Save'}
                      </span>
                    </DropdownMenuItem>
                    
                    <DropdownMenuItem
                      className="flex items-center gap-2 cursor-pointer"
                      onClick={() => handleFollowUser(post.author)}
                    >
                      {followingUsers.has(post.author) ? (
                        <UserMinus className="w-4 h-4 text-accent" />
                      ) : (
                        <UserPlus className="w-4 h-4" />
                      )}
                      <span style={{ fontSize: '14px', fontWeight: '500' }}>
                        {followingUsers.has(post.author)
                          ? language === 'bn' ? 'আনফলো করুন' : 'Unfollow'
                          : language === 'bn' ? 'ফলো করুন' : 'Follow'}
                      </span>
                    </DropdownMenuItem>
                    
                    <DropdownMenuSeparator />
                    
                    <DropdownMenuItem
                      className="flex items-center gap-2 cursor-pointer"
                      onClick={() => handleCopyLink(post.id)}
                    >
                      <Link2 className="w-4 h-4" />
                      <span style={{ fontSize: '14px', fontWeight: '500' }}>
                        {language === 'bn' ? 'লিংক কপি করুন' : 'Copy link'}
                      </span>
                    </DropdownMenuItem>
                    
                    <DropdownMenuItem
                      className="flex items-center gap-2 cursor-pointer"
                      onClick={() => handleHidePost(post.id)}
                    >
                      <EyeOff className="w-4 h-4" />
                      <span style={{ fontSize: '14px', fontWeight: '500' }}>
                        {language === 'bn' ? 'পোস্ট লুকান' : 'Hide post'}
                      </span>
                    </DropdownMenuItem>
                    
                    <DropdownMenuSeparator />
                    
                    <DropdownMenuItem
                      className="flex items-center gap-2 cursor-pointer text-destructive focus:text-destructive"
                      onClick={() => handleReportPost(post.id)}
                    >
                      <Flag className="w-4 h-4" />
                      <span style={{ fontSize: '14px', fontWeight: '500' }}>
                        {language === 'bn' ? 'রিপোর্ট করুন' : 'Report'}
                      </span>
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>


              </div>
            ))}
          </div>
        </motion.div>
      </div>

      {/* Report Dialog */}
      <Dialog open={reportDialogOpen} onOpenChange={handleReportCancel}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle style={{ fontSize: '20px', fontWeight: '700' }}>
              {language === 'bn' ? 'পোস্ট রিপোর্ট করুন' : 'Report Post'}
            </DialogTitle>
            <DialogDescription style={{ fontSize: '14px' }}>
              {reportStep === 1 && (language === 'bn' 
                ? 'এই পোস্ট কেন রিপোর্ট করছেন তা নির্বাচন করুন' 
                : 'Select why you are reporting this post')}
              {reportStep === 2 && (language === 'bn' 
                ? 'আরও বিস্তারিত তথ্য দিন' 
                : 'Provide more details')}
              {reportStep === 3 && (language === 'bn' 
                ? 'আপনার রিপোর্ট নিশ্চিত করুন' 
                : 'Confirm your report')}
            </DialogDescription>
          </DialogHeader>

          <div className="py-4">
            {/* Step 1: Select main reason */}
            {reportStep === 1 && (
              <div className="space-y-2">
                {Object.entries(reportReasons).map(([key, reason]) => (
                  <Button
                    key={key}
                    variant={reportReason === key ? 'default' : 'outline'}
                    className="w-full justify-start h-auto py-3"
                    style={{ fontSize: '15px', fontWeight: '500' }}
                    onClick={() => {
                      setReportReason(key);
                      setReportStep(2);
                    }}
                  >
                    <Flag className="w-4 h-4 mr-2" />
                    {reason.label}
                  </Button>
                ))}
              </div>
            )}

            {/* Step 2: Select sub-reason */}
            {reportStep === 2 && reportReason && (
              <div className="space-y-2">
                {reportReasons[reportReason as keyof typeof reportReasons].subReasons.map((subReason) => (
                  <Button
                    key={subReason.id}
                    variant={reportSubReason === subReason.id ? 'default' : 'outline'}
                    className="w-full justify-start h-auto py-3"
                    style={{ fontSize: '15px', fontWeight: '500' }}
                    onClick={() => {
                      setReportSubReason(subReason.id);
                      setReportStep(3);
                    }}
                  >
                    {subReason.label}
                  </Button>
                ))}
              </div>
            )}

            {/* Step 3: Confirmation */}
            {reportStep === 3 && (
              <div className="space-y-4">
                <div className="p-4 bg-muted/40 rounded-lg">
                  <p style={{ fontSize: '15px', fontWeight: '600', marginBottom: '8px' }}>
                    {language === 'bn' ? 'রিপোর্টের সারাংশ:' : 'Report Summary:'}
                  </p>
                  <p className="text-muted-foreground" style={{ fontSize: '14px' }}>
                    <span className="font-medium">{language === 'bn' ? 'কারণ:' : 'Reason:'}</span>{' '}
                    {reportReasons[reportReason as keyof typeof reportReasons].label}
                  </p>
                  <p className="text-muted-foreground" style={{ fontSize: '14px', marginTop: '4px' }}>
                    <span className="font-medium">{language === 'bn' ? 'বিস্তারিত:' : 'Details:'}</span>{' '}
                    {reportReasons[reportReason as keyof typeof reportReasons].subReasons.find(
                      (sr) => sr.id === reportSubReason
                    )?.label}
                  </p>
                </div>
                <p className="text-muted-foreground text-center" style={{ fontSize: '13px' }}>
                  {language === 'bn'
                    ? 'আমরা আপনার রিপোর্ট পর্যালোচনা করব এবং যথাযথ ব্যবস্থা নেব। আপনার গোপনীয়তা রক্ষা করা হবে।'
                    : 'We will review your report and take appropriate action. Your privacy will be protected.'}
                </p>
              </div>
            )}
          </div>

          <DialogFooter>
            {reportStep > 1 && (
              <Button
                variant="outline"
                onClick={() => {
                  if (reportStep === 2) {
                    setReportStep(1);
                    setReportReason('');
                  } else if (reportStep === 3) {
                    setReportStep(2);
                    setReportSubReason('');
                  }
                }}
                style={{ fontSize: '14px', fontWeight: '500' }}
              >
                {language === 'bn' ? 'পেছনে' : 'Back'}
              </Button>
            )}
            <Button
              variant="ghost"
              onClick={handleReportCancel}
              style={{ fontSize: '14px', fontWeight: '500' }}
            >
              {language === 'bn' ? 'বাতিল' : 'Cancel'}
            </Button>
            {reportStep === 3 && (
              <Button
                onClick={handleReportSubmit}
                className="bg-destructive hover:bg-destructive/90 text-white"
                style={{ fontSize: '14px', fontWeight: '500' }}
              >
                {language === 'bn' ? 'রিপোর্ট জমা দিন' : 'Submit Report'}
              </Button>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* REMOVED: Old CommentDialog - Now using PostWithComments only for all post types */}
    </div>
  );
};