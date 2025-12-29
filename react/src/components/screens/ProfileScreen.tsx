import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';
import { Card } from '../ui/card';
import { Badge } from '../ui/badge';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '../ui/tabs';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '../ui/dialog';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Textarea } from '../ui/textarea';
import { 
  Settings, 
  MapPin, 
  Link as LinkIcon, 
  Calendar, 
  Heart, 
  MessageCircle, 
  Share2, 
  Camera, 
  Upload, 
  Check,
  TrendingUp,
  Users,
  Award,
  Bookmark,
  Image as ImageIcon,
  Video,
  BarChart3,
  Clock,
  Eye,
  Zap,
  Target,
  Crown,
  Star,
  Flame,
  ChevronRight,
  Link2,
  Globe
} from 'lucide-react';
import { toast } from 'sonner@2.0.3';

interface Post {
  id: string;
  content: string;
  image?: string;
  likes: number;
  comments: number;
  shares: number;
  views: number;
  timestamp: string;
  isLiked: boolean;
  isSaved: boolean;
}

interface Achievement {
  id: string;
  title_bn: string;
  title_en: string;
  description_bn: string;
  description_en: string;
  icon: any;
  color: string;
  unlocked: boolean;
  progress?: number;
  total?: number;
}

interface Stats {
  totalPosts: number;
  totalLikes: number;
  totalComments: number;
  totalViews: number;
  postsThisMonth: number;
  engagementRate: string;
  topPostViews: number;
  streak: number;
}

// Generate comprehensive mock posts
const generatePosts = (): Post[] => {
  const postContents = [
    { content: 'আজকের সূর্যাস্ত সত্যিই অসাধারণ ছিল!', image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800' },
    { content: 'নতুন প্রোগ্রামিং শেখার জন্য কোন ভাষা দিয়ে শুরু করা উচিত? আমি Python নিয়ে ভাবছি।' },
    { content: 'ঢাকায় সেরা বাংলা বইয়ের দোকান কোনটি? রেকমেন্ডেশন চাই!', image: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=800' },
    { content: 'আজ প্রথমবার মারাঠন দৌড়েছি। অসাধারণ অভিজ্ঞতা!', image: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800' },
    { content: 'বাংলাদেশের টেক স্টার্টআপ ইকোসিস্টেম সম্পর্কে আপনার মতামত কি?' },
    { content: 'আজকের রান্না - চিকেন বিরিয়ানি 🍛', image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800' },
    { content: 'সান্ধ্যকালীন পার্কে সময় কাটানো। প্রকৃতি সত্যিই সুন্দর!', image: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800' },
    { content: 'ফ্রিল্যান্সিং নিয়ে কিছু টিপস শেয়ার করতে চাই। আগ্রহী কেউ?' },
    { content: 'নতুন বই পড়া শুরু করেছি - "হিমু"। অনেক দিন পর বাংলা বই পড়ছি।', image: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800' },
    { content: 'কফি এবং কোডিং - সকালের সেরা কম্বিনেশন!', image: 'https://images.unsplash.com/photo-1461988625982-7e46a099bf4f?w=800' },
  ];

  return postContents.map((post, index) => ({
    id: `${index + 1}`,
    content: post.content,
    image: post.image,
    likes: Math.floor(Math.random() * 500) + 50,
    comments: Math.floor(Math.random() * 100) + 10,
    shares: Math.floor(Math.random() * 50) + 5,
    views: Math.floor(Math.random() * 2000) + 200,
    timestamp: index === 0 ? '২ ঘণ্টা আগে' : index === 1 ? '১ দিন আগে' : `${index} দিন আগে`,
    isLiked: Math.random() > 0.5,
    isSaved: Math.random() > 0.7
  }));
};

const achievements: Achievement[] = [
  {
    id: '1',
    title_bn: 'প্রথম পোস্ট',
    title_en: 'First Post',
    description_bn: 'প্রথম পোস্ট করেছেন',
    description_en: 'Made your first post',
    icon: Zap,
    color: '#d97757',
    unlocked: true
  },
  {
    id: '2',
    title_bn: 'জনপ্রিয়',
    title_en: 'Popular',
    description_bn: '১০০+ লাইক পেয়েছেন',
    description_en: 'Received 100+ likes',
    icon: Heart,
    color: '#dc2626',
    unlocked: true
  },
  {
    id: '3',
    title_bn: 'ধারাবাহিকতা',
    title_en: 'Streak',
    description_bn: '৭ দিন একটানা পোস্ট',
    description_en: '7 days posting streak',
    icon: Flame,
    color: '#ea580c',
    unlocked: true,
    progress: 7,
    total: 7
  },
  {
    id: '4',
    title_bn: 'কন্টেন্ট ক্রিয়েটর',
    title_en: 'Content Creator',
    description_bn: '৫০+ পোস্ট করেছেন',
    description_en: 'Posted 50+ times',
    icon: Target,
    color: '#16a34a',
    unlocked: false,
    progress: 32,
    total: 50
  },
  {
    id: '5',
    title_bn: 'ইনফ্লুয়েন্সার',
    title_en: 'Influencer',
    description_bn: '১,০০০+ ফলোয়ার',
    description_en: '1,000+ followers',
    icon: Crown,
    color: '#9333ea',
    unlocked: false,
    progress: 678,
    total: 1000
  },
  {
    id: '6',
    title_bn: 'সুপারস্টার',
    title_en: 'Superstar',
    description_bn: '১০,০০০+ ভিউ পেয়েছেন',
    description_en: 'Received 10,000+ views',
    icon: Star,
    color: '#eab308',
    unlocked: false,
    progress: 6543,
    total: 10000
  },
];

const mockStats: Stats = {
  totalPosts: 32,
  totalLikes: 4567,
  totalComments: 892,
  totalViews: 23456,
  postsThisMonth: 8,
  engagementRate: '12.5%',
  topPostViews: 2341,
  streak: 7
};

interface ProfileScreenProps {
  onNavigate: (screen: string) => void;
}

export const ProfileScreen: React.FC<ProfileScreenProps> = ({ onNavigate }) => {
  const { language, showNotification } = useApp();
  const [activeTab, setActiveTab] = useState('posts');
  const [isEditingProfile, setIsEditingProfile] = useState(false);
  const [posts, setPosts] = useState(generatePosts());
  const [stats] = useState(mockStats);
  const [profileData, setProfileData] = useState({
    name: 'আহমেদ আলী',
    username: 'ahmed_ali',
    bio: 'প্রযুক্তি প্রেমী | সফটওয়্যার ডেভেলপার | বাংলাদেশ থেকে',
    location: 'ঢাকা, বাংলাদেশ',
    website: 'torko.app',
    joinedDate: 'জানুয়ারি ২০২৪',
    following: 1234,
    followers: 5678,
    coverImage: 'https://images.unsplash.com/photo-1557683316-973673baf926?w=1500',
    profileImage: ''
  });

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

  const handleSave = (postId: string) => {
    setPosts(posts.map(post => {
      if (post.id === postId) {
        const isSaving = !post.isSaved;
        showNotification && showNotification({
          type: 'success',
          message: isSaving 
            ? (language === 'bn' ? 'পোস্ট সংরক্ষিত হয়েছে' : 'Post saved')
            : (language === 'bn' ? 'পোস্ট আনসেভ করা হয়েছে' : 'Post unsaved'),
          duration: 2000
        });
        return {
          ...post,
          isSaved: isSaving
        };
      }
      return post;
    }));
  };

  const handleShare = (postId: string, content: string) => {
    if (navigator.share) {
      navigator.share({
        title: 'Torko Post',
        text: content,
        url: `https://torko.app/post/${postId}`
      }).catch(() => {});
    } else {
      showNotification && showNotification({
        type: 'info',
        message: language === 'bn' ? 'শেয়ার লিংক কপি করা হয়েছে' : 'Share link copied',
        duration: 2000
      });
    }
  };

  const savedPosts = posts.filter(post => post.isSaved);

  return (
    <div className="fixed inset-0 bg-background flex flex-col overflow-hidden">
      {/* Header */}
      <div className="px-6 py-4 border-b border-border/40 flex items-center justify-between bg-background relative z-10">
        <h1 
          className="font-['Noto_Sans_Bengali:Bold',sans-serif] font-bold"
          style={{ fontSize: '24px', lineHeight: '1.3' }}
        >
          {language === 'bn' ? 'প্রোফাইল' : 'Profile'}
        </h1>
        <Button
          variant="ghost"
          size="icon"
          className="rounded-full hover:bg-muted/80"
          style={{ width: '44px', height: '44px' }}
          onClick={() => onNavigate('settings')}
        >
          <Settings style={{ width: '22px', height: '22px' }} />
        </Button>
      </div>

      <div className="flex-1 overflow-y-auto pb-24">
        {/* Profile Header */}
        <div className="relative">
          {/* Cover Image */}
          <div 
            className="h-40 bg-gradient-to-br from-accent via-accent/80 to-secondary relative overflow-hidden"
          >
            {profileData.coverImage && (
              <img 
                src={profileData.coverImage} 
                alt="Cover" 
                className="w-full h-full object-cover opacity-70"
              />
            )}
          </div>
          
          {/* Profile Info */}
          <div className="px-6 pb-6">
            <div className="flex items-end justify-between -mt-16 mb-4">
              <Avatar className="w-32 h-32 border-4 border-background shadow-lg">
                <AvatarImage src={profileData.profileImage} />
                <AvatarFallback className="bg-accent text-white" style={{ fontSize: '40px', fontWeight: '700' }}>
                  {profileData.name[0]}
                </AvatarFallback>
              </Avatar>
              <Button 
                className="rounded-xl bg-accent hover:bg-accent/90 text-white"
                style={{ fontSize: '14px', fontWeight: '600', height: '40px', paddingLeft: '20px', paddingRight: '20px' }}
                onClick={() => setIsEditingProfile(true)}
              >
                {language === 'bn' ? 'প্রোফাইল এডিট' : 'Edit Profile'}
              </Button>
            </div>

            <div className="space-y-3">
              <div>
                <h2 style={{ fontSize: '24px', fontWeight: '700', lineHeight: '1.3' }}>
                  {profileData.name}
                </h2>
                <p className="text-muted-foreground" style={{ fontSize: '15px' }}>
                  @{profileData.username}
                </p>
              </div>

              <p style={{ fontSize: '15px', lineHeight: '1.5' }}>
                {profileData.bio}
              </p>

              <div className="flex flex-wrap gap-4 text-muted-foreground" style={{ fontSize: '14px' }}>
                <div className="flex items-center gap-1.5">
                  <MapPin className="w-4 h-4" />
                  <span>{profileData.location}</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <Globe className="w-4 h-4" />
                  <span className="text-accent">{profileData.website}</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <Calendar className="w-4 h-4" />
                  <span>{language === 'bn' ? 'যোগদান' : 'Joined'} {profileData.joinedDate}</span>
                </div>
              </div>

              <div className="flex gap-6" style={{ fontSize: '15px' }}>
                <button className="hover:underline">
                  <span style={{ fontWeight: '700' }}>{profileData.following.toLocaleString()}</span>
                  {' '}
                  <span className="text-muted-foreground">{language === 'bn' ? 'ফলোয়িং' : 'Following'}</span>
                </button>
                <button className="hover:underline">
                  <span style={{ fontWeight: '700' }}>{profileData.followers.toLocaleString()}</span>
                  {' '}
                  <span className="text-muted-foreground">{language === 'bn' ? 'ফলোয়ার' : 'Followers'}</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="px-4 mb-6">
          <div className="grid grid-cols-4 gap-2">
            <Card className="p-3 text-center border-border/40" style={{ borderRadius: '12px' }}>
              <div style={{ fontSize: '20px', fontWeight: '700', color: '#d97757' }}>
                {stats.totalPosts}
              </div>
              <div className="text-muted-foreground" style={{ fontSize: '11px', marginTop: '2px' }}>
                {language === 'bn' ? 'পোস্ট' : 'Posts'}
              </div>
            </Card>
            <Card className="p-3 text-center border-border/40" style={{ borderRadius: '12px' }}>
              <div style={{ fontSize: '20px', fontWeight: '700', color: '#dc2626' }}>
                {stats.totalLikes > 999 ? `${(stats.totalLikes / 1000).toFixed(1)}k` : stats.totalLikes}
              </div>
              <div className="text-muted-foreground" style={{ fontSize: '11px', marginTop: '2px' }}>
                {language === 'bn' ? 'লাইক' : 'Likes'}
              </div>
            </Card>
            <Card className="p-3 text-center border-border/40" style={{ borderRadius: '12px' }}>
              <div style={{ fontSize: '20px', fontWeight: '700', color: '#16a34a' }}>
                {stats.totalViews > 999 ? `${(stats.totalViews / 1000).toFixed(1)}k` : stats.totalViews}
              </div>
              <div className="text-muted-foreground" style={{ fontSize: '11px', marginTop: '2px' }}>
                {language === 'bn' ? 'ভিউ' : 'Views'}
              </div>
            </Card>
            <Card className="p-3 text-center border-border/40" style={{ borderRadius: '12px' }}>
              <div style={{ fontSize: '20px', fontWeight: '700', color: '#ea580c' }}>
                {stats.streak}
              </div>
              <div className="text-muted-foreground" style={{ fontSize: '11px', marginTop: '2px' }}>
                {language === 'bn' ? 'স্ট্রিক' : 'Streak'}
              </div>
            </Card>
          </div>
        </div>

        {/* Tabs */}
        <div className="border-t border-border/40">
          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="w-full bg-transparent border-b border-border/40 rounded-none h-12">
              <TabsTrigger 
                value="posts" 
                className="flex-1 rounded-none data-[state=active]:border-b-2 data-[state=active]:border-accent"
                style={{ fontSize: '14px', fontWeight: '600' }}
              >
                {language === 'bn' ? 'পোস্ট' : 'Posts'}
              </TabsTrigger>
              <TabsTrigger 
                value="media" 
                className="flex-1 rounded-none data-[state=active]:border-b-2 data-[state=active]:border-accent"
                style={{ fontSize: '14px', fontWeight: '600' }}
              >
                {language === 'bn' ? 'মিডিয়া' : 'Media'}
              </TabsTrigger>
              <TabsTrigger 
                value="saved" 
                className="flex-1 rounded-none data-[state=active]:border-b-2 data-[state=active]:border-accent"
                style={{ fontSize: '14px', fontWeight: '600' }}
              >
                {language === 'bn' ? 'সংরক্ষিত' : 'Saved'}
              </TabsTrigger>
              <TabsTrigger 
                value="achievements" 
                className="flex-1 rounded-none data-[state=active]:border-b-2 data-[state=active]:border-accent"
                style={{ fontSize: '14px', fontWeight: '600' }}
              >
                {language === 'bn' ? 'অর্জন' : 'Achievements'}
              </TabsTrigger>
            </TabsList>

            {/* Posts Tab */}
            <TabsContent value="posts" className="px-4 pt-4 space-y-3">
              {posts.map((post, index) => (
                <div
                  key={post.id}
                >
                  <Card className="p-4 border-border/40" style={{ borderRadius: '16px' }}>
                    <p className="mb-3" style={{ fontSize: '15px', lineHeight: '1.5' }}>
                      {post.content}
                    </p>
                    {post.image && (
                      <div className="mb-3 rounded-xl overflow-hidden">
                        <img 
                          src={post.image} 
                          alt="Post" 
                          className="w-full object-cover"
                          style={{ maxHeight: '320px' }}
                        />
                      </div>
                    )}
                    
                    {/* Stats */}
                    <div className="flex items-center gap-4 mb-3 text-muted-foreground" style={{ fontSize: '13px' }}>
                      <div className="flex items-center gap-1">
                        <Eye className="w-4 h-4" />
                        <span>{post.views.toLocaleString()}</span>
                      </div>
                      <span>•</span>
                      <span>{post.timestamp}</span>
                    </div>

                    {/* Actions */}
                    <div className="flex items-center justify-between pt-3 border-t border-border/40">
                      <Button
                        variant="ghost"
                        size="sm"
                        className="flex-1 gap-2 rounded-xl hover:bg-muted/50"
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
                        className="flex-1 gap-2 rounded-xl hover:bg-muted/50"
                        style={{ height: '36px', fontSize: '14px', fontWeight: '500' }}
                      >
                        <MessageCircle className="w-4.5 h-4.5" />
                        <span>{post.comments}</span>
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="flex-1 gap-2 rounded-xl hover:bg-muted/50"
                        style={{ height: '36px', fontSize: '14px', fontWeight: '500' }}
                        onClick={() => handleShare(post.id, post.content)}
                      >
                        <Share2 className="w-4.5 h-4.5" />
                        <span>{post.shares}</span>
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="rounded-xl hover:bg-muted/50"
                        style={{ height: '36px', width: '36px', padding: '0' }}
                        onClick={() => handleSave(post.id)}
                      >
                        <Bookmark 
                          className={`w-4.5 h-4.5 ${post.isSaved ? 'fill-accent text-accent' : ''}`}
                        />
                      </Button>
                    </div>
                  </Card>
                </div>
              ))}
            </TabsContent>

            {/* Media Tab */}
            <TabsContent value="media" className="px-4 pt-4">
              <div className="grid grid-cols-3 gap-2">
                {posts.filter(p => p.image).map((post, index) => (
                  <div
                    key={post.id}
                    className="aspect-square rounded-xl overflow-hidden cursor-pointer hover:opacity-80 transition-opacity"
                  >
                    <img 
                      src={post.image} 
                      alt="Media" 
                      className="w-full h-full object-cover"
                    />
                  </div>
                ))}
              </div>
            </TabsContent>

            {/* Saved Tab */}
            <TabsContent value="saved" className="px-4 pt-4 space-y-3">
              {savedPosts.length === 0 ? (
                <div className="text-center py-12">
                  <Bookmark className="w-12 h-12 mx-auto mb-3 text-muted-foreground/50" />
                  <p className="text-muted-foreground" style={{ fontSize: '15px' }}>
                    {language === 'bn' ? 'কোনো সংরক্ষিত পোস্ট নেই' : 'No saved posts'}
                  </p>
                </div>
              ) : (
                savedPosts.map((post, index) => (
                  <div
                    key={post.id}
                  >
                    <Card className="p-4 border-border/40" style={{ borderRadius: '16px' }}>
                      <p className="mb-3" style={{ fontSize: '15px', lineHeight: '1.5' }}>
                        {post.content}
                      </p>
                      {post.image && (
                        <div className="mb-3 rounded-xl overflow-hidden">
                          <img 
                            src={post.image} 
                            alt="Post" 
                            className="w-full object-cover"
                            style={{ maxHeight: '320px' }}
                          />
                        </div>
                      )}
                      <div className="flex items-center justify-between pt-3 border-t border-border/40">
                        <Button
                          variant="ghost"
                          size="sm"
                          className="flex-1 gap-2 rounded-xl hover:bg-muted/50"
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
                          className="rounded-xl hover:bg-muted/50"
                          style={{ height: '36px', width: '36px', padding: '0' }}
                          onClick={() => handleSave(post.id)}
                        >
                          <Bookmark className="w-4.5 h-4.5 fill-accent text-accent" />
                        </Button>
                      </div>
                    </Card>
                  </div>
                ))
              )}
            </TabsContent>

            {/* Achievements Tab */}
            <TabsContent value="achievements" className="px-4 pt-4 space-y-3">
              <div className="mb-4">
                <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '8px' }}>
                  {language === 'bn' ? 'আনলক করা হয়েছে' : 'Unlocked'}
                </h3>
                <div className="space-y-2">
                  {achievements.filter(a => a.unlocked).map((achievement, index) => {
                    const Icon = achievement.icon;
                    return (
                      <motion.div
                        key={achievement.id}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.05, duration: 0.2 }}
                      >
                        <Card className="p-4 border-border/40" style={{ borderRadius: '16px' }}>
                          <div className="flex items-center gap-3">
                            <div 
                              className="w-12 h-12 rounded-xl flex items-center justify-center"
                              style={{ backgroundColor: `${achievement.color}20` }}
                            >
                              <Icon className="w-6 h-6" style={{ color: achievement.color }} />
                            </div>
                            <div className="flex-1">
                              <div className="flex items-center gap-2">
                                <p style={{ fontSize: '15px', fontWeight: '600' }}>
                                  {language === 'bn' ? achievement.title_bn : achievement.title_en}
                                </p>
                                <Check className="w-4 h-4 text-green-500" />
                              </div>
                              <p className="text-muted-foreground" style={{ fontSize: '13px' }}>
                                {language === 'bn' ? achievement.description_bn : achievement.description_en}
                              </p>
                            </div>
                          </div>
                        </Card>
                      </motion.div>
                    );
                  })}
                </div>
              </div>

              <div>
                <h3 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '8px' }}>
                  {language === 'bn' ? 'লক করা' : 'Locked'}
                </h3>
                <div className="space-y-2">
                  {achievements.filter(a => !a.unlocked).map((achievement, index) => {
                    const Icon = achievement.icon;
                    const progress = achievement.progress && achievement.total 
                      ? (achievement.progress / achievement.total) * 100 
                      : 0;
                    
                    return (
                      <motion.div
                        key={achievement.id}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.05, duration: 0.2 }}
                      >
                        <Card className="p-4 border-border/40 opacity-60" style={{ borderRadius: '16px' }}>
                          <div className="flex items-center gap-3 mb-2">
                            <div 
                              className="w-12 h-12 rounded-xl flex items-center justify-center"
                              style={{ backgroundColor: `${achievement.color}20` }}
                            >
                              <Icon className="w-6 h-6" style={{ color: achievement.color }} />
                            </div>
                            <div className="flex-1">
                              <p style={{ fontSize: '15px', fontWeight: '600' }}>
                                {language === 'bn' ? achievement.title_bn : achievement.title_en}
                              </p>
                              <p className="text-muted-foreground" style={{ fontSize: '13px' }}>
                                {language === 'bn' ? achievement.description_bn : achievement.description_en}
                              </p>
                            </div>
                          </div>
                          {achievement.progress !== undefined && achievement.total && (
                            <div>
                              <div className="flex items-center justify-between mb-1" style={{ fontSize: '12px' }}>
                                <span className="text-muted-foreground">
                                  {language === 'bn' ? 'অগ্রগতি' : 'Progress'}
                                </span>
                                <span className="text-muted-foreground">
                                  {achievement.progress} / {achievement.total}
                                </span>
                              </div>
                              <div className="w-full bg-muted rounded-full h-2">
                                <div 
                                  className="h-2 rounded-full transition-all"
                                  style={{ 
                                    width: `${progress}%`,
                                    backgroundColor: achievement.color
                                  }}
                                />
                              </div>
                            </div>
                          )}
                        </Card>
                      </motion.div>
                    );
                  })}
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </div>
      </div>

      {/* Edit Profile Dialog */}
      <Dialog open={isEditingProfile} onOpenChange={setIsEditingProfile}>
        <DialogContent className="sm:max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{language === 'bn' ? 'প্রোফাইল এডিট করুন' : 'Edit Profile'}</DialogTitle>
            <DialogDescription>
              {language === 'bn' ? 'আপনার প্রোফাইল তথ্য আপডেট করুন' : 'Update your profile information'}
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-6 py-4">
            {/* Cover Image */}
            <div className="space-y-2">
              <Label>{language === 'bn' ? 'কভার ছবি' : 'Cover Image'}</Label>
              <div className="relative h-32 rounded-2xl overflow-hidden bg-gradient-to-r from-accent to-secondary group">
                {profileData.coverImage && (
                  <img src={profileData.coverImage} alt="Cover" className="w-full h-full object-cover" />
                )}
                <div className="absolute inset-0 bg-black/0 group-hover:bg-black/40 transition-colors flex items-center justify-center">
                  <Button
                    variant="ghost"
                    size="icon"
                    className="opacity-0 group-hover:opacity-100 transition-opacity rounded-full bg-background/90 hover:bg-background text-foreground h-12 w-12"
                  >
                    <Camera className="w-5 h-5" />
                  </Button>
                </div>
              </div>
            </div>

            {/* Profile Image */}
            <div className="space-y-2">
              <Label>{language === 'bn' ? 'প্রোফাইল ছবি' : 'Profile Image'}</Label>
              <div className="flex items-center gap-4">
                <div className="relative group">
                  <Avatar className="w-24 h-24">
                    <AvatarImage src={profileData.profileImage} />
                    <AvatarFallback className="bg-accent text-white" style={{ fontSize: '32px' }}>
                      {profileData.name[0]}
                    </AvatarFallback>
                  </Avatar>
                  <div className="absolute inset-0 bg-black/0 group-hover:bg-black/40 transition-colors rounded-full flex items-center justify-center">
                    <Button
                      variant="ghost"
                      size="icon"
                      className="opacity-0 group-hover:opacity-100 transition-opacity rounded-full bg-background/90 hover:bg-background text-foreground h-10 w-10"
                    >
                      <Camera className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
                <div className="flex-1">
                  <Button variant="outline" className="rounded-2xl w-full">
                    <Upload className="w-4 h-4 mr-2" />
                    {language === 'bn' ? 'ছবি আপলোড করুন' : 'Upload Image'}
                  </Button>
                </div>
              </div>
            </div>

            {/* Name */}
            <div className="space-y-2">
              <Label htmlFor="name">{language === 'bn' ? 'নাম' : 'Name'}</Label>
              <Input
                id="name"
                value={profileData.name}
                onChange={(e) => setProfileData({ ...profileData, name: e.target.value })}
                placeholder={language === 'bn' ? 'আপনার নাম লিখুন' : 'Enter your name'}
                className="rounded-2xl"
              />
            </div>

            {/* Username */}
            <div className="space-y-2">
              <Label htmlFor="username">{language === 'bn' ? 'ইউজারনেম' : 'Username'}</Label>
              <div className="relative">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 text-muted-foreground">@</span>
                <Input
                  id="username"
                  value={profileData.username}
                  onChange={(e) => setProfileData({ ...profileData, username: e.target.value })}
                  placeholder={language === 'bn' ? 'ইউজারনেম' : 'username'}
                  className="rounded-2xl pl-8"
                />
              </div>
            </div>

            {/* Bio */}
            <div className="space-y-2">
              <Label htmlFor="bio">{language === 'bn' ? 'বায়ো' : 'Bio'}</Label>
              <Textarea
                id="bio"
                value={profileData.bio}
                onChange={(e) => setProfileData({ ...profileData, bio: e.target.value })}
                placeholder={language === 'bn' ? 'নিজের সম্পর্কে লিখুন' : 'Tell us about yourself'}
                className="rounded-2xl min-h-24 resize-none"
                maxLength={160}
              />
              <p className="text-xs text-muted-foreground text-right">
                {profileData.bio.length}/160
              </p>
            </div>

            {/* Location */}
            <div className="space-y-2">
              <Label htmlFor="location">{language === 'bn' ? 'অবস্থান' : 'Location'}</Label>
              <div className="relative">
                <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  id="location"
                  value={profileData.location}
                  onChange={(e) => setProfileData({ ...profileData, location: e.target.value })}
                  placeholder={language === 'bn' ? 'আপনার অবস্থান' : 'Your location'}
                  className="rounded-2xl pl-10"
                />
              </div>
            </div>

            {/* Website */}
            <div className="space-y-2">
              <Label htmlFor="website">{language === 'bn' ? 'ওয়েবসাইট' : 'Website'}</Label>
              <div className="relative">
                <Globe className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  id="website"
                  value={profileData.website}
                  onChange={(e) => setProfileData({ ...profileData, website: e.target.value })}
                  placeholder={language === 'bn' ? 'আপনার ওয়েবসাইট' : 'Your website'}
                  className="rounded-2xl pl-10"
                />
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex gap-3 pt-4 border-t">
            <Button
              variant="outline"
              className="flex-1 rounded-2xl"
              onClick={() => setIsEditingProfile(false)}
            >
              {language === 'bn' ? 'বাতিল' : 'Cancel'}
            </Button>
            <Button
              className="flex-1 rounded-2xl bg-accent hover:bg-accent/90 text-white"
              onClick={() => {
                toast.success(language === 'bn' ? 'প্রোফাইল সফলভাবে আপডেট হয়েছে' : 'Profile updated successfully');
                setIsEditingProfile(false);
              }}
            >
              {language === 'bn' ? 'সংরক্ষণ করুন' : 'Save Changes'}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
};