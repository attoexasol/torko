import React, { useState, useRef, useEffect } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '../ui/tabs';
import { MessageCircle, Search, MoreVertical, Plus, Users, Phone, Video, PhoneIncoming, PhoneOutgoing, PhoneMissed } from 'lucide-react';
import { MessagesHeader } from '../MessagesHeader';
import { CheckIcon } from '../CheckIcon';
import { ImageWithFallback } from '../figma/ImageWithFallback';

interface MessagesScreenProps {
  onNavigate: (screen: string) => void;
}

interface Conversation {
  id: number;
  name: string;
  lastMessage: string;
  time: string;
  unread: number;
  avatarColor: string;
  initials: string;
  isGroup?: boolean;
  isOnline?: boolean;
}

interface CallHistory {
  id: number;
  name: string;
  time: string;
  duration: string;
  type: 'incoming' | 'outgoing' | 'missed';
  isVideo: boolean;
  avatarColor: string;
  initials: string;
  isGroup?: boolean;
}

export const MessagesScreen: React.FC<MessagesScreenProps> = ({ onNavigate }) => {
  const { language, openConversation, startCall, theme } = useApp();
  const [activeTab, setActiveTab] = useState('chats');
  const [showHeader, setShowHeader] = useState(true);
  const [lastScrollY, setLastScrollY] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');
  const chatsScrollRef = useRef<HTMLDivElement>(null);
  const callsScrollRef = useRef<HTMLDivElement>(null);

  // Detect scroll direction for both tabs
  useEffect(() => {
    const handleScroll = (scrollContainer: HTMLDivElement | null) => {
      if (!scrollContainer) return;

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

    const chatsContainer = chatsScrollRef.current;
    const callsContainer = callsScrollRef.current;

    const activeContainer = activeTab === 'chats' ? chatsContainer : callsContainer;
    
    if (activeContainer) {
      const scrollHandler = () => handleScroll(activeContainer);
      activeContainer.addEventListener('scroll', scrollHandler, { passive: true });
      return () => activeContainer.removeEventListener('scroll', scrollHandler);
    }
  }, [lastScrollY, activeTab]);

  // Separate normal chats from group chats
  const normalChats: Conversation[] = [
    {
      id: 1,
      name: language === 'bn' ? 'কাইটলিন' : 'Kaitlyn',
      lastMessage: language === 'bn' ? 'ভালো থেকো!' : 'Have a good one!',
      time: language === 'bn' ? '৩:০২ PM' : '3:02 PM',
      unread: 0,
      avatarColor: '#6B9BD1',
      initials: language === 'bn' ? 'ক' : 'K',
      isGroup: false,
      isOnline: true,
    },
    {
      id: 2,
      name: language === 'bn' ? 'ক্লোয়ি' : 'Chloe',
      lastMessage: language === 'bn' ? 'হ্যালো! আজ রাতের জন্য তুমি কি উপলব্ধ...' : 'Hello! Are you available for toni...',
      time: language === 'bn' ? '২:৫৮ PM' : '2:58 PM',
      unread: 2,
      avatarColor: '#E8A87C',
      initials: language === 'bn' ? 'ক্ল' : 'C',
      isGroup: false,
      isOnline: false,
    },
    {
      id: 3,
      name: language === 'bn' ? 'কাইটলিন' : 'Kaitlyn',
      lastMessage: language === 'bn' ? 'ভালো থেকো!' : 'Have a good one!',
      time: language === 'bn' ? '৩:০২ PM' : '3:02 PM',
      unread: 0,
      avatarColor: '#6B9BD1',
      initials: language === 'bn' ? 'ক' : 'K',
      isGroup: false,
      isOnline: false,
    },
    {
      id: 4,
      name: language === 'bn' ? 'ক্লোয়ি' : 'Chloe',
      lastMessage: language === 'bn' ? 'হ্যালো! আজ রাতের জন্য তুমি কি উপলব্ধ...' : 'Hello! Are you available for toni...',
      time: language === 'bn' ? '২:৫৮ PM' : '2:58 PM',
      unread: 2,
      avatarColor: '#E8A87C',
      initials: language === 'bn' ? 'ক্ল' : 'C',
      isGroup: false,
      isOnline: true,
    },
  ];

  const groupChats: Conversation[] = [
    {
      id: 2,
      name: language === 'bn' ? 'ঢাকা কমিউনিটি' : 'Dhaka Community',
      lastMessage: language === 'bn' ? 'নতুন ইভেন্ট এই সপ্তাহে' : 'New event this week',
      time: language === 'bn' ? '৫ ঘণ্টা' : '5h',
      unread: 5,
      avatarColor: '#8B9FA8',
      initials: language === 'bn' ? 'ঢা' : 'DC',
      isGroup: true,
    },
    {
      id: 5,
      name: language === 'bn' ? 'ঢাকা কমিউনিটি' : 'Dhaka Community',
      time: language === 'bn' ? '৩ দিন আগে' : '3d ago',
      duration: language === 'bn' ? '৪৫ মিনিট' : '45 min',
      type: 'outgoing',
      isVideo: true,
      avatarColor: '#8B9FA8',
      initials: language === 'bn' ? 'ঢা' : 'DC',
      isGroup: true,
    },
    {
      id: 7,
      name: language === 'bn' ? 'টেক স্টার্টআপ বিডি' : 'Tech Startup BD',
      lastMessage: language === 'bn' ? 'নতুন ফান্ডিং সুযোগ!' : 'New funding opportunity!',
      time: language === 'bn' ? '২ দিন' : '2d',
      unread: 12,
      avatarColor: '#7DA8D9',
      initials: language === 'bn' ? 'টে' : 'TS',
      isGroup: true,
    },
  ];

  // Filter conversations based on search query
  const filterConversations = (conversations: Conversation[]) => {
    if (!searchQuery.trim()) return conversations;
    
    return conversations.filter(conv => 
      conv.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      conv.lastMessage.toLowerCase().includes(searchQuery.toLowerCase())
    );
  };

  const filteredNormalChats = filterConversations(normalChats);
  const filteredGroupChats = filterConversations(groupChats);

  const callHistory: CallHistory[] = [
    {
      id: 1,
      name: language === 'bn' ? 'রহিম আহমেদ' : 'Rahim Ahmed',
      time: language === 'bn' ? '২ ঘণ্টা আগে' : '2h ago',
      duration: language === 'bn' ? '১২ মিনিট' : '12 min',
      type: 'incoming',
      isVideo: false,
      avatarColor: '#6B9BD1',
      initials: language === 'bn' ? 'র' : 'RA',
    },
    {
      id: 2,
      name: language === 'bn' ? 'করিম খান' : 'Karim Khan',
      time: language === 'bn' ? 'গতকাল' : 'Yesterday',
      duration: language === 'bn' ? '২৫ মিনিট' : '25 min',
      type: 'outgoing',
      isVideo: true,
      avatarColor: '#A8B5A0',
      initials: language === 'bn' ? 'ক' : 'KK',
    },
    {
      id: 3,
      name: language === 'bn' ? 'সাবিনা রহমান' : 'Sabina Rahman',
      time: language === 'bn' ? 'গতকাল' : 'Yesterday',
      duration: '',
      type: 'missed',
      isVideo: false,
      avatarColor: '#C9A899',
      initials: language === 'bn' ? 'সা' : 'SR',
    },
    {
      id: 4,
      name: language === 'bn' ? 'তানিয়া ইসলাম' : 'Tania Islam',
      time: language === 'bn' ? '২ দিন আগে' : '2d ago',
      duration: language === 'bn' ? '৮ মিনিট' : '8 min',
      type: 'incoming',
      isVideo: true,
      avatarColor: '#D9A67D',
      initials: language === 'bn' ? 'ত' : 'TI',
    },
    {
      id: 5,
      name: language === 'bn' ? 'ঢাকা কমিউনিটি' : 'Dhaka Community',
      time: language === 'bn' ? '৩ দিন আগে' : '3d ago',
      duration: language === 'bn' ? '৪৫ মিনিট' : '45 min',
      type: 'outgoing',
      isVideo: true,
      avatarColor: '#8B9FA8',
      initials: language === 'bn' ? 'ঢা' : 'DC',
    },
  ];

  const renderConversationItem = (conversation: Conversation, index: number) => {
    const hasCheck = conversation.unread === 0 && index % 2 === 0; // Some messages have check marks
    const isUnread = conversation.unread > 0;
    
    return (
      <div
        key={conversation.id}
        className="rounded-[16px] mb-3 cursor-pointer"
        style={{
          backgroundColor: theme === 'dark' ? '#0a2f3d' : '#ffffff',
          border: theme === 'dark' ? '1px solid #0d3a4a' : '1px solid #f2f2f2',
          height: '70px',
        }}
        onClick={() => openConversation(conversation.name, conversation.avatarColor, conversation.initials, conversation.avatarColor, conversation.isGroup)}
      >
        <div className="box-border flex items-center justify-center overflow-clip h-full px-4 py-2" style={{ gap: isUnread ? '8px' : '32px' }}>
          {/* Left side - Avatar + Content */}
          <div className="basis-0 flex grow items-start min-h-px min-w-px relative shrink-0" style={{ gap: '10px' }}>
            {/* Avatar */}
            <div className="relative shrink-0" style={{ width: '40px', height: '40px' }}>
              <ImageWithFallback
                alt={conversation.name}
                className="block rounded-full object-cover"
                style={{ width: '40px', height: '40px' }}
                src="https://images.unsplash.com/photo-1649589244330-09ca58e4fa64?w=80&h=80&fit=crop"
              />
            </div>

            {/* Name and Message */}
            <div className="flex flex-col justify-center relative shrink-0" style={{ gap: '6px', height: '40px' }}>
              {/* Name */}
              <p 
                className="font-['Roboto:Regular',sans-serif] font-normal leading-[normal] relative shrink-0"
                style={{ 
                  fontSize: '14px',
                  height: '16px',
                  fontVariationSettings: "'wdth' 100",
                  color: theme === 'dark' ? '#ffffff' : '#010101',
                }}
              >
                {conversation.name}
              </p>

              {/* Message Preview */}
              <div className="h-[18px] relative shrink-0" style={{ width: hasCheck ? '156px' : '213px' }}>
                <div className="flex flex-row items-center size-full">
                  <div 
                    className="box-border flex items-center pl-0 pr-[10px] py-[10px] relative"
                    style={{ 
                      gap: '4px',
                      height: '18px',
                      width: hasCheck ? '156px' : '213px'
                    }}
                  >
                    {hasCheck && <CheckIcon />}
                    <p 
                      className="font-['Roboto:Regular',sans-serif] font-normal leading-[normal] relative shrink-0 truncate"
                      style={{ 
                        fontSize: '14px',
                        height: '14px',
                        width: hasCheck ? '128px' : '213px',
                        fontVariationSettings: "'wdth' 100",
                        color: theme === 'dark' ? '#a0a0a0' : '#3c3c3c',
                      }}
                    >
                      {conversation.lastMessage}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Right side - Time and Badge */}
          <div 
            className="box-border flex flex-col items-end relative shrink-0"
            style={{
              gap: '4px',
              height: '42px',
              width: '44px',
              paddingBottom: '10px',
              paddingLeft: '10px',
              paddingRight: '1px',
              paddingTop: isUnread ? '8px' : '4px',
              justifyContent: isUnread ? 'center' : 'flex-start'
            }}
          >
            {/* Time */}
            <p 
              className="font-['Roboto:Regular',sans-serif] font-normal leading-[normal] relative shrink-0 text-nowrap whitespace-pre"
              style={{ 
                fontSize: '12px',
                color: isUnread ? '#d6775c' : (theme === 'dark' ? '#a0a0a0' : 'black'),
                fontVariationSettings: "'wdth' 100"
              }}
            >
              {conversation.time}
            </p>

            {/* Unread Badge */}
            {isUnread && (
              <div 
                className="bg-[#d6775c] relative rounded-[16px] shrink-0"
                style={{ width: '16px', height: '16px' }}
              >
                <div className="flex flex-col items-center justify-center overflow-clip rounded-[inherit] size-full">
                  <div 
                    className="box-border flex flex-col items-center justify-center relative size-[16px]"
                    style={{
                      gap: '10px',
                      paddingLeft: '11px',
                      paddingRight: '11px',
                      paddingTop: '6px',
                      paddingBottom: '6px'
                    }}
                  >
                    <p 
                      className="font-['Roboto:Regular',sans-serif] font-normal relative shrink-0 text-white"
                      style={{ 
                        fontSize: '10px',
                        height: '9px',
                        lineHeight: '10px',
                        width: '5px',
                        fontVariationSettings: "'wdth' 100"
                      }}
                    >
                      {conversation.unread}
                    </p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    );
  };

  const renderCallItem = (call: CallHistory, index: number) => {
    const getCallIcon = () => {
      if (call.type === 'missed') return <PhoneMissed className="w-3.5 h-3.5 text-red-500" />;
      if (call.type === 'incoming') return <PhoneIncoming className="w-3.5 h-3.5 text-green-500" />;
      return <PhoneOutgoing className="w-3.5 h-3.5 text-muted-foreground" />;
    };

    return (
      <div
        key={call.id}
        className="w-full flex items-center gap-3.5 py-3 hover:bg-muted/30 transition-colors rounded-xl px-1"
      >
        {/* Avatar */}
        <div 
          className="flex-shrink-0 flex items-center justify-center text-white relative"
          style={{
            width: '50px',
            height: '50px',
            borderRadius: '50%',
            backgroundColor: call.avatarColor,
            fontSize: '16px',
            fontWeight: '600',
            boxShadow: '0 2px 6px rgba(0, 0, 0, 0.12)',
          }}
        >
          {call.isVideo && (
            <div className="absolute -bottom-1 -right-1 bg-background rounded-full p-1">
              <Video className="w-3.5 h-3.5 text-accent" />
            </div>
          )}
          {call.initials}
        </div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between mb-0.5">
            <h3 
              className={`truncate flex-1 ${call.type === 'missed' ? 'text-red-500' : 'text-foreground'}`}
              style={{
                fontSize: '15.5px',
                fontWeight: '600',
                lineHeight: '1.4'
              }}
            >
              {call.name}
            </h3>
            <span 
              className="text-muted-foreground flex-shrink-0 ml-2.5"
              style={{
                fontSize: '11.5px',
                fontWeight: '400',
                opacity: '0.6',
                lineHeight: '1.4'
              }}
            >
              {call.time}
            </span>
          </div>

          <div className="flex items-center gap-1.5">
            {getCallIcon()}
            <span 
              className="text-muted-foreground"
              style={{
                fontSize: '13.5px',
                lineHeight: '1.4',
                fontWeight: '400',
                opacity: '0.7'
              }}
            >
              {call.type === 'missed' 
                ? (language === 'bn' ? 'মিসড কল' : 'Missed call')
                : call.duration
              }
            </span>
          </div>
        </div>

        {/* Call button */}
        <Button
          variant="ghost"
          size="icon"
          className="rounded-full h-9 w-9 hover:bg-accent/10 flex-shrink-0"
          onClick={(e) => {
            e.stopPropagation();
            startCall(call.name, call.avatarColor, call.initials, call.isVideo, false, call.isGroup);
          }}
        >
          {call.isVideo ? (
            <Video className="w-4.5 h-4.5 text-accent" />
          ) : (
            <Phone className="w-4.5 h-4.5 text-accent" />
          )}
        </Button>
      </div>
    );
  };

  return (
    <div className="fixed inset-0 bg-background flex flex-col pb-20 overflow-hidden">
      {/* Header - Same as HomeScreen */}
      <motion.div 
        className="absolute top-0 left-0 right-0 z-10"
        initial={{ y: 0, opacity: 1 }}
        animate={{ 
          y: showHeader ? 0 : -60,
          opacity: showHeader ? 1 : 0.7
        }}
        transition={{ 
          duration: 0.25, 
          ease: showHeader ? 'easeIn' : 'easeOut'
        }}
      >
        <MessagesHeader 
          onNavigate={onNavigate} 
          onSearchChange={(query) => setSearchQuery(query)} 
        />
      </motion.div>


      

      {/* Secondary Header - Tabs */}
      <motion.div 
        className="px-5 pt-3 pb-3 absolute left-0 right-0 z-9"
        initial={{ top: '20px' }}
        animate={{ 
          top: showHeader ? '19px' : '0px'
        }}
        transition={{ 
          duration: 0.25, 
          ease: showHeader ? 'easeIn' : 'easeOut'
        }}
        style={{
          backgroundColor: theme === 'dark' ? '#052029' : '#ffffff',
          borderColor: theme === 'dark' ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.1)',
        }}
      >
      {/* Chat / Group Chat / Call Segmented Control */}
        <div 
          className="flex items-center gap-1 p-[5px] mt-12"
          style={{ 
            borderRadius: '15px',
            backgroundColor: theme === 'dark' ? '#0a2f3d' : '#fafafa',
            top: '0px'
          }}
        >
          <button
            className="flex-1 flex flex-col items-center justify-center gap-1"
            style={{ 
              borderRadius: '10px',
              fontSize: '13px',
              fontWeight: '700',
              height: '60px',
              backgroundColor: activeTab === 'chats' ? '#d6775c' : (theme === 'dark' ? '#0d3a4a' : '#FAFAFA'),
              color: activeTab === 'chats' ? '#fafafa' : '#9d9d9d',
              letterSpacing: '-0.1px',
              transition: 'all 0.3s ease-in-out',
            }}
            onClick={() => setActiveTab('chats')}
          >
            <MessageCircle className="w-[20px] h-[20px]" strokeWidth={1.5} />
            {language === 'bn' ? 'চ্যাট' : 'Chat'}
          </button>
          <button
            className="flex-1 flex flex-col items-center justify-center gap-1"
            style={{ 
              borderRadius: '10px',
              fontSize: '13px',
              fontWeight: '700',
              height: '60px',
              backgroundColor: activeTab === 'groups' ? '#d6775c' : (theme === 'dark' ? '#0d3a4a' : '#FAFAFA'),
              color: activeTab === 'groups' ? '#ffffff' : '#9d9d9d',
              letterSpacing: '-0.1px',
              transition: 'all 0.3s ease-in-out',
            }}
            onClick={() => setActiveTab('groups')}
          >
            <Users className="w-[20px] h-[20px]" strokeWidth={1.5} />
            {language === 'bn' ? 'গ্রুপ চ্যাট' : 'Group Chat'}
          </button>
          <button
            className="flex-1 flex flex-col items-center justify-center gap-1"
            style={{ 
              borderRadius: '10px',
              fontSize: '13px',
              fontWeight: '700',
              height: '60px',
              backgroundColor: activeTab === 'calls' ? '#d6775c' : (theme === 'dark' ? '#0d3a4a' : '#FAFAFA'),
              color: activeTab === 'calls' ? '#ffffff' : '#9d9d9d',
              letterSpacing: '-0.1px',
              transition: 'all 0.3s ease-in-out',
            }}
            onClick={() => setActiveTab('calls')}
          >
            <Phone className="w-[20px] h-[20px]" strokeWidth={1.5} />
            {language === 'bn' ? 'কল' : 'Call'}
          </button>
        </div>

        
      </motion.div>

      {/* Tab Content */}
      <Tabs value={activeTab} className="flex-1 overflow-hidden">
        {/* Chats Tab */}
        <TabsContent 
          value="chats" 
          className="h-full overflow-y-auto mt-0" 
          ref={chatsScrollRef}
          style={{
            paddingTop: showHeader ? '165px' : '60px',
            paddingBottom: '120px',
            transition: 'padding-top 0.3s ease-in-out',
            backgroundColor: theme === 'dark' ? '#052029' : '#ffffff'
          }}
        >
          <div className="px-5" style={{  }}>
            {/* Normal Chats Section */}
            <div>
              <div className="space-y-0">
                {filteredNormalChats.length > 0 ? (
                  filteredNormalChats.map((chat, index) => renderConversationItem(chat, index))
                ) : searchQuery.trim() ? (
                  <div className="flex flex-col items-center justify-center py-16">
                    <MessageCircle className="w-12 h-12 text-muted-foreground/40 mb-3" />
                    <p className="text-muted-foreground text-center" style={{ fontSize: '15px' }}>
                      {language === 'bn' ? `"${searchQuery}" এর জন্য কোন চ্যাট পাওয়া যায়নি` : `No chats found for "${searchQuery}"`}
                    </p>
                  </div>
                ) : null}
              </div>
            </div>
          </div>
        </TabsContent>

        {/* Groups Tab (separate from chats) */}
        <TabsContent 
          value="groups" 
          className="h-full overflow-y-auto mt-0"
          style={{
            paddingTop: showHeader ? '165px' : '60px',
            paddingBottom: '120px',
            transition: 'padding-top 0.3s ease-in-out',
            backgroundColor: theme === 'dark' ? '#052029' : '#ffffff'
          }}
        >
          <div className="px-5">
            <h2 
              className="mb-2.5 text-foreground px-1"
              style={{
                fontSize: '13px',
                fontWeight: '700',
                lineHeight: '1.4',
                opacity: '0.85',
                textTransform: 'uppercase',
                letterSpacing: '0.5px'
              }}
            >
              {language === 'bn' ? 'গ্রুপ চ্যাট' : 'Group Chats'}
            </h2>
            <div className="space-y-0">
              {filteredGroupChats.length > 0 ? (
                filteredGroupChats.map((chat, index) => renderConversationItem(chat, index))
              ) : searchQuery.trim() ? (
                <div className="flex flex-col items-center justify-center py-16">
                  <Users className="w-12 h-12 text-muted-foreground/40 mb-3" />
                  <p className="text-muted-foreground text-center" style={{ fontSize: '15px' }}>
                    {language === 'bn' ? `"${searchQuery}" এর জন্য কোন গ্রুপ পাওয়া যায়নি` : `No groups found for "${searchQuery}"`}
                  </p>
                </div>
              ) : null}
            </div>
          </div>
        </TabsContent>

        {/* Calls Tab */}
        <TabsContent 
          value="calls" 
          className="h-full overflow-y-auto mt-0" 
          ref={callsScrollRef}
          style={{
            paddingTop: showHeader ? '165px' : '60px',
            paddingBottom: '120px',
            transition: 'padding-top 0.3s ease-in-out',
            backgroundColor: theme === 'dark' ? '#052029' : '#ffffff'
          }}
        >
          <div className="px-5">
            <h2 
              className="mb-2.5 text-foreground px-1"
              style={{
                fontSize: '13px',
                fontWeight: '700',
                lineHeight: '1.4',
                opacity: '0.85',
                textTransform: 'uppercase',
                letterSpacing: '0.5px'
              }}
            >
              {language === 'bn' ? 'কল ইতিহাস' : 'Call History'}
            </h2>
            <div className="space-y-0">
              {callHistory.map((call, index) => renderCallItem(call, index))}
            </div>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
};