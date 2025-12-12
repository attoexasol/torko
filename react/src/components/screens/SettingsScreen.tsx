import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { 
  ArrowLeft, 
  User, 
  Lock, 
  Bell, 
  Globe, 
  Moon, 
  Sun,
  HelpCircle,
  FileText,
  Shield,
  LogOut,
  ChevronRight,
  MapPin
} from 'lucide-react';

interface SettingsScreenProps {
  onNavigate: (screen: string) => void;
}

export const SettingsScreen: React.FC<SettingsScreenProps> = ({ onNavigate }) => {
  const { t, language, setLanguage, theme, toggleTheme } = useApp();
  const [showNearby, setShowNearby] = useState(false);

  const settingsSections = [
    {
      title: language === 'bn' ? 'অ্যাকাউন্ট' : 'Account',
      items: [
        { 
          icon: User, 
          label: language === 'bn' ? 'অ্যাকাউন্ট সেটিংস' : 'Account Settings', 
          action: () => onNavigate('accountSettings')
        },
        { 
          icon: Lock, 
          label: language === 'bn' ? 'গোপনীয়তা সেটিংস' : 'Privacy Settings', 
          action: () => onNavigate('privacySettings')
        },
        { 
          icon: Bell, 
          label: language === 'bn' ? 'নোটিফিকেশন সেটিংস' : 'Notification Settings', 
          action: () => onNavigate('notificationSettings')
        },
      ],
    },
    {
      title: language === 'bn' ? 'লোকেশন ও গোপনীয়তা' : 'Location & Privacy',
      items: [
        { 
          icon: MapPin, 
          label: language === 'bn' ? 'আমাকে কাছাকাছি লোকদের কাছে দেখান' : 'Show me to nearby people', 
          action: () => setShowNearby(!showNearby),
          description: language === 'bn' ? 'আপনার লোকেশন শেয়ার করুন এবং কাছাকাছি কমিউনিটি আবিষ্কার করুন' : 'Share your location and discover nearby communities',
          hasSwitch: true,
          switchValue: showNearby,
        },
      ],
    },
    {
      title: language === 'bn' ? 'পছন্দসমূহ' : 'Preferences',
      items: [
        { 
          icon: Globe, 
          label: language === 'bn' ? 'ভাষা' : 'Language', 
          action: () => setLanguage(language === 'bn' ? 'en' : 'bn'),
          value: language === 'bn' ? 'বাংলা' : 'English',
        },
        { 
          icon: theme === 'dark' ? Moon : Sun, 
          label: language === 'bn' ? 'থিম' : 'Theme', 
          action: toggleTheme,
          description: theme === 'dark' ? (language === 'bn' ? 'ডার্ক মোড' : 'Dark Mode') : (language === 'bn' ? 'লাইট মোড' : 'Light Mode'),
          hasSwitch: true,
        },
      ],
    },
    {
      title: language === 'bn' ? 'সহায়তা' : 'Support',
      items: [
        { 
          icon: HelpCircle, 
          label: language === 'bn' ? 'সাহায্য কেন্দ্র' : 'Help Center', 
          action: () => {} 
        },
        { 
          icon: FileText, 
          label: language === 'bn' ? 'শর্তাবলী' : 'Terms of Service', 
          action: () => {} 
        },
        { 
          icon: Shield, 
          label: language === 'bn' ? 'গোপনীয়তা নীতি' : 'Privacy Policy', 
          action: () => {} 
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
            onClick={() => onNavigate('profile')}
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <h1 
            className="text-[22px] tracking-tight" 
            style={{ lineHeight: '1.4' }}
          >
            {t('settings')}
          </h1>
        </div>
      </header>

      {/* Content */}
      <div className="flex-1 overflow-y-auto">
        <div className="px-6 pt-6 pb-8">
          {/* Sections */}
          {settingsSections.map((section, sectionIndex) => (
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

              {/* Cards Container */}
              <div className="space-y-4">
                {section.items.map((item, itemIndex) => (
                  <motion.div
                    key={itemIndex}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: (sectionIndex * 0.1) + (itemIndex * 0.05), duration: 0.3 }}
                  >
                    {item.hasSwitch ? (
                      <div 
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
                            {item.description && (
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
                            )}
                          </div>

                          {/* Switch */}
                          <Switch 
                            checked={item.switchValue !== undefined ? item.switchValue : theme === 'dark'} 
                            onCheckedChange={item.action}
                            className="flex-shrink-0"
                          />
                        </div>
                      </div>
                    ) : (
                      <button
                        onClick={item.action}
                        className="w-full bg-card border border-border/50 hover:border-border hover:bg-card/80 transition-all duration-200 text-left"
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
                            {item.value && (
                              <p 
                                className="text-muted-foreground mt-1" 
                                style={{ 
                                  fontSize: '14px',
                                  lineHeight: '1.4',
                                  opacity: '0.7'
                                }}
                              >
                                {item.value}
                              </p>
                            )}
                          </div>

                          {/* Chevron */}
                          <ChevronRight className="w-5 h-5 text-muted-foreground flex-shrink-0 opacity-50" />
                        </div>
                      </button>
                    )}
                  </motion.div>
                ))}
              </div>
            </motion.section>
          ))}

          {/* App Version */}
          <div 
            className="text-center text-muted-foreground mt-8" 
            style={{ 
              fontSize: '14px',
              opacity: '0.5'
            }}
          >
            {language === 'bn' ? 'সংস্করণ' : 'Version'} 1.0.0
          </div>

          {/* Logout Button */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.3 }}
            className="mt-8"
          >
            <Button
              variant="destructive"
              className="w-full gap-2 transition-all duration-200"
              style={{ 
                height: '48px',
                borderRadius: '12px',
                fontSize: '16px',
                fontWeight: '500'
              }}
            >
              <LogOut className="w-5 h-5" />
              {t('logout')}
            </Button>
          </motion.div>
        </div>
      </div>
    </div>
  );
};