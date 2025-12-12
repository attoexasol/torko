import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Avatar, AvatarFallback } from '../ui/avatar';
import { ArrowLeft, MoreVertical, Phone, Video, Send, Smile, Paperclip, Mic, Image as ImageIcon, Plus, FileText, Film, Camera, X, Check, CheckCheck, CornerUpLeft, Play, Pause, Users, Bell, BellOff, UserX, Trash2, Flag, User, Search, Pin, PinOff, Archive } from 'lucide-react';
import { GroupMembersModal } from '../GroupMembersModal';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '../ui/dropdown-menu';

interface ConversationScreenProps {
  onBack: () => void;
  conversationName: string;
  conversationAvatar?: string;
  conversationColor: string;
  conversationInitials: string;
  isGroup?: boolean;
}

interface Message {
  id: string;
  text: string;
  sender: 'me' | 'other';
  timestamp: string;
  avatar?: string;
  senderName?: string;
  status?: 'sent' | 'delivered' | 'seen'; // Message status
  type?: 'text' | 'voice' | 'image' | 'file' | 'gif' | 'camera'; // Message type
  voiceDuration?: number; // Voice message duration in seconds
  attachmentUrl?: string; // URL for images, files, gifs
  fileName?: string; // File name for file attachments
  fileSize?: string; // File size for file attachments
  replyTo?: {
    id: string;
    text: string;
    sender: string;
  };
}

interface ActionMenuItem {
  id: string;
  icon: React.ReactNode;
  label: string;
  labelBn: string;
  color: string;
  disabled?: boolean;
}

export const ConversationScreen: React.FC<ConversationScreenProps> = ({
  onBack,
  conversationName,
  conversationAvatar,
  conversationColor,
  conversationInitials,
  isGroup = false,
}) => {
  const { language, startCall, theme } = useApp();
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      text: language === 'bn' ? 'হ্যালো! কেমন আছেন?' : 'Hello! How are you?',
      sender: 'other',
      timestamp: language === 'bn' ? '১০:৩০ পূর্বাহ্ন' : '10:30 AM',
      senderName: conversationName,
    },
    {
      id: '2',
      text: language === 'bn' ? 'আমি ভালো আছি, ধন্যবাদ! আপনি?' : 'I am fine, thank you! And you?',
      sender: 'me',
      timestamp: language === 'bn' ? '১০:৩২ পূর্বাহ্ন' : '10:32 AM',
    },
    {
      id: '3',
      text: language === 'bn' ? 'আলহামদুলিল্লাহ, আমিও ভালো।' : 'Alhamdulillah, I am also fine.',
      sender: 'other',
      timestamp: language === 'bn' ? '১০:৩৫ পূর্বাহ্ন' : '10:35 AM',
      senderName: conversationName,
    },
    {
      id: '4',
      text: language === 'bn' ? 'আজকে আমাদের মিটিং কখন?' : 'What time is our meeting today?',
      sender: 'other',
      timestamp: language === 'bn' ? '১০:৩৬ পূর্বাহ্ন' : '10:36 AM',
      senderName: conversationName,
    },
    {
      id: '5',
      text: language === 'bn' ? 'আজ বিকাল ৩টায়। কনফারেন্স রুমে।' : 'Today at 3 PM. In the conference room.',
      sender: 'me',
      timestamp: language === 'bn' ? '১০:৪০ পূর্বাহ্ন' : '10:40 AM',
    },
  ]);
  const [inputValue, setInputValue] = useState('');
  const [showActionMenu, setShowActionMenu] = useState(false);
  const [selectedMessageId, setSelectedMessageId] = useState<string | null>(null); // For showing status
  const [showReplyMenu, setShowReplyMenu] = useState<string | null>(null); // For showing reply menu
  const [replyingTo, setReplyingTo] = useState<Message | null>(null); // Current reply target
  const [isRecording, setIsRecording] = useState(false);
  const [recordingDuration, setRecordingDuration] = useState(0);
  const [playingVoiceId, setPlayingVoiceId] = useState<string | null>(null);
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);
  const [showMembersModal, setShowMembersModal] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [isPinned, setIsPinned] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const recordingIntervalRef = useRef<NodeJS.Timeout | null>(null);

  // Mock group members data
  const groupMembers = [
    { id: 1, name: language === 'bn' ? 'আহমেদ রহমান' : 'Ahmed Rahman', initials: language === 'bn' ? 'আ' : 'AR', color: '#6B9BD1', isAdmin: true, isOnline: true },
    { id: 2, name: language === 'bn' ? 'ফাতিমা খান' : 'Fatima Khan', initials: language === 'bn' ? 'ফ' : 'FK', color: '#E8A87C', isAdmin: false, isOnline: true },
    { id: 3, name: language === 'bn' ? 'মাহমুদ হাসান' : 'Mahmud Hasan', initials: language === 'bn' ? 'ম' : 'MH', color: '#B5A8C9', isAdmin: false, isOnline: false },
    { id: 4, name: language === 'bn' ? 'নাফিসা আক্তার' : 'Nafisa Akter', initials: language === 'bn' ? 'না' : 'NA', color: '#7DA8D9', isAdmin: false, isOnline: true },
    { id: 5, name: language === 'bn' ? 'রাকিব ইসলাম' : 'Rakib Islam', initials: language === 'bn' ? 'রা' : 'RI', color: '#8B9FA8', isAdmin: false, isOnline: false },
    { id: 6, name: language === 'bn' ? 'সাবিনা রহমান' : 'Sabina Rahman', initials: language === 'bn' ? 'সা' : 'SR', color: '#C9A899', isAdmin: false, isOnline: true },
  ];

  const actionMenuItems: ActionMenuItem[] = [
    {
      id: 'files',
      icon: <FileText className="w-5 h-5" />,
      label: 'Files',
      labelBn: 'ফাইল',
      color: '#6B9BD1',
    },
    {
      id: 'gifs',
      icon: <Film className="w-5 h-5" />,
      label: 'GIFs',
      labelBn: 'GIF',
      color: '#A8B5A0',
    },
    {
      id: 'camera',
      icon: <Camera className="w-5 h-5" />,
      label: 'Camera',
      labelBn: 'ক্যামেরা',
      color: '#C9A899',
    },
    {
      id: 'photos',
      icon: <ImageIcon className="w-5 h-5" />,
      label: 'Photos',
      labelBn: 'ছবি',
      color: '#D9A67D',
    },
  ];

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = () => {
    if (inputValue.trim()) {
      const newMessage: Message = {
        id: Date.now().toString(),
        text: inputValue,
        sender: 'me',
        timestamp: new Date().toLocaleTimeString(language === 'bn' ? 'bn-BD' : 'en-US', { 
          hour: '2-digit', 
          minute: '2-digit' 
        }),
        status: 'sent',
        ...(replyingTo && {
          replyTo: {
            id: replyingTo.id,
            text: replyingTo.text,
            sender: replyingTo.sender === 'me' ? (language === 'bn' ? 'আপনি' : 'You') : replyingTo.senderName || conversationName,
          }
        })
      };
      setMessages([...messages, newMessage]);
      setInputValue('');
      setReplyingTo(null);
      
      // Simulate message status updates
      setTimeout(() => {
        setMessages(prev => prev.map(msg => 
          msg.id === newMessage.id ? { ...msg, status: 'delivered' as const } : msg
        ));
      }, 500);
      
      setTimeout(() => {
        setMessages(prev => prev.map(msg => 
          msg.id === newMessage.id ? { ...msg, status: 'seen' as const } : msg
        ));
      }, 1500);
      
      // Simulate response after 1-2 seconds
      setTimeout(() => {
        const responses = language === 'bn' 
          ? ['ঠিক আছে!', 'বুঝেছি', 'ধন্যবাদ!', 'হ্যাঁ, অবশ্যই', 'আচ্ছা']
          : ['Okay!', 'Got it', 'Thanks!', 'Yes, sure', 'Alright'];
        const randomResponse = responses[Math.floor(Math.random() * responses.length)];
        
        const responseMessage: Message = {
          id: (Date.now() + 1).toString(),
          text: randomResponse,
          sender: 'other',
          timestamp: new Date().toLocaleTimeString(language === 'bn' ? 'bn-BD' : 'en-US', { 
            hour: '2-digit', 
            minute: '2-digit' 
          }),
          senderName: conversationName,
        };
        setMessages(prev => [...prev, responseMessage]);
      }, 1000 + Math.random() * 1000);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  const handleMessageClick = (messageId: string) => {
    setSelectedMessageId(selectedMessageId === messageId ? null : messageId);
    setShowReplyMenu(null);
  };

  const handleMessageLongPress = (message: Message) => {
    setShowReplyMenu(message.id);
    setSelectedMessageId(null);
  };

  const handleReply = (message: Message) => {
    setReplyingTo(message);
    setShowReplyMenu(null);
    inputRef.current?.focus();
  };

  // Voice recording handlers
  const startRecording = () => {
    setIsRecording(true);
    setRecordingDuration(0);
    setShowActionMenu(false);
    
    // Start timer
    recordingIntervalRef.current = setInterval(() => {
      setRecordingDuration(prev => prev + 1);
    }, 1000);
  };

  const stopRecording = () => {
    if (recordingIntervalRef.current) {
      clearInterval(recordingIntervalRef.current);
      recordingIntervalRef.current = null;
    }
    
    // Send voice message
    const newMessage: Message = {
      id: Date.now().toString(),
      text: language === 'bn' ? 'ভয়েস মেসেজ' : 'Voice message',
      sender: 'me',
      timestamp: new Date().toLocaleTimeString(language === 'bn' ? 'bn-BD' : 'en-US', { 
        hour: '2-digit', 
        minute: '2-digit' 
      }),
      status: 'sent',
      type: 'voice',
      voiceDuration: recordingDuration,
    };
    
    setMessages(prev => [...prev, newMessage]);
    setIsRecording(false);
    setRecordingDuration(0);
    
    // Simulate message status updates
    setTimeout(() => {
      setMessages(prev => prev.map(msg => 
        msg.id === newMessage.id ? { ...msg, status: 'delivered' as const } : msg
      ));
    }, 500);
    
    setTimeout(() => {
      setMessages(prev => prev.map(msg => 
        msg.id === newMessage.id ? { ...msg, status: 'seen' as const } : msg
      ));
    }, 1500);
  };

  const cancelRecording = () => {
    if (recordingIntervalRef.current) {
      clearInterval(recordingIntervalRef.current);
      recordingIntervalRef.current = null;
    }
    setIsRecording(false);
    setRecordingDuration(0);
  };

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const toggleVoicePlayback = (messageId: string) => {
    setPlayingVoiceId(playingVoiceId === messageId ? null : messageId);
  };

  // Attachment handlers
  const handleAttachment = (type: 'files' | 'gifs' | 'camera' | 'photos') => {
    setShowActionMenu(false);
    
    let messageText = '';
    let messageType: 'text' | 'voice' | 'image' | 'file' | 'gif' | 'camera' = 'text';
    let attachmentUrl = '';
    let fileName = '';
    let fileSize = '';
    
    switch (type) {
      case 'photos':
        messageText = language === 'bn' ? 'ছবি' : 'Photo';
        messageType = 'image';
        attachmentUrl = 'https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?w=400&h=300&fit=crop';
        break;
      case 'camera':
        messageText = language === 'bn' ? 'ক্যামেরা ছবি' : 'Camera photo';
        messageType = 'camera';
        attachmentUrl = 'https://images.unsplash.com/photo-1682687221038-404cb8830901?w=400&h=300&fit=crop';
        break;
      case 'gifs':
        messageText = 'GIF';
        messageType = 'gif';
        attachmentUrl = 'https://images.unsplash.com/photo-1682687220063-4742bd7fd538?w=400&h=300&fit=crop';
        break;
      case 'files':
        messageText = language === 'bn' ? 'ডকুমেন্ট.pdf' : 'Document.pdf';
        messageType = 'file';
        fileName = 'Project_Report_2024.pdf';
        fileSize = '2.4 MB';
        break;
    }
    
    const newMessage: Message = {
      id: Date.now().toString(),
      text: messageText,
      sender: 'me',
      timestamp: new Date().toLocaleTimeString(language === 'bn' ? 'bn-BD' : 'en-US', { 
        hour: '2-digit', 
        minute: '2-digit' 
      }),
      status: 'sent',
      type: messageType,
      attachmentUrl,
      fileName,
      fileSize,
    };
    
    setMessages(prev => [...prev, newMessage]);
    
    // Simulate message status updates
    setTimeout(() => {
      setMessages(prev => prev.map(msg => 
        msg.id === newMessage.id ? { ...msg, status: 'delivered' as const } : msg
      ));
    }, 500);
    
    setTimeout(() => {
      setMessages(prev => prev.map(msg => 
        msg.id === newMessage.id ? { ...msg, status: 'seen' as const } : msg
      ));
    }, 1500);
  };

  // Emoji handler
  const handleEmojiSelect = (emoji: string) => {
    setInputValue(prev => prev + emoji);
    setShowEmojiPicker(false);
    inputRef.current?.focus();
  };

  // Common emojis organized by category
  const emojis = {
    smileys: ['😊', '😂', '🥰', '😍', '🤗', '😘', '😁', '😎', '🤔', '😅', '😢', '😭', '😡', '🥺', '😴', '🤩'],
    gestures: ['👍', '👎', '👏', '🙏', '💪', '✌️', '🤝', '👋', '🤚', '✋', '🙌', '👊', '✊', '🤲', '💅', '🤞'],
    hearts: ['❤️', '💕', '💖', '💗', '💓', '💞', '💝', '💘', '💙', '💚', '💛', '🧡', '💜', '🖤', '🤍', '🤎'],
    celebrations: ['🎉', '🎊', '🎈', '🎁', '🏆', '🥇', '🎯', '⭐', '✨', '💫', '🌟', '🔥', '💯', '🎆', '🎇', '🌈'],
  };

  const getMessageStatus = (message: Message) => {
    if (message.sender !== 'me' || !message.status) return null;
    
    const statusColors = {
      sent: '#8B8B8B',
      delivered: '#8B8B8B',
      seen: '#d97757',
    };

    return (
      <AnimatePresence>
        {selectedMessageId === message.id && (
          <motion.div
            initial={{ opacity: 0, y: -4 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -4 }}
            transition={{ duration: 0.2, ease: 'easeOut' }}
            className="flex items-center gap-1 mt-1"
            style={{
              fontSize: '10px',
              color: statusColors[message.status],
            }}
          >
            {message.status === 'sent' && (
              <>
                <Check className="w-3 h-3" />
                <span>{language === 'bn' ? 'পাঠানো হয়েছে' : 'Sent'}</span>
              </>
            )}
            {message.status === 'delivered' && (
              <>
                <CheckCheck className="w-3 h-3" />
                <span>{language === 'bn' ? 'ডেলিভার হয়েছে' : 'Delivered'}</span>
              </>
            )}
            {message.status === 'seen' && (
              <>
                <CheckCheck className="w-3 h-3" style={{ color: '#d97757' }} />
                <span style={{ color: '#d97757' }}>{language === 'bn' ? 'দেখা হয়েছে' : 'Seen'}</span>
              </>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    );
  };

  return (
    <div className={`fixed inset-0 flex flex-col ${theme === 'dark' ? 'bg-[#052029]' : 'bg-[#f5f5f5]'}`}>
      {/* Header */}
      <header className={`px-4 py-3 border-b flex items-center justify-between backdrop-blur-sm z-50 relative ${
        theme === 'dark' ? 'bg-[#052029]/95 border-[rgba(255,255,255,0.1)]' : 'bg-white/95 border-[rgba(44,44,46,0.12)]'
      }`}>
        <div className="flex items-center gap-3 flex-1">
          <Button
            variant="ghost"
            size="icon"
            className="rounded-full h-10 w-10 hover:bg-muted/80"
            onClick={onBack}
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          
          {/* Avatar & Name */}
          <div 
            className="flex-shrink-0 flex items-center justify-center text-white relative"
            style={{
              width: '42px',
              height: '42px',
              borderRadius: '50%',
              backgroundColor: conversationColor,
              fontSize: '15px',
              fontWeight: '600',
              boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
            }}
          >
            {conversationInitials}
            {/* Online indicator */}
            <div 
              className={`absolute -bottom-0.5 -right-0.5 rounded-full flex items-center justify-center ${
                theme === 'dark' ? 'bg-[#052029]' : 'bg-white'
              }`}
              style={{
                width: '14px',
                height: '14px',
                padding: '2px'
              }}
            >
              <div 
                className="w-full h-full rounded-full bg-green-500"
                style={{
                  boxShadow: theme === 'dark' ? '0 0 0 2px #052029' : '0 0 0 2px white'
                }}
              />
            </div>
          </div>

          <div className="flex-1 min-w-0" onClick={() => isGroup && setShowMembersModal(true)} style={{ cursor: isGroup ? 'pointer' : 'default' }}>
            <h1 
              className={`tracking-tight truncate ${theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}`}
              style={{ 
                fontSize: '17px',
                fontWeight: '600',
                lineHeight: '1.3'
              }}
            >
              {conversationName}
            </h1>
            <p 
              className={`truncate ${theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}`}
              style={{ 
                fontSize: '13px',
                opacity: '0.8'
              }}
            >
              {isGroup ? `${groupMembers.length} ${language === 'bn' ? 'সদস্য' : 'members'}` : language === 'bn' ? 'অনলাইন' : 'Online'}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-1">
          <Button
            variant="ghost"
            size="icon"
            className="rounded-full h-10 w-10 hover:bg-muted/80"
            onClick={() => startCall(conversationName, conversationColor, conversationInitials, false, false, isGroup)}
          >
            <Phone className="w-5 h-5" />
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="rounded-full h-10 w-10 hover:bg-muted/80"
            onClick={() => startCall(conversationName, conversationColor, conversationInitials, true, false, isGroup)}
          >
            <Video className="w-5 h-5" />
          </Button>
          
          {/* 3-Dot Menu */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="rounded-full h-10 w-10 hover:bg-muted/80"
              >
                <MoreVertical className="w-5 h-5" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56 z-[9999]">
              <DropdownMenuLabel>
                {language === 'bn' ? 'অপশন' : 'Options'}
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              
              {/* View Profile / Group Info */}
              <DropdownMenuItem onClick={() => isGroup && setShowMembersModal(true)}>
                {isGroup ? <Users className="w-4 h-4 mr-2" /> : <User className="w-4 h-4 mr-2" />}
                {isGroup 
                  ? (language === 'bn' ? 'গ্রুপ তথ্য' : 'Group Info')
                  : (language === 'bn' ? 'প্রোফাইল দেখুন' : 'View Profile')
                }
              </DropdownMenuItem>

              {/* Search in Conversation */}
              <DropdownMenuItem>
                <Search className="w-4 h-4 mr-2" />
                {language === 'bn' ? 'মেসেজ খুঁজুন' : 'Search Messages'}
              </DropdownMenuItem>

              {/* Pin/Unpin Chat */}
              <DropdownMenuItem onClick={() => setIsPinned(!isPinned)}>
                {isPinned ? (
                  <>
                    <PinOff className="w-4 h-4 mr-2" />
                    {language === 'bn' ? 'আনপিন করুন' : 'Unpin Chat'}
                  </>
                ) : (
                  <>
                    <Pin className="w-4 h-4 mr-2" />
                    {language === 'bn' ? 'পিন করুন' : 'Pin Chat'}
                  </>
                )}
              </DropdownMenuItem>

              {/* Mute/Unmute */}
              <DropdownMenuItem onClick={() => setIsMuted(!isMuted)}>
                {isMuted ? (
                  <>
                    <Bell className="w-4 h-4 mr-2" />
                    {language === 'bn' ? 'আনমিউট করুন' : 'Unmute'}
                  </>
                ) : (
                  <>
                    <BellOff className="w-4 h-4 mr-2" />
                    {language === 'bn' ? 'মিউট করুন' : 'Mute'}
                  </>
                )}
              </DropdownMenuItem>

              <DropdownMenuSeparator />

              {/* Archive */}
              <DropdownMenuItem>
                <Archive className="w-4 h-4 mr-2" />
                {language === 'bn' ? 'আর্কাইভ করুন' : 'Archive Chat'}
              </DropdownMenuItem>

              {/* Delete Chat */}
              <DropdownMenuItem className="text-red-600 dark:text-red-400">
                <Trash2 className="w-4 h-4 mr-2" />
                {language === 'bn' ? 'চ্যাট মুছুন' : 'Delete Chat'}
              </DropdownMenuItem>

              <DropdownMenuSeparator />

              {/* Block/Report (only for 1-on-1) */}
              {!isGroup && (
                <>
                  <DropdownMenuItem className="text-red-600 dark:text-red-400">
                    <UserX className="w-4 h-4 mr-2" />
                    {language === 'bn' ? 'ব্লক করুন' : 'Block User'}
                  </DropdownMenuItem>
                  
                  <DropdownMenuItem className="text-red-600 dark:text-red-400">
                    <Flag className="w-4 h-4 mr-2" />
                    {language === 'bn' ? 'রিপোর্ট করুন' : 'Report User'}
                  </DropdownMenuItem>
                </>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </header>

      {/* Messages Area */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3 bg-white dark:bg-transparent">
        {messages.map((message, index) => (
          <motion.div
            key={message.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.25, ease: 'easeOut' }}
            className={`flex ${message.sender === 'me' ? 'justify-end' : 'justify-start'} relative`}
          >
            <div className={`flex gap-2.5 max-w-[75%] ${message.sender === 'me' ? 'flex-row-reverse' : 'flex-row'}`}>
              {message.sender === 'other' && (
                <div 
                  className="flex-shrink-0 flex items-center justify-center text-white"
                  style={{
                    width: '32px',
                    height: '32px',
                    borderRadius: '50%',
                    backgroundColor: conversationColor,
                    fontSize: '13px',
                    fontWeight: '600',
                  }}
                >
                  {conversationInitials}
                </div>
              )}
              
              <div className="relative">
                {/* Reply Menu Popup */}
                <AnimatePresence>
                  {showReplyMenu === message.id && (
                    <motion.div
                      initial={{ opacity: 0, y: -8 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -8 }}
                      transition={{ duration: 0.2, ease: 'easeOut' }}
                      className={`absolute z-50 ${message.sender === 'me' ? 'right-0' : 'left-0'}`}
                      style={{
                        bottom: 'calc(100% + 8px)',
                      }}
                    >
                      <div
                        className={`px-4 py-2 rounded-xl flex items-center gap-2 cursor-pointer ${
                          theme === 'dark' ? 'bg-[#0a2f3d]/95' : 'bg-white/95'
                        }`}
                        style={{
                          boxShadow: theme === 'dark'
                            ? '0 4px 12px rgba(0, 0, 0, 0.4)'
                            : '0 4px 12px rgba(0, 0, 0, 0.15)',
                          backdropFilter: 'blur(10px)',
                        }}
                        onClick={() => handleReply(message)}
                      >
                        <CornerUpLeft className="w-4 h-4" style={{ color: '#d97757' }} />
                        <span
                          className={theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}
                          style={{
                            fontSize: '14px',
                            fontWeight: '500',
                          }}
                        >
                          {language === 'bn' ? 'উত্তর দিন' : 'Reply'}
                        </span>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>

                <div
                  onClick={() => handleMessageClick(message.id)}
                  onContextMenu={(e) => {
                    e.preventDefault();
                    handleMessageLongPress(message);
                  }}
                  className={`cursor-pointer ${
                    message.sender === 'me'
                      ? 'text-white'
                      : theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
                  }`}
                  style={{
                    backgroundColor: message.sender === 'me' 
                      ? '#d97757' 
                      : theme === 'dark' ? '#0a2f3d' : '#e8e8e8',
                    borderRadius: message.sender === 'me' 
                      ? '18px 18px 4px 18px' 
                      : '18px 18px 18px 4px',
                    padding: '10px 14px',
                    fontSize: '15px',
                    lineHeight: '1.45',
                    boxShadow: message.sender === 'me' 
                      ? '0 1px 2px rgba(217, 119, 87, 0.15)' 
                      : '0 1px 2px rgba(0, 0, 0, 0.08)',
                  }}
                >
                  {/* Reply Preview (if this is a reply) */}
                  {message.replyTo && (
                    <div
                      className="mb-2 pb-2 border-l-2 pl-2"
                      style={{
                        borderColor: message.sender === 'me' ? 'rgba(255,255,255,0.3)' : '#d97757',
                        opacity: 0.8,
                      }}
                    >
                      <p
                        style={{
                          fontSize: '12px',
                          fontWeight: '600',
                          opacity: 0.9,
                        }}
                      >
                        {message.replyTo.sender}
                      </p>
                      <p
                        style={{
                          fontSize: '13px',
                          opacity: 0.7,
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          whiteSpace: 'nowrap',
                        }}
                      >
                        {message.replyTo.text}
                      </p>
                    </div>
                  )}
                  
                  {/* Voice Message UI */}
                  {message.type === 'voice' ? (
                    <div className="flex items-center gap-3 min-w-[180px]">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          toggleVoicePlayback(message.id);
                        }}
                        className="flex-shrink-0 rounded-full p-1.5 transition-all active:scale-95"
                        style={{
                          backgroundColor: message.sender === 'me' 
                            ? 'rgba(255, 255, 255, 0.2)' 
                            : 'rgba(217, 119, 87, 0.15)',
                        }}
                      >
                        {playingVoiceId === message.id ? (
                          <Pause 
                            className="w-4 h-4" 
                            style={{ 
                              color: message.sender === 'me' ? 'white' : '#d97757' 
                            }} 
                          />
                        ) : (
                          <Play 
                            className="w-4 h-4" 
                            style={{ 
                              color: message.sender === 'me' ? 'white' : '#d97757',
                              marginLeft: '1px'
                            }} 
                          />
                        )}
                      </button>
                      
                      {/* Waveform bars */}
                      <div className="flex-1 flex items-center gap-0.5" style={{ height: '24px' }}>
                        {[3, 6, 4, 8, 5, 7, 4, 6, 5, 8, 6, 5].map((height, i) => (
                          <div
                            key={i}
                            className="flex-1 rounded-full transition-all"
                            style={{
                              height: `${height * 2}px`,
                              backgroundColor: message.sender === 'me' 
                                ? 'rgba(255, 255, 255, 0.6)' 
                                : theme === 'dark' ? 'rgba(245, 245, 245, 0.4)' : 'rgba(44, 44, 46, 0.4)',
                              opacity: playingVoiceId === message.id && i <= 6 ? 1 : 0.6,
                            }}
                          />
                        ))}
                      </div>
                      
                      <span
                        style={{
                          fontSize: '13px',
                          fontWeight: '500',
                          opacity: 0.8,
                        }}
                      >
                        {formatDuration(message.voiceDuration || 0)}
                      </span>
                    </div>
                  ) : message.type === 'file' ? (
                    <div className="flex items-center gap-3 min-w-[200px]">
                      <div
                        className="flex-shrink-0 rounded-xl p-2.5 flex items-center justify-center"
                        style={{
                          backgroundColor: message.sender === 'me' 
                            ? 'rgba(255, 255, 255, 0.2)' 
                            : 'rgba(217, 119, 87, 0.15)',
                        }}
                      >
                        <FileText 
                          className="w-6 h-6" 
                          style={{ 
                            color: message.sender === 'me' ? 'white' : '#d97757' 
                          }} 
                        />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p
                          style={{
                            fontSize: '14px',
                            fontWeight: '500',
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                          }}
                        >
                          {message.fileName}
                        </p>
                        <p
                          style={{
                            fontSize: '12px',
                            opacity: 0.7,
                            marginTop: '2px',
                          }}
                        >
                          {message.fileSize}
                        </p>
                      </div>
                    </div>
                  ) : (message.type === 'image' || message.type === 'gif' || message.type === 'camera') ? (
                    <div style={{ margin: '-10px -14px' }}>
                      <img
                        src={message.attachmentUrl}
                        alt={message.text}
                        style={{
                          width: '100%',
                          maxWidth: '250px',
                          height: 'auto',
                          borderRadius: '12px',
                          display: 'block',
                        }}
                      />
                      {message.type === 'gif' && (
                        <div
                          className="absolute top-2 right-2 px-2 py-0.5 rounded"
                          style={{
                            backgroundColor: 'rgba(0, 0, 0, 0.6)',
                            fontSize: '10px',
                            fontWeight: '600',
                            color: 'white',
                          }}
                        >
                          GIF
                        </div>
                      )}
                    </div>
                  ) : (
                    message.text
                  )}
                </div>
                <p
                  className={`mt-1 px-1 ${message.sender === 'me' ? 'text-right' : 'text-left'}`}
                  style={{
                    fontSize: '11px',
                    opacity: '0.55',
                    color: theme === 'dark' ? '#9b9b9b' : '#6b6b6b',
                  }}
                >
                  {message.timestamp}
                </p>
                
                {/* Always visible status indicator for sent messages */}
                {message.sender === 'me' && message.status && (
                  <div className="flex items-center justify-end gap-1 mt-0.5 px-1">
                    {message.status === 'sent' && (
                      <Check className="w-3.5 h-3.5" style={{ color: theme === 'dark' ? '#9b9b9b' : '#6b6b6b', opacity: 0.6 }} />
                    )}
                    {message.status === 'delivered' && (
                      <CheckCheck className="w-3.5 h-3.5" style={{ color: theme === 'dark' ? '#9b9b9b' : '#6b6b6b', opacity: 0.6 }} />
                    )}
                    {message.status === 'seen' && (
                      <CheckCheck className="w-3.5 h-3.5" style={{ color: '#d97757' }} />
                    )}
                  </div>
                )}
                
                {getMessageStatus(message)}
              </div>
            </div>
          </motion.div>
        ))}
        
        {/* Security Note */}
        <div className="flex justify-center py-4">
          <p 
            className={`text-center ${theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}`}
            style={{
              fontSize: '12px',
              opacity: '0.6',
              fontWeight: '400',
            }}
          >
            {language === 'bn' ? 'আপনার মেসেজ এনক্রিপ্টেড ও সুরক্ষিত' : 'Your messages are encrypted and secure'}
          </p>
        </div>
        
        <div ref={messagesEndRef} />
      </div>

      {/* Action Menu (Animated) */}
      <AnimatePresence>
        {showActionMenu && (
          <motion.div 
            className="px-4 pb-2"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            transition={{ duration: 0.25, ease: 'easeOut' }}
          >
            <div 
              className={`rounded-xl p-3 ${
                theme === 'dark' ? 'bg-[#0a2f3d]' : 'bg-white'
              }`}
              style={{
                boxShadow: theme === 'dark' 
                  ? '0 4px 12px rgba(0, 0, 0, 0.3)' 
                  : '0 4px 12px rgba(0, 0, 0, 0.12)',
              }}
            >
              <div className="grid grid-cols-4 gap-3">
                {actionMenuItems.map((item, index) => (
                  <motion.button
                    key={item.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: item.disabled ? 0.4 : 1, y: 0 }}
                    transition={{ delay: index * 0.05, duration: 0.2 }}
                    className={`flex flex-col items-center gap-2 p-3 rounded-xl transition-all ${
                      item.disabled ? 'cursor-not-allowed' : 'hover:bg-muted/40 active:scale-95'
                    }`}
                    disabled={item.disabled}
                    onClick={() => handleAttachment(item.id as 'files' | 'gifs' | 'camera' | 'photos')}
                  >
                    <div 
                      className="w-12 h-12 rounded-full flex items-center justify-center text-white"
                      style={{
                        backgroundColor: item.color,
                        boxShadow: '0 2px 6px rgba(0, 0, 0, 0.12)',
                      }}
                    >
                      {item.icon}
                    </div>
                    <span 
                      className={theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}
                      style={{
                        fontSize: '12px',
                        fontWeight: '500',
                      }}
                    >
                      {language === 'bn' ? item.labelBn : item.label}
                    </span>
                  </motion.button>
                ))}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Emoji Picker (Animated) */}
      <AnimatePresence>
        {showEmojiPicker && (
          <motion.div 
            className= {`px-4 pb-2 ${ theme === 'dark' ? 'bg-[#0a2f3d]' : 'bg-[#ffffff]' }`}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            transition={{ duration: 0.25, ease: 'easeOut' }}
          >
            <div 
              className={`rounded-xl p-4 ${
                theme === 'dark' ? 'bg-[#0a2f3d]' : 'bg-[#ffffff]'
              }`}
              style={{
                boxShadow: theme === 'dark' 
                  ? '0 4px 12px rgba(0, 0, 0, 0.3)' 
                  : '0 4px 12px rgba(0, 0, 0, 0.12)',
                maxHeight: '240px',
                overflowY: 'auto',
              }}
            >
              {/* Smileys */}
              <div className="mb-3">
                <p 
                  className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                  style={{
                    fontSize: '11px',
                    fontWeight: '600',
                    marginBottom: '8px',
                    textTransform: 'uppercase',
                    letterSpacing: '0.5px',
                  }}
                >
                  {language === 'bn' ? 'স্মাইলি' : 'Smileys'}
                </p>
                <div className="grid grid-cols-8 gap-2">
                  {emojis.smileys.map((emoji, index) => (
                    <motion.button
                      key={index}
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: index * 0.02, duration: 0.15 }}
                      className="flex items-center justify-center rounded-lg p-2 transition-all hover:bg-muted/40 dark:hover:bg-[#104050] active:scale-90"
                      onClick={() => handleEmojiSelect(emoji)}
                      style={{
                        fontSize: '24px',
                      }}
                    >
                      {emoji}
                    </motion.button>
                  ))}
                </div>
              </div>

              {/* Gestures */}
              <div className="mb-3">
                <p 
                  className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                  style={{
                    fontSize: '11px',
                    fontWeight: '600',
                    marginBottom: '8px',
                    textTransform: 'uppercase',
                    letterSpacing: '0.5px',
                  }}
                >
                  {language === 'bn' ? 'ইশারা' : 'Gestures'}
                </p>
                <div className="grid grid-cols-8 gap-2">
                  {emojis.gestures.map((emoji, index) => (
                    <motion.button
                      key={index}
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: index * 0.02, duration: 0.15 }}
                      className="flex items-center justify-center rounded-lg p-2 transition-all hover:bg-muted/40 dark:hover:bg-[#104050] active:scale-90"
                      onClick={() => handleEmojiSelect(emoji)}
                      style={{
                        fontSize: '24px',
                      }}
                    >
                      {emoji}
                    </motion.button>
                  ))}
                </div>
              </div>

              {/* Hearts */}
              <div className="mb-3">
                <p 
                  className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                  style={{
                    fontSize: '11px',
                    fontWeight: '600',
                    marginBottom: '8px',
                    textTransform: 'uppercase',
                    letterSpacing: '0.5px',
                  }}
                >
                  {language === 'bn' ? 'হার্ট' : 'Hearts'}
                </p>
                <div className="grid grid-cols-8 gap-2">
                  {emojis.hearts.map((emoji, index) => (
                    <motion.button
                      key={index}
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: index * 0.02, duration: 0.15 }}
                      className="flex items-center justify-center rounded-lg p-2 transition-all hover:bg-muted/40 dark:hover:bg-[#104050] active:scale-90"
                      onClick={() => handleEmojiSelect(emoji)}
                      style={{
                        fontSize: '24px',
                      }}
                    >
                      {emoji}
                    </motion.button>
                  ))}
                </div>
              </div>

              {/* Celebrations */}
              <div>
                <p 
                  className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                  style={{
                    fontSize: '11px',
                    fontWeight: '600',
                    marginBottom: '8px',
                    textTransform: 'uppercase',
                    letterSpacing: '0.5px',
                  }}
                >
                  {language === 'bn' ? 'উদযাপন' : 'Celebrations'}
                </p>
                <div className="grid grid-cols-8 gap-2">
                  {emojis.celebrations.map((emoji, index) => (
                    <motion.button
                      key={index}
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: index * 0.02, duration: 0.15 }}
                      className="flex items-center justify-center rounded-lg p-2 transition-all hover:bg-muted/40 dark:hover:bg-[#104050] active:scale-90"
                      onClick={() => handleEmojiSelect(emoji)}
                      style={{
                        fontSize: '24px',
                      }}
                    >
                      {emoji}
                    </motion.button>
                  ))}
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Input Area */}
      <div className={`px-4 py-3 border-t ${
        theme === 'dark' ? 'bg-[#052029] border-[rgba(255,255,255,0.1)]' : 'bg-[#ffffff] border-[rgba(44,44,46,0.12)]'
      }`}>
        {/* Recording UI */}
        <AnimatePresence>
          {isRecording && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 10 }}
              transition={{ duration: 0.25, ease: 'easeOut' }}
              className={`mb-2.5 px-4 py-3 rounded-xl flex items-center gap-3 ${
                theme === 'dark' ? 'bg-[#0a2f3d]' : 'bg-white'
              }`}
              style={{
                boxShadow: theme === 'dark'
                  ? '0 2px 6px rgba(0, 0, 0, 0.2)'
                  : '0 2px 6px rgba(0, 0, 0, 0.08)',
              }}
            >
              {/* Pulsing record indicator */}
              <motion.div
                className="w-3 h-3 rounded-full bg-red-500"
                animate={{
                  scale: [1, 1.2, 1],
                  opacity: [1, 0.7, 1],
                }}
                transition={{
                  duration: 1.5,
                  repeat: Infinity,
                  ease: 'easeInOut',
                }}
              />
              
              {/* Waveform animation */}
              <div className="flex-1 flex items-center gap-1" style={{ height: '32px' }}>
                {[4, 8, 6, 10, 7, 9, 5, 8, 6, 10, 7, 5].map((baseHeight, i) => (
                  <motion.div
                    key={i}
                    className="flex-1 rounded-full bg-[#d97757]"
                    animate={{
                      height: [`${baseHeight * 2}px`, `${baseHeight * 3}px`, `${baseHeight * 2}px`],
                    }}
                    transition={{
                      duration: 0.8,
                      repeat: Infinity,
                      delay: i * 0.1,
                      ease: 'easeInOut',
                    }}
                  />
                ))}
              </div>
              
              {/* Duration timer */}
              <span
                className={theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}
                style={{
                  fontSize: '15px',
                  fontWeight: '500',
                  minWidth: '45px',
                  textAlign: 'right',
                }}
              >
                {formatDuration(recordingDuration)}
              </span>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Reply Preview Bar */}
        <AnimatePresence>
          {replyingTo && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 10 }}
              transition={{ duration: 0.25, ease: 'easeOut' }}
              className={`mb-2.5 px-3 py-2.5 rounded-xl flex items-center justify-between ${
                theme === 'dark' ? 'bg-[#0a2f3d]' : 'bg-white'
              }`}
              style={{
                boxShadow: theme === 'dark'
                  ? '0 2px 6px rgba(0, 0, 0, 0.2)'
                  : '0 2px 6px rgba(0, 0, 0, 0.08)',
              }}
            >
              <div className="flex items-center gap-2.5 flex-1 min-w-0">
                <div
                  className="w-1 self-stretch rounded-full"
                  style={{ backgroundColor: '#d97757' }}
                />
                <div className="flex-1 min-w-0">
                  <p
                    className={theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}
                    style={{
                      fontSize: '12px',
                      fontWeight: '600',
                      marginBottom: '2px',
                    }}
                  >
                    {language === 'bn' ? 'উত্তর দিচ্ছেন' : 'Replying to'} {replyingTo.sender === 'me' ? (language === 'bn' ? 'নিজেকে' : 'yourself') : replyingTo.senderName}
                  </p>
                  <p
                    className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                    style={{
                      fontSize: '13px',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      whiteSpace: 'nowrap',
                    }}
                  >
                    {replyingTo.text}
                  </p>
                </div>
              </div>
              <Button
                variant="ghost"
                size="icon"
                className="rounded-full h-8 w-8 hover:bg-muted/40 flex-shrink-0"
                onClick={() => setReplyingTo(null)}
              >
                <X className="w-4 h-4" />
              </Button>
            </motion.div>
          )}
        </AnimatePresence>

        <div className="flex items-center gap-2.5">
          {/* Plus/Cancel Button */}
          {isRecording ? (
            <Button
              variant="ghost"
              size="icon"
              className="rounded-full h-10 w-10 hover:bg-muted/80 flex-shrink-0"
              onClick={cancelRecording}
            >
              <X className="w-5 h-5 text-red-500" />
            </Button>
          ) : (
            <Button
              variant="ghost"
              size="icon"
              className="rounded-full h-10 w-10 hover:bg-muted/80 flex-shrink-0"
              onClick={() => setShowActionMenu(!showActionMenu)}
            >
              <motion.div
                animate={{ rotate: showActionMenu ? 45 : 0 }}
                transition={{ duration: 0.2 }}
              >
                <Plus className="w-5 h-5" />
              </motion.div>
            </Button>
          )}

          {/* Input Container - Hidden when recording */}
          {!isRecording && (
            <div 
              className={`flex-1 flex items-center gap-2 px-4 py-2.5 transition-all ${
                theme === 'dark' ? 'bg-[#0a2f3d]' : 'bg-white'
              }`}
              style={{ 
                borderRadius: '24px',
                boxShadow: theme === 'dark' 
                  ? '0 2px 8px rgba(0, 0, 0, 0.2)' 
                  : '0 2px 8px rgba(0, 0, 0, 0.06)',
              }}
            >
              <Button
                variant="ghost"
                size="icon"
                className="rounded-full h-8 w-8 hover:bg-muted/40 flex-shrink-0"
                onClick={() => setShowEmojiPicker(!showEmojiPicker)}
              >
                <Smile className="w-5 h-5 text-muted-foreground" />
              </Button>
              
              <input
                ref={inputRef}
                type="text"
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
                onKeyPress={handleKeyPress}
                placeholder={language === 'bn' ? 'মেসেজ লিখুন...' : 'Type a message...'}
                className={`flex-1 bg-transparent border-none outline-none min-w-0 ${
                  theme === 'dark' ? 'text-[#f5f5f5] placeholder:text-[#9b9b9b]' : 'text-[#2c2c2e] placeholder:text-[#6b6b6b]'
                }`}
                style={{
                  fontSize: '15px',
                  fontWeight: '400',
                }}
              />
            </div>
          )}

          {/* Send/Mic/Stop Recording Button */}
          {isRecording ? (
            <Button
              size="icon"
              className="rounded-full h-11 w-11 flex-shrink-0 shadow-md"
              onClick={stopRecording}
              style={{
                backgroundColor: '#d97757',
              }}
            >
              <Send className="w-5 h-5 text-white" />
            </Button>
          ) : inputValue.trim() ? (
            <Button
              size="icon"
              className="rounded-full h-11 w-11 flex-shrink-0 shadow-md"
              onClick={handleSendMessage}
              style={{
                backgroundColor: '#d97757',
              }}
            >
              <Send className="w-5 h-5 text-white" />
            </Button>
          ) : (
            <Button
              size="icon"
              className="rounded-full h-11 w-11 flex-shrink-0 shadow-md"
              onClick={startRecording}
              style={{
                backgroundColor: '#d97757',
              }}
            >
              <Mic className="w-5 h-5 text-white" />
            </Button>
          )}
        </div>
      </div>

      {/* Group Members Modal */}
      <GroupMembersModal
        isOpen={showMembersModal}
        onClose={() => setShowMembersModal(false)}
        groupName={conversationName}
        members={groupMembers}
      />
    </div>
  );
};