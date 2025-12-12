import React, { useRef, useState } from 'react';
import { motion } from 'motion/react';
import { Share2, MessageCircle, MapPin, Users, Lock, Calendar, TrendingUp, Copy } from 'lucide-react';
import svgPaths from "../imports/svg-64srki310g";
import { toast } from 'sonner@2.0.3';

interface GroupDetailViewProps {
  group: any;
  language: 'bn' | 'en';
  onBack: () => void;
  posts: any[];
  onNavigate?: (screen: string) => void;
}

export const GroupDetailView: React.FC<GroupDetailViewProps> = ({
  group,
  language,
  onBack,
  posts,
  onNavigate,
}) => {
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const shareMenuRef = useRef<HTMLDivElement>(null);
  const [activeTab, setActiveTab] = useState<'posts' | 'about'>('posts');
  
  // State for post interactions
  const [postLikes, setPostLikes] = useState<Map<string, boolean>>(new Map());
  const [postLikeCounts, setPostLikeCounts] = useState<Map<string, number>>(new Map());
  const [showShareMenu, setShowShareMenu] = useState<string | null>(null);

  // Close share menu when clicking outside
  React.useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (shareMenuRef.current && !shareMenuRef.current.contains(event.target as Node)) {
        setShowShareMenu(null);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Format count to k format (e.g., 1.2k, 5.6k)
  const formatCount = (count: number): string => {
    if (count >= 1000) {
      const formatted = (count / 1000).toFixed(1);
      return formatted.endsWith('.0') ? `${Math.floor(count / 1000)}k` : `${formatted}k`;
    }
    return count.toString();
  };

  const t = {
    members: language === 'bn' ? 'সদস্য' : 'Members',
    join: language === 'bn' ? 'যোগ দিন' : 'Join',
    joined: language === 'bn' ? 'যুক্ত' : 'Joined',
    about: language === 'bn' ? 'সম্পর্কে' : 'About',
    posts: language === 'bn' ? 'পোস্ট' : 'Posts',
    anyoneCanJoin: language === 'bn' ? 'যে কেউ যোগ দিতে পারবে' : 'Anyone can join',
    location: language === 'bn' ? 'অবস্থান' : 'Location',
    created: language === 'bn' ? 'তৈরি হয়েছে' : 'Created',
    active: language === 'bn' ? 'সক্রিয়' : 'Active',
    activity: language === 'bn' ? 'কার্যকলাপ' : 'Activity',
  };

  // Handle like toggle
  const handleLike = (postId: string, currentLikes: number) => {
    const isLiked = postLikes.get(postId) || false;
    const newLikes = new Map(postLikes);
    const newCounts = new Map(postLikeCounts);
    
    newLikes.set(postId, !isLiked);
    newCounts.set(postId, isLiked ? currentLikes - 1 : currentLikes + 1);
    
    setPostLikes(newLikes);
    setPostLikeCounts(newCounts);
  };

  // Handle comment
  const handleComment = (postId: string) => {
    console.log('Comment clicked on post:', postId);
    // Open comment notification
    setTimeout(() => {
      alert(language === 'bn' ? 'মন্তব্য বৈশিষ্ট্য শীঘ্রই আসছে!' : 'Comment feature coming soon!')
    }, 100);
  };

  // Handle share menu for posts
  const handleShareMenuToggle = (postId: string) => {
    setShowShareMenu(showShareMenu === postId ? null : postId);
  };

  // Handle different share types
  const handleShareOptions = (type: string, post: any) => {
    const postUrl = `https://torko.app/group/${group.id}/post/${post.id}`;
    
    switch(type) {
      case 'copy':
        simpleCopyToClipboard(postUrl);
        break;
      case 'whatsapp':
        window.open(`https://wa.me/?text=${encodeURIComponent(post.content + ' - ' + postUrl)}`, '_blank');
        toast.success(language === 'bn' ? 'ওয়াটসঅ্যাপে শেয়ার করা হচ্ছে' : 'Sharing to WhatsApp');
        break;
      case 'facebook':
        window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(postUrl)}`, '_blank');
        toast.success(language === 'bn' ? 'ফেসবুকে শেয়ার করা হচ্ছে' : 'Sharing to Facebook');
        break;
      case 'twitter':
        window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(post.content)}&url=${encodeURIComponent(postUrl)}`, '_blank');
        toast.success(language === 'bn' ? 'এক্সে শেয়ার করা হচ্ছে' : 'Sharing to X');
        break;
    }
    setShowShareMenu(null);
  };

  // Simple clipboard copy function
  const simpleCopyToClipboard = (text: string) => {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    textArea.style.position = 'fixed';
    textArea.style.left = '-9999px';
    document.body.appendChild(textArea);
    textArea.select();
    
    try {
      const success = document.execCommand('copy');
      document.body.removeChild(textArea);
      
      if (success) {
        toast.success(language === 'bn' ? 'লিঙ্ক কপি হয়েছে!' : 'Link copied!');
      } else {
        toast.error(language === 'bn' ? 'কপি করা যায়নি' : 'Copy failed');
        // Show URL as final fallback
        prompt(language === 'bn' ? 'এই লিঙ্কটি কপি করুন:' : 'Copy this link:', text);
      }
    } catch (err) {
      document.body.removeChild(textArea);
      // Show URL in prompt for manual copy
      prompt(language === 'bn' ? 'এই লিঙ্কটি কপি করুন:' : 'Copy this link:', text);
    }
  };

  // Handle group share (header button)
  const handleShare = () => {
    const groupUrl = window.location.href;
    
    if (navigator.share) {
      navigator.share({
        title: group.name,
        text: group.description,
        url: groupUrl,
      })
      .then(() => {
        toast.success(language === 'bn' ? 'শেয়ার সফল হয়েছে!' : 'Shared successfully!');
      })
      .catch((error) => {
        if (error.name !== 'AbortError') {
          simpleCopyToClipboard(groupUrl);
        }
      });
    } else {
      simpleCopyToClipboard(groupUrl);
    }
  };

  const handleMessage = () => {
    if (onNavigate) {
      onNavigate('messages');
    }
  };

  return (
    <div 
      ref={scrollContainerRef}
      className="h-screen bg-[#FAFAFA] dark:bg-[#052029] overflow-y-auto"
    >
      <div className="max-w-auto mx-auto bg-[#FAFAFA] dark:bg-[#052029] relative pb-24 min-h-full">
        {/* Compact Header with Cover */}
        <div className="relative h-[180px]">
          {/* Cover Image with Gradient Overlay */}
          <div className="absolute inset-0">
            <img 
              src="https://images.unsplash.com/photo-1560265475-39c396aa9d53?w=800" 
              alt={group.name}
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-b from-black/40 via-black/20 to-transparent" />
          </div>
          
          {/* Top Navigation */}
          <div className="absolute top-[16px] left-0 right-0 px-[16px] flex items-center justify-between z-10">
            <button
              onClick={onBack}
              className="w-[40px] h-[40px] rounded-[12px] bg-white dark:bg-white flex items-center justify-center shadow-lg"
            >
              <svg className="w-[8px] h-[14px]" viewBox="0 0 8 14" fill="none">
                <path 
                  clipRule="evenodd" 
                  d={svgPaths.p195c4a00} 
                  fill="currentColor"
                  className="fill-[#0f1419]"
                  fillRule="evenodd" 
                />
              </svg>
            </button>

            <div className="flex gap-2">
              <button 
                onClick={handleShare}
                className="w-[40px] h-[40px] rounded-[12px] bg-white dark:bg-white flex items-center justify-center shadow-lg"
              >
                <Share2 className="w-[18px] h-[18px] text-[#0f1419]" />
              </button>
              <button 
                onClick={handleMessage}
                className="w-[40px] h-[40px] rounded-[12px] bg-white dark:bg-white flex items-center justify-center shadow-lg"
              >
                <MessageCircle className="w-[18px] h-[18px] text-[#0f1419]" />
              </button>
            </div>
          </div>
        </div>

        {/* Group Info Card - Overlapping Design */}
        <div className="px-[16px] -mt-[60px] relative z-20">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white dark:bg-[#0a2f3d] rounded-[20px] shadow-lg border border-[#EBEBEB] dark:border-[#0d3a4a] overflow-hidden"
          >
            {/* Group Name & Stats */}
            <div className="p-[20px] pb-[16px]">
              <h1 className="text-[24px] font-['Noto_Sans_Bengali',sans-serif] text-[#0f1419] dark:text-white mb-2">
                {group.name}
              </h1>
              
              {/* Quick Stats */}
              <div className="flex items-center gap-4 mb-4">
                <div className="flex items-center gap-1.5">
                  <Users className="w-[16px] h-[16px] text-[#d97757]" />
                  <span className="text-[14px] text-[#555e67] dark:text-[#9e9e9e]">
                    {group.members} {t.members}
                  </span>
                </div>
                <div className="flex items-center gap-1.5">
                  <TrendingUp className="w-[16px] h-[16px] text-[#B8DED6]" />
                  <span className="text-[14px] text-[#555e67] dark:text-[#9e9e9e]">
                    {t.active}
                  </span>
                </div>
              </div>

              {/* Join Button */}
              <button className="w-full h-[48px] rounded-[12px] bg-gradient-to-r from-[#d97757] to-[#c96647] text-white font-['Roboto:SemiBold',sans-serif] hover:from-[#c96647] hover:to-[#b85537] transition-all shadow-sm">
                {group.isJoined ? t.joined : t.join}
              </button>
            </div>

            {/* Tabs */}
            <div className="flex border-t border-[#EBEBEB] dark:border-[#0d3a4a]">
              <button
                onClick={() => setActiveTab('posts')}
                className={`flex-1 h-[48px] text-[15px] font-['Roboto:Medium',sans-serif] transition-colors relative ${
                  activeTab === 'posts'
                    ? 'text-[#d97757] dark:text-[#d97757]'
                    : 'text-[#9D9D9D] dark:text-[#666666]'
                }`}
              >
                {t.posts}
                {activeTab === 'posts' && (
                  <motion.div
                    layoutId="activeTab"
                    className="absolute bottom-0 left-0 right-0 h-[2px] bg-[#d97757]"
                  />
                )}
              </button>
              <button
                onClick={() => setActiveTab('about')}
                className={`flex-1 h-[48px] text-[15px] font-['Roboto:Medium',sans-serif] transition-colors relative ${
                  activeTab === 'about'
                    ? 'text-[#d97757] dark:text-[#d97757]'
                    : 'text-[#9D9D9D] dark:text-[#666666]'
                }`}
              >
                {t.about}
                {activeTab === 'about' && (
                  <motion.div
                    layoutId="activeTab"
                    className="absolute bottom-0 left-0 right-0 h-[2px] bg-[#d97757]"
                  />
                )}
              </button>
            </div>
          </motion.div>
        </div>

        {/* Content Area */}
        <div className="px-[16px] mt-4">
          {activeTab === 'about' ? (
            /* About Tab */
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="space-y-3"
            >
              {/* Description Card */}
              <div className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a]">
                <p className="text-[15px] text-[#555e67] dark:text-[#9e9e9e] leading-relaxed">
                  {group.description}
                </p>
              </div>

              {/* Info Cards Grid */}
              <div className="grid grid-cols-2 gap-3">
                {/* Location */}
                <div className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a]">
                  <MapPin className="w-[20px] h-[20px] text-[#B8DED6] mb-3" />
                  <p className="text-[13px] text-[#9D9D9D] mb-1">{t.location}</p>
                  <p className="text-[15px] text-[#0f1419] dark:text-white font-['Roboto:Medium',sans-serif]">
                    {language === 'bn' ? 'গুলশান' : 'Gulshan'}
                  </p>
                </div>

                {/* Privacy */}
                <div className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a]">
                  <Lock className="w-[20px] h-[20px] text-[#B8DED6] mb-3" />
                  <p className="text-[13px] text-[#9D9D9D] mb-1">
                    {language === 'bn' ? 'গোপনীয়তা' : 'Privacy'}
                  </p>
                  <p className="text-[15px] text-[#0f1419] dark:text-white font-['Roboto:Medium',sans-serif]">
                    {language === 'bn' ? 'সর্বজনীন' : 'Public'}
                  </p>
                </div>

                {/* Created */}
                <div className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a]">
                  <Calendar className="w-[20px] h-[20px] text-[#B8DED6] mb-3" />
                  <p className="text-[13px] text-[#9D9D9D] mb-1">{t.created}</p>
                  <p className="text-[15px] text-[#0f1419] dark:text-white font-['Roboto:Medium',sans-serif]">
                    {language === 'bn' ? 'জানুয়ারি ২০২৩' : 'Jan 2023'}
                  </p>
                </div>

                {/* Activity */}
                <div className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a]">
                  <TrendingUp className="w-[20px] h-[20px] text-[#B8DED6] mb-3" />
                  <p className="text-[13px] text-[#9D9D9D] mb-1">{t.activity}</p>
                  <p className="text-[15px] text-[#0f1419] dark:text-white font-['Roboto:Medium',sans-serif]">
                    {language === 'bn' ? 'খুব সক্রিয়' : 'Very Active'}
                  </p>
                </div>
              </div>
            </motion.div>
          ) : (
            /* Posts Tab */
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="space-y-3"
            >
              {posts.map((post, index) => (
                <motion.div
                  key={post.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  className="bg-white dark:bg-[#0a2f3d] rounded-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a] p-[16px] relative"
                >
                  {/* Post Header */}
                  <div className="flex items-start gap-3 mb-3">
                    <div className="relative">
                      <img 
                        src={post.avatar} 
                        alt={post.author}
                        className="w-[44px] h-[44px] rounded-full object-cover"
                      />
                      {post.verified && (
                        <div className="absolute -bottom-1 -right-1 w-[18px] h-[18px] bg-[#d97757] rounded-full flex items-center justify-center border-2 border-white dark:border-[#0a2f3d]">
                          <svg className="w-[10px] h-[10px] text-white" viewBox="0 0 20 20" fill="currentColor">
                            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                          </svg>
                        </div>
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="text-[15px] font-['Noto_Sans_Bengali',sans-serif] text-[#0f1419] dark:text-white truncate">
                        {post.author}
                      </h3>
                      <p className="text-[13px] text-[#9D9D9D]">
                        {post.time}
                      </p>
                    </div>
                    <button className="w-[32px] h-[32px] rounded-[8px] hover:bg-[#F5F5F5] dark:hover:bg-[#0d3a4a] flex items-center justify-center transition-colors">
                      <svg className="w-5 h-5 text-[#9D9D9D]" fill="currentColor" viewBox="0 0 20 20">
                        <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
                      </svg>
                    </button>
                  </div>
                  
                  {/* Post Content */}
                  <p className="text-[15px] text-[#0f1419] dark:text-white leading-relaxed mb-4">
                    {post.content}
                  </p>

                  {/* Post Actions */}
                  <div className="flex items-center gap-3 pt-3 border-t border-[#EBEBEB] dark:border-[#0d3a4a]">
                    {/* Like Button - Pill Shape */}
                    <button
                      onClick={() => handleLike(post.id, post.likes)}
                      className={`flex items-center gap-2 px-4 py-2.5 rounded-full border transition-all ${
                        postLikes.get(post.id)
                          ? 'bg-[#d97757]/10 border-[#d97757] text-[#d97757]'
                          : 'bg-[#f5f5f5] dark:bg-[#0d3a4a] border-[#e6e6e6] dark:border-[#104050] text-[#9D9D9D] hover:border-[#d97757] hover:text-[#d97757]'
                      }`}
                    >
                      {postLikes.get(post.id) ? (
                        <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
                        </svg>
                      ) : (
                        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                        </svg>
                      )}
                      <span className="font-['Roboto',sans-serif] text-[14px] font-medium">
                        {formatCount(postLikeCounts.get(post.id) || post.likes)}
                      </span>
                    </button>

                    {/* Comment Button - Pill Shape */}
                    <button
                      onClick={() => handleComment(post.id)}
                      className="flex items-center gap-2 px-4 py-2.5 rounded-full border bg-[#f5f5f5] dark:bg-[#0d3a4a] border-[#e6e6e6] dark:border-[#104050] text-[#9D9D9D] hover:border-[#B8DED6] hover:text-[#B8DED6] transition-all"
                    >
                      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                      </svg>
                      <span className="font-['Roboto',sans-serif] text-[14px] font-medium">
                        {formatCount(post.comments)}
                      </span>
                    </button>

                    {/* Share Button - Pill Shape */}
                    <button
                      onClick={() => handleShareMenuToggle(post.id)}
                      className="flex items-center gap-2 px-4 py-2.5 rounded-full border bg-[#f5f5f5] dark:bg-[#0d3a4a] border-[#e6e6e6] dark:border-[#104050] text-[#9D9D9D] hover:border-[#B8DED6] hover:text-[#B8DED6] transition-all ml-auto"
                    >
                      <Share2 className="w-5 h-5" />
                      <span className="font-['Roboto',sans-serif] text-[14px] font-medium">
                        {language === 'bn' ? 'শেয়ার' : 'Share'}
                      </span>
                    </button>
                  </div>

                  {/* Share Menu */}
                  {showShareMenu === post.id && (
                    <div ref={shareMenuRef} className="absolute right-0 top-[50px] bg-white dark:bg-[#0a2f3d] rounded-[8px] shadow-lg border border-[#EBEBEB] dark:border-[#0d3a4a] z-50">
                      <button
                        onClick={() => handleShareOptions('copy', post)}
                        className="w-full h-[40px] px-[16px] flex items-center gap-2 hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors rounded-t-[8px]"
                      >
                        <Copy className="w-[18px] h-[18px] text-[#536471]" />
                        <span className="font-['Noto_Sans_Bengali',sans-serif] text-[14px] text-[#0f1419] dark:text-white">
                          {language === 'bn' ? 'লিংক কপি করুন' : 'Copy link'}
                        </span>
                      </button>
                      <button
                        onClick={() => handleShareOptions('whatsapp', post)}
                        className="w-full h-[40px] px-[16px] flex items-center gap-2 hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors"
                      >
                        <svg className="w-[18px] h-[18px] text-[#25D366]" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                        </svg>
                        <span className="font-['Noto_Sans_Bengali',sans-serif] text-[14px] text-[#0f1419] dark:text-white">
                          WhatsApp
                        </span>
                      </button>
                      <button
                        onClick={() => handleShareOptions('facebook', post)}
                        className="w-full h-[40px] px-[16px] flex items-center gap-2 hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors"
                      >
                        <svg className="w-[18px] h-[18px] text-[#1877F2]" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                        </svg>
                        <span className="font-['Noto_Sans_Bengali',sans-serif] text-[14px] text-[#0f1419] dark:text-white">
                          Facebook
                        </span>
                      </button>
                      <button
                        onClick={() => handleShareOptions('twitter', post)}
                        className="w-full h-[40px] px-[16px] flex items-center gap-2 hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors rounded-b-[8px]"
                      >
                        <svg className="w-[18px] h-[18px] text-[#000000] dark:text-[#ffffff]" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                        </svg>
                        <span className="font-['Noto_Sans_Bengali',sans-serif] text-[14px] text-[#0f1419] dark:text-white">
                          X
                        </span>
                      </button>
                    </div>
                  )}
                </motion.div>
              ))}
            </motion.div>
          )}
        </div>
      </div>
    </div>
  );
};