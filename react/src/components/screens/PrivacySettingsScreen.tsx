import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { ArrowLeft, Lock, Eye, EyeOff, Users, MessageCircle, Shield } from 'lucide-react';

interface PrivacySettingsScreenProps {
  onNavigate: (screen: string) => void;
}

export const PrivacySettingsScreen: React.FC<PrivacySettingsScreenProps> = ({ onNavigate }) => {
  const { language } = useApp();
  const [privacySettings, setPrivacySettings] = useState({
    privateAccount: false,
    showOnlineStatus: true,
    allowMessages: true,
    showReadReceipts: true,
    showTypingIndicator: true,
    allowTagging: true,
    showActivity: true,
  });

  const toggleSetting = (key: keyof typeof privacySettings) => {
    setPrivacySettings(prev => ({
      ...prev,
      [key]: !prev[key]
    }));
  };

  const privacySections = [
    {
      title: language === 'bn' ? 'অ্যাকাউন্ট গোপনীয়তা' : 'Account Privacy',
      items: [
        {
          icon: Lock,
          label: language === 'bn' ? 'ব্যক্তিগত অ্যাকাউন্ট' : 'Private Account',
          description: language === 'bn' ? 'শুধুমাত্র অনুমোদিত ফলোয়াররা আপনার পোস্ট দেখতে পারবে' : 'Only approved followers can see your posts',
          value: privacySettings.privateAccount,
          onChange: () => toggleSetting('privateAccount'),
        },
        {
          icon: Eye,
          label: language === 'bn' ? 'অনলাইন স্ট্যাটাস দেখান' : 'Show Online Status',
          description: language === 'bn' ? 'অন্যরা দেখতে পারবে আপনি অনলাইনে আছেন কিনা' : 'Let others see when you\'re online',
          value: privacySettings.showOnlineStatus,
          onChange: () => toggleSetting('showOnlineStatus'),
        },
        {
          icon: Users,
          label: language === 'bn' ? 'কার্যকলাপ দেখান' : 'Show Activity',
          description: language === 'bn' ? 'আপনার লাইক এবং কমেন্ট দেখান' : 'Show your likes and comments',
          value: privacySettings.showActivity,
          onChange: () => toggleSetting('showActivity'),
        },
      ],
    },
    {
      title: language === 'bn' ? 'মেসেজিং' : 'Messaging',
      items: [
        {
          icon: MessageCircle,
          label: language === 'bn' ? 'যে কেউ মেসেজ পাঠাতে পারবে' : 'Allow Messages from Anyone',
          description: language === 'bn' ? 'সকলের কাছ থেকে মেসেজ গ্রহণ করুন' : 'Accept messages from everyone',
          value: privacySettings.allowMessages,
          onChange: () => toggleSetting('allowMessages'),
        },
        {
          icon: Eye,
          label: language === 'bn' ? 'রিড রিসিট দেখান' : 'Show Read Receipts',
          description: language === 'bn' ? 'প্রেরক জানতে পারবে আপনি মেসেজ পড়েছেন' : 'Let senders know you\'ve read their messages',
          value: privacySettings.showReadReceipts,
          onChange: () => toggleSetting('showReadReceipts'),
        },
        {
          icon: MessageCircle,
          label: language === 'bn' ? 'টাইপিং ইন্ডিকেটর' : 'Typing Indicator',
          description: language === 'bn' ? 'দেখান যখন আপনি টাইপ করছেন' : 'Show when you\'re typing',
          value: privacySettings.showTypingIndicator,
          onChange: () => toggleSetting('showTypingIndicator'),
        },
      ],
    },
    {
      title: language === 'bn' ? 'ইন্টারঅ্যাকশন' : 'Interactions',
      items: [
        {
          icon: Users,
          label: language === 'bn' ? 'অন্যরা আমাকে ট্যাগ করতে পারবে' : 'Allow Others to Tag Me',
          description: language === 'bn' ? 'পোস্ট এবং কমেন্টে ট্যাগ করার অনুমতি দিন' : 'Allow tagging in posts and comments',
          value: privacySettings.allowTagging,
          onChange: () => toggleSetting('allowTagging'),
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
            {language === 'bn' ? 'গোপনীয়তা সেটিংস' : 'Privacy Settings'}
          </h1>
        </div>
      </header>

      {/* Content */}
      <div className="flex-1 overflow-y-auto">
        <div className="px-6 pt-6 pb-8">
          {/* Info Banner */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
            className="bg-secondary/20 border border-secondary/30 p-4 mb-6 flex gap-3"
            style={{ borderRadius: '12px' }}
          >
            <Shield className="w-5 h-5 text-secondary flex-shrink-0 mt-0.5" />
            <p 
              className="text-foreground" 
              style={{ 
                fontSize: '14px',
                lineHeight: '1.5'
              }}
            >
              {language === 'bn' 
                ? 'আপনার গোপনীয়তা নিয়ন্ত্রণ করুন এবং আপনার তথ্য কে দেখতে পারবে তা সিদ্ধান্ত নিন।'
                : 'Control your privacy and decide who can see your information.'}
            </p>
          </motion.div>

          {/* Privacy Sections */}
          {privacySections.map((section, sectionIndex) => (
            <motion.section
              key={sectionIndex}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: (sectionIndex + 1) * 0.1, duration: 0.3 }}
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
                    className="bg-card border border-border/50 hover:border-border transition-all duration-200"
                    style={{ 
                      borderRadius: '12px',
                      boxShadow: '0 2px 8px rgba(0, 0, 0, 0.08)'
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

          {/* Blocked Users */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4, duration: 0.3 }}
            className="mt-8"
          >
            <Button
              variant="outline"
              className="w-full justify-between"
              style={{ 
                height: '56px',
                borderRadius: '12px'
              }}
            >
              <span style={{ fontSize: '16px', fontWeight: '500' }}>
                {language === 'bn' ? 'ব্লক করা ব্যবহারকারী' : 'Blocked Users'}
              </span>
              <span 
                className="text-muted-foreground" 
                style={{ fontSize: '14px' }}
              >
                0
              </span>
            </Button>
          </motion.div>
        </div>
      </div>
    </div>
  );
};
