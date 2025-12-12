import React from 'react';
import { motion } from 'motion/react';
import { useApp } from './contexts/AppContext';
import svgPaths from '../imports/svg-jgg1iae82p';

interface BottomNavProps {
  activeScreen: string;
  onNavigate: (screen: string) => void;
  hideNav?: boolean;
}

export const BottomNav: React.FC<BottomNavProps> = ({ activeScreen, onNavigate, hideNav }) => {
  const { language, messageNotificationCount, resetMessageNotifications } = useApp();

  const isHome = activeScreen === 'home';
  const isMessages = activeScreen === 'messages';
  const isLocalCommunity = activeScreen === 'localCommunity' || activeScreen === 'explore';
  const isProfile = activeScreen === 'profile';

  const handleMessageClick = () => {
    resetMessageNotifications();
    onNavigate('messages');
  };

  const translations = {
    home: language === 'bn' ? 'হোম' : 'Home',
    community: language === 'bn' ? 'কমিউনিটি' : 'Community',
    messages: language === 'bn' ? 'মেসেজ' : 'Messages',
    profile: language === 'bn' ? 'প্রোফাইল' : 'Profile',
  };

  return (
    <motion.nav
      initial={{ y: 0, opacity: 1 }}
      animate={{ 
        y: hideNav ? 100 : 0,
        opacity: hideNav ? 0.7 : 1
      }}
      transition={{ 
        duration: 0.3, 
        ease: [0.4, 0, 0.2, 1]
      }}
      className="fixed bottom-0 left-0 right-0 z-50"
      style={{
        paddingBottom: 'env(safe-area-inset-bottom, 0px)',
      }}
    >
      <div className="max-w-[768px] mx-auto px-2.5 py-2" style={{ minWidth: '350px' }}>
        <div className="bg-[#d6775c] rounded-[75px] h-[90px] px-2 flex items-center justify-around relative shadow-lg shadow-black/10">
          {/* Home Button */}
          <motion.button
            onClick={() => onNavigate('home')}
            whileTap={{ scale: 0.92 }}
            whileHover={{ scale: 1.05 }}
            className="flex flex-col items-center justify-center gap-0.5 transition-all duration-300"
          >
            <div className={`${isHome ? 'bg-[#bd4e2e] shadow-inner' : 'bg-transparent hover:bg-white/10'} rounded-full size-[52px] flex items-center justify-center transition-all duration-300 relative overflow-hidden`}>
              {isHome && (
                <motion.div 
                  layoutId="activeIndicator"
                  className="absolute inset-0 bg-[#bd4e2e] rounded-full"
                  transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                />
              )}
              <div className={`relative shrink-0 transition-all duration-300 ${isHome ? 'size-[20px]' : 'size-[24px]'} z-10`}>
                <svg className="block size-full drop-shadow-sm" fill="none" preserveAspectRatio="none" viewBox="0 0 25 25">
                  <g>
                    <path 
                      d={svgPaths.p3c873280} 
                      stroke="white" 
                      strokeWidth={isHome ? "2.5" : "2"} 
                    />
                    <path 
                      d={svgPaths.p505e900} 
                      opacity="0" 
                      stroke="white" 
                    />
                  </g>
                </svg>
              </div>
            </div>
            <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[9px] text-white transition-opacity duration-300 ${isHome ? 'opacity-100' : 'opacity-70'}`}>
              {translations.home}
            </p>
          </motion.button>

          {/* Community Button */}
          <motion.button
            onClick={() => onNavigate('localCommunity')}
            whileTap={{ scale: 0.92 }}
            whileHover={{ scale: 1.05 }}
            className="flex flex-col items-center justify-center gap-0.5 transition-all duration-300"
          >
            <div className={`${isLocalCommunity ? 'bg-[#bd4e2e] shadow-inner' : 'bg-transparent hover:bg-white/10'} rounded-full size-[52px] flex items-center justify-center transition-all duration-300 relative overflow-hidden`}>
              {isLocalCommunity && (
                <motion.div 
                  layoutId="activeIndicator"
                  className="absolute inset-0 bg-[#bd4e2e] rounded-full"
                  transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                />
              )}
              <div className={`relative shrink-0 transition-all duration-300 ${isLocalCommunity ? 'size-[38px]' : 'size-[46px]'} z-10`}>
                <svg className="block size-full drop-shadow-sm" fill="none" preserveAspectRatio="none" viewBox="0 0 60 60">
                  <g>
                    <path 
                      d={svgPaths.p1ea17a00} 
                      stroke="white" 
                      strokeLinecap="round" 
                      strokeLinejoin="round" 
                      strokeWidth={isLocalCommunity ? "2.5" : "2"} 
                    />
                  </g>
                </svg>
              </div>
            </div>
            <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[9px] text-white transition-opacity duration-300 ${isLocalCommunity ? 'opacity-100' : 'opacity-70'}`}>
              {translations.community}
            </p>
          </motion.button>

          {/* Create Post Button (Center) */}
          <motion.button
            onClick={() => onNavigate('createPost')}
            whileTap={{ scale: 0.88 }}
            whileHover={{ scale: 1.08 }}
            className="bg-white rounded-full size-[55px] flex items-center justify-center transition-all duration-300 shadow-xl shadow-black/20 hover:shadow-2xl hover:shadow-black/30 relative overflow-hidden group -mt-2"
          >
            <motion.div
              className="absolute inset-0 bg-gradient-to-br from-white to-[#f5f5f5] rounded-full"
              whileHover={{ scale: 1.1 }}
              transition={{ duration: 0.3 }}
            />
            <div className="relative shrink-0 size-[22px] z-10">
              <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 19 19">
                <g>
                  <motion.path 
                    d="M4.75 9.5H14.25" 
                    stroke="#D6775C" 
                    strokeLinecap="round" 
                    strokeLinejoin="round" 
                    strokeWidth="1.5" 
                  />
                  <motion.path 
                    d="M9.5 14.25V4.75" 
                    stroke="#D6775C" 
                    strokeLinecap="round" 
                    strokeLinejoin="round" 
                    strokeWidth="1.5" 
                  />
                </g>
              </svg>
            </div>
          </motion.button>

          {/* Messages Button */}
          <motion.button
            onClick={handleMessageClick}
            whileTap={{ scale: 0.92 }}
            whileHover={{ scale: 1.05 }}
            className="flex flex-col items-center justify-center gap-0.5 transition-all duration-300"
          >
            <div className={`relative ${isMessages ? 'bg-[#bd4e2e] shadow-inner' : 'bg-transparent hover:bg-white/10'} rounded-full size-[52px] flex items-center justify-center transition-all duration-300`}>
              {isMessages && (
                <motion.div 
                  layoutId="activeIndicator"
                  className="absolute inset-0 bg-[#bd4e2e] rounded-full"
                  transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                />
              )}
              <div className={`relative shrink-0 transition-all duration-300 ${isMessages ? 'size-[18px]' : 'size-[22px]'} z-10`}>
                <svg className="block size-full drop-shadow-sm" fill="none" preserveAspectRatio="none" viewBox="0 0 24 24">
                  <g>
                    <path 
                      d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" 
                      stroke="white" 
                      strokeWidth={isMessages ? "2.5" : "2"} 
                      fill="none"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </g>
                </svg>
              </div>
              {/* Notification Badge */}
              {messageNotificationCount > 0 && (
                <motion.div 
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  exit={{ scale: 0 }}
                  className="absolute -top-1 -right-1 bg-[#ff3b30] border-2 border-white dark:border-[#d6775c] rounded-full min-w-[20px] h-[20px] flex items-center justify-center px-1 shadow-md z-20"
                >
                  <span className="text-white text-[10px] font-bold">
                    {messageNotificationCount > 99 ? '99+' : messageNotificationCount}
                  </span>
                </motion.div>
              )}
            </div>
            <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[9px] text-white transition-opacity duration-300 ${isMessages ? 'opacity-100' : 'opacity-70'}`}>
              {translations.messages}
            </p>
          </motion.button>

          {/* Profile Button */}
          <motion.button
            onClick={() => onNavigate('profile')}
            whileTap={{ scale: 0.92 }}
            whileHover={{ scale: 1.05 }}
            className="flex flex-col items-center justify-center gap-0.5 transition-all duration-300"
          >
            <div className={`${isProfile ? 'bg-[#bd4e2e] shadow-inner' : 'bg-transparent hover:bg-white/10'} rounded-full size-[52px] flex items-center justify-center transition-all duration-300 relative overflow-hidden`}>
              {isProfile && (
                <motion.div 
                  layoutId="activeIndicator"
                  className="absolute inset-0 bg-[#bd4e2e] rounded-full"
                  transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                />
              )}
              <div className={`relative shrink-0 transition-all duration-300 ${isProfile ? 'size-[18px]' : 'size-[22px]'} z-10`}>
                <svg className="block size-full drop-shadow-sm" fill="none" preserveAspectRatio="none" viewBox="0 0 20 20">
                  <g>
                    <path 
                      d={svgPaths.p1039200} 
                      stroke="white" 
                      strokeLinecap="round" 
                      strokeLinejoin="round" 
                      strokeWidth={isProfile ? "2.5" : "2"} 
                    />
                    <path 
                      d={svgPaths.p19362f00} 
                      stroke="white" 
                      strokeLinecap="round" 
                      strokeLinejoin="round" 
                      strokeWidth={isProfile ? "2.5" : "2"} 
                    />
                    <path 
                      d="M19.5 0.5V19.5H0.5V0.5H19.5Z" 
                      opacity="0" 
                      stroke="white" 
                    />
                  </g>
                </svg>
              </div>
            </div>
            <p className={`font-['Noto_Sans_Bengali',sans-serif] text-[9px] text-white transition-opacity duration-300 ${isProfile ? 'opacity-100' : 'opacity-70'}`}>
              {translations.profile}
            </p>
          </motion.button>
        </div>
      </div>
    </motion.nav>
  );
};