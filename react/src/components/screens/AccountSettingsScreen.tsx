import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { ArrowLeft, User, Mail, Phone, Calendar, MapPin, Edit2 } from 'lucide-react';

interface AccountSettingsScreenProps {
  onNavigate: (screen: string) => void;
}

export const AccountSettingsScreen: React.FC<AccountSettingsScreenProps> = ({ onNavigate }) => {
  const { language } = useApp();
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    name: 'রহিম আহমেদ',
    username: '@rahim_ahmed',
    email: 'rahim@example.com',
    phone: '+880 1712-345678',
    bio: 'ঢাকায় থাকি। প্রযুক্তি এবং ফটোগ্রাফি পছন্দ করি।',
    location: 'ঢাকা, বাংলাদেশ',
  });

  const handleSave = () => {
    setIsEditing(false);
    // Save logic here
  };

  return (
    <div className="fixed inset-0 bg-background flex flex-col">
      {/* Header */}
      <header className="px-6 pt-6 pb-4 border-b border-border/50">
        <div className="flex items-center justify-between">
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
              {language === 'bn' ? 'অ্যাকাউন্ট সেটিংস' : 'Account Settings'}
            </h1>
          </div>
          <Button
            variant={isEditing ? "default" : "ghost"}
            size="sm"
            onClick={() => isEditing ? handleSave() : setIsEditing(true)}
            className="gap-2"
            style={{ borderRadius: '8px' }}
          >
            <Edit2 className="w-4 h-4" />
            {isEditing 
              ? (language === 'bn' ? 'সংরক্ষণ করুন' : 'Save')
              : (language === 'bn' ? 'সম্পাদনা' : 'Edit')
            }
          </Button>
        </div>
      </header>

      {/* Content */}
      <div className="flex-1 overflow-y-auto">
        <div className="px-6 pt-6 pb-8">
          {/* Profile Picture */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
            className="flex flex-col items-center mb-8"
          >
            <div 
              className="relative bg-gradient-to-br from-accent to-secondary flex items-center justify-center mb-4"
              style={{ 
                width: '100px', 
                height: '100px',
                borderRadius: '50%'
              }}
            >
              <User className="w-12 h-12 text-white" />
              {isEditing && (
                <button
                  className="absolute bottom-0 right-0 bg-accent text-white p-2 border-4 border-background"
                  style={{ borderRadius: '50%' }}
                >
                  <Edit2 className="w-4 h-4" />
                </button>
              )}
            </div>
            <p 
              className="text-muted-foreground" 
              style={{ fontSize: '14px' }}
            >
              {language === 'bn' ? 'প্রোফাইল ছবি পরিবর্তন করুন' : 'Change profile picture'}
            </p>
          </motion.div>

          {/* Form Fields */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.3 }}
            className="space-y-6"
          >
            {/* Name */}
            <div>
              <label 
                className="block mb-2 text-foreground" 
                style={{ 
                  fontSize: '14px',
                  fontWeight: '500'
                }}
              >
                {language === 'bn' ? 'নাম' : 'Name'}
              </label>
              <Input
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                disabled={!isEditing}
                className="h-12"
                style={{ borderRadius: '10px' }}
              />
            </div>

            {/* Username */}
            <div>
              <label 
                className="block mb-2 text-foreground" 
                style={{ 
                  fontSize: '14px',
                  fontWeight: '500'
                }}
              >
                {language === 'bn' ? 'ইউজারনেম' : 'Username'}
              </label>
              <Input
                value={formData.username}
                onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                disabled={!isEditing}
                className="h-12"
                style={{ borderRadius: '10px' }}
              />
            </div>

            {/* Email */}
            <div>
              <label 
                className="block mb-2 text-foreground" 
                style={{ 
                  fontSize: '14px',
                  fontWeight: '500'
                }}
              >
                {language === 'bn' ? 'ইমেইল' : 'Email'}
              </label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                <Input
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  disabled={!isEditing}
                  className="h-12 pl-10"
                  style={{ borderRadius: '10px' }}
                />
              </div>
            </div>

            {/* Phone */}
            <div>
              <label 
                className="block mb-2 text-foreground" 
                style={{ 
                  fontSize: '14px',
                  fontWeight: '500'
                }}
              >
                {language === 'bn' ? 'ফোন' : 'Phone'}
              </label>
              <div className="relative">
                <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                <Input
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  disabled={!isEditing}
                  className="h-12 pl-10"
                  style={{ borderRadius: '10px' }}
                />
              </div>
            </div>

            {/* Bio */}
            <div>
              <label 
                className="block mb-2 text-foreground" 
                style={{ 
                  fontSize: '14px',
                  fontWeight: '500'
                }}
              >
                {language === 'bn' ? 'বায়ো' : 'Bio'}
              </label>
              <textarea
                value={formData.bio}
                onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                disabled={!isEditing}
                rows={3}
                className="w-full px-4 py-3 bg-background border border-input rounded-[10px] resize-none focus:outline-none focus:ring-2 focus:ring-ring disabled:opacity-50"
                style={{ fontSize: '15px' }}
              />
            </div>

            {/* Location */}
            <div>
              <label 
                className="block mb-2 text-foreground" 
                style={{ 
                  fontSize: '14px',
                  fontWeight: '500'
                }}
              >
                {language === 'bn' ? 'অবস্থান' : 'Location'}
              </label>
              <div className="relative">
                <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                <Input
                  value={formData.location}
                  onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                  disabled={!isEditing}
                  className="h-12 pl-10"
                  style={{ borderRadius: '10px' }}
                />
              </div>
            </div>
          </motion.div>

          {/* Danger Zone */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.3 }}
            className="mt-8 pt-8 border-t border-border/50"
          >
            <h3 
              className="mb-4 text-destructive" 
              style={{ 
                fontSize: '16px',
                fontWeight: '600'
              }}
            >
              {language === 'bn' ? 'বিপজ্জনক জোন' : 'Danger Zone'}
            </h3>
            <Button
              variant="outline"
              className="w-full border-destructive text-destructive hover:bg-destructive hover:text-white transition-all duration-200"
              style={{ 
                height: '48px',
                borderRadius: '10px'
              }}
            >
              {language === 'bn' ? 'অ্যাকাউন্ট ডিলিট করুন' : 'Delete Account'}
            </Button>
          </motion.div>
        </div>
      </div>
    </div>
  );
};
