import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { useApp } from './contexts/AppContext';
import svgPaths from '../imports/svg-r218mbjjro';
import { X, Search, Home, MessageCircle, Bell, User, Settings, LogOut, TrendingUp, Users, Hash, Bookmark } from 'lucide-react';
import torkoLogo from 'figma:asset/54b40a5db169e3bbfb66dd47ad9182426b12a2e8.png';

interface HomeHeaderProps {
  onNavigate: (screen: string) => void;
}

export const HomeHeader: React.FC<HomeHeaderProps> = ({ onNavigate }) => {
  const { language, theme } = useApp();
  const [menuOpen, setMenuOpen] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [notificationOpen, setNotificationOpen] = useState(false);
  const [unreadCount, setUnreadCount] = useState(5); // Mock unread count

  // Menu items for sidebar
  const menuItems = [
    { icon: Home, label: language === 'bn' ? 'হোম' : 'Home', action: () => onNavigate('home') },
    { icon: Users, label: language === 'bn' ? 'লোকাল কমিউনিটি' : 'Local Community', action: () => onNavigate('localCommunity') },
    { icon: Bookmark, label: language === 'bn' ? 'সেভ করা' : 'Saved', action: () => console.log('Saved') },
    { icon: MessageCircle, label: language === 'bn' ? 'মেসেজ' : 'Messages', action: () => onNavigate('messages') },
    { icon: Bell, label: language === 'bn' ? 'বিজ্ঞপ্তি' : 'Notifications', action: () => onNavigate('notifications') },
    { icon: User, label: language === 'bn' ? 'প্রোফাইল' : 'Profile', action: () => onNavigate('profile') },
    { icon: Settings, label: language === 'bn' ? 'সেটিংস' : 'Settings', action: () => onNavigate('settings') },
  ];

  // Mock trending searches
  const trendingSearches = [
    language === 'bn' ? 'ঢাকা ট্রাফিক' : 'Dhaka Traffic',
    language === 'bn' ? 'বাংলাদেশ ক্রিকেট' : 'Bangladesh Cricket',
    language === 'bn' ? 'টেক স্টার্টআপ' : 'Tech Startup',
    language === 'bn' ? 'রমজান ২০২৫' : 'Ramadan 2025',
    language === 'bn' ? 'চট্টগ্রাম ইভেন্ট' : 'Chittagong Events',
  ];

  // Mock notifications
  const mockNotifications = [
    {
      id: 1,
      type: 'like',
      user: language === 'bn' ? 'আহমেদ রহমান' : 'Ahmed Rahman',
      action: language === 'bn' ? 'আপনার পোস্ট লাইক করেছে' : 'liked your post',
      time: language === 'bn' ? '৫ মিনিট আগে' : '5 min ago',
      unread: true,
      avatar: '🙂',
    },
    {
      id: 2,
      type: 'comment',
      user: language === 'bn' ? 'ফাতিমা খান' : 'Fatima Khan',
      action: language === 'bn' ? 'আপনার পোস্টে মন্তব্য করেছে' : 'commented on your post',
      time: language === 'bn' ? '১৫ মিনিট আগে' : '15 min ago',
      unread: true,
      avatar: '👩',
    },
    {
      id: 3,
      type: 'follow',
      user: language === 'bn' ? 'মাহমুদ হাসান' : 'Mahmud Hasan',
      action: language === 'bn' ? 'আপনাকে ফলো করতে শুরু করেছে' : 'started following you',
      time: language === 'bn' ? '১ ঘণ্টা আগে' : '1 hour ago',
      unread: true,
      avatar: '👨',
    },
    {
      id: 4,
      type: 'message',
      user: language === 'bn' ? 'নাফিসা আক্তার' : 'Nafisa Akter',
      action: language === 'bn' ? 'আপনাকে একটি মেসেজ পাঠিয়েছে' : 'sent you a message',
      time: language === 'bn' ? '২ ঘণ্টা আগে' : '2 hours ago',
      unread: false,
      avatar: '👩‍💼',
    },
    {
      id: 5,
      type: 'like',
      user: language === 'bn' ? 'রাকিব ইসলাম' : 'Rakib Islam',
      action: language === 'bn' ? 'আপনার মন্তব্য লাইক করেছে' : 'liked your comment',
      time: language === 'bn' ? '৩ ঘণ্টা আগে' : '3 hours ago',
      unread: false,
      avatar: '🧑',
    },
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
    }
  };

  const handleNotificationClick = (notificationId: number) => {
    // Mark as read and navigate
    console.log('Notification clicked:', notificationId);
    setNotificationOpen(false);
    setUnreadCount(prev => Math.max(0, prev - 1));
  };

  const handleMarkAllAsRead = () => {
    setUnreadCount(0);
  };

  return (
    <>
      <div className="relative w-full h-[55px] px-[16px] flex items-center justify-between bg-white dark:bg-[#052029] pt-[39px] pb-[40px] pr-[16px] pl-[16px] py-[40px]">
        {/* LOGO - Clickable to open menu */}
        <button 
          onClick={() => setMenuOpen(true)}
          className="h-[50px] flex items-center hover:opacity-70 transition-opacity"
        >
          {/* Light mode logo */}
          <img 
            src={torkoLogo} 
            alt="Torko" 
            className="h-[45px] w-auto object-contain block dark:hidden"
          />
          {/* Dark mode logo */}
          <img 
            src={torkoLogo} 
            alt="Torko" 
            className="h-[45px] w-auto object-contain hidden dark:block"
          />
        </button>

        {/* Right Side - Search, Message and Notification */}
        <div className="relative flex items-center gap-2">
          {/* Search Icon */}
          <button 
            onClick={() => setSearchOpen(true)}
            className="relative w-[40px] h-[40px] rounded-full hover:bg-muted/50 transition-all flex items-center justify-center"
          >
            <Search className="w-5 h-5 text-muted-foreground" />
          </button>
          
          {/* Notification Icon */}
          <button 
            onClick={() => setNotificationOpen(true)}
            className="relative w-[40px] h-[40px] rounded-full hover:bg-muted/50 transition-all flex items-center justify-center"
          >
            <Bell className="w-5 h-5 text-muted-foreground" />
            {unreadCount > 0 && (
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                className="absolute -top-0.5 -right-0.5 bg-red-500 rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1"
              >
                <span className="text-white" style={{ fontSize: '10px', fontWeight: '700' }}>
                  {unreadCount > 9 ? '9+' : unreadCount}
                </span>
              </motion.div>
            )}
          </button>
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
              <div className="py-2">
                {menuItems.map((item, index) => {
                  const Icon = item.icon;
                  return (
                    <motion.button
                      key={index}
                      onClick={() => handleMenuItemClick(item.action)}
                      whileTap={{ scale: 0.98 }}
                      className="w-full flex items-center gap-3 px-5 py-3.5 hover:bg-muted transition-colors text-left"
                    >
                      <Icon className="w-5 h-5 text-muted-foreground" />
                      <span className="text-foreground" style={{ fontSize: '15px', fontWeight: '500' }}>
                        {item.label}
                      </span>
                    </motion.button>
                  );
                })}
              </div>

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
                    placeholder={language === 'bn' ? 'খুঁজুন...' : 'Search...'}
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
                {/* Trending Searches */}
                <div className="p-4">
                  <h3 className="text-muted-foreground mb-3" style={{ fontSize: '13px', fontWeight: '600', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                    {language === 'bn' ? 'ট্রেন্ডিং সার্চ' : 'Trending Searches'}
                  </h3>
                  <div className="space-y-1">
                    {trendingSearches.map((term, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          setSearchQuery(term);
                          console.log('Search trending:', term);
                        }}
                        className="w-full flex items-center gap-3 p-3 hover:bg-muted/50 rounded-xl transition-colors text-left"
                      >
                        <TrendingUp className="w-4 h-4 text-accent" />
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

      {/* Notification Dialog */}
      <AnimatePresence>
        {notificationOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.2 }}
              className="fixed inset-0 bg-black/50 z-40"
              onClick={() => setNotificationOpen(false)}
            />

            {/* Notification Dialog */}
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: -20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: -20 }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              className="fixed top-20 left-1/2 -translate-x-1/2 w-[90%] max-w-[600px] bg-background rounded-2xl shadow-2xl z-50 overflow-hidden"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Notification Header */}
              <div className="flex items-center justify-between p-4 border-b border-border">
                <div className="flex items-center gap-3">
                  <Bell className="w-5 h-5 text-muted-foreground" />
                  <h3 className="text-foreground" style={{ fontSize: '17px', fontWeight: '600' }}>
                    {language === 'bn' ? 'বিজ্ঞপ্তি' : 'Notifications'}
                  </h3>
                </div>
                <div className="flex items-center gap-2">
                  {unreadCount > 0 && (
                    <button
                      onClick={handleMarkAllAsRead}
                      className="px-3 py-1.5 text-accent hover:bg-muted rounded-lg transition-colors"
                      style={{ fontSize: '13px', fontWeight: '500' }}
                    >
                      {language === 'bn' ? 'সব পড়া হয়েছে চিহ্নিত করুন' : 'Mark all read'}
                    </button>
                  )}
                  <button
                    onClick={() => setNotificationOpen(false)}
                    className="p-2 hover:bg-muted rounded-full transition-colors"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>
              </div>

              {/* Notification Content */}
              <div className="max-h-[500px] overflow-y-auto">
                {mockNotifications.length === 0 ? (
                  <div className="py-12 text-center">
                    <Bell className="w-12 h-12 mx-auto mb-3 text-muted-foreground opacity-30" />
                    <p className="text-muted-foreground" style={{ fontSize: '14px' }}>
                      {language === 'bn' ? 'কোন বিজ্ঞপ্তি নেই' : 'No notifications'}
                    </p>
                  </div>
                ) : (
                  mockNotifications.map((notification, index) => (
                    <motion.button
                      key={notification.id}
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.05, duration: 0.2 }}
                      className={`w-full p-4 flex items-start gap-3 hover:bg-muted/50 transition-colors text-left border-b border-border last:border-b-0 ${
                        notification.unread ? 'bg-muted/30' : ''
                      }`}
                      onClick={() => handleNotificationClick(notification.id)}
                    >
                      {/* Avatar */}
                      <div 
                        className="flex-shrink-0 w-11 h-11 rounded-full flex items-center justify-center"
                        style={{ 
                          backgroundColor: notification.unread ? '#d6775c' : '#8B8B8B',
                          fontSize: '20px',
                        }}
                      >
                        {notification.avatar}
                      </div>
                      
                      {/* Content */}
                      <div className="flex-1 min-w-0">
                        <p className="text-foreground" style={{ fontSize: '14px', lineHeight: '1.5' }}>
                          <span style={{ fontWeight: '600' }}>{notification.user}</span>
                          {' '}
                          <span style={{ fontWeight: '400' }}>{notification.action}</span>
                        </p>
                        <p className="text-muted-foreground mt-1" style={{ fontSize: '12px' }}>
                          {notification.time}
                        </p>
                      </div>

                      {/* Unread Indicator */}
                      {notification.unread && (
                        <div className="flex-shrink-0 w-2 h-2 rounded-full bg-accent mt-2" />
                      )}
                    </motion.button>
                  ))
                )}
              </div>

              {/* Footer - View All Button */}
              {mockNotifications.length > 0 && (
                <div className="p-3 border-t border-border">
                  <button
                    onClick={() => {
                      onNavigate('notifications');
                      setNotificationOpen(false);
                    }}
                    className="w-full py-2.5 text-center text-accent hover:bg-muted rounded-lg transition-colors"
                    style={{ fontSize: '14px', fontWeight: '500' }}
                  >
                    {language === 'bn' ? 'সব বিজ্ঞপ্তি দেখুন' : 'View all notifications'}
                  </button>
                </div>
              )}
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
};