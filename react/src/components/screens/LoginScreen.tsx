import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { ArrowLeft, ArrowRight, Sun, Moon, Phone, Check } from 'lucide-react';
import { InputOTP, InputOTPGroup, InputOTPSlot } from '../ui/input-otp';
import svgPaths from '../../imports/svg-ti0ghl5u57';

interface LoginScreenProps {
  onComplete: () => void;
  onBack?: () => void;
  isReturningUser?: boolean;
}

export const LoginScreen: React.FC<LoginScreenProps> = ({ onComplete, onBack, isReturningUser = false }) => {
  const { t, language, showNotification, theme, toggleTheme } = useApp();
  const [step, setStep] = useState<'phone' | 'otp'>('phone');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [otp, setOtp] = useState('');
  const [resendTimer, setResendTimer] = useState(0);
  const [canResend, setCanResend] = useState(true);
  const [cookiesAccepted, setCookiesAccepted] = useState(false);
  const [showPhoneError, setShowPhoneError] = useState(false);
  const [hasResentOnce, setHasResentOnce] = useState(false);
  const [showOtpResentConfirm, setShowOtpResentConfirm] = useState(false);
  const [termsAccepted, setTermsAccepted] = useState(false);

  // OTP Resend Timer
  useEffect(() => {
    if (step === 'otp' && resendTimer > 0) {
      const interval = setInterval(() => {
        setResendTimer((prev) => {
          if (prev <= 1) {
            setCanResend(true);
            clearInterval(interval);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
      return () => clearInterval(interval);
    }
  }, [step, resendTimer]);

  const isValidPhoneNumber = (phone: string) => {
    const digits = phone.replace(/\D/g, '');
    // Valid if it's 11 digits (after +88) and starts with 0
    if (digits.length !== 11) return false;
    
    // Must start with 0
    if (!digits.startsWith('0')) return false;
    
    // Check if starts with valid Bangladesh operator codes (after the 0)
    const validPrefixes = ['017', '018', '013', '012', '016', '014', '015', '019'];
    const prefix = digits.substring(0, 3);
    
    return validPrefixes.includes(prefix);
  };

  const handlePhoneSubmit = () => {
    if (isValidPhoneNumber(phoneNumber) && termsAccepted) {
      setStep('otp');
      setResendTimer(0);
      setCanResend(true);
      setShowPhoneError(false);
      setHasResentOnce(false);
    } else {
      if (!isValidPhoneNumber(phoneNumber)) {
        setShowPhoneError(true);
      }
    }
  };

  const handleOTPSubmit = () => {
    if (otp.length === 6) {
      // Welcome notification removed as per user request
      // User doesn't want popup notification after login
      onComplete();
    }
  };

  const handleResendOTP = () => {
    if (canResend) {
      setResendTimer(60);
      setCanResend(false);
      setOtp('');
      setHasResentOnce(true);
      setShowOtpResentConfirm(true);
      
      // Hide confirmation after 3 seconds
      setTimeout(() => {
        setShowOtpResentConfirm(false);
      }, 3000);
    }
  };

  useEffect(() => {
    if (otp.length === 6) {
      handleOTPSubmit();
    }
  }, [otp]);

  return (
    <div className={`relative w-full h-screen overflow-hidden transition-colors duration-500 ${
      theme === 'dark' ? 'bg-[#052029]' : 'bg-neutral-100'
    }`}>
      {/* Main Content */}
      <div className="absolute h-full left-0 overflow-y-auto top-0 w-full pb-24">
        {step === 'phone' ? (
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.3 }}
          >
            {/* Back Button */}
            <button 
              className="flex gap-2 items-center px-6 py-4 mt-5"
              onClick={() => onBack ? onBack() : window.history.back()}
            >
              <div className="size-[20px]">
                <svg className="block size-full" fill="none" viewBox="0 0 20 20">
                  <path d="M16.875 10H3.125" stroke={theme === 'dark' ? '#9B9B9B' : '#6B6B6B'} strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.875" />
                  <path d={svgPaths.p281bb680} stroke={theme === 'dark' ? '#9B9B9B' : '#6B6B6B'} strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.875" />
                </svg>
              </div>
              <p className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] text-[14px] ${
                theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
              }`}>
                {t('back')}
              </p>
            </button>

            {/* Theme Toggle Button */}
            <motion.button 
              key={theme}
              initial={{ rotate: 0, scale: 0.8, opacity: 0 }}
              animate={{ rotate: 360, scale: 1, opacity: 1 }}
              transition={{ 
                duration: 0.5,
                ease: "easeInOut"
              }}
              onClick={toggleTheme}
              className={`absolute flex items-center justify-center right-8 rounded-full shadow-[0px_10px_15px_-3px_rgba(0,0,0,0.1),0px_4px_6px_-4px_rgba(0,0,0,0.1)] size-[42px] top-5 ${
              theme === 'dark' ? 'bg-[#0a2f3d] border border-[#0d3a4a]' : 'bg-[#fafaf8] border border-[rgba(44,44,46,0.1)]'
            }`}>
              {theme === 'dark' ? (
                <Sun className="size-5 text-[#f5f5f5]" />
              ) : (
                <Moon className="size-5 text-[#2c2c2e]" />
              )}
            </motion.button>

            {/* Content Container */}
            <div className="flex flex-col gap-8 px-8 pt-12">
              {/* Heading */}
              <div className="flex flex-col gap-2">
                <h1 className={`font-['Noto_Sans_Bengali:Bold',sans-serif] font-bold leading-[40px] text-[36px] tracking-[-0.9px] ${
                  theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
                }`}>
                  {t('enterPhone')}
                </h1>
                <p className={`font-['Noto_Sans_Bengali:Regular','Noto_Sans:Regular',sans-serif] font-normal leading-[26px] text-[16px] ${
                  theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
                }`}>
                  {t('sendOTPDescription')}
                </p>
              </div>

              {/* Phone Input Section */}
              <div className="flex flex-col gap-6">
                <div className="relative">
                  {/* Label */}
                  <p className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] text-[14px] mb-2 ${
                    theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
                  }`}>
                    {t('phoneNumberLabel')}
                  </p>

                  {/* Input Container - Two separate fields */}
                  <div className="flex gap-3">
                    {/* Country Code Section - Separate */}
                    <div className={`flex gap-2 items-center px-[18px] h-[56px] rounded-2xl ${
                      theme === 'dark' 
                        ? 'bg-[#0a2f3d] border-2 border-[#0d3a4a]' 
                        : 'bg-[#fafaf8] border-2 border-[rgba(44,44,46,0.1)]'
                    }`}>
                      <Phone className={`size-4 ${
                        theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
                      }`} />
                      <p className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] text-[14px] ${
                        theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
                      }`}>
                        +88
                      </p>
                    </div>

                    {/* Phone Input - Separate */}
                    <div className={`flex-1 flex items-center px-[18px] h-[56px] rounded-2xl relative ${
                      theme === 'dark' 
                        ? 'bg-[#0a2f3d] border-2 border-[#0d3a4a]' 
                        : 'bg-[#fafaf8] border-2 border-[rgba(44,44,46,0.1)]'
                    }`}>
                      <input
                        type="tel"
                        inputMode="numeric"
                        placeholder="01XXX-XXXXXX"
                        value={phoneNumber}
                        onChange={(e) => {
                          const value = e.target.value.replace(/[^0-9-]/g, '');
                          const digitsOnly = value.replace(/-/g, '');
                          
                          if (digitsOnly.length <= 11) {
                            // Add hyphen after 5 characters (after 01XXX)
                            if (digitsOnly.length > 5) {
                              setPhoneNumber(digitsOnly.slice(0, 5) + '-' + digitsOnly.slice(5));
                            } else {
                              setPhoneNumber(digitsOnly);
                            }
                            
                            // Clear error when user starts typing
                            if (showPhoneError) {
                              setShowPhoneError(false);
                            }
                          }
                        }}
                        onBlur={() => {
                          // Show error when user leaves the input field with invalid number
                          if (phoneNumber && !isValidPhoneNumber(phoneNumber)) {
                            setShowPhoneError(true);
                          }
                        }}
                        className={`bg-transparent flex-1 font-['Noto_Sans_Bengali:Regular','Noto_Sans:Regular',sans-serif] font-normal outline-none text-[16px] w-full ${
                          theme === 'dark' 
                            ? 'text-[#f5f5f5] placeholder:text-[rgba(255,255,255,0.3)]' 
                            : 'text-[#2c2c2e] placeholder:text-[rgba(44,44,46,0.3)]'
                        }`}
                      />
                      
                      {/* Green Checkmark - Show when valid */}
                      {isValidPhoneNumber(phoneNumber) && (
                        <motion.div
                          initial={{ scale: 0, opacity: 0 }}
                          animate={{ scale: 1, opacity: 1 }}
                          transition={{ 
                            type: "spring",
                            stiffness: 300,
                            damping: 20
                          }}
                          className="flex-shrink-0 flex items-center justify-center bg-green-500 rounded-full"
                          style={{
                            width: '22px',
                            height: '22px',
                          }}
                        >
                          <Check className="w-3.5 h-3.5 text-white" strokeWidth={3} />
                        </motion.div>
                      )}
                    </div>
                  </div>

                  {/* Phone Error Message or Example Text */}
                  {showPhoneError ? (
                    <motion.p 
                      initial={{ opacity: 0, y: -10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[16px] mt-1 px-1 text-[12px] text-red-500"
                    >
                      {t('invalidPhone')}
                    </motion.p>
                  ) : (
                    <p className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[16px] mt-1 px-1 text-[12px] ${
                      theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
                    }`}>
                      {t('phoneExample')}
                    </p>
                  )}
                </div>

                {/* Terms and Conditions Checkbox */}
                <div className="flex items-start gap-3">
                  <div 
                    onClick={() => setTermsAccepted(!termsAccepted)}
                    className={`flex-shrink-0 mt-0.5 w-5 h-5 rounded border-2 flex items-center justify-center transition-all cursor-pointer ${
                      termsAccepted
                        ? 'bg-[#d97757] border-[#d97757]'
                        : theme === 'dark'
                          ? 'border-[#0d3a4a] bg-[#0a2f3d]'
                          : 'border-[rgba(44,44,46,0.2)] bg-[#fafaf8]'
                    }`}
                  >
                    {termsAccepted && (
                      <Check className="w-3.5 h-3.5 text-white" strokeWidth={3} />
                    )}
                  </div>
                  <p className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] text-[13px] ${
                    theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
                  }`}>
                    {language === 'bn' ? (
                      <>
                        আমি{' '}
                        <button 
                          onClick={(e) => {
                            e.preventDefault();
                            window.open('/terms', '_blank');
                          }}
                          className="text-[#d97757] hover:underline"
                        >
                          শর্তাবলী
                        </button>
                        {' '}এবং{' '}
                        <button 
                          onClick={(e) => {
                            e.preventDefault();
                            window.open('/privacy', '_blank');
                          }}
                          className="text-[#d97757] hover:underline"
                        >
                          গোপনীয়তা নীতিতে
                        </button>
                        {' '}সম্মত আছি
                      </>
                    ) : (
                      <>
                        I agree to the{' '}
                        <button 
                          onClick={(e) => {
                            e.preventDefault();
                            window.open('/terms', '_blank');
                          }}
                          className="text-[#d97757] hover:underline"
                        >
                          Terms and Conditions
                        </button>
                        {' '}and{' '}
                        <button 
                          onClick={(e) => {
                            e.preventDefault();
                            window.open('/privacy', '_blank');
                          }}
                          className="text-[#d97757] hover:underline"
                        >
                          Privacy Policy
                        </button>
                      </>
                    )}
                  </p>
                </div>

                {/* Continue Button */}
                <button
                  onClick={handlePhoneSubmit}
                  disabled={!isValidPhoneNumber(phoneNumber) || !termsAccepted}
                  className="bg-[#d97757] flex gap-3 h-[56px] items-center justify-center rounded-full shadow-[0px_4px_6px_-1px_rgba(0,0,0,0.1),0px_2px_4px_-2px_rgba(0,0,0,0.1)] transition-opacity w-full disabled:opacity-40"
                >
                  <p className="font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[24px] text-[16px] text-neutral-100">
                    {t('continue')}
                  </p>
                  <div className="size-[20px]">
                    <svg className="block size-full" fill="none" viewBox="0 0 20 20">
                      <path d="M3.125 10H16.875" stroke="#F5F5F5" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.875" />
                      <path d={svgPaths.p223c5f00} stroke="#F5F5F5" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.875" />
                    </svg>
                  </div>
                </button>
              </div>
            </div>
          </motion.div>
        ) : (
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.3 }}
          >
            {/* Back Button */}
            <button 
              className="flex gap-2 items-center px-6 py-4 mt-5"
              onClick={() => setStep('phone')}
            >
              <div className="size-[20px]">
                <svg className="block size-full" fill="none" viewBox="0 0 20 20">
                  <path d="M16.875 10H3.125" stroke={theme === 'dark' ? '#9B9B9B' : '#6B6B6B'} strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.875" />
                  <path d={svgPaths.p281bb680} stroke={theme === 'dark' ? '#9B9B9B' : '#6B6B6B'} strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.875" />
                </svg>
              </div>
              <p className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] text-[14px] ${
                theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
              }`}>
                {t('back')}
              </p>
            </button>

            {/* Theme Toggle Button */}
            <motion.button 
              key={theme}
              initial={{ rotate: 0, scale: 0.8, opacity: 0 }}
              animate={{ rotate: 360, scale: 1, opacity: 1 }}
              transition={{ 
                duration: 0.5,
                ease: "easeInOut"
              }}
              onClick={toggleTheme}
              className={`absolute flex items-center justify-center right-8 rounded-full shadow-[0px_10px_15px_-3px_rgba(0,0,0,0.1),0px_4px_6px_-4px_rgba(0,0,0,0.1)] size-[42px] top-5 ${
              theme === 'dark' ? 'bg-[#0a2f3d] border border-[#0d3a4a]' : 'bg-[#fafaf8] border border-[rgba(44,44,46,0.1)]'
            }`}>
              {theme === 'dark' ? (
                <Sun className="size-5 text-[#f5f5f5]" />
              ) : (
                <Moon className="size-5 text-[#2c2c2e]" />
              )}
            </motion.button>

            {/* Content Container */}
            <div className="flex flex-col gap-8 px-8 pt-12">
              {/* Heading */}
              <div className="flex flex-col gap-2">
                <h1 className={`font-['Noto_Sans_Bengali:Bold',sans-serif] font-bold leading-[40px] text-[36px] tracking-[-0.9px] ${
                  theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
                }`}>
                  {t('verifyOTP')}
                </h1>
                <p className={`font-['Noto_Sans_Bengali:Regular','Noto_Sans:Regular',sans-serif] font-normal leading-[26px] text-[16px] ${
                  theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
                }`}>
                  +88 {phoneNumber} {t('otpSentTo')}
                </p>
              </div>

              {/* OTP Input */}
              <div className="flex flex-col gap-6">
                <div className="flex justify-center">
                  <InputOTP 
                    maxLength={6} 
                    value={otp} 
                    onChange={(value) => {
                      setOtp(value);
                    }}
                    autoFocus
                  >
                    <InputOTPGroup className="gap-2">
                      <InputOTPSlot index={0} className={`w-12 h-12 text-lg rounded-2xl border-2 ${
                        theme === 'dark' 
                          ? 'bg-[#0a2f3d] border-[#0d3a4a]' 
                          : 'bg-[#fafaf8] border-[rgba(44,44,46,0.1)]'
                      }`} />
                      <InputOTPSlot index={1} className={`w-12 h-12 text-lg rounded-2xl border-2 ${
                        theme === 'dark' 
                          ? 'bg-[#0a2f3d] border-[#0d3a4a]' 
                          : 'bg-[#fafaf8] border-[rgba(44,44,46,0.1)]'
                      }`} />
                      <InputOTPSlot index={2} className={`w-12 h-12 text-lg rounded-2xl border-2 ${
                        theme === 'dark' 
                          ? 'bg-[#0a2f3d] border-[#0d3a4a]' 
                          : 'bg-[#fafaf8] border-[rgba(44,44,46,0.1)]'
                      }`} />
                    </InputOTPGroup>
                    <div className={`flex items-center justify-center mx-2 ${
                      theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
                    }`}>
                      <span className="text-lg">-</span>
                    </div>
                    <InputOTPGroup className="gap-2">
                      <InputOTPSlot index={3} className={`w-12 h-12 text-lg rounded-2xl border-2 ${
                        theme === 'dark' 
                          ? 'bg-[#0a2f3d] border-[#0d3a4a]' 
                          : 'bg-[#fafaf8] border-[rgba(44,44,46,0.1)]'
                      }`} />
                      <InputOTPSlot index={4} className={`w-12 h-12 text-lg rounded-2xl border-2 ${
                        theme === 'dark' 
                          ? 'bg-[#0a2f3d] border-[#0d3a4a]' 
                          : 'bg-[#fafaf8] border-[rgba(44,44,46,0.1)]'
                      }`} />
                      <InputOTPSlot index={5} className={`w-12 h-12 text-lg rounded-2xl border-2 ${
                        theme === 'dark' 
                          ? 'bg-[#0a2f3d] border-[#0d3a4a]' 
                          : 'bg-[#fafaf8] border-[rgba(44,44,46,0.1)]'
                      }`} />
                    </InputOTPGroup>
                  </InputOTP>
                </div>

                {/* Resend OTP */}
                <div className="text-center">
                  <p className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] mb-3 text-[14px] ${
                    theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
                  }`}>
                    {t('didntGetCode')}
                  </p>
                  <button 
                    className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] px-6 py-2 rounded-2xl text-[14px] transition-opacity ${
                      !canResend 
                        ? `opacity-40 cursor-not-allowed ${theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}` 
                        : 'text-[#d97757] hover:opacity-80'
                    }`}
                    onClick={handleResendOTP}
                    disabled={!canResend}
                  >
                    {canResend 
                      ? t('resendOTP')
                      : `${t('resendOTP')} (${Math.floor(resendTimer / 60)}:${(resendTimer % 60).toString().padStart(2, '0')})`
                    }
                  </button>
                </div>

                {/* OTP Resent Confirmation - Above Continue Button */}
                {showOtpResentConfirm && (
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -10 }}
                    transition={{ duration: 0.3 }}
                    className="flex items-center justify-center gap-2 px-4 py-2"
                  >
                    <div className="flex items-center justify-center bg-[#B8DED6] rounded-full size-[18px]">
                      <Check className="w-3 h-3 text-[#1A1A1A]" strokeWidth={3} />
                    </div>
                    <p className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal text-[13px] ${
                      theme === 'dark' ? 'text-[#B8DED6]' : 'text-[#7BC3B8]'
                    }`}>
                      {t('otpResent')}
                    </p>
                  </motion.div>
                )}

                {/* Continue Button */}
                <button
                  onClick={handleOTPSubmit}
                  disabled={otp.length !== 6}
                  className="bg-[#d97757] flex gap-3 h-[56px] items-center justify-center rounded-full shadow-[0px_4px_6px_-1px_rgba(0,0,0,0.1),0px_2px_4px_-2px_rgba(0,0,0,0.1)] transition-opacity w-full disabled:opacity-40"
                >
                  <p className="font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[24px] text-[16px] text-neutral-100">
                    {t('continue')}
                  </p>
                  <div className="size-[20px]">
                    <svg className="block size-full" fill="none" viewBox="0 0 20 20">
                      <path d="M3.125 10H16.875" stroke="#F5F5F5" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.875" />
                      <path d={svgPaths.p223c5f00} stroke="#F5F5F5" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.875" />
                    </svg>
                  </div>
                </button>
              </div>
            </div>
          </motion.div>
        )}
      </div>

      {/* Cookie Notice - Fixed at bottom */}
      {!cookiesAccepted && (
        <div className={`absolute bottom-0 left-0 right-0 border-t flex flex-col items-start pb-4 pt-4 px-4 ${ 
          theme === 'dark' 
            ? 'bg-[rgba(5,32,41,0.95)] border-[#0d3a4a]' 
            : 'bg-[rgba(232,232,232,0.95)] border-[rgba(44,44,46,0.1)]'
        }`}>
          <div className="flex flex-col gap-3 w-full">
            <div className="flex items-center gap-2">
              <p className="font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[19.5px] text-[12px]">
                🍪
              </p>
              <p className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[19.5px] text-[12px] ${
                theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'
              }`}>
                {t('cookiesAbout')}
              </p>
            </div>
            <p className={`font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[19.5px] text-[12px] ${
              theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'
            }`}>
              {t('cookiesDescription')}
            </p>
            <button
              onClick={() => setCookiesAccepted(true)}
              className="bg-[#d97757] h-[40px] rounded-full transition-opacity hover:opacity-90 w-full flex items-center justify-center"
            >
              <p className="font-['Noto_Sans_Bengali:Regular',sans-serif] font-normal leading-[20px] text-[14px] text-neutral-100">
                {t('acceptCookies')}
              </p>
            </button>
          </div>
        </div>
      )}
    </div>
  );
};