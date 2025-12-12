import React, { useState } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { ArrowRight, Check, Calendar, ChevronDown } from 'lucide-react';
import { Calendar as CalendarComponent } from '../ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '../ui/popover';

interface ProfileDataOnboardingScreenProps {
  onComplete: () => void;
}

type Gender = 'male' | 'female' | 'other' | 'prefer-not-to-say' | null;

export const ProfileDataOnboardingScreen: React.FC<ProfileDataOnboardingScreenProps> = ({ onComplete }) => {
  const { t, theme } = useApp();
  const [fullName, setFullName] = useState('');
  const [dateOfBirth, setDateOfBirth] = useState<Date | undefined>(undefined);
  const [gender, setGender] = useState<Gender>(null);
  const [isCalendarOpen, setIsCalendarOpen] = useState(false);
  const [isGenderOpen, setIsGenderOpen] = useState(false);

  const isFormValid = fullName.trim().length > 0 && dateOfBirth && gender;

  const handleSubmit = () => {
    if (isFormValid) {
      // Store user data in localStorage
      if (typeof window !== 'undefined') {
        localStorage.setItem('torko_user_profile', JSON.stringify({
          fullName,
          dateOfBirth: dateOfBirth?.toISOString(),
          gender
        }));
      }
      onComplete();
    }
  };

  const genderOptions: { value: Gender; label: string }[] = [
    { value: 'male', label: t('male') },
    { value: 'female', label: t('female') },
    { value: 'other', label: t('other') },
    { value: 'prefer-not-to-say', label: t('preferNotToSay') },
  ];

  const formatDate = (date: Date) => {
    const day = date.getDate();
    const monthNames = ['জানুয়ারী', 'ফেব্রুয়ারী', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
    const month = monthNames[date.getMonth()];
    const year = date.getFullYear();
    return `${day} ${month} ${year}`;
  };

  return (
    <div className={`relative w-full h-screen overflow-hidden transition-colors duration-500 ${
      theme === 'dark' ? 'bg-[#052029]' : 'bg-neutral-100'
    }`}>
      {/* Main Content */}
      <div className="absolute h-full left-0 overflow-y-auto top-0 w-full">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4 }}
          className="flex flex-col gap-8 px-8 pt-16 pb-8"
        >
          {/* Heading */}
          <div className="flex flex-col gap-2">
            <h1 className={`font-['Noto_Sans_Bengali:Bold',sans-serif] font-bold leading-[40px] text-[36px] tracking-[-0.9px] ${
              theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
            }`}>
              {t('completeProfile')}
            </h1>
            <p className={`font-['Noto_Sans_Bengali:Regular','Noto_Sans:Regular',sans-serif] font-normal leading-[26px] text-[16px] ${
              theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
            }`}>
              {t('completeProfileDesc')}
            </p>
          </div>

          {/* Form Fields */}
          <div className="flex flex-col gap-6">
            {/* Full Name Input */}
            <div className="flex flex-col gap-2">
              <label className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] text-[14px] ${
                theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
              }`}>
                {t('fullName')}
              </label>
              <div className={`relative flex items-center px-[18px] h-[56px] rounded-2xl ${
                theme === 'dark' 
                  ? 'bg-[#0a2f3d] border-2 border-[#0d3a4a]' 
                  : 'bg-[#fafaf8] border-2 border-[rgba(44,44,46,0.1)]'
              }`}>
                <input
                  type="text"
                  placeholder={t('enterFullName')}
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className={`bg-transparent flex-1 font-['Noto_Sans_Bengali:Regular','Noto_Sans:Regular',sans-serif] font-normal outline-none text-[16px] w-full ${
                    theme === 'dark' 
                      ? 'text-[#f5f5f5] placeholder:text-[rgba(255,255,255,0.3)]' 
                      : 'text-[#2c2c2e] placeholder:text-[rgba(44,44,46,0.3)]'
                  }`}
                />
                {fullName.trim().length > 0 && (
                  <motion.div
                    initial={{ scale: 0, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    transition={{ 
                      type: "spring",
                      stiffness: 300,
                      damping: 20
                    }}
                    className="flex-shrink-0 flex items-center justify-center bg-[#B8DED6] rounded-full size-[22px]"
                  >
                    <Check className="w-3.5 h-3.5 text-[#1A1A1A]" strokeWidth={3} />
                  </motion.div>
                )}
              </div>
            </div>

            {/* Date of Birth */}
            <div className="flex flex-col gap-2">
              <label className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] text-[14px] ${
                theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
              }`}>
                {t('dateOfBirth')}
              </label>
              <Popover open={isCalendarOpen} onOpenChange={setIsCalendarOpen}>
                <PopoverTrigger asChild>
                  <button
                    className={`relative flex items-center justify-between px-[18px] h-[56px] rounded-2xl ${
                      theme === 'dark' 
                        ? 'bg-[#0a2f3d] border-2 border-[#0d3a4a]' 
                        : 'bg-[#fafaf8] border-2 border-[rgba(44,44,46,0.1)]'
                    }`}
                  >
                    <span className={`font-['Noto_Sans_Bengali:Regular','Noto_Sans:Regular',sans-serif] font-normal text-[16px] ${
                      dateOfBirth
                        ? theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
                        : theme === 'dark' ? 'text-[rgba(255,255,255,0.3)]' : 'text-[rgba(44,44,46,0.3)]'
                    }`}>
                      {dateOfBirth ? formatDate(dateOfBirth) : t('selectDate')}
                    </span>
                    <div className="flex items-center gap-2">
                      {dateOfBirth && (
                        <motion.div
                          initial={{ scale: 0, opacity: 0 }}
                          animate={{ scale: 1, opacity: 1 }}
                          transition={{ 
                            type: "spring",
                            stiffness: 300,
                            damping: 20
                          }}
                          className="flex-shrink-0 flex items-center justify-center bg-[#B8DED6] rounded-full size-[22px]"
                        >
                          <Check className="w-3.5 h-3.5 text-[#1A1A1A]" strokeWidth={3} />
                        </motion.div>
                      )}
                      <Calendar className={`size-5 ${
                        theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
                      }`} />
                    </div>
                  </button>
                </PopoverTrigger>
                <PopoverContent className={`w-auto p-0 ${
                  theme === 'dark' ? 'bg-[#0a2f3d] border-[#0d3a4a]' : 'bg-[#fafaf8] border-[rgba(44,44,46,0.1)]'
                }`} align="start">
                  <CalendarComponent
                    mode="single"
                    selected={dateOfBirth}
                    onSelect={(date) => {
                      setDateOfBirth(date);
                      setIsCalendarOpen(false);
                    }}
                    disabled={(date) => date > new Date() || date < new Date('1900-01-01')}
                    initialFocus
                    defaultMonth={dateOfBirth || new Date(2000, 0, 1)}
                  />
                </PopoverContent>
              </Popover>
            </div>

            {/* Gender Select */}
            <div className="flex flex-col gap-2">
              <label className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] text-[14px] ${
                theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
              }`}>
                {t('gender')}
              </label>
              <Popover open={isGenderOpen} onOpenChange={setIsGenderOpen}>
                <PopoverTrigger asChild>
                  <button
                    className={`relative flex items-center justify-between px-[18px] h-[56px] rounded-2xl ${
                      theme === 'dark' 
                        ? 'bg-[#0a2f3d] border-2 border-[#0d3a4a]' 
                        : 'bg-[#fafaf8] border-2 border-[rgba(44,44,46,0.1)]'
                    }`}
                  >
                    <span className={`font-['Noto_Sans_Bengali:Regular','Noto_Sans:Regular',sans-serif] font-normal text-[16px] ${
                      gender
                        ? theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
                        : theme === 'dark' ? 'text-[rgba(255,255,255,0.3)]' : 'text-[rgba(44,44,46,0.3)]'
                    }`}>
                      {gender ? genderOptions.find(g => g.value === gender)?.label : t('selectGender')}
                    </span>
                    <div className="flex items-center gap-2">
                      {gender && (
                        <motion.div
                          initial={{ scale: 0, opacity: 0 }}
                          animate={{ scale: 1, opacity: 1 }}
                          transition={{ 
                            type: "spring",
                            stiffness: 300,
                            damping: 20
                          }}
                          className="flex-shrink-0 flex items-center justify-center bg-[#B8DED6] rounded-full size-[22px]"
                        >
                          <Check className="w-3.5 h-3.5 text-[#1A1A1A]" strokeWidth={3} />
                        </motion.div>
                      )}
                      <ChevronDown className={`size-5 ${
                        theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
                      }`} />
                    </div>
                  </button>
                </PopoverTrigger>
                <PopoverContent className={`w-[calc(100vw-64px)] max-w-[704px] p-2 ${
                  theme === 'dark' ? 'bg-[#0a2f3d] border-[#0d3a4a]' : 'bg-[#fafaf8] border-[rgba(44,44,46,0.1)]'
                }`} align="start">
                  <div className="flex flex-col gap-1">
                    {genderOptions.map((option) => (
                      <button
                        key={option.value}
                        onClick={() => {
                          setGender(option.value);
                          setIsGenderOpen(false);
                        }}
                        className={`flex items-center justify-between px-4 py-3 rounded-xl transition-colors ${
                          gender === option.value
                            ? theme === 'dark' 
                              ? 'bg-[rgba(184,222,214,0.15)]' 
                              : 'bg-[rgba(184,222,214,0.3)]'
                            : theme === 'dark'
                              ? 'hover:bg-[#104050]'
                              : 'hover:bg-[rgba(44,44,46,0.05)]'
                        }`}
                      >
                        <span className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal text-[16px] ${
                          theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
                        }`}>
                          {option.label}
                        </span>
                        {gender === option.value && (
                          <div className="flex items-center justify-center bg-[#B8DED6] rounded-full size-[20px]">
                            <Check className="w-3 h-3 text-[#1A1A1A]" strokeWidth={3} />
                          </div>
                        )}
                      </button>
                    ))}
                  </div>
                </PopoverContent>
              </Popover>
            </div>
          </div>

          {/* Submit Button */}
          <div className="flex flex-col gap-4 mt-4">
            <button
              onClick={handleSubmit}
              disabled={!isFormValid}
              className="bg-[#d97757] flex gap-3 h-[56px] items-center justify-center rounded-full shadow-[0px_4px_6px_-1px_rgba(0,0,0,0.1),0px_2px_4px_-2px_rgba(0,0,0,0.1)] transition-opacity w-full disabled:opacity-40"
            >
              <p className="font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[24px] text-[16px] text-neutral-100">
                {t('letsGo')}
              </p>
              <ArrowRight className="size-5 text-neutral-100" strokeWidth={2} />
            </button>
          </div>
        </motion.div>
      </div>
    </div>
  );
};