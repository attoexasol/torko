import React, { useState, useRef, useEffect } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Card } from '../ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';
import { Badge } from '../ui/badge';
import { Tabs, TabsList, TabsTrigger } from '../ui/tabs';
import { Search, TrendingUp, Hash, Users, Radio, MapPin, BookOpen, Briefcase, Heart, Utensils, Camera, Music, Gamepad2, Code, GraduationCap, CheckCircle2, ArrowUpRight } from 'lucide-react';

interface TrendingTopic {
  id: string;
  hashtag: string;
  posts: number;
  category: string;
  trend: 'up' | 'down' | 'stable';
  trendPercentage: number;
}

interface Creator {
  id: string;
  name: string;
  username: string;
  avatar: string;
  followers: string;
  isVerified: boolean;
  bio: string;
  category: string;
}

interface Stage {
  id: string;
  title: string;
  host: string;
  listeners: number;
  category: string;
  isLive: boolean;
}

interface Community {
  id: string;
  name: string;
  members: string;
  posts: number;
  category: string;
  icon: any;
  coverImage: string;
  isJoined: boolean;
}

interface PopularPost {
  id: string;
  author: string;
  authorAvatar: string;
  content: string;
  image?: string;
  likes: number;
  comments: number;
  category: string;
}

// Generate comprehensive mock data
const generateTrendingTopics = (): TrendingTopic[] => [
  { id: '1', hashtag: 'বাংলাদেশ', posts: 12500, category: 'রাজনীতি', trend: 'up', trendPercentage: 25 },
  { id: '2', hashtag: 'ক্রিকেট', posts: 8900, category: 'খেলাধুলা', trend: 'up', trendPercentage: 15 },
  { id: '3', hashtag: 'প্রযুক্তি', posts: 5600, category: 'প্রযুক্তি', trend: 'stable', trendPercentage: 0 },
  { id: '4', hashtag: 'শিক্ষা', posts: 4200, category: 'শিক্ষা', trend: 'up', trendPercentage: 12 },
  { id: '5', hashtag: 'স্টার্টআপ', posts: 3800, category: 'ব্যবসা', trend: 'up', trendPercentage: 30 },
  { id: '6', hashtag: 'ভ্রমণ', posts: 3200, category: 'ভ্রমণ', trend: 'down', trendPercentage: -5 },
  { id: '7', hashtag: 'খাবার', posts: 2900, category: 'খাবার', trend: 'stable', trendPercentage: 2 },
  { id: '8', hashtag: 'বই', posts: 2400, category: 'সাহিত্য', trend: 'up', trendPercentage: 18 },
  { id: '9', hashtag: 'সিনেমা', posts: 2100, category: 'বিনোদন', trend: 'up', trendPercentage: 22 },
  { id: '10', hashtag: 'সংগীত', posts: 1800, category: 'সংগীত', trend: 'stable', trendPercentage: 3 },
];

const generateCreators = (): Creator[] => [
  { id: '1', name: 'রহিম আহমেদ', username: '@rahim', avatar: '', followers: '১২.৫k', isVerified: true, bio: 'প্রযুক্তি উদ্যোক্তা', category: 'প্রযুক্তি' },
  { id: '2', name: 'সাবিনা খাতুন', username: '@sabina', avatar: '', followers: '৮.৯k', isVerified: false, bio: 'লেখক ও সাংবাদিক', category: 'সাহিত্য' },
  { id: '3', name: 'কামাল হোসেন', username: '@kamal', avatar: '', followers: '৫.৬k', isVerified: true, bio: 'ক্রিকেট বিশ্লেষক', category: 'খেলাধুলা' },
  { id: '4', name: 'তানিয়া রহমান', username: '@tania', avatar: '', followers: '৭.২k', isVerified: true, bio: 'ডিজিটাল মার্কেটার', category: 'ব্যবসা' },
  { id: '5', name: 'নাহিদা আক্তার', username: '@nahida', avatar: '', followers: '৪.৮k', isVerified: false, bio: 'ফুড ব্লগার', category: 'খাবার' },
  { id: '6', name: 'ফারুক ইসলাম', username: '@faruq', avatar: '', followers: '৬.৩k', isVerified: true, bio: 'ভ্রমণ গাইড', category: 'ভ্রমণ' },
  { id: '7', name: 'রুমানা সুলতানা', username: '@rumana', avatar: '', followers: '৯.১k', isVerified: true, bio: 'শিক্ষক ও মোটিভেশনাল স্পিকার', category: 'শিক্ষা' },
  { id: '8', name: 'মাহমুদ হাসান', username: '@mahmud', avatar: '', followers: '৫.৪k', isVerified: false, bio: 'সফটওয়্যার ডেভেলপার', category: 'প্রযুক্তি' },
];

const generateStages = (): Stage[] => [
  { id: '1', title: 'বাংলাদেশের প্রযুক্তি ভবিষ্যৎ', host: 'Tech Community BD', listeners: 234, category: 'প্রযুক্তি', isLive: true },
  { id: '2', title: 'ক্রিকেট আলোচনা: আজকের ম্যাচ', host: 'Sports Hub', listeners: 567, category: 'খেলাধুলা', isLive: true },
  { id: '3', title: 'স্টার্টআপ টিপস', host: 'Startup BD', listeners: 123, category: 'ব্যবসা', isLive: true },
  { id: '4', title: 'বাংলা সাহিত্য পাঠচক্র', host: 'Bangla Literature', listeners: 89, category: 'সাহিত্য', isLive: true },
];

const generateCommunities = (): Community[] => [
  { id: '1', name: 'ঢাকা টেক', members: '১২.৫k', posts: 3400, category: 'প্রযুক্তি', icon: Code, coverImage: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800', isJoined: false },
  { id: '2', name: 'বাংলা সাহিত্য', members: '৮.৯k', posts: 2200, category: 'সাহিত্য', icon: BookOpen, coverImage: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=800', isJoined: true },
  { id: '3', name: 'স্টার্টআপ BD', members: '৫.৬k', posts: 1800, category: 'ব্যবসা', icon: Briefcase, coverImage: 'https://images.unsplash.com/photo-1557426272-fc759fdf7a8d?w=800', isJoined: false },
  { id: '4', name: 'খাবার প্রেমী', members: '৭.২k', posts: 2900, category: 'খাবার', icon: Utensils, coverImage: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800', isJoined: true },
  { id: '5', name: 'ভ্রমণ বাংলা', members: '৪.৮k', posts: 1500, category: 'ভ্রমণ', icon: MapPin, coverImage: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800', isJoined: false },
  { id: '6', name: 'ফটোগ্রাফি', members: '৬.৩k', posts: 2100, category: 'ফটোগ্রাফি', icon: Camera, coverImage: 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=800', isJoined: false },
];

const generatePopularPosts = (): PopularPost[] => [
  { id: '1', author: 'রহিম আহমেদ', authorAvatar: '', content: 'বাংলাদেশে AI এর ভবিষ্যৎ নিয়ে আমার নতুন আর্টিকেল পড়ুন', image: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800', likes: 1234, comments: 89, category: 'প্রযুক্তি' },
  { id: '2', author: 'সাবিনা খাতুন', authorAvatar: '', content: 'রবীন্দ্রনাথের কবিতা নিয়ে নতুন পর্যালোচনা', likes: 892, comments: 45, category: 'সাহিত্য' },
  { id: '3', author: 'কামাল হোসেন', authorAvatar: '', content: 'আজকের ম্যাচের সম্পূর্ণ বিশ্লেষণ', image: 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800', likes: 2341, comments: 156, category: 'খেলাধুলা' },
];

const categories = [
  { id: 'all', label_bn: 'সব', label_en: 'All', icon: Hash },
  { id: 'technology', label_bn: 'প্রযুক্তি', label_en: 'Technology', icon: Code },
  { id: 'sports', label_bn: 'খেলাধুলা', label_en: 'Sports', icon: TrendingUp },
  { id: 'business', label_bn: 'ব্যবসা', label_en: 'Business', icon: Briefcase },
  { id: 'education', label_bn: 'শিক্ষা', label_en: 'Education', icon: GraduationCap },
  { id: 'food', label_bn: 'খাবার', label_en: 'Food', icon: Utensils },
  { id: 'travel', label_bn: 'ভ্রমণ', label_en: 'Travel', icon: MapPin },
  { id: 'literature', label_bn: 'সাহিত্য', label_en: 'Literature', icon: BookOpen },
  { id: 'entertainment', label_bn: 'বিনোদন', label_en: 'Entertainment', icon: Music },
];

interface ExploreScreenProps {
  onNavigate: (screen: string) => void;
}

export const ExploreScreen: React.FC<ExploreScreenProps> = ({ onNavigate }) => {
  const { language, showNotification } = useApp();
  const [searchQuery, setSearchQuery] = useState('');
  const [showHeader, setShowHeader] = useState(true);
  const [lastScrollY, setLastScrollY] = useState(0);
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const [activeTab, setActiveTab] = useState<'trending' | 'people' | 'communities' | 'stages'>('trending');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [followedCreators, setFollowedCreators] = useState<Set<string>>(new Set(['2', '5']));
  const [joinedCommunities, setJoinedCommunities] = useState<Set<string>>(new Set(['2', '4']));

  // Mock data
  const [trendingTopics] = useState(generateTrendingTopics());
  const [creators] = useState(generateCreators());
  const [stages] = useState(generateStages());
  const [communities] = useState(generateCommunities());
  const [popularPosts] = useState(generatePopularPosts());

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

  const handleFollowCreator = (creatorId: string, creatorName: string) => {
    const newFollowed = new Set(followedCreators);
    if (newFollowed.has(creatorId)) {
      newFollowed.delete(creatorId);
      showNotification && showNotification({
        type: 'info',
        message: language === 'bn' ? `${creatorName} কে আনফলো করা হয়েছে` : `Unfollowed ${creatorName}`,
        duration: 2000
      });
    } else {
      newFollowed.add(creatorId);
      showNotification && showNotification({
        type: 'success',
        message: language === 'bn' ? `${creatorName} কে ফলো করা হয়েছে` : `Following ${creatorName}`,
        duration: 2000
      });
    }
    setFollowedCreators(newFollowed);
  };

  const handleJoinCommunity = (communityId: string, communityName: string) => {
    const newJoined = new Set(joinedCommunities);
    if (newJoined.has(communityId)) {
      newJoined.delete(communityId);
      showNotification && showNotification({
        type: 'info',
        message: language === 'bn' ? `${communityName} ত্যাগ করা হয়েছে` : `Left ${communityName}`,
        duration: 2000
      });
    } else {
      newJoined.add(communityId);
      showNotification && showNotification({
        type: 'success',
        message: language === 'bn' ? `${communityName} যোগদান করা হয়েছে` : `Joined ${communityName}`,
        duration: 2000
      });
    }
    setJoinedCommunities(newJoined);
  };

  // Filter data based on search and category
  const filteredTrendingTopics = trendingTopics.filter(topic => {
    const matchesSearch = topic.hashtag.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'all' || topic.category.includes(selectedCategory);
    return matchesSearch && matchesCategory;
  });

  const filteredCreators = creators.filter(creator => {
    const matchesSearch = creator.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
                         creator.username.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'all' || creator.category.includes(selectedCategory);
    return matchesSearch && matchesCategory;
  });

  const filteredCommunities = communities.filter(community => {
    const matchesSearch = community.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'all' || community.category.includes(selectedCategory);
    return matchesSearch && matchesCategory;
  });

  const filteredStages = stages.filter(stage => {
    const matchesSearch = stage.title.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'all' || stage.category.includes(selectedCategory);
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="fixed inset-0 bg-background flex flex-col overflow-hidden">
      {/* Header */}
      <motion.div 
        className="px-6 pt-6 pb-4 border-b border-border/40 bg-background absolute top-0 left-0 right-0 z-10"
        initial={{ y: 0 }}
        animate={{ y: showHeader ? 0 : -220 }}
        transition={{ duration: 0.25, ease: 'easeInOut' }}
        style={{ boxShadow: '0 1px 3px rgba(0, 0, 0, 0.05)' }}
      >
        <h1 
          className="mb-4 font-['Noto_Sans_Bengali:Bold',sans-serif] font-bold"
          style={{ fontSize: '24px', lineHeight: '1.3' }}
        >
          {language === 'bn' ? 'অন্বেষণ' : 'Explore'}
        </h1>
        
        {/* Search */}
        <div className="relative mb-4">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
          <Input
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder={language === 'bn' ? 'খুঁজুন...' : 'Search...'}
            className="pl-12 rounded-xl bg-muted/40 border-border/40"
            style={{ height: '48px', fontSize: '15px' }}
          />
        </div>

        {/* Tabs */}
        <Tabs value={activeTab} onValueChange={(value) => setActiveTab(value as any)} className="w-full">
          <TabsList className="w-full bg-muted/40 h-11 overflow-x-auto flex justify-start" style={{ borderRadius: '12px' }}>
            <TabsTrigger value="trending" className="flex-1 min-w-[110px] sm:flex-1" style={{ borderRadius: '10px', fontSize: '14px', fontWeight: '500' }}>
              <TrendingUp className="w-4 h-4 mr-1.5" />
              {language === 'bn' ? 'ট্রেন্ডিং' : 'Trending'}
            </TabsTrigger>
            <TabsTrigger value="people" className="flex-1 min-w-[100px] sm:flex-1" style={{ borderRadius: '10px', fontSize: '14px', fontWeight: '500' }}>
              <Users className="w-4 h-4 mr-1.5" />
              {language === 'bn' ? 'মানুষ' : 'People'}
            </TabsTrigger>
            <TabsTrigger value="communities" className="flex-1 min-w-[130px] sm:flex-1" style={{ borderRadius: '10px', fontSize: '14px', fontWeight: '500' }}>
              <Hash className="w-4 h-4 mr-1.5" />
              {language === 'bn' ? 'কমিউনিটি' : 'Communities'}
            </TabsTrigger>
            <TabsTrigger value="stages" className="flex-1 min-w-[100px] sm:flex-1" style={{ borderRadius: '10px', fontSize: '14px', fontWeight: '500' }}>
              <Radio className="w-4 h-4 mr-1.5" />
              {language === 'bn' ? 'স্টেজ' : 'Stages'}
            </TabsTrigger>
          </TabsList>
        </Tabs>
      </motion.div>

      <motion.div 
        className="flex-1 overflow-y-auto pb-24"
        ref={scrollContainerRef}
        initial={{ paddingTop: '220px' }}
        animate={{ paddingTop: showHeader ? '220px' : '12px' }}
        transition={{ duration: 0.25, ease: 'easeInOut' }}
      >
        <div className="px-4 space-y-6">
          {/* Category Pills */}
          <div className="flex gap-2 overflow-x-auto pb-2 no-scrollbar">
            {categories.map((category) => (
              <Button
                key={category.id}
                variant={selectedCategory === category.id ? 'default' : 'outline'}
                size="sm"
                className="rounded-full whitespace-nowrap"
                style={{ fontSize: '13px', fontWeight: '500', height: '32px' }}
                onClick={() => setSelectedCategory(category.id)}
              >
                <category.icon className="w-3.5 h-3.5 mr-1.5" />
                {language === 'bn' ? category.label_bn : category.label_en}
              </Button>
            ))}
          </div>

          {/* Trending Topics Tab */}
          {activeTab === 'trending' && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
              className="space-y-3"
            >
              <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '12px' }}>
                {language === 'bn' ? 'ট্রেন্ডিং হ্যাশট্যাগ' : 'Trending Hashtags'}
              </h3>
              {filteredTrendingTopics.length === 0 ? (
                <p className="text-muted-foreground text-center py-8" style={{ fontSize: '14px' }}>
                  {language === 'bn' ? 'কোনো ফলাফল পাওয়া যায়নি' : 'No results found'}
                </p>
              ) : (
                filteredTrendingTopics.map((topic, index) => (
                  <motion.div
                    key={topic.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.03, duration: 0.2 }}
                  >
                    <Card className="p-4 border-border/40 cursor-pointer hover:border-accent/50 transition-all hover:shadow-sm" style={{ borderRadius: '16px' }}>
                      <div className="flex items-center justify-between">
                        <div className="flex-1">
                          <p className="text-muted-foreground mb-1" style={{ fontSize: '13px', opacity: '0.7' }}>
                            {topic.category}
                          </p>
                          <p className="flex items-center gap-2 mb-1" style={{ fontSize: '16px', fontWeight: '600' }}>
                            <Hash className="w-4.5 h-4.5 text-accent" />
                            {topic.hashtag}
                          </p>
                          <div className="flex items-center gap-2">
                            <p className="text-muted-foreground" style={{ fontSize: '13px' }}>
                              {topic.posts.toLocaleString()} {language === 'bn' ? 'পোস্ট' : 'posts'}
                            </p>
                            {topic.trend === 'up' && (
                              <Badge className="bg-green-500/10 text-green-600 hover:bg-green-500/20 rounded-full px-2" style={{ fontSize: '11px', height: '20px' }}>
                                <ArrowUpRight className="w-3 h-3 mr-0.5" />
                                {topic.trendPercentage}%
                              </Badge>
                            )}
                          </div>
                        </div>
                        <TrendingUp className={`w-6 h-6 ${topic.trend === 'up' ? 'text-green-500' : 'text-muted-foreground'}`} />
                      </div>
                    </Card>
                  </motion.div>
                ))
              )}
            </motion.div>
          )}

          {/* People Tab */}
          {activeTab === 'people' && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
              className="space-y-3"
            >
              <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '12px' }}>
                {language === 'bn' ? 'জনপ্রিয় ক্রিয়েটর' : 'Popular Creators'}
              </h3>
              {filteredCreators.length === 0 ? (
                <p className="text-muted-foreground text-center py-8" style={{ fontSize: '14px' }}>
                  {language === 'bn' ? 'কোনো ফলাফল পাওয়া যায়নি' : 'No results found'}
                </p>
              ) : (
                filteredCreators.map((creator, index) => (
                  <motion.div
                    key={creator.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.03, duration: 0.2 }}
                  >
                    <Card className="p-4 border-border/40" style={{ borderRadius: '16px' }}>
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <Avatar className="w-12 h-12">
                            <AvatarImage src={creator.avatar} />
                            <AvatarFallback className="bg-accent/10 text-accent" style={{ fontSize: '16px', fontWeight: '600' }}>
                              {creator.name[0]}
                            </AvatarFallback>
                          </Avatar>
                          <div>
                            <p className="flex items-center gap-1.5 mb-0.5" style={{ fontSize: '15px', fontWeight: '600' }}>
                              {creator.name}
                              {creator.isVerified && <CheckCircle2 className="w-4 h-4 text-accent fill-accent" />}
                            </p>
                            <p className="text-muted-foreground mb-1" style={{ fontSize: '13px', opacity: '0.7' }}>
                              {creator.username}
                            </p>
                            <p className="text-muted-foreground" style={{ fontSize: '12px' }}>
                              {creator.bio}
                            </p>
                            <p className="text-muted-foreground mt-1" style={{ fontSize: '12px' }}>
                              {creator.followers} {language === 'bn' ? 'ফলোয়ার' : 'followers'}
                            </p>
                          </div>
                        </div>
                        <Button 
                          size="sm" 
                          variant={followedCreators.has(creator.id) ? 'outline' : 'default'}
                          className="rounded-xl h-9"
                          style={{ fontSize: '13px', fontWeight: '500', minWidth: '80px' }}
                          onClick={() => handleFollowCreator(creator.id, creator.name)}
                        >
                          {followedCreators.has(creator.id) 
                            ? (language === 'bn' ? 'ফলোয়িং' : 'Following')
                            : (language === 'bn' ? 'ফলো করুন' : 'Follow')}
                        </Button>
                      </div>
                    </Card>
                  </motion.div>
                ))
              )}
            </motion.div>
          )}

          {/* Communities Tab */}
          {activeTab === 'communities' && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
              className="space-y-3"
            >
              <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '12px' }}>
                {language === 'bn' ? 'জনপ্রিয় কমিউনিটি' : 'Popular Communities'}
              </h3>
              {filteredCommunities.length === 0 ? (
                <p className="text-muted-foreground text-center py-8" style={{ fontSize: '14px' }}>
                  {language === 'bn' ? 'কোনো ফলাফল পাওয়া যায়নি' : 'No results found'}
                </p>
              ) : (
                filteredCommunities.map((community, index) => (
                  <motion.div
                    key={community.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.03, duration: 0.2 }}
                  >
                    <Card className="overflow-hidden border-border/40 cursor-pointer hover:border-accent/50 transition-all" style={{ borderRadius: '16px' }}>
                      {/* Cover Image */}
                      <div className="h-24 bg-gradient-to-br from-accent/20 to-accent/5 relative overflow-hidden">
                        <img 
                          src={community.coverImage} 
                          alt={community.name}
                          className="w-full h-full object-cover opacity-50"
                        />
                      </div>
                      
                      <div className="p-4 pt-2">
                        <div className="flex items-start justify-between mb-2">
                          <div className="flex items-center gap-2">
                            <div className="w-10 h-10 rounded-xl bg-accent/10 flex items-center justify-center -mt-6 border-4 border-background">
                              <community.icon className="w-5 h-5 text-accent" />
                            </div>
                            <div>
                              <p style={{ fontSize: '16px', fontWeight: '600' }}>{community.name}</p>
                              <p className="text-muted-foreground" style={{ fontSize: '12px' }}>
                                {community.category}
                              </p>
                            </div>
                          </div>
                          <Button 
                            size="sm" 
                            variant={joinedCommunities.has(community.id) ? 'outline' : 'default'}
                            className="rounded-xl h-8"
                            style={{ fontSize: '12px', fontWeight: '500' }}
                            onClick={() => handleJoinCommunity(community.id, community.name)}
                          >
                            {joinedCommunities.has(community.id)
                              ? (language === 'bn' ? 'যোগদান করেছেন' : 'Joined')
                              : (language === 'bn' ? 'যোগদান' : 'Join')}
                          </Button>
                        </div>
                        <div className="flex items-center gap-4 text-muted-foreground" style={{ fontSize: '12px' }}>
                          <span>
                            <Users className="w-3.5 h-3.5 inline mr-1" />
                            {community.members} {language === 'bn' ? 'সদস্য' : 'members'}
                          </span>
                          <span>
                            <Hash className="w-3.5 h-3.5 inline mr-1" />
                            {community.posts} {language === 'bn' ? 'পোস্ট' : 'posts'}
                          </span>
                        </div>
                      </div>
                    </Card>
                  </motion.div>
                ))
              )}
            </motion.div>
          )}

          {/* Stages Tab */}
          {activeTab === 'stages' && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
              className="space-y-3"
            >
              <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '12px' }}>
                {language === 'bn' ? 'লাইভ স্টেজ' : 'Live Stages'}
              </h3>
              {filteredStages.length === 0 ? (
                <p className="text-muted-foreground text-center py-8" style={{ fontSize: '14px' }}>
                  {language === 'bn' ? 'কোনো ফলাফল পাওয়া যায়নি' : 'No results found'}
                </p>
              ) : (
                filteredStages.map((stage, index) => (
                  <motion.div
                    key={stage.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.03, duration: 0.2 }}
                  >
                    <Card 
                      className="p-4 border-border/40 cursor-pointer hover:border-accent/50 transition-all hover:shadow-sm"
                      style={{ borderRadius: '16px' }}
                    >
                      <div className="flex items-start justify-between mb-3">
                        <Badge className="bg-red-500 text-white rounded-full animate-pulse" style={{ fontSize: '11px', height: '22px' }}>
                          <Radio className="w-3 h-3 mr-1" />
                          {language === 'bn' ? 'লাইভ' : 'LIVE'}
                        </Badge>
                        <Badge variant="outline" className="rounded-full" style={{ fontSize: '11px' }}>
                          {stage.category}
                        </Badge>
                      </div>
                      <h4 className="mb-2" style={{ fontSize: '16px', fontWeight: '600', lineHeight: '1.4' }}>
                        {stage.title}
                      </h4>
                      <p className="text-muted-foreground mb-3" style={{ fontSize: '13px' }}>
                        {language === 'bn' ? 'হোস্ট:' : 'Host:'} {stage.host}
                      </p>
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-1.5 text-muted-foreground" style={{ fontSize: '13px' }}>
                          <Users className="w-4 h-4" />
                          <span>{stage.listeners.toLocaleString()} {language === 'bn' ? 'শুনছে' : 'listening'}</span>
                        </div>
                        <Button size="sm" className="rounded-xl bg-accent hover:bg-accent/90 h-8" style={{ fontSize: '12px', fontWeight: '500' }}>
                          {language === 'bn' ? 'যোগদান' : 'Join'}
                        </Button>
                      </div>
                    </Card>
                  </motion.div>
                ))
              )}
            </motion.div>
          )}
        </div>
      </motion.div>
    </div>
  );
};