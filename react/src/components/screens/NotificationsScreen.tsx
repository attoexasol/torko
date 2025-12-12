import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';
import { ArrowLeft, Heart, MessageCircle, UserPlus, Radio, Trash2 } from 'lucide-react';

interface Notification {
  id: string;
  type: 'like' | 'comment' | 'follow' | 'stage';
  subtype?: 'post' | 'comment';
  user: string;
  userAvatar: string;
  actionKey: string;
  commentText?: string;
  stageTitle?: string;
  minutesAgo: number;
  isRead: boolean;
}

const mockNotifications: Notification[] = [
  {
    id: '1',
    type: 'like',
    subtype: 'post',
    user: 'রহিম আহমেদ',
    userAvatar: '',
    actionKey: 'likedYourPost',
    minutesAgo: 5,
    isRead: false,
  },
  {
    id: '2',
    type: 'comment',
    user: 'সাবিনা খাতুন',
    userAvatar: '',
    actionKey: 'commentedOnYourPost',
    commentText: 'awesomePost',
    minutesAgo: 15,
    isRead: false,
  },
  {
    id: '3',
    type: 'follow',
    user: 'কামাল হোসেন',
    userAvatar: '',
    actionKey: 'followedYou',
    minutesAgo: 60,
    isRead: false,
  },
  {
    id: '4',
    type: 'stage',
    user: 'ঢাকা টেক কমিউনিটি',
    userAvatar: '',
    actionKey: 'stageLive',
    stageTitle: 'AI এবং ভবিষ্যৎ',
    minutesAgo: 120,
    isRead: true,
  },
  {
    id: '5',
    type: 'like',
    subtype: 'comment',
    user: 'ফাতিমা আক্তার',
    userAvatar: '',
    actionKey: 'likedYourComment',
    minutesAgo: 180,
    isRead: true,
  },
  {
    id: '6',
    type: 'comment',
    user: 'তানিয়া রহমান',
    userAvatar: '',
    actionKey: 'commentedOnYourPost',
    commentText: 'nicePhoto',
    minutesAgo: 240,
    isRead: true,
  },
  {
    id: '7',
    type: 'follow',
    user: 'মাহমুদ হাসান',
    userAvatar: '',
    actionKey: 'followedYou',
    minutesAgo: 300,
    isRead: true,
  },
  {
    id: '8',
    type: 'like',
    subtype: 'post',
    user: 'নাহিদা আক্তার',
    userAvatar: '',
    actionKey: 'likedYourPost',
    minutesAgo: 360,
    isRead: true,
  },
  {
    id: '9',
    type: 'comment',
    user: 'ফারুক ইসলাম',
    userAvatar: '',
    actionKey: 'commentedOnYourPost',
    commentText: 'agreed',
    minutesAgo: 480,
    isRead: true,
  },
  {
    id: '10',
    type: 'stage',
    user: 'বাংলা সাহিত্য',
    userAvatar: '',
    actionKey: 'stageLive',
    stageTitle: 'কবিতা পাঠ',
    minutesAgo: 600,
    isRead: true,
  },
  {
    id: '11',
    type: 'follow',
    user: 'সানজিদা খান',
    userAvatar: '',
    actionKey: 'followedYou',
    minutesAgo: 720,
    isRead: true,
  },
  {
    id: '12',
    type: 'like',
    subtype: 'comment',
    user: 'রাকিব মাহমুদ',
    userAvatar: '',
    actionKey: 'likedYourComment',
    minutesAgo: 1440,
    isRead: true,
  },
];

interface NotificationsScreenProps {
  onNavigate: (screen: string) => void;
}

export const NotificationsScreen: React.FC<NotificationsScreenProps> = ({ onNavigate }) => {
  const { t, language } = useApp();

  const getIcon = (type: Notification['type']) => {
    switch (type) {
      case 'like':
        return <Heart className="w-5 h-5 text-red-500 fill-red-500" />;
      case 'comment':
        return <MessageCircle className="w-5 h-5 text-accent" />;
      case 'follow':
        return <UserPlus className="w-5 h-5 text-accent" />;
      case 'stage':
        return <Radio className="w-5 h-5 text-red-500" />;
    }
  };

  const formatTimestamp = (minutesAgo: number): string => {
    if (minutesAgo < 1) {
      return t('justNow');
    } else if (minutesAgo < 60) {
      const num = language === 'bn' ? toBengaliNumber(minutesAgo) : minutesAgo;
      return `${num} ${t(minutesAgo === 1 ? 'minuteAgo' : 'minutesAgo')}`;
    } else if (minutesAgo < 1440) {
      const hours = Math.floor(minutesAgo / 60);
      const num = language === 'bn' ? toBengaliNumber(hours) : hours;
      return `${num} ${t(hours === 1 ? 'hourAgo' : 'hoursAgo')}`;
    } else {
      const days = Math.floor(minutesAgo / 1440);
      const num = language === 'bn' ? toBengaliNumber(days) : days;
      return `${num} ${t(days === 1 ? 'dayAgo' : 'daysAgo')}`;
    }
  };

  const toBengaliNumber = (num: number): string => {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return num.toString().split('').map(digit => bengaliDigits[parseInt(digit)] || digit).join('');
  };

  const getNotificationContent = (notification: Notification): string => {
    let content = t(notification.actionKey);
    
    if (notification.type === 'comment' && notification.commentText) {
      content += `: "${t(notification.commentText)}"`;
    } else if (notification.type === 'stage' && notification.stageTitle) {
      content += ` - "${notification.stageTitle}"`;
    }
    
    return content;
  };

  const [notifications, setNotifications] = useState(mockNotifications);

  const handleMarkAsRead = (id: string) => {
    setNotifications(
      notifications.map((notification) =>
        notification.id === id ? { ...notification, isRead: true } : notification
      )
    );
  };

  const handleMarkAllAsRead = () => {
    setNotifications(
      notifications.map((notification) => ({ ...notification, isRead: true }))
    );
  };

  const handleDeleteNotification = (id: string) => {
    setNotifications(notifications.filter((notification) => notification.id !== id));
  };

  const unreadCount = notifications.filter((n) => !n.isRead).length;

  return (
    <div className="fixed inset-0 bg-background flex flex-col">
      {/* Header */}
      <div className="px-4 py-3 border-b border-border bg-background relative z-10">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="icon"
              className="rounded-full"
              onClick={() => onNavigate('home')}
            >
              <ArrowLeft className="w-5 h-5" />
            </Button>
            <h1 className="text-2xl">{t('notifications')}</h1>
          </div>
          <Button
            variant="ghost"
            className="text-accent text-sm"
            onClick={handleMarkAllAsRead}
          >
            {t('markAllRead')}
          </Button>
        </div>
      </div>

      {/* Notifications List */}
      <div className="flex-1 overflow-y-auto pb-24">
        {notifications.map((notification, index) => (
          <motion.div
            key={notification.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: index * 0.03, duration: 0.2 }}
            className={`px-4 py-3 hover:bg-muted/50 cursor-pointer transition-colors border-b border-border ${
              !notification.isRead ? 'bg-accent/5' : ''
            }`}
            onClick={() => handleMarkAsRead(notification.id)}
          >
            <div className="flex items-start gap-3">
              <div className="relative">
                <Avatar className="w-10 h-10">
                  <AvatarImage src={notification.userAvatar} />
                  <AvatarFallback className="bg-accent/10 text-accent">
                    {notification.user[0]}
                  </AvatarFallback>
                </Avatar>
                <div className="absolute -bottom-0.5 -right-0.5 w-5 h-5 bg-background rounded-full flex items-center justify-center border-2 border-background">
                  {getIcon(notification.type)}
                </div>
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-2 mb-0.5">
                  <p className="text-sm">
                    <span className="font-medium">{notification.user}</span>
                    {' '}
                    <span className="text-muted-foreground">{getNotificationContent(notification)}</span>
                  </p>
                  {!notification.isRead && (
                    <span className="w-2 h-2 bg-accent rounded-full flex-shrink-0 mt-2" />
                  )}
                </div>
                <p className="text-sm text-muted-foreground">{formatTimestamp(notification.minutesAgo)}</p>
              </div>
              <Button
                variant="ghost"
                size="icon"
                className="rounded-full hover:bg-destructive/10 hover:text-destructive"
                onClick={(e) => {
                  e.stopPropagation();
                  handleDeleteNotification(notification.id);
                }}
              >
                <Trash2 className="w-4.5 h-4.5" />
              </Button>
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  );
};
