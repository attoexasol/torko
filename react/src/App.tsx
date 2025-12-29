import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { AppProvider, useApp } from './components/contexts/AppContext';
import { BottomNav } from './components/BottomNav';
import { SplashScreen } from './components/screens/SplashScreen';
import { OnboardingScreen } from './components/screens/OnboardingScreen';
import { LoginScreen } from './components/screens/LoginScreen';
import { ProfileDataOnboardingScreen } from './components/screens/ProfileDataOnboardingScreen';
import { HomeScreen } from './components/screens/HomeScreen';
import { CreatePostScreen } from './components/screens/CreatePostScreen';
import { NotificationsScreen } from './components/screens/NotificationsScreen';
import { ProfileScreen } from './components/screens/ProfileScreen';
import { ProfileScreenNew } from './components/screens/ProfileScreenNew';
import { ExploreScreen } from './components/screens/ExploreScreen';
import { ExploreScreenNew } from './components/screens/ExploreScreenNew';
import { SettingsScreen } from './components/screens/SettingsScreen';
import { MessagesScreen } from './components/screens/MessagesScreen';
import { CommunityScreen } from './components/screens/CommunityScreen';
import { LocalCommunityScreen } from './components/screens/LocalCommunityScreen';
import { LocalCommunityScreenNew } from './components/screens/LocalCommunityScreenNew';
import { ConversationScreen } from './components/screens/ConversationScreen';
import { CallingScreen } from './components/screens/CallingScreen';
import { CommentThreadDemo } from './components/screens/CommentThreadDemo';
import { ModernCommentDemo } from './components/screens/ModernCommentDemo';
import { PostWithComments } from './components/screens/PostWithComments';
import { StageRoomScreen } from './components/screens/StageRoomScreen';
import { AccountSettingsScreen } from './components/screens/AccountSettingsScreen';
import { PrivacySettingsScreen } from './components/screens/PrivacySettingsScreen';
import { NotificationSettingsScreen } from './components/screens/NotificationSettingsScreen';
import { TorkoCommentsDemo } from './components/screens/TorkoCommentsDemo';
import { NotificationBar } from './components/NotificationBar';
import { Toaster } from './components/ui/sonner';

type AppState = 
  | 'splash' 
  | 'onboarding' 
  | 'login'
  | 'profileData' 
  | 'home' 
  | 'createPost' 
  | 'notifications' 
  | 'profile' 
  | 'explore'
  | 'exploreNew'
  | 'exploreStages'
  | 'exploreGroups'
  | 'messages'
  | 'community'
  | 'localCommunity'
  | 'stageRoom'
  | 'settings'
  | 'accountSettings'
  | 'privacySettings'
  | 'notificationSettings'
  | 'commentThreadDemo'
  | 'modernCommentDemo'
  | 'torkoCommentsDemo';

const AppContent: React.FC = () => {
  const [appState, setAppState] = useState<AppState>('splash');
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [showBottomNavFromScroll, setShowBottomNavFromScroll] = useState(true);
  const [exploreDefaultTab, setExploreDefaultTab] = useState<'stages' | 'groups'>('stages');
  const [currentStageData, setCurrentStageData] = useState<any>(null);
  const { conversationData, closeConversation, callData, endCall, hideBottomNav, postDetailData, closePostDetail, language } = useApp();

  // Initialize browser history on mount
  useEffect(() => {
    // Set initial state in history
    window.history.replaceState({ screen: appState }, '', `#${appState}`);
  }, []);

  // Sync with browser history
  useEffect(() => {
    const handlePopState = (event: PopStateEvent) => {
      if (event.state && event.state.screen) {
        setAppState(event.state.screen);
      } else {
        // Fallback if no state
        setAppState('home');
      }
    };

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  const handleNavigate = (screen: AppState) => {
    setAppState(screen);
    // Push to browser history
    window.history.pushState({ screen }, '', `#${screen}`);
  };

  const handleSplashComplete = () => {
    handleNavigate('onboarding');
  };

  const handleOnboardingComplete = () => {
    handleNavigate('login');
  };

  const handleBackToOnboarding = () => {
    handleNavigate('onboarding');
  };

  const handleLoginComplete = () => {
    // Check if user has completed profile data
    const hasProfileData = typeof window !== 'undefined' && localStorage.getItem('torko_user_profile');
    
    if (hasProfileData) {
      setIsAuthenticated(true);
      handleNavigate('home');
    } else {
      // New user - go to profile data onboarding
      handleNavigate('profileData');
    }
  };

  const handleProfileDataComplete = () => {
    setIsAuthenticated(true);
    handleNavigate('home');
  };

  const renderScreen = () => {
    switch (appState) {
      case 'splash':
        return <SplashScreen onComplete={handleSplashComplete} />;
      case 'onboarding':
        return <OnboardingScreen onComplete={handleOnboardingComplete} />;
      case 'login':
        return <LoginScreen onComplete={handleLoginComplete} onBack={handleBackToOnboarding} isReturningUser={false} />;
      case 'profileData':
        return <ProfileDataOnboardingScreen onComplete={handleProfileDataComplete} />;
      case 'home':
        return <HomeScreen onNavigate={handleNavigate} />;
      case 'createPost':
        return <CreatePostScreen onNavigate={handleNavigate} />;
      case 'notifications':
        return <NotificationsScreen onNavigate={handleNavigate} />;
      case 'profile':
        return <ProfileScreenNew onBack={() => handleNavigate('home')} onNavigate={handleNavigate} language={language} />;
      case 'explore':
        // Redirect explore to localCommunity
        return <LocalCommunityScreenNew onNavigate={handleNavigate} language={language} onScroll={(show) => setShowBottomNavFromScroll(show)} />;
      case 'exploreNew':
        return <ExploreScreenNew onNavigate={handleNavigate} language={language} onScroll={(show) => setShowBottomNavFromScroll(show)} defaultTab={exploreDefaultTab} />;
      case 'exploreStages':
        return <ExploreScreenNew onNavigate={handleNavigate} language={language} onScroll={(show) => setShowBottomNavFromScroll(show)} defaultTab="stages" />;
      case 'exploreGroups':
        return <ExploreScreenNew onNavigate={handleNavigate} language={language} onScroll={(show) => setShowBottomNavFromScroll(show)} defaultTab="groups" />;
      case 'messages':
        return <MessagesScreen onNavigate={handleNavigate} />;
      case 'community':
        return <CommunityScreen onNavigate={handleNavigate} />;
      case 'localCommunity':
        return <LocalCommunityScreenNew onNavigate={handleNavigate} language={language} onScroll={(show) => setShowBottomNavFromScroll(show)} onStageCreate={setCurrentStageData} />;
      case 'stageRoom':
        return <StageRoomScreen onNavigate={handleNavigate} language={language} stageData={currentStageData} />;
      case 'settings':
        return <SettingsScreen onNavigate={handleNavigate} />;
      case 'accountSettings':
        return <AccountSettingsScreen onNavigate={handleNavigate} />;
      case 'privacySettings':
        return <PrivacySettingsScreen onNavigate={handleNavigate} />;
      case 'notificationSettings':
        return <NotificationSettingsScreen onNavigate={handleNavigate} />;
      case 'commentThreadDemo':
        return <CommentThreadDemo />;
      case 'modernCommentDemo':
        return <ModernCommentDemo />;
      case 'torkoCommentsDemo':
        return <TorkoCommentsDemo />;
      default:
        return <HomeScreen onNavigate={handleNavigate} />;
    }
  };

  const showBottomNav = 
    isAuthenticated && 
    !['splash', 'onboarding', 'login', 'profileData', 'createPost', 'notifications', 'stageRoom', 'settings', 'accountSettings', 'privacySettings', 'notificationSettings'].includes(appState);

  return (
    <div className="relative w-full h-screen overflow-hidden bg-background">
      {/* Mobile & Tablet Container - responsive from 350px to tablet */}
      <div className="w-full h-full max-w-[768px] mx-auto relative bg-background shadow-2xl" style={{ minWidth: '350px' }}>
        {/* Conversation Screen Overlay */}
        {conversationData && (
          <div className="absolute inset-0 z-50">
            <ConversationScreen
              onBack={closeConversation}
              conversationName={conversationData.name}
              conversationAvatar={conversationData.avatar}
              conversationColor={conversationData.color}
              conversationInitials={conversationData.initials}
              isGroup={conversationData.isGroup}
            />
          </div>
        )}

        {/* Calling Screen Overlay */}
        {callData && (
          <div className="absolute inset-0 z-50">
            <CallingScreen
              onEndCall={endCall}
              callerName={callData.name}
              callerColor={callData.color}
              callerInitials={callData.initials}
              isVideo={callData.isVideo}
              isIncoming={callData.isIncoming}
              isGroup={callData.isGroup}
            />
          </div>
        )}

        {/* Post Detail with Comments Overlay */}
        {postDetailData && (
          <div className="absolute inset-0 z-50">
            <PostWithComments
              post={postDetailData}
              language={language}
              onBack={closePostDetail}
              onAddComment={(text, replyTo) => {
                console.log('Comment added:', text, 'Reply to:', replyTo);
              }}
            />
          </div>
        )}

        <AnimatePresence mode="wait">
          <motion.div
            key={appState}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="w-full h-full"
          >
            {renderScreen()}
          </motion.div>
        </AnimatePresence>

        {/* Bottom Navigation */}
        {showBottomNav && !conversationData && !callData && (
          <BottomNav 
            activeScreen={appState} 
            onNavigate={handleNavigate}
            hideNav={hideBottomNav || !showBottomNavFromScroll}
          />
        )}
      </div>
    </div>
  );
};

const App: React.FC = () => {
  return (
    <AppProvider>
      <AppContent />
      <NotificationBarWrapper />
      <Toaster />
    </AppProvider>
  );
};

const NotificationBarWrapper: React.FC = () => {
  const { notification, dismissNotification } = useApp();
  return <NotificationBar notification={notification} onDismiss={dismissNotification} />;
};

export default App;