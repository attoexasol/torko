import React from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import communityIllustration from 'figma:asset/064b2e909a16e9c01aeefc0200a24a582996e060.png';
import { Languages } from 'lucide-react';

interface OnboardingScreenProps {
  onComplete: () => void;
}

export const OnboardingScreen: React.FC<OnboardingScreenProps> = ({ onComplete }) => {
  const { theme, language, setLanguage } = useApp();

  return (
    <div className="relative w-full h-screen overflow-hidden">
      {/* Full-Screen Community Illustration Background */}
      <div className="absolute inset-0">
        {/* Main Background - Community Illustration */}
        <div className="absolute inset-0" style={{ backgroundColor: 'transparent' }}>
          <img
            src={communityIllustration}
            alt="Community neighborhood illustration - Torko"
            className="w-full h-full object-cover"
          />
        </div>
      </div>

      {/* Language Toggle - Top Right */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.2, ease: "easeOut" }}
        className="absolute top-6 right-6 z-10"
      >
        <button
          onClick={() => setLanguage(language === 'bn' ? 'en' : 'bn')}
          className="bg-black/40 hover:bg-black/50 backdrop-blur-md transition-all duration-200 flex items-center gap-2 px-4 py-2.5 rounded-full shadow-lg border border-white/30"
        >
          <Languages 
            className="text-white" 
            size={18} 
          />
          <span 
            className="text-white"
            style={{
              fontFamily: "'Noto Sans Bengali', sans-serif",
              fontWeight: 600,
              fontSize: '14px',
              lineHeight: '20px',
            }}
          >
            {language === 'bn' ? 'EN' : 'বাংলা'}
          </span>
        </button>
      </motion.div>

      {/* Content Area - Bottom Center */}
      <div className="absolute inset-0 flex flex-col justify-start items-center p-6 pb-40 mt-30">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: "easeOut" }}
          className="flex flex-col gap-4 w-full max-w-[500px]"
        >
          {/* Text Section - Clean, Single Instances */}
          <div className="flex flex-col gap-4 mb-4 text-center">
            {/* Main Title - Bold, Dark, High Contrast */}
            <h1 
              style={{
                fontFamily: "'Noto Sans Bengali', sans-serif",
                fontWeight: 700,
                fontSize: '48px',
                lineHeight: '56px',
                letterSpacing: '-0.5px',
                color: '#ffffff',
              }}
            >
              {language === 'bn' ? 'তর্কে স্বাগতম' : 'Welcome to Torko'}
            </h1>

            {/* Subtitle - Regular, Slightly Soft Contrast */}
            <p 
              style={{
                fontFamily: "'Noto Sans Bengali', sans-serif",
                fontWeight: 400,
                fontSize: '18px',
                lineHeight: '28px',
                color: '#F2F2F2',
              }}
            >
              {language === 'bn' 
                ? 'আপনার চিন্তা শেয়ার করুন, বন্ধুদের সাথে যুক্ত থাকুন' 
                : 'Share your thoughts, stay connected with friends'}
            </p>
          </div>

          {/* Primary CTA Button - Rounded with Proper Spacing */}
          <div className="flex justify-center">
            <button
              onClick={onComplete}
              className="hover:bg-[#c86847] active:scale-[0.98] transition-all duration-200"
              style={{
                display: 'flex',
                flexDirection: 'row',
                justifyContent: 'center',
                alignItems: 'center',
                gap: '10px',
                width: '279px',
                height: '55px',
                background: '#D6775C',
                borderRadius: '14px',
              }}
            >
              <span 
                className="text-white"
                style={{
                  fontFamily: "'Noto Sans Bengali', sans-serif",
                  fontWeight: 500,
                  fontSize: '18px',
                  lineHeight: '24px',
                }}
              >
                {language === 'bn' ? 'শুরু করুন' : 'Get Started'}
              </span>
              <svg 
                width="20" 
                height="20" 
                viewBox="0 0 24 24" 
                fill="none"
                className="flex-shrink-0"
              >
                <path 
                  d="M5 12H19M19 12L12 5M19 12L12 19" 
                  stroke="white" 
                  strokeWidth="2.5" 
                  strokeLinecap="round" 
                  strokeLinejoin="round"
                />
              </svg>
            </button>
          </div>
        </motion.div>
      </div>
    </div>
  );
};