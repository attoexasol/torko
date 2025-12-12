import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { ArrowLeft, Bell, MessageCircle, Heart, Users, AtSign, Megaphone } from 'lucide-react';

interface NotificationSettingsScreenProps {
  onNavigate: (screen: string) => void;
}

export const NotificationSettingsScreen: React.FC<NotificationSettingsScreenProps> = ({ onNavigate }) => {
  const { language } = useApp();
  const [notificationSettings, setNotificationSettings] = useState({
    pushNotifications: true,
    likes: true,
    comments: true,
    newFollowers: true,
    mentions: true,
    messages: true,
    communityUpdates: true,
    emailNotifications: false,
  });

  const toggleSetting = (key: keyof typeof notificationSettings) => {
    setNotificationSettings(prev => ({
      ...prev,
      [key]: !prev[key]
    }));
  };

  const notificationSections = [
    {
      title: language === 'bn' ? 'পুশ নোটিফিকেশন' : 'Push Notifications',
      items: [
        {
          icon: Bell,
          label: language === 'bn' ? 'পুশ নোটিফিকেশন চালু করুন' : 'Enable Push Notifications',
          description: language === 'bn' ? 'আপনার ডিভাইসে নোটিফিকেশন পান' : 'Receive notifications on your device',
          value: notificationSettings.pushNotifications,
          onChange: () => toggleSetting('pushNotifications'),
          highlighted: true,
        },
      ],
    },
    {
      title: language === 'bn' ? 'কার্যকলাপ' : 'Activity',
      items: [
        {
          icon: Heart,
          label: language === 'bn' ? 'লাইক' : 'Likes',
          description: language === 'bn' ? 'যখন কেউ আপনার পোস্ট লাইক করে' : 'When someone likes your post',
          value: notificationSettings.likes,
          onChange: () => toggleSetting('likes'),
        },
        {
          icon: MessageCircle,
          label: language === 'bn' ? 'কমেন্ট' : 'Comments',
          description: language === 'bn' ? 'যখন কেউ আপনার পোস্টে কমেন্ট করে' : 'When someone comments on your post',
          value: notificationSettings.comments,
          onChange: () => toggleSetting('comments'),
        },
        {
          icon: AtSign,
          label: language === 'bn' ? 'মেনশন' : 'Mentions',
          description: language === 'bn' ? 'যখন কেউ আপনাকে ট্যাগ করে' : 'When someone mentions you',
          value: notificationSettings.mentions,
          onChange: () => toggleSetting('mentions'),
        },
      ],
    },
    {
      title: language === 'bn' ? 'সামাজিক' : 'Social',
      items: [
        {
          icon: Users,
          label: language === 'bn' ? 'নতুন ফলোয়ার' : 'New Followers',
          description: language === 'bn' ? 'যখন কেউ আপনাকে ফলো করে' : 'When someone follows you',
          value: notificationSettings.newFollowers,
          onChange: () => toggleSetting('newFollowers'),
        },
        {
          icon: MessageCircle,
          label: language === 'bn' ? 'মেসেজ' : 'Messages',
          description: language === 'bn' ? 'নতুন ডাইরেক্ট মেসেজ' : 'New direct messages',
          value: notificationSettings.messages,
          onChange: () => toggleSetting('messages'),
        },
      ],
    },
    {
      title: language === 'bn' ? 'কমিউনিটি' : 'Community',
      items: [
        {
          icon: Megaphone,
          label: language === 'bn' ? 'কমিউনিটি আপডেট' : 'Community Updates',
          description: language === 'bn' ? 'আপনার কমিউনিটি থেকে আপডেট' : 'Updates from your communities',
          value: notificationSettings.communityUpdates,
          onChange: () => toggleSetting('communityUpdates'),
        },
      ],
    },
    {
      title: language === 'bn' ? 'অন্যান্য' : 'Other',
      items: [
        {
          icon: Bell,
          label: language === 'bn' ? 'ইমেইল নোটিফিকেশন' : 'Email Notifications',
          description: language === 'bn' ? 'ইমেইলে নোটিফিকেশন পান' : 'Receive notifications via email',
          value: notificationSettings.emailNotifications,
          onChange: () => toggleSetting('emailNotifications'),
        },
      ],
    },
  ];

  return (
    <div className="fixed inset-0 bg-background flex flex-col">
      {/* Header */}
      <header className="px-6 pt-6 pb-4 border-b border-border/50">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="icon"
            className="rounded-full h-10 w-10 -ml-2 hover:bg-accent/10"
            onClick={() => onNavigate('settings')}
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <h1 
            className="text-[22px] tracking-tight" 
            style={{ lineHeight: '1.4' }}
          >
            {language === 'bn' ? 'নোটিফিকেশন সেটিংস' : 'Notification Settings'}
          </h1>
        </div>
      </header>

      {/* Content */}
      <div className="flex-1 overflow-y-auto">
        <div className="px-6 pt-6 pb-8">
          {/* Notification Sections */}
          {notificationSections.map((section, sectionIndex) => (
            <motion.section
              key={sectionIndex}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: sectionIndex * 0.1, duration: 0.3 }}
              className={sectionIndex > 0 ? 'mt-8' : ''}
            >
              {/* Section Title */}
              <h2 
                className="mb-4 opacity-60" 
                style={{ 
                  fontSize: '18px', 
                  fontWeight: '600',
                  lineHeight: '1.4'
                }}
              >
                {section.title}
              </h2>

              {/* Settings Cards */}
              <div className="space-y-4">
                {section.items.map((item, itemIndex) => (
                  <div
                    key={itemIndex}
                    className={`bg-card border transition-all duration-200 ${
                      item.highlighted 
                        ? 'border-accent ring-2 ring-accent/20 bg-accent/5' 
                        : 'border-border/50 hover:border-border'
                    }`}
                    style={{ 
                      borderRadius: '12px',
                      boxShadow: item.highlighted 
                        ? '0 4px 12px rgba(217, 119, 87, 0.15)' 
                        : '0 2px 8px rgba(0, 0, 0, 0.08)'
                    }}
                  >
                    <div className="p-4 flex items-center gap-4">
                      {/* Icon */}
                      <div 
                        className="bg-accent/10 flex items-center justify-center flex-shrink-0"
                        style={{ 
                          width: '40px', 
                          height: '40px',
                          borderRadius: '10px'
                        }}
                      >
                        <item.icon className="w-5 h-5 text-accent" />
                      </div>

                      {/* Text Content */}
                      <div className="flex-1 min-w-0">
                        <p 
                          className="text-foreground" 
                          style={{ 
                            fontSize: '16px',
                            fontWeight: '500',
                            lineHeight: '1.4'
                          }}
                        >
                          {item.label}
                        </p>
                        <p 
                          className="text-muted-foreground mt-1" 
                          style={{ 
                            fontSize: '14px',
                            lineHeight: '1.4',
                            opacity: '0.7'
                          }}
                        >
                          {item.description}
                        </p>
                      </div>

                      {/* Switch */}
                      <Switch 
                        checked={item.value} 
                        onCheckedChange={item.onChange}
                        className="flex-shrink-0"
                      />
                    </div>
                  </div>
                ))}
              </div>
            </motion.section>
          ))}

          {/* Quiet Hours */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.3 }}
            className="mt-8 pt-8 border-t border-border/50"
          >
            <h3 
              className="mb-4 opacity-60" 
              style={{ 
                fontSize: '18px',
                fontWeight: '600'
              }}
            >
              {language === 'bn' ? 'নিরব সময়' : 'Quiet Hours'}
            </h3>
            <Button
              variant="outline"
              className="w-full justify-between"
              style={{ 
                height: '56px',
                borderRadius: '12px'
              }}
            >
              <span style={{ fontSize: '16px', fontWeight: '500' }}>
                {language === 'bn' ? 'নিরব সময় সেট করুন' : 'Set Quiet Hours'}
              </span>
              <span 
                className="text-muted-foreground" 
                style={{ fontSize: '14px' }}
              >
                {language === 'bn' ? 'বন্ধ' : 'Off'}
              </span>
            </Button>
          </motion.div>
        </div>
      </div>
    </div>
  );
};
