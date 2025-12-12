import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { useApp } from './contexts/AppContext';
import svgPaths from '../imports/svg-r218mbjjro';
import { X, Search, Home, MessageCircle, Bell, User, Settings, LogOut, TrendingUp, Users, Hash, Bookmark, Plus, MoreVertical, ArrowLeft, Moon, Sun, Globe, Archive, Star, Trash2 } from 'lucide-react';
import torkoLogoLight from 'figma:asset/9246639333a6633f8b19602c38369e20423e5b1f.png';
import torkoLogoDark from 'figma:asset/3987d93a1615b2091fddb961a1ee353e7e4dd6b2.png';

interface MessagesHeaderProps {
  onNavigate: (screen: string) => void;
  onSearchChange?: (query: string) => void;
}

export const MessagesHeader: React.FC<MessagesHeaderProps> = ({ onNavigate, onSearchChange }) => {
  const { language, theme, toggleTheme, toggleLanguage } = useApp();
  const [menuOpen, setMenuOpen] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [moreMenuOpen, setMoreMenuOpen] = useState(false);
  const moreMenuRef = useRef<HTMLDivElement>(null);

  // Close more menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (moreMenuRef.current && !moreMenuRef.current.contains(event.target as Node)) {
        setMoreMenuOpen(false);
      }
    };

    if (moreMenuOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [moreMenuOpen]);

  // Menu items for sidebar
  const menuItems = [
    { icon: Home, label: language === 'bn' ? 'হোম' : 'Home', action: () => onNavigate('home') },
    { icon: TrendingUp, label: language === 'bn' ? 'ট্রেন্ডিং' : 'Trending', action: () => onNavigate('home') },
    { icon: Users, label: language === 'bn' ? 'কমিউনিটি' : 'Communities', action: () => console.log('Communities') },
    { icon: Hash, label: language === 'bn' ? 'হ্যাশট্যাগ' : 'Hashtags', action: () => console.log('Hashtags') },
    { icon: Bookmark, label: language === 'bn' ? 'সেভ করা' : 'Saved', action: () => console.log('Saved') },
    { icon: MessageCircle, label: language === 'bn' ? 'মেসেজ' : 'Messages', action: () => onNavigate('messages') },
    { icon: Bell, label: language === 'bn' ? 'বিজ্ঞপ্তি' : 'Notifications', action: () => onNavigate('notifications') },
    { icon: User, label: language === 'bn' ? 'প্রোফাইল' : 'Profile', action: () => onNavigate('profile') },
    { icon: Settings, label: language === 'bn' ? 'সেটিংস' : 'Settings', action: () => onNavigate('settings') },
  ];

  // Mock recent searches for messages
  const recentSearches = [
    language === 'bn' ? 'রহিম আহমেদ' : 'Rahim Ahmed',
    language === 'bn' ? 'ঢাকা কমিউনিটি' : 'Dhaka Community',
    language === 'bn' ? 'করিম খান' : 'Karim Khan',
    language === 'bn' ? 'সাবিনা রহমান' : 'Sabina Rahman',
    language === 'bn' ? 'চট্টগ্রাম গ্রুপ' : 'Chittagong Group',
  ];

  const handleMenuItemClick = (action: () => void) => {
    action();
    setMenuOpen(false);
  };

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      console.log('Searching for:', searchQuery);
      setSearchOpen(false);
      setSearchQuery('');
      if (onSearchChange) {
        onSearchChange(searchQuery);
      }
    }
  };

  return (
    <>
      <div className="relative w-full h-[55px] px-[16px] flex items-center justify-between bg-[rgb(255,255,255)] dark:bg-background pt-[39px] pb-[40px] pr-[16px] pl-[16px] py-[40px]">
        {/* Back Button */}
        <button 
          onClick={() => window.history.back()}
          className="flex items-center justify-center w-[23px] h-[23px] hover:opacity-70 transition-opacity p-[0px] mt-[12px] mr-[0px] mb-[0px] ml-[0px]"
        >
          <ArrowLeft className="w-6 h-6 text-foreground" />
        </button>

        {/* LOGO */}
        <div className="absolute left-[12%] h-[40px] flex items-center gap-2">
          {/* Chat Text */}
          <span className="text-foreground flex items-center" style={{ fontSize: '18px', fontWeight: '600', lineHeight: '1' }}>
            {language === 'bn' ? 'চ্যাট' : 'Chat'}
          </span>
        </div>

        {/* Right Side - Search, Plus and More options */}
        <div className="relative flex items-center gap-2">
          {/* Search Icon */}
          <button 
            onClick={() => setSearchOpen(true)}
            className="bg-neutral-50 dark:bg-[#0a2f3d] h-[40px] w-[40px] rounded-full flex items-center justify-center hover:opacity-70 transition-opacity"
          >
            <Search className="w-5 h-5 text-muted-foreground" />
          </button>

          {/* More Options Icon */}
          <button 
            onClick={() => setMoreMenuOpen(!moreMenuOpen)}
            className="bg-neutral-50 dark:bg-[#0a2f3d] h-[40px] w-[40px] rounded-full flex items-center justify-center hover:opacity-70 transition-opacity"
          >
            <MoreVertical className="w-5 h-5 text-muted-foreground" />
          </button>

          {/* More Options Menu */}
          {moreMenuOpen && (
            <motion.div 
              initial={{ opacity: 0, scale: 0.95, y: -10 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: -10 }}
              transition={{ duration: 0.15 }}
              className="absolute right-0 top-12 bg-background border border-border rounded-2xl shadow-xl z-50 overflow-hidden"
              ref={moreMenuRef}
              style={{ minWidth: '220px' }}
            >
              <div className="py-1.5">
                {/* Theme Toggle */}
                <button
                  onClick={() => {
                    toggleTheme();
                    setMoreMenuOpen(false);
                  }}
                  className="w-full flex items-center gap-3 px-4 py-3 hover:bg-muted/50 transition-colors text-left"
                >
                  {theme === 'dark' ? (
                    <Sun className="w-5 h-5 text-muted-foreground" />
                  ) : (
                    <Moon className="w-5 h-5 text-muted-foreground" />
                  )}
                  <span className="text-foreground" style={{ fontSize: '14.5px', fontWeight: '500' }}>
                    {language === 'bn' 
                      ? (theme === 'dark' ? 'লাইট মোড' : 'ডার্ক মোড')
                      : (theme === 'dark' ? 'Light Mode' : 'Dark Mode')
                    }
                  </span>
                </button>

                {/* Language Toggle */}
                <button
                  onClick={() => {
                    toggleLanguage();
                    setMoreMenuOpen(false);
                  }}
                  className="w-full flex items-center gap-3 px-4 py-3 hover:bg-muted/50 transition-colors text-left"
                >
                  <Globe className="w-5 h-5 text-muted-foreground" />
                  <span className="text-foreground" style={{ fontSize: '14.5px', fontWeight: '500' }}>
                    {language === 'bn' ? 'English' : 'বাংলা'}
                  </span>
                </button>

                <div className="h-px bg-border my-1.5" />

                {/* Archive Chats */}
                <button
                  onClick={() => {
                    console.log('Archive chats');
                    setMoreMenuOpen(false);
                  }}
                  className="w-full flex items-center gap-3 px-4 py-3 hover:bg-muted/50 transition-colors text-left"
                >
                  <Archive className="w-5 h-5 text-muted-foreground" />
                  <span className="text-foreground" style={{ fontSize: '14.5px', fontWeight: '500' }}>
                    {language === 'bn' ? 'আর্কাইভ' : 'Archived'}
                  </span>
                </button>

                {/* Starred Messages */}
                <button
                  onClick={() => {
                    console.log('Starred messages');
                    setMoreMenuOpen(false);
                  }}
                  className="w-full flex items-center gap-3 px-4 py-3 hover:bg-muted/50 transition-colors text-left"
                >
                  <Star className="w-5 h-5 text-muted-foreground" />
                  <span className="text-foreground" style={{ fontSize: '14.5px', fontWeight: '500' }}>
                    {language === 'bn' ? 'স্টার করা' : 'Starred'}
                  </span>
                </button>

                {/* Settings */}
                <button
                  onClick={() => {
                    onNavigate('settings');
                    setMoreMenuOpen(false);
                  }}
                  className="w-full flex items-center gap-3 px-4 py-3 hover:bg-muted/50 transition-colors text-left"
                >
                  <Settings className="w-5 h-5 text-muted-foreground" />
                  <span className="text-foreground" style={{ fontSize: '14.5px', fontWeight: '500' }}>
                    {language === 'bn' ? 'সেটিংস' : 'Settings'}
                  </span>
                </button>
              </div>
            </motion.div>
          )}
        </div>
      </div>

      {/* Left Sidebar Menu */}
      <AnimatePresence>
        {menuOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.2 }}
              className="fixed inset-0 bg-black/50 z-[55]"
              onClick={() => setMenuOpen(false)}
            />

            {/* Sidebar */}
            <motion.div
              initial={{ x: '-100%' }}
              animate={{ x: 0 }}
              exit={{ x: '-100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              className="fixed top-0 left-0 bottom-0 w-[280px] bg-background border-r border-border z-[70] overflow-y-auto"
            >
              {/* Header */}
              <div className="flex items-center justify-between p-5 border-b border-border">
                <h2 className="text-xl text-foreground" style={{ fontWeight: '700' }}>
                  {language === 'bn' ? 'মেনু' : 'Menu'}
                </h2>
                <button
                  onClick={() => setMenuOpen(false)}
                  className="p-2 hover:bg-muted rounded-full transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              {/* User Info Section */}
              <div className="p-5 border-b border-border">
                <div className="flex items-center gap-3">
                  <div 
                    className="w-12 h-12 rounded-full bg-accent flex items-center justify-center text-white"
                    style={{ fontSize: '18px', fontWeight: '600' }}
                  >
                    {language === 'bn' ? 'আ' : 'U'}
                  </div>
                  <div>
                    <p className="text-foreground" style={{ fontSize: '16px', fontWeight: '600' }}>
                      {language === 'bn' ? 'আপনার নাম' : 'Your Name'}
                    </p>
                    <p className="text-muted-foreground" style={{ fontSize: '13px' }}>
                      @username
                    </p>
                  </div>
                </div>
              </div>

              {/* Menu Items */}
              <nav className="py-2">
                {menuItems.map((item, index) => (
                  <button
                    key={index}
                    onClick={() => handleMenuItemClick(item.action)}
                    className="w-full flex items-center gap-3 px-5 py-3.5 hover:bg-muted/50 transition-colors text-left"
                  >
                    <item.icon className="w-5 h-5 text-muted-foreground" />
                    <span className="text-foreground" style={{ fontSize: '15px', fontWeight: '500' }}>
                      {item.label}
                    </span>
                  </button>
                ))}
              </nav>

              {/* Logout */}
              <div className="border-t border-border mt-2 pb-6">
                <button
                  onClick={() => {
                    console.log('Logout');
                    setMenuOpen(false);
                  }}
                  className="w-full flex items-center gap-3 px-5 py-3.5 hover:bg-red-50 dark:hover:bg-red-950/20 transition-colors text-left text-red-600"
                >
                  <LogOut className="w-5 h-5" />
                  <span style={{ fontSize: '15px', fontWeight: '500' }}>
                    {language === 'bn' ? 'লগ আউট' : 'Logout'}
                  </span>
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Search Dialog */}
      <AnimatePresence>
        {searchOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.2 }}
              className="fixed inset-0 bg-black/50 z-40"
              onClick={() => setSearchOpen(false)}
            />

            {/* Search Dialog */}
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: -20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: -20 }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              className="fixed top-20 left-1/2 -translate-x-1/2 w-[90%] max-w-[600px] bg-background rounded-2xl shadow-2xl z-50 overflow-hidden"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Search Header */}
              <div className="flex items-center gap-3 p-4 border-b border-border">
                <Search className="w-5 h-5 text-muted-foreground" />
                <form onSubmit={handleSearchSubmit} className="flex-1">
                  <input
                    type="text"
                    placeholder={language === 'bn' ? 'মেসেজ বা নাম খুঁজুন...' : 'Search messages or names...'}
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    autoFocus
                    className="w-full bg-transparent border-none outline-none text-foreground placeholder:text-muted-foreground"
                    style={{ fontSize: '16px' }}
                  />
                </form>
                <button
                  onClick={() => setSearchOpen(false)}
                  className="p-2 hover:bg-muted rounded-full transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              {/* Search Content */}
              <div className="max-h-[400px] overflow-y-auto">
                {/* Recent Searches */}
                <div className="p-4">
                  <h3 className="text-muted-foreground mb-3" style={{ fontSize: '13px', fontWeight: '600', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                    {language === 'bn' ? 'সাম্প্রতিক সার্চ' : 'Recent Searches'}
                  </h3>
                  <div className="space-y-1">
                    {recentSearches.map((term, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          setSearchQuery(term);
                          console.log('Search recent:', term);
                        }}
                        className="w-full flex items-center gap-3 p-3 hover:bg-muted/50 rounded-xl transition-colors text-left"
                      >
                        <MessageCircle className="w-4 h-4 text-accent" />
                        <span className="text-foreground" style={{ fontSize: '15px' }}>
                          {term}
                        </span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Search Results (when query exists) */}
                {searchQuery.trim() && (
                  <div className="p-4 border-t border-border">
                    <h3 className="text-muted-foreground mb-3" style={{ fontSize: '13px', fontWeight: '600', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                      {language === 'bn' ? 'ফলাফল' : 'Results'}
                    </h3>
                    <p className="text-center text-muted-foreground py-8" style={{ fontSize: '14px' }}>
                      {language === 'bn' ? `"${searchQuery}" এর জন্য কোন ফলাফল নেই` : `No results for "${searchQuery}"`}
                    </p>
                  </div>
                )}
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
};