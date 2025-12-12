import React, { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { X, Image as ImageIcon, MapPin, Users, Globe, Lock, ChevronDown, Sparkles } from 'lucide-react';

interface CreatePostScreenProps {
  onNavigate: (screen: string) => void;
}

type PostType = 'text' | 'image' | 'poll';
type Audience = 'public' | 'community' | 'friends';

export const CreatePostScreen: React.FC<CreatePostScreenProps> = ({ onNavigate }) => {
  const { t, language, showNotification, theme } = useApp();
  const [postContent, setPostContent] = useState('');
  const [selectedImages, setSelectedImages] = useState<string[]>([]);
  const [audience, setAudience] = useState<Audience>('public');
  const [showAudienceMenu, setShowAudienceMenu] = useState(false);
  const [location, setLocation] = useState('');
  const [category, setCategory] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  const maxChars = 500;
  const progress = (postContent.length / maxChars) * 100;

  const categories = [
    { id: 'general', label: t('general') },
    { id: 'helpNeeded', label: t('helpNeeded') },
    { id: 'event', label: t('event') },
    { id: 'forSale', label: t('forSale') },
    { id: 'news', label: t('news') },
    { id: 'question', label: t('question') },
  ];

  const audienceOptions = [
    { 
      id: 'public' as Audience, 
      label: t('everyone'),
      icon: Globe,
      desc: t('anyoneCanSee')
    },
    { 
      id: 'community' as Audience, 
      label: t('community'),
      icon: Users,
      desc: t('onlyYourCommunity')
    },
    { 
      id: 'friends' as Audience, 
      label: t('friends'),
      icon: Lock,
      desc: t('onlyFriends')
    },
  ];

  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (files) {
      const newImages = Array.from(files).map(file => URL.createObjectURL(file));
      setSelectedImages(prev => [...prev, ...newImages].slice(0, 4));
    }
  };

  const handlePost = () => {
    if (postContent.trim()) {
      const successMessage = language === 'bn' 
        ? 'আপনার পোস্ট সফলভাবে প্রকাশিত হয়েছে!'
        : 'Your post has been published successfully!';
      
      showNotification({
        type: 'success',
        message: successMessage,
        duration: 3000,
      });
      
      // Check if user came from welcome screen
      const fromWelcome = typeof window !== 'undefined' ? localStorage.getItem('torko_from_welcome') : null;
      
      if (fromWelcome === 'first_post') {
        // Mark first post task as complete
        const savedProgress = localStorage.getItem('torko_welcome_progress');
        
        if (savedProgress) {
          try {
            const progress = JSON.parse(savedProgress);
            const updatedProgress = progress.map((item: any) => 
              item.id === 'first_post' ? { ...item, completed: true } : item
            );
            localStorage.setItem('torko_welcome_progress', JSON.stringify(updatedProgress));
            console.log('✅ First post completion saved:', updatedProgress);
          } catch (e) {
            console.error('Error updating welcome progress:', e);
          }
        } else {
          // Create initial progress if doesn't exist
          const initialProgress = [
            { id: 'complete_profile', completed: true },
            { id: 'find_community', completed: true },
            { id: 'follow_people', completed: false },
            { id: 'first_post', completed: true },
          ];
          localStorage.setItem('torko_welcome_progress', JSON.stringify(initialProgress));
          console.log('✅ Created initial progress with first post complete:', initialProgress);
        }
        
        // Clear the flag and navigate back to welcome screen
        localStorage.removeItem('torko_from_welcome');
        onNavigate('welcomeProfile');
      } else {
        onNavigate('home');
      }
    }
  };

  const selectedAudience = audienceOptions.find(a => a.id === audience);

  return (
    <div className="fixed inset-0 bg-[#FAFAFA] dark:bg-[#052029] z-50">
      {/* Header */}
      <div className="bg-white dark:bg-[#0a2f3d] border-b border-[#EBEBEB] dark:border-[#0d3a4a]">
        <div className="px-[16px] h-[60px] flex items-center justify-between">
          <button
            onClick={() => onNavigate('home')}
            className="w-[40px] h-[40px] rounded-[12px] flex items-center justify-center hover:bg-[#F5F5F5] dark:hover:bg-[#104050] transition-colors"
          >
            <X className="w-[20px] h-[20px] text-[#0f1419] dark:text-white" />
          </button>
          
          <h2 className="text-[18px] font-['Noto_Sans_Bengali',sans-serif] text-[#0f1419] dark:text-white">
            {t('newPostTitle')}
          </h2>
          
          <button
            onClick={handlePost}
            disabled={!postContent.trim()}
            className="h-[40px] px-[20px] rounded-[12px] bg-gradient-to-r from-[#d97757] to-[#c96647] text-white font-['Roboto:SemiBold',sans-serif] disabled:opacity-40 disabled:cursor-not-allowed hover:from-[#c96647] hover:to-[#b85537] transition-all shadow-sm"
          >
            {t('post')}
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="h-[calc(100vh-60px)] overflow-y-auto pb-[20px]">
        <div className="px-[16px] pt-[20px] space-y-4">
          {/* User Info Card */}
          <div className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a]">
            <div className="flex items-center gap-3">
              <div className="w-[48px] h-[48px] rounded-full bg-gradient-to-br from-[#d97757] to-[#c96647] flex items-center justify-center text-white text-[18px] font-['Noto_Sans_Bengali',sans-serif]">
                আ
              </div>
              <div className="flex-1">
                <p className="text-[15px] font-['Noto_Sans_Bengali',sans-serif] text-[#0f1419] dark:text-white">
                  {t('yourName')}
                </p>
                <button
                  onClick={() => setShowAudienceMenu(!showAudienceMenu)}
                  className="flex items-center gap-1.5 text-[13px] text-[#555e67] dark:text-[#9e9e9e] hover:text-[#d97757] dark:hover:text-[#d97757] transition-colors"
                >
                  {selectedAudience && <selectedAudience.icon className="w-[14px] h-[14px]" />}
                  <span>{selectedAudience?.label}</span>
                  <ChevronDown className="w-[14px] h-[14px]" />
                </button>
              </div>
            </div>

            {/* Audience Menu */}
            <AnimatePresence>
              {showAudienceMenu && (
                <motion.div
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: 'auto' }}
                  exit={{ opacity: 0, height: 0 }}
                  className="mt-3 pt-3 border-t border-[#EBEBEB] dark:border-[#0d3a4a] space-y-2"
                >
                  {audienceOptions.map((option) => {
                    const Icon = option.icon;
                    return (
                      <button
                        key={option.id}
                        onClick={() => {
                          setAudience(option.id);
                          setShowAudienceMenu(false);
                        }}
                        className={`w-full flex items-center gap-3 p-3 rounded-[12px] transition-all ${
                          audience === option.id
                            ? 'bg-[#d97757]/10 border border-[#d97757]/30'
                            : 'hover:bg-[#F5F5F5] dark:hover:bg-[#0d3a4a]'
                        }`}
                      >
                        <div className={`w-[36px] h-[36px] rounded-[10px] flex items-center justify-center ${
                          audience === option.id
                            ? 'bg-[#d97757] text-white'
                            : 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
                        }`}>
                          <Icon className="w-[18px] h-[18px]" />
                        </div>
                        <div className="flex-1 text-left">
                          <p className={`text-[14px] font-['Roboto:Medium',sans-serif] ${
                            audience === option.id
                              ? 'text-[#d97757]'
                              : 'text-[#0f1419] dark:text-white'
                          }`}>
                            {option.label}
                          </p>
                          <p className="text-[12px] text-[#9D9D9D]">{option.desc}</p>
                        </div>
                      </button>
                    );
                  })}
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* Text Input Card */}
          <div className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a]">
            <textarea
              value={postContent}
              onChange={(e) => {
                if (e.target.value.length <= maxChars) {
                  setPostContent(e.target.value);
                }
              }}
              placeholder={t('whatsOnYourMind')}
              className="w-full min-h-[150px] bg-transparent text-[16px] text-[#0f1419] dark:text-white placeholder:text-[#9D9D9D] resize-none outline-none font-['Noto_Sans_Bengali',sans-serif]"
              autoFocus
            />
            
            {/* Character Counter with Progress Ring */}
            {postContent.length > 0 && (
              <div className="flex items-center justify-end gap-2 mt-3 pt-3 border-t border-[#EBEBEB] dark:border-[#0d3a4a]">
                <span className="text-[13px] text-[#9D9D9D]">
                  {postContent.length}/{maxChars}
                </span>
                <svg className="w-[24px] h-[24px] -rotate-90">
                  <circle
                    cx="12"
                    cy="12"
                    r="10"
                    fill="none"
                    stroke="#EBEBEB"
                    strokeWidth="2"
                  />
                  <circle
                    cx="12"
                    cy="12"
                    r="10"
                    fill="none"
                    stroke={progress > 90 ? '#e74c3c' : '#d97757'}
                    strokeWidth="2"
                    strokeDasharray={`${2 * Math.PI * 10}`}
                    strokeDashoffset={`${2 * Math.PI * 10 * (1 - progress / 100)}`}
                    className="transition-all duration-300"
                  />
                </svg>
              </div>
            )}
          </div>

          {/* Image Grid */}
          <AnimatePresence>
            {selectedImages.length > 0 && (
              <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }}
                className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[12px] border border-[#EBEBEB] dark:border-[#0d3a4a]"
              >
                <div className={`grid gap-2 ${
                  selectedImages.length === 1 ? 'grid-cols-1' :
                  selectedImages.length === 2 ? 'grid-cols-2' :
                  selectedImages.length === 3 ? 'grid-cols-3' :
                  'grid-cols-2'
                }`}>
                  {selectedImages.map((img, idx) => (
                    <motion.div
                      key={idx}
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: idx * 0.1 }}
                      className="relative aspect-square rounded-[12px] overflow-hidden group"
                    >
                      <img src={img} alt="" className="w-full h-full object-cover" />
                      <button
                        onClick={() => setSelectedImages(prev => prev.filter((_, i) => i !== idx))}
                        className="absolute top-2 right-2 w-[28px] h-[28px] rounded-full bg-black/60 backdrop-blur-sm flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                      >
                        <X className="w-[16px] h-[16px] text-white" />
                      </button>
                    </motion.div>
                  ))}
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Categories */}
          <div className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a]">
            <div className="flex items-center gap-2 mb-3">
              <Sparkles className="w-[16px] h-[16px] text-[#d97757]" />
              <p className="text-[14px] font-['Roboto:Medium',sans-serif] text-[#0f1419] dark:text-white">
                {t('category')}
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              {categories.map((cat) => (
                <button
                  key={cat.id}
                  onClick={() => setCategory(category === cat.id ? '' : cat.id)}
                  className={`h-[36px] px-[16px] rounded-full text-[13px] font-['Noto_Sans_Bengali',sans-serif] transition-all ${
                    category === cat.id
                      ? 'bg-gradient-to-r from-[#d97757] to-[#c96647] text-white shadow-sm'
                      : 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e] hover:bg-[#EBEBEB] dark:hover:bg-[#104050]'
                  }`}
                >
                  {cat.label}
                </button>
              ))}
            </div>
          </div>

          {/* Location Card */}
          {location && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[16px] border border-[#EBEBEB] dark:border-[#0d3a4a]"
            >
              <div className="flex items-center gap-3">
                <div className="w-[40px] h-[40px] rounded-[12px] bg-[#B8DED6]/20 flex items-center justify-center">
                  <MapPin className="w-[18px] h-[18px] text-[#B8DED6]" />
                </div>
                <div className="flex-1">
                  <p className="text-[13px] text-[#9D9D9D]">
                    {t('location')}
                  </p>
                  <p className="text-[15px] text-[#0f1419] dark:text-white font-['Noto_Sans_Bengali',sans-serif]">
                    {location}
                  </p>
                </div>
                <button
                  onClick={() => setLocation('')}
                  className="w-[32px] h-[32px] rounded-full hover:bg-[#F5F5F5] dark:hover:bg-[#104050] flex items-center justify-center"
                >
                  <X className="w-[16px] h-[16px] text-[#9D9D9D]" />
                </button>
              </div>
            </motion.div>
          )}

          {/* Actions Bar */}
          <div className="bg-white dark:bg-[#0a2f3d] rounded-[16px] p-[12px] border border-[#EBEBEB] dark:border-[#0d3a4a]">
            <div className="flex items-center gap-2">
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                multiple
                onChange={handleImageSelect}
                className="hidden"
              />
              
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => fileInputRef.current?.click()}
                className="flex-1 h-[48px] rounded-[12px] bg-[#d97757]/10 hover:bg-[#d97757]/20 flex items-center justify-center gap-2 transition-colors group"
              >
                <ImageIcon className="w-[18px] h-[18px] text-[#d97757]" />
                <span className="text-[14px] font-['Roboto:Medium',sans-serif] text-[#d97757]">
                  {t('photo')}
                </span>
              </motion.button>

              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setLocation(location ? '' : (language === 'bn' ? 'গুলশান, ঢাকা' : 'Gulshan, Dhaka'))}
                className={`flex-1 h-[48px] rounded-[12px] flex items-center justify-center gap-2 transition-colors ${
                  location
                    ? 'bg-[#B8DED6]/20 hover:bg-[#B8DED6]/30'
                    : 'bg-[#B8DED6]/10 hover:bg-[#B8DED6]/20'
                }`}
              >
                <MapPin className={`w-[18px] h-[18px] ${location ? 'text-[#B8DED6]' : 'text-[#B8DED6]'}`} />
                <span className="text-[14px] font-['Roboto:Medium',sans-serif] text-[#B8DED6]">
                  {t('location')}
                </span>
              </motion.button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};