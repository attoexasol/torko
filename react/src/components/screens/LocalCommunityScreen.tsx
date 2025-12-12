import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { ArrowLeft, MapPin, List, Map, Heart, MessageCircle, Share2, AlertCircle, TrendingUp, CheckCircle, Clock, MoreVertical } from 'lucide-react';

interface LocalCommunityScreenProps {
  onNavigate: (screen: string) => void;
}

interface Post {
  id: string;
  author: string;
  authorInitials: string;
  authorColor: string;
  time: string;
  location: string;
  content: string;
  badge?: {
    text: string;
    textBn: string;
    color: string;
    bgColor: string;
  };
  likes: number;
  comments: number;
  shares?: number;
  verified?: boolean;
}

export const LocalCommunityScreen: React.FC<LocalCommunityScreenProps> = ({ onNavigate }) => {
  const { language, theme } = useApp();
  const [activeFilter, setActiveFilter] = useState('সব');
  const [viewMode, setViewMode] = useState<'list' | 'map'>('list');
  const [selectedLocation, setSelectedLocation] = useState('চট্টগ্রাম');

  const filters = [
    { id: 'all', labelBn: 'সব', labelEn: 'All' },
    { id: 'district', labelBn: 'আমার জেলা', labelEn: 'My District' },
    { id: 'nearby', labelBn: 'আমার কাছে', labelEn: 'Near Me' },
  ];

  const posts: Post[] = [
    {
      id: '1',
      author: language === 'bn' ? 'সুফিয়া আহমাদ' : 'Sufia Ahmad',
      authorInitials: 'সু',
      authorColor: '#d97757',
      time: language === 'bn' ? '৩৮ মিনিট আগে' : '38 minutes ago',
      location: language === 'bn' ? 'পতেঙ্গা, ঢাকা' : 'Potenga, Dhaka',
      content: language === 'bn' 
        ? 'কেউ কি জানেন আজ রাত ৮টায় কেন বিদ্যুৎ চলে গেলো আজকে? চলবে ভাবছি অনেকক্ষণ ধরেই!'
        : 'Does anyone know why the power went out at 8 PM today? Been out for quite a while!',
      badge: {
        text: 'Alert',
        textBn: 'সতর্কতা',
        color: '#ff3b30',
        bgColor: 'rgba(255, 59, 48, 0.15)',
      },
      likes: 12,
      comments: 8,
      shares: 0,
    },
    {
      id: '2',
      author: language === 'bn' ? 'মেহেদী হাসান' : 'Mehedi Hasan',
      authorInitials: 'মে',
      authorColor: '#6B9BD1',
      time: language === 'bn' ? '৬ ঘন্টা আগে' : '6 hours ago',
      location: language === 'bn' ? 'কদমতলী, ঢাকা' : 'Kadamtoli, Dhaka',
      content: language === 'bn'
        ? 'এখানকার বিদ্যুৎ চলে গেছে। কেউ জানেন কতক্ষণ লাগবে?'
        : 'Power went out here. Does anyone know how long it will take?',
      badge: {
        text: 'Popular',
        textBn: 'জনপ্রিয়',
        color: '#ff9500',
        bgColor: 'rgba(255, 149, 0, 0.15)',
      },
      likes: 0,
      comments: 0,
      shares: 0,
      verified: true,
    },
  ];

  return (
    <div className={`fixed inset-0 flex flex-col ${theme === 'dark' ? 'bg-[#1c1c1e]' : 'bg-[#f5f5f5]'}`}>
      {/* Header */}
      <header className={`px-4 pt-3 pb-4 border-b ${
        theme === 'dark' ? 'bg-[#1c1c1e] border-[rgba(255,255,255,0.1)]' : 'bg-white border-[rgba(44,44,46,0.12)]'
      }`}>
        <div className="flex items-center justify-between mb-2">
          <button
            onClick={() => onNavigate('home')}
            className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-muted/80 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          
          <div className="flex-1 flex items-center justify-center gap-2">
            <h1
              className={theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}
              style={{
                fontSize: '20px',
                fontWeight: '600',
                lineHeight: '1.3',
              }}
            >
              {language === 'bn' ? 'স্থানীয় কমিউনিটি' : 'Local Community'}
            </h1>
            <span
              className="px-2.5 py-1 rounded-full text-white"
              style={{
                backgroundColor: '#d97757',
                fontSize: '12px',
                fontWeight: '500',
              }}
            >
              {language === 'bn' ? '৫ জেলা' : '5 Districts'}
            </span>
          </div>

          <div className="w-10" />
        </div>

        <p
          className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
          style={{
            fontSize: '13px',
            textAlign: 'center',
            opacity: 0.8,
          }}
        >
          {language === 'bn' ? 'আশেপাশের এলাকায় সাম্প্রতিক পোস্ট' : 'Recent posts in your area'}
        </p>
      </header>

      {/* Filter Chips */}
      <div className={`px-4 py-3 border-b ${
        theme === 'dark' ? 'bg-[#1c1c1e] border-[rgba(255,255,255,0.1)]' : 'bg-[#f5f5f5] border-[rgba(44,44,46,0.12)]'
      }`}>
        <div className="flex gap-2 overflow-x-auto scrollbar-hide">
          {filters.map((filter) => {
            const label = language === 'bn' ? filter.labelBn : filter.labelEn;
            const isActive = activeFilter === label;

            return (
              <button
                key={filter.id}
                onClick={() => setActiveFilter(label)}
                className={`flex-shrink-0 px-4 h-9 rounded-full transition-all ${
                  isActive
                    ? 'bg-[#d97757] text-white'
                    : theme === 'dark'
                    ? 'bg-[#2c2c2e] text-[#f5f5f5] hover:bg-[#363638]'
                    : 'bg-white text-[#2c2c2e] hover:bg-[#ebebeb]'
                }`}
                style={{
                  fontSize: '14px',
                  fontWeight: '500',
                }}
              >
                {label}
              </button>
            );
          })}
        </div>
      </div>

      {/* View Mode Buttons */}
      <div className={`px-4 py-3 flex gap-2 ${
        theme === 'dark' ? 'bg-[#1c1c1e]' : 'bg-[#f5f5f5]'
      }`}>
        <button
          onClick={() => setViewMode('list')}
          className={`flex-1 h-10 rounded-xl flex items-center justify-center gap-2 transition-all ${
            viewMode === 'list'
              ? theme === 'dark'
                ? 'bg-[#2c2c2e] text-[#f5f5f5]'
                : 'bg-white text-[#2c2c2e]'
              : theme === 'dark'
              ? 'bg-transparent text-[#9b9b9b]'
              : 'bg-transparent text-[#6b6b6b]'
          }`}
          style={{
            fontSize: '14px',
            fontWeight: '500',
          }}
        >
          <List className="w-4 h-4" />
          {language === 'bn' ? 'তালিকা' : 'List'}
        </button>
        
        <button
          onClick={() => setViewMode('map')}
          className={`flex-1 h-10 rounded-xl flex items-center justify-center gap-2 transition-all ${
            viewMode === 'map'
              ? theme === 'dark'
                ? 'bg-[#2c2c2e] text-[#f5f5f5]'
                : 'bg-white text-[#2c2c2e]'
              : theme === 'dark'
              ? 'bg-transparent text-[#9b9b9b]'
              : 'bg-transparent text-[#6b6b6b]'
          }`}
          style={{
            fontSize: '14px',
            fontWeight: '500',
          }}
        >
          <Map className="w-4 h-4" />
          {language === 'bn' ? 'ম্যাপভিউ' : 'Map View'}
        </button>
      </div>

      {/* Location Selector */}
      <div className="px-4 pb-3">
        <div
          className={`rounded-2xl p-4 flex items-center justify-between ${
            theme === 'dark' ? 'bg-[#2c2c2e]' : 'bg-white'
          }`}
          style={{
            boxShadow: theme === 'dark'
              ? '0 2px 8px rgba(0, 0, 0, 0.2)'
              : '0 2px 8px rgba(0, 0, 0, 0.06)',
          }}
        >
          <div className="flex items-center gap-3">
            <div
              className="w-12 h-12 rounded-full flex items-center justify-center"
              style={{
                backgroundColor: 'rgba(217, 119, 87, 0.15)',
              }}
            >
              <MapPin className="w-5 h-5" style={{ color: '#d97757' }} />
            </div>
            <div>
              <h3
                className={theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}
                style={{
                  fontSize: '17px',
                  fontWeight: '600',
                  lineHeight: '1.3',
                }}
              >
                {selectedLocation}
              </h3>
              <p
                className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                style={{
                  fontSize: '13px',
                  marginTop: '2px',
                }}
              >
                {language === 'bn' ? '৩ কিমি এর মধ্যে' : 'Within 3 km'}
              </p>
            </div>
          </div>

          <span
            className="px-3 py-1.5 rounded-full"
            style={{
              backgroundColor: 'rgba(217, 119, 87, 0.15)',
              color: '#d97757',
              fontSize: '12px',
              fontWeight: '500',
            }}
          >
            {language === 'bn' ? 'পরিবর্তন করুন' : 'Change'}
          </span>
        </div>
      </div>

      {/* Posts List */}
      <div className="flex-1 overflow-y-auto px-4 pb-24 space-y-3">
        {posts.map((post, index) => (
          <motion.div
            key={post.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1, duration: 0.3 }}
            className={`rounded-2xl p-4 ${
              theme === 'dark' ? 'bg-[#2c2c2e]' : 'bg-white'
            }`}
            style={{
              boxShadow: theme === 'dark'
                ? '0 2px 8px rgba(0, 0, 0, 0.2)'
                : '0 2px 8px rgba(0, 0, 0, 0.06)',
            }}
          >
            {/* Author Header */}
            <div className="flex items-start gap-3 mb-3">
              <div
                className="flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center text-white"
                style={{
                  backgroundColor: post.authorColor,
                  fontSize: '14px',
                  fontWeight: '600',
                }}
              >
                {post.authorInitials}
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <h3
                    className={theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}
                    style={{
                      fontSize: '15px',
                      fontWeight: '600',
                      lineHeight: '1.3',
                    }}
                  >
                    {post.author}
                  </h3>
                  {post.verified && (
                    <CheckCircle className="w-4 h-4" style={{ color: '#d97757' }} />
                  )}
                  <span
                    className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                    style={{
                      fontSize: '13px',
                    }}
                  >
                    • {post.time}
                  </span>
                </div>

                <div className="flex items-center gap-1.5">
                  <MapPin className={`w-3.5 h-3.5 ${theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}`} />
                  <span
                    className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                    style={{
                      fontSize: '13px',
                    }}
                  >
                    {post.location}
                  </span>
                </div>
              </div>

              {post.badge && (
                <span
                  className="px-2.5 py-1 rounded-full flex-shrink-0"
                  style={{
                    backgroundColor: post.badge.bgColor,
                    color: post.badge.color,
                    fontSize: '12px',
                    fontWeight: '500',
                  }}
                >
                  {language === 'bn' ? post.badge.textBn : post.badge.text}
                </span>
              )}
            </div>

            {/* Post Content */}
            <p
              className={theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}
              style={{
                fontSize: '15px',
                lineHeight: '1.5',
                marginBottom: '12px',
              }}
            >
              {post.content}
            </p>

            {/* Metrics Row */}
            <div className="flex items-center gap-4 pt-3 border-t" style={{
              borderColor: theme === 'dark' ? 'rgba(255,255,255,0.08)' : 'rgba(44,44,46,0.08)',
            }}>
              <button className="flex items-center gap-1.5 hover:opacity-70 transition-opacity">
                <Heart className="w-4.5 h-4.5" style={{ color: '#9b9b9b' }} />
                <span
                  className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                  style={{
                    fontSize: '14px',
                    fontWeight: '500',
                  }}
                >
                  {post.likes}
                </span>
              </button>

              <button className="flex items-center gap-1.5 hover:opacity-70 transition-opacity">
                <MessageCircle className="w-4.5 h-4.5" style={{ color: '#9b9b9b' }} />
                <span
                  className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                  style={{
                    fontSize: '14px',
                    fontWeight: '500',
                  }}
                >
                  {post.comments}
                </span>
              </button>

              <button className="flex items-center gap-1.5 ml-auto hover:opacity-70 transition-opacity">
                <Share2 className="w-4.5 h-4.5" style={{ color: '#9b9b9b' }} />
                <span
                  className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                  style={{
                    fontSize: '14px',
                    fontWeight: '500',
                  }}
                >
                  {language === 'bn' ? 'শেয়ার' : 'Share'}
                </span>
              </button>
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  );
};