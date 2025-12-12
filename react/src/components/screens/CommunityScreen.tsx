import React, { useState, useRef, useEffect } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Card } from '../ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';
import { Badge } from '../ui/badge';
import { Input } from '../ui/input';
import { 
  MapPin, 
  Clock, 
  Heart, 
  MessageCircle, 
  Share2, 
  ChevronLeft, 
  List, 
  Search,
  AlertCircle,
  Zap,
  TrendingUp,
  Filter,
  UserPlus,
  Check,
  ShoppingBag,
  Briefcase,
  Home,
  Wrench,
  Users,
  HelpCircle,
  Package,
  Bike,
  Activity
} from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '../ui/dropdown-menu';

interface CommunityScreenProps {
  onNavigate: (screen: string) => void;
}

interface Post {
  id: string;
  userName: string;
  userInitial: string;
  avatarColor: string;
  location: string;
  locationDetail: string;
  time: string;
  timeAgo: number; // in minutes
  content: string;
  likes: number;
  comments: number;
  shares: number;
  category: string;
  badge?: 'urgent' | 'warning' | 'trending' | 'verified';
  isLiked: boolean;
  distance?: string; // e.g., "2.5 km"
  images?: string[];
}

interface Category {
  id: string;
  label_bn: string;
  label_en: string;
  icon: any;
  color: string;
}

const categories: Category[] = [
  { id: 'all', label_bn: 'সব', label_en: 'All', icon: List, color: '#d97757' },
  { id: 'emergency', label_bn: 'জরুরি', label_en: 'Emergency', icon: AlertCircle, color: '#dc2626' },
  { id: 'services', label_bn: 'সেবা', label_en: 'Services', icon: Wrench, color: '#2563eb' },
  { id: 'marketplace', label_bn: 'বাজার', label_en: 'Marketplace', icon: ShoppingBag, color: '#16a34a' },
  { id: 'events', label_bn: 'ইভেন্ট', label_en: 'Events', icon: Users, color: '#9333ea' },
  { id: 'jobs', label_bn: 'চাকরি', label_en: 'Jobs', icon: Briefcase, color: '#ea580c' },
  { id: 'housing', label_bn: 'বাসস্থান', label_en: 'Housing', icon: Home, color: '#0891b2' },
  { id: 'help', label_bn: 'সাহায্য', label_en: 'Help', icon: HelpCircle, color: '#db2777' },
];

// Generate comprehensive mock posts
const generatePosts = (): Post[] => {
  const names = [
    'রহিম আহমেদ', 'তানিয়া রহমান', 'সাবিনা খাতুন', 'মাহমুদ হাসান', 'নাহিদা আক্তার',
    'ফারুক ইসলাম', 'রুমানা সুলতানা', 'কামাল হোসেন', 'সানজিদা খান', 'রাকিব মাহমুদ',
    'নাজমুল হক', 'রুপা বেগম', 'তাসনিম চৌধুরী', 'সাদিয়া ইসলাম', 'জাহিদ করিম'
  ];

  const locations = [
    'গুলশান, ঢাকা', 'বনানী, ঢাকা', 'ধানমন্ডি, ঢাকা', 'মিরপুর, ঢাকা', 'রামপুরা, ঢাকা',
    'উত্তরা, ঢাকা', 'মহাখালী, ঢাকা', 'বারিধারা, ঢাকা', 'বসুন্ধরা, ঢাকা', 'মতিঝিল, ঢাকা',
    'মগবাজার, ঢাকা', 'শাহবাগ, ঢাকা', 'লালমাটিয়া, ঢাকা', 'কাকরাইল, ঢাকা', 'নিকেতন, ঢাকা'
  ];

  const postContents = {
    emergency: [
      'জরুরি ভিত্তিতে অ্যাম্বুলেন্স প্রয়োজন। কেউ সাহায্য করতে পারবেন?',
      'এলাকায় বিদ্যুৎ চলে গেছে। কেউ জানেন কতক্ষণ লাগবে?',
      'হারিয়ে যাওয়া শিশু পাওয়া গেছে। মা-বাবা যোগাযোগ করুন।',
      'রাস্তায় দুর্ঘটনা ঘটেছে। পুলিশ এবং অ্যাম্বুলেন্স আসছে।',
      'আগুন লেগেছে! ফায়ার সার্ভিস ডাকা হয়েছে।'
    ],
    services: [
      'বাসার জন্য ভালো প্লাম্বার খুঁজছি। কেউ রেকমেন্ড করতে পারবেন?',
      'এসি রিপেয়ার করার জন্য কাউকে দরকার। কন্টাক্ট নাম্বার দিন প্লিজ।',
      'গাড়ি মেকানিক লাগবে। কেউ ভালো জানেন?',
      'বাসার কাজের জন্য পার্ট-টাইম হেল্পার দরকার।',
      'ইলেকট্রিশিয়ান প্রয়োজন আজ সন্ধ্যায়।'
    ],
    marketplace: [
      'নতুন ফ্রিজ বিক্রি করছি। দাম নেগোশিয়েবল।',
      'বাচ্চাদের খেলনা বিক্রি হবে। খুবই ভালো কন্ডিশনে।',
      'পুরাতন বই বিক্রয়। স্কুল এবং কলেজের বই।',
      'ফার্নিচার বিক্রয় - সোফা সেট এবং ডাইনিং টেবিল।',
      'ল্যাপটপ বিক্রি হবে। ২ বছর ব্যবহৃত, ভালো কন্ডিশন।'
    ],
    events: [
      'আগামী শুক্রবার ক্রিকেট টুর্নামেন্ট। সবাই আসুন!',
      'কমিউনিটি ক্লিনআপ ড্রাইভ এই শনিবার। যোগ দিন আমাদের সাথে।',
      'মাসিক বই পড়ার অধিবেশন আগামীকাল বিকেল ৫টায়।',
      'যোগব্যায়াম ক্লাস শুরু হচ্ছে প্রতি সকাল ৭টায়।',
      'কমিউনিটি ইফতার পার্টি আয়োজন - সবাইকে আমন্ত্রণ!'
    ],
    jobs: [
      'গ্রাফিক ডিজাইনার প্রয়োজন। ফ্রিল্যান্স বেসিস।',
      'রেস্তোরাঁর জন্য ওয়েটার নিয়োগ চলছে।',
      'অনলাইন টিউটর খুঁজছি গণিতের জন্য।',
      'কন্টেন্ট রাইটার দরকার। পার্ট টাইম।',
      'ডেলিভারি ড্রাইভার নিয়োগ - ভালো বেতন।'
    ],
    housing: [
      'ব্যাচেলর মেসের জন্য রুমমেট খুঁজছি।',
      'ফ্ল্যাট ভাড়া দেওয়া হবে - ২ বেডরুম।',
      'সাবলেট - ১ মাসের জন্য। ফার্নিশড।',
      'রুম শেয়ার করতে চাই। বাজেট ফ্রেন্ডলি।',
      'ছোট অফিস স্পেস ভাড়া নেওয়া যাবে।'
    ],
    help: [
      'কেউ কি বিদ্যুতের বিল পেমেন্ট করতে সাহায্য করতে পারবেন?',
      'নতুন এলাকায় এসেছি। ভালো ডাক্তার রেকমেন্ড করুন।',
      'গাড়ির চার্জার কোথায় পাওয়া যাবে? জরুরি দরকার।',
      'স্কুল ভর্তির জন্য কোন ডকুমেন্ট লাগে?',
      'ভালো রেস্তোরাঁর সাজেশন চাই এলাকায়।'
    ],
  };

  const posts: Post[] = [];
  const avatarColors = ['#d97757', '#6B9BD1', '#8B9FA8', '#9333ea', '#16a34a', '#ea580c', '#0891b2', '#db2777'];

  let id = 1;
  Object.entries(postContents).forEach(([category, contents]) => {
    contents.forEach((content, index) => {
      const timeAgo = Math.floor(Math.random() * 180) + 5; // 5-185 minutes ago
      const name = names[Math.floor(Math.random() * names.length)];
      const location = locations[Math.floor(Math.random() * locations.length)];
      
      let badge: 'urgent' | 'warning' | 'trending' | 'verified' | undefined;
      if (category === 'emergency') badge = 'urgent';
      else if (Math.random() > 0.7) badge = 'trending';
      
      posts.push({
        id: `${id++}`,
        userName: name,
        userInitial: name[0],
        avatarColor: avatarColors[Math.floor(Math.random() * avatarColors.length)],
        location: location.split(',')[0],
        locationDetail: location,
        time: timeAgo < 60 ? `${timeAgo} মিনিট আগে` : `${Math.floor(timeAgo / 60)} ঘণ্টা আগে`,
        timeAgo,
        content,
        likes: Math.floor(Math.random() * 50) + 1,
        comments: Math.floor(Math.random() * 30) + 1,
        shares: Math.floor(Math.random() * 15) + 1,
        category,
        badge,
        isLiked: Math.random() > 0.7,
        distance: `${(Math.random() * 5 + 0.5).toFixed(1)} km`,
      });
    });
  });

  // Sort by time (most recent first)
  return posts.sort((a, b) => a.timeAgo - b.timeAgo);
};

export const CommunityScreen: React.FC<CommunityScreenProps> = ({ onNavigate }) => {
  const { language, showNotification } = useApp();
  const [searchQuery, setSearchQuery] = useState('');
  const [showHeader, setShowHeader] = useState(true);
  const [lastScrollY, setLastScrollY] = useState(0);
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const [activeFilter, setActiveFilter] = useState<'all' | 'nearby' | 'myarea'>('all');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [posts, setPosts] = useState(generatePosts());
  const [sortBy, setSortBy] = useState<'recent' | 'popular' | 'nearest'>('recent');

  // Detect scroll direction
  useEffect(() => {
    const scrollContainer = scrollContainerRef.current;
    if (!scrollContainer) return;

    const handleScroll = () => {
      const currentScrollY = scrollContainer.scrollTop;
      
      if (currentScrollY < 10) {
        setShowHeader(true);
      } else if (currentScrollY > lastScrollY && currentScrollY > 80) {
        setShowHeader(false);
      } else if (currentScrollY < lastScrollY) {
        setShowHeader(true);
      }
      
      setLastScrollY(currentScrollY);
    };

    scrollContainer.addEventListener('scroll', handleScroll, { passive: true });
    return () => scrollContainer.removeEventListener('scroll', handleScroll);
  }, [lastScrollY]);

  const handleLike = (postId: string) => {
    setPosts(posts.map(post => {
      if (post.id === postId) {
        return {
          ...post,
          isLiked: !post.isLiked,
          likes: post.isLiked ? post.likes - 1 : post.likes + 1
        };
      }
      return post;
    }));
  };

  const handleShare = (postId: string, content: string) => {
    if (navigator.share) {
      navigator.share({
        title: 'Torko Community Post',
        text: content,
        url: `https://torko.app/community/post/${postId}`
      }).catch(() => {
        // User cancelled or error
      });
    } else {
      showNotification && showNotification({
        type: 'info',
        message: language === 'bn' ? 'শেয়ার লিংক কপি করা হয়েছে' : 'Share link copied',
        duration: 2000
      });
    }
  };

  // Filter posts
  const filteredPosts = posts.filter(post => {
    // Search filter
    const matchesSearch = post.content.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         post.userName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         post.location.toLowerCase().includes(searchQuery.toLowerCase());
    
    // Category filter
    const matchesCategory = selectedCategory === 'all' || post.category === selectedCategory;
    
    return matchesSearch && matchesCategory;
  });

  // Sort posts
  const sortedPosts = [...filteredPosts].sort((a, b) => {
    switch (sortBy) {
      case 'popular':
        return (b.likes + b.comments) - (a.likes + a.comments);
      case 'nearest':
        return parseFloat(a.distance || '999') - parseFloat(b.distance || '999');
      case 'recent':
      default:
        return a.timeAgo - b.timeAgo;
    }
  });

  const getBadgeConfig = (badge?: 'urgent' | 'warning' | 'trending' | 'verified') => {
    switch (badge) {
      case 'urgent':
        return {
          label: language === 'bn' ? 'জরুরি' : 'Urgent',
          color: '#dc2626',
          icon: AlertCircle
        };
      case 'trending':
        return {
          label: language === 'bn' ? 'ট্রেন্ডিং' : 'Trending',
          color: '#d97757',
          icon: TrendingUp
        };
      case 'warning':
        return {
          label: language === 'bn' ? 'সতর্কতা' : 'Warning',
          color: '#f59e0b',
          icon: AlertCircle
        };
      case 'verified':
        return {
          label: language === 'bn' ? 'যাচাইকৃত' : 'Verified',
          color: '#16a34a',
          icon: Check
        };
      default:
        return null;
    }
  };

  return (
    <div className="fixed inset-0 bg-background flex flex-col overflow-hidden">
      {/* Header */}
      <motion.div 
        className="px-4 pt-4 pb-3 border-b border-border/40 bg-background absolute top-0 left-0 right-0 z-10"
        initial={{ y: 0 }}
        animate={{ y: showHeader ? 0 : -280 }}
        transition={{ duration: 0.25, ease: 'easeInOut' }}
        style={{ boxShadow: '0 1px 3px rgba(0, 0, 0, 0.05)' }}
      >
        <div className="max-w-md mx-auto w-full">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <Button
                variant="ghost"
                size="icon"
                className="rounded-full h-9 w-9"
                onClick={() => onNavigate('home')}
              >
                <ChevronLeft className="w-5 h-5" />
              </Button>
              <div>
                <div className="flex items-center gap-2">
                  <h1 
                    className="font-['Noto_Sans_Bengali:Bold',sans-serif] font-bold"
                    style={{ fontSize: '20px', lineHeight: '1.3' }}
                  >
                    {language === 'bn' ? 'স্থানীয় কমিউনিটি' : 'Local Community'}
                  </h1>
                  <Badge className="bg-accent/20 text-accent hover:bg-accent/30 rounded-full" style={{ fontSize: '10px', height: '18px', paddingLeft: '6px', paddingRight: '6px' }}>
                    {language === 'bn' ? 'বেটা' : 'Beta'}
                  </Badge>
                </div>
                <p className="text-muted-foreground" style={{ fontSize: '12px' }}>
                  {language === 'bn' ? 'আপনার এলাকার মানুষদের সাথে যুক্ত হন' : 'Connect with people in your area'}
                </p>
              </div>
            </div>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="sm" className="rounded-xl h-8" style={{ fontSize: '12px', fontWeight: '500' }}>
                  <Filter className="w-3.5 h-3.5 mr-1" />
                  {sortBy === 'recent' && (language === 'bn' ? 'সাম্প্রতিক' : 'Recent')}
                  {sortBy === 'popular' && (language === 'bn' ? 'জনপ্রিয়' : 'Popular')}
                  {sortBy === 'nearest' && (language === 'bn' ? 'নিকটতম' : 'Nearest')}
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem onClick={() => setSortBy('recent')}>
                  <Clock className="w-4 h-4 mr-2" />
                  {language === 'bn' ? 'সাম্প্রতিক' : 'Recent'}
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => setSortBy('popular')}>
                  <TrendingUp className="w-4 h-4 mr-2" />
                  {language === 'bn' ? 'জনপ্রিয়' : 'Popular'}
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => setSortBy('nearest')}>
                  <MapPin className="w-4 h-4 mr-2" />
                  {language === 'bn' ? 'নিকটতম' : 'Nearest'}
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
          
          {/* Search */}
          <div className="relative mb-3">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-muted-foreground" />
            <Input
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder={language === 'bn' ? 'খুঁজুন...' : 'Search...'}
              className="pl-10 rounded-xl bg-muted/40 border-border/40"
              style={{ height: '42px', fontSize: '14px' }}
            />
          </div>

          {/* Filter Pills */}
          <div className="flex gap-2 mb-3">
            <Button
              variant={activeFilter === 'all' ? 'default' : 'outline'}
              size="sm"
              className="rounded-full h-8"
              style={{ fontSize: '12px', fontWeight: '500' }}
              onClick={() => setActiveFilter('all')}
            >
              {language === 'bn' ? 'সব' : 'All'}
            </Button>
            <Button
              variant={activeFilter === 'myarea' ? 'default' : 'outline'}
              size="sm"
              className="rounded-full h-8"
              style={{ fontSize: '12px', fontWeight: '500' }}
              onClick={() => setActiveFilter('myarea')}
            >
              {language === 'bn' ? 'আমার এলাকা' : 'My Area'}
            </Button>
            <Button
              variant={activeFilter === 'nearby' ? 'default' : 'outline'}
              size="sm"
              className="rounded-full h-8"
              style={{ fontSize: '12px', fontWeight: '500' }}
              onClick={() => setActiveFilter('nearby')}
            >
              <MapPin className="w-3 h-3 mr-1" />
              {language === 'bn' ? 'কাছাকাছি' : 'Nearby'}
            </Button>
          </div>

          {/* Category Pills */}
          <div className="flex gap-2 overflow-x-auto pb-2 no-scrollbar">
            {categories.map((category) => (
              <Button
                key={category.id}
                variant={selectedCategory === category.id ? 'default' : 'outline'}
                size="sm"
                className="rounded-full whitespace-nowrap h-8"
                style={{ 
                  fontSize: '12px', 
                  fontWeight: '500',
                  ...(selectedCategory === category.id ? { backgroundColor: category.color } : {})
                }}
                onClick={() => setSelectedCategory(category.id)}
              >
                <category.icon className="w-3 h-3 mr-1.5" />
                {language === 'bn' ? category.label_bn : category.label_en}
              </Button>
            ))}
          </div>
        </div>
      </motion.div>

      {/* Posts Feed */}
      <motion.div 
        className="flex-1 overflow-y-auto pb-24"
        ref={scrollContainerRef}
        initial={{ paddingTop: '280px' }}
        animate={{ paddingTop: showHeader ? '280px' : '16px' }}
        transition={{ duration: 0.25, ease: 'easeInOut' }}
      >
        <div className="max-w-md mx-auto w-full px-4 space-y-3">
          {sortedPosts.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-muted-foreground" style={{ fontSize: '15px' }}>
                {language === 'bn' ? 'কোনো পোস্ট পাওয়া যায়নি' : 'No posts found'}
              </p>
            </div>
          ) : (
            sortedPosts.map((post, index) => {
              const badgeConfig = getBadgeConfig(post.badge);
              
              return (
                <div
                  key={post.id}
                >
                  <Card className="p-4 border-border/40" style={{ borderRadius: '16px' }}>
                    {/* Post Header */}
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex items-center gap-3 flex-1">
                        <Avatar className="w-11 h-11" style={{ backgroundColor: post.avatarColor }}>
                          <AvatarFallback style={{ backgroundColor: post.avatarColor, color: 'white', fontSize: '16px', fontWeight: '600' }}>
                            {post.userInitial}
                          </AvatarFallback>
                        </Avatar>
                        <div className="flex-1">
                          <p style={{ fontSize: '15px', fontWeight: '600', lineHeight: '1.4' }}>
                            {post.userName}
                          </p>
                          <div className="flex items-center gap-1.5 text-muted-foreground" style={{ fontSize: '12px' }}>
                            <MapPin className="w-3 h-3" />
                            <span>{post.locationDetail}</span>
                            <span>•</span>
                            <span>{post.time}</span>
                          </div>
                          {post.distance && (
                            <p className="text-muted-foreground mt-0.5" style={{ fontSize: '11px' }}>
                              {post.distance} {language === 'bn' ? 'দূরে' : 'away'}
                            </p>
                          )}
                        </div>
                      </div>
                      {badgeConfig && (
                        <Badge 
                          className="text-white rounded-full"
                          style={{ 
                            backgroundColor: badgeConfig.color,
                            fontSize: '11px',
                            height: '22px'
                          }}
                        >
                          <badgeConfig.icon className="w-3 h-3 mr-1" />
                          {badgeConfig.label}
                        </Badge>
                      )}
                    </div>

                    {/* Category Badge */}
                    <div className="mb-3">
                      {(() => {
                        const cat = categories.find(c => c.id === post.category);
                        if (cat && cat.id !== 'all') {
                          return (
                            <Badge 
                              variant="outline" 
                              className="rounded-full"
                              style={{ fontSize: '11px', height: '20px' }}
                            >
                              <cat.icon className="w-3 h-3 mr-1" />
                              {language === 'bn' ? cat.label_bn : cat.label_en}
                            </Badge>
                          );
                        }
                        return null;
                      })()}
                    </div>

                    {/* Post Content */}
                    <p className="mb-4" style={{ fontSize: '15px', lineHeight: '1.5' }}>
                      {post.content}
                    </p>

                    {/* Actions */}
                    <div className="flex items-center justify-between pt-3 border-t border-border/40">
                      <Button
                        variant="ghost"
                        size="sm"
                        className="flex-1 gap-2 rounded-xl hover:bg-muted/50 transition-colors"
                        style={{ height: '36px', fontSize: '14px', fontWeight: '500' }}
                        onClick={() => handleLike(post.id)}
                      >
                        <Heart 
                          className={`w-4.5 h-4.5 ${post.isLiked ? 'fill-red-500 text-red-500' : ''}`} 
                        />
                        <span className={post.isLiked ? 'text-red-500' : ''}>{post.likes}</span>
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="flex-1 gap-2 rounded-xl hover:bg-muted/50 transition-colors"
                        style={{ height: '36px', fontSize: '14px', fontWeight: '500' }}
                      >
                        <MessageCircle className="w-4.5 h-4.5" />
                        <span>{post.comments}</span>
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="flex-1 gap-2 rounded-xl hover:bg-muted/50 transition-colors"
                        style={{ height: '36px', fontSize: '14px', fontWeight: '500' }}
                        onClick={() => handleShare(post.id, post.content)}
                      >
                        <Share2 className="w-4.5 h-4.5" />
                        <span>{post.shares}</span>
                      </Button>
                    </div>
                  </Card>
                </div>
              );
            })
          )}
        </div>
      </motion.div>

      {/* Floating Create Button */}
      <motion.button
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        transition={{ 
          delay: 0.5, 
          type: 'spring', 
          stiffness: 260, 
          damping: 20 
        }}
        className="fixed bottom-24 right-6 bg-accent hover:bg-accent/90 text-white shadow-lg flex items-center justify-center z-10"
        style={{
          width: '56px',
          height: '56px',
          borderRadius: '50%'
        }}
        onClick={() => {
          showNotification && showNotification({
            type: 'info',
            message: language === 'bn' ? 'পোস্ট তৈরি ফিচার শীঘ্রই আসছে' : 'Create post feature coming soon',
            duration: 2000
          });
        }}
      >
        <Activity className="w-7 h-7" />
      </motion.button>
    </div>
  );
};