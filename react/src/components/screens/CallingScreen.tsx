import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { useApp } from '../contexts/AppContext';
import { Button } from '../ui/button';
import { Phone, Video, Mic, MicOff, VideoOff, Volume2, VolumeX, PhoneOff, Maximize2, Minimize2, Users } from 'lucide-react';

interface Participant {
  id: string;
  name: string;
  initials: string;
  color: string;
  isMuted: boolean;
  isVideoEnabled: boolean;
}

interface CallingScreenProps {
  onEndCall: () => void;
  callerName: string;
  callerColor: string;
  callerInitials: string;
  isVideo: boolean;
  isIncoming?: boolean;
  isGroup?: boolean;
}

export const CallingScreen: React.FC<CallingScreenProps> = ({
  onEndCall,
  callerName,
  callerColor,
  callerInitials,
  isVideo,
  isIncoming = false,
  isGroup = false,
}) => {
  const { language, theme } = useApp();
  const [callStatus, setCallStatus] = useState<'ringing' | 'connected'>('ringing');
  const [isMuted, setIsMuted] = useState(false);
  const [isSpeakerOn, setIsSpeakerOn] = useState(false);
  const [isVideoEnabled, setIsVideoEnabled] = useState(isVideo);
  const [callDuration, setCallDuration] = useState(0);
  const [isFullScreen, setIsFullScreen] = useState(false);

  // Mock group participants (only shown when connected in group call)
  const [participants, setParticipants] = useState<Participant[]>([
    { id: '1', name: language === 'bn' ? 'আহমেদ রহমান' : 'Ahmed Rahman', initials: language === 'bn' ? 'আ' : 'AR', color: '#6B9BD1', isMuted: false, isVideoEnabled: true },
    { id: '2', name: language === 'bn' ? 'ফাতিমা খান' : 'Fatima Khan', initials: language === 'bn' ? 'ফ' : 'FK', color: '#E8A87C', isMuted: false, isVideoEnabled: true },
    { id: '3', name: language === 'bn' ? 'মাহমুদ হাসান' : 'Mahmud Hasan', initials: language === 'bn' ? 'ম' : 'MH', color: '#B5A8C9', isMuted: true, isVideoEnabled: false },
    { id: '4', name: language === 'bn' ? 'নাফিসা আক্তার' : 'Nafisa Akter', initials: language === 'bn' ? 'না' : 'NA', color: '#7DA8D9', isMuted: false, isVideoEnabled: true },
  ]);

  // Auto-accept after 2 seconds for demo purposes
  useEffect(() => {
    if (isIncoming) {
      const timer = setTimeout(() => {
        setCallStatus('connected');
      }, 2000);
      return () => clearTimeout(timer);
    } else {
      // For outgoing calls, connect after 3 seconds
      const timer = setTimeout(() => {
        setCallStatus('connected');
      }, 3000);
      return () => clearTimeout(timer);
    }
  }, [isIncoming]);

  // Call duration counter
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (callStatus === 'connected') {
      interval = setInterval(() => {
        setCallDuration(prev => prev + 1);
      }, 1000);
    }
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [callStatus]);

  const formatDuration = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleEndCall = () => {
    onEndCall();
  };

  const handleAcceptCall = () => {
    setCallStatus('connected');
  };

  const formatDurationBengali = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    const bengaliNumerals = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    
    const convertToBengali = (num: number): string => {
      return num.toString().split('').map(digit => bengaliNumerals[parseInt(digit)]).join('');
    };
    
    return `${convertToBengali(mins).padStart(2, '০')}:${convertToBengali(secs).padStart(2, '০')}`;
  };

  const displayDuration = language === 'bn' ? formatDurationBengali(callDuration) : formatDuration(callDuration);

  // Render Group Call View (when connected)
  if (isGroup && callStatus === 'connected') {
    return (
      <div 
        className="fixed inset-0 flex flex-col z-50"
        style={{
          background: theme === 'dark' 
            ? 'linear-gradient(to bottom right, #052029, #0a2f3d)' 
            : 'linear-gradient(to bottom right, #1f2937, #111827)',
        }}
      >
        {/* Header - Call Info */}
        <div className="relative z-10 px-6 py-4 bg-black/30 backdrop-blur-sm">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-white" style={{ fontSize: '18px', fontWeight: '600' }}>
                {callerName}
              </h1>
              <div className="flex items-center gap-2 mt-1">
                <Users className="w-4 h-4 text-white/70" />
                <p className="text-white/70" style={{ fontSize: '13px' }}>
                  {participants.length + 1} {language === 'bn' ? 'জন' : 'participants'}
                </p>
                <span className="text-white/50 mx-1">•</span>
                <p className="text-white/70" style={{ fontSize: '13px' }}>
                  {displayDuration}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Participants Grid */}
        <div className="flex-1 p-4 overflow-y-auto">
          <div className="grid grid-cols-2 gap-3 h-full">
            {/* You (Current User) */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              className="relative rounded-2xl overflow-hidden"
              style={{
                minHeight: '180px',
                backdropFilter: 'blur(10px)',
                backgroundColor: theme === 'dark' ? 'rgba(13, 58, 74, 0.5)' : 'rgba(55, 65, 81, 0.5)',
              }}
            >
              <div className="w-full h-full flex flex-col items-center justify-center">
                {isVideoEnabled ? (
                  <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-gray-600 to-gray-800">
                    <span className="text-white" style={{ fontSize: '32px', fontWeight: '600' }}>
                      {language === 'bn' ? 'আপনি' : 'You'}
                    </span>
                  </div>
                ) : (
                  <div className="flex flex-col items-center">
                    <div
                      className="flex items-center justify-center text-white rounded-full mb-2"
                      style={{
                        width: '60px',
                        height: '60px',
                        backgroundColor: callerColor,
                        fontSize: '22px',
                        fontWeight: '600',
                      }}
                    >
                      {language === 'bn' ? 'আ' : 'Y'}
                    </div>
                    <span className="text-white text-center" style={{ fontSize: '14px', fontWeight: '500' }}>
                      {language === 'bn' ? 'আপনি' : 'You'}
                    </span>
                  </div>
                )}
              </div>
              
              {/* Name & Status Overlay */}
              <div className="absolute bottom-0 left-0 right-0 p-2 bg-gradient-to-t from-black/60 to-transparent">
                <div className="flex items-center justify-between">
                  <span className="text-white text-sm font-medium">
                    {language === 'bn' ? 'আপনি' : 'You'}
                  </span>
                  <div className="flex items-center gap-1">
                    {!isVideoEnabled && (
                      <div className="bg-red-500/90 p-1 rounded-full">
                        <VideoOff className="w-3 h-3 text-white" />
                      </div>
                    )}
                    {isMuted && (
                      <div className="bg-red-500/90 p-1 rounded-full">
                        <MicOff className="w-3 h-3 text-white" />
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </motion.div>

            {/* Other Participants */}
            {participants.map((participant, index) => (
              <motion.div
                key={participant.id}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: index * 0.1 }}
                className="relative rounded-2xl overflow-hidden"
                style={{
                  minHeight: '180px',
                  backdropFilter: 'blur(10px)',
                  backgroundColor: theme === 'dark' ? 'rgba(13, 58, 74, 0.5)' : 'rgba(55, 65, 81, 0.5)',
                }}
              >
                <div className="w-full h-full flex flex-col items-center justify-center">
                  {participant.isVideoEnabled ? (
                    <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-gray-600 to-gray-800">
                      <span className="text-white" style={{ fontSize: '32px', fontWeight: '600' }}>
                        {participant.initials}
                      </span>
                    </div>
                  ) : (
                    <div className="flex flex-col items-center">
                      <div
                        className="flex items-center justify-center text-white rounded-full mb-2"
                        style={{
                          width: '60px',
                          height: '60px',
                          backgroundColor: participant.color,
                          fontSize: '22px',
                          fontWeight: '600',
                        }}
                      >
                        {participant.initials}
                      </div>
                      <span className="text-white text-center px-2" style={{ fontSize: '14px', fontWeight: '500' }}>
                        {participant.name}
                      </span>
                    </div>
                  )}
                </div>
                
                {/* Name & Status Overlay */}
                <div className="absolute bottom-0 left-0 right-0 p-2 bg-gradient-to-t from-black/60 to-transparent">
                  <div className="flex items-center justify-between">
                    <span className="text-white text-sm font-medium truncate">
                      {participant.name}
                    </span>
                    <div className="flex items-center gap-1">
                      {!participant.isVideoEnabled && (
                        <div className="bg-red-500/90 p-1 rounded-full">
                          <VideoOff className="w-3 h-3 text-white" />
                        </div>
                      )}
                      {participant.isMuted && (
                        <div className="bg-red-500/90 p-1 rounded-full">
                          <MicOff className="w-3 h-3 text-white" />
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Call Controls */}
        <div className="relative z-10 pb-8 px-6 bg-gradient-to-t from-black/50 to-transparent">
          <motion.div
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.2, duration: 0.4 }}
            className="flex items-center justify-center gap-4"
          >
            {/* Mute Button */}
            <Button
              size="icon"
              variant="outline"
              className={`rounded-full h-14 w-14 border-2 transition-all ${
                isMuted 
                  ? 'bg-red-500 border-red-500 hover:bg-red-600 text-white' 
                  : 'bg-white/20 border-white/30 hover:bg-white/30 text-white backdrop-blur-md'
              }`}
              onClick={() => setIsMuted(!isMuted)}
            >
              {isMuted ? (
                <MicOff className="w-6 h-6" />
              ) : (
                <Mic className="w-6 h-6" />
              )}
            </Button>

            {/* Speaker Button */}
            <Button
              size="icon"
              variant="outline"
              className={`rounded-full h-14 w-14 border-2 transition-all ${
                isSpeakerOn 
                  ? 'bg-accent border-accent hover:bg-accent/90 text-white' 
                  : 'bg-white/20 border-white/30 hover:bg-white/30 text-white backdrop-blur-md'
              }`}
              onClick={() => setIsSpeakerOn(!isSpeakerOn)}
            >
              {isSpeakerOn ? (
                <Volume2 className="w-6 h-6" />
              ) : (
                <VolumeX className="w-6 h-6" />
              )}
            </Button>

            {/* Video Toggle (only for video calls) */}
            {isVideo && (
              <Button
                size="icon"
                variant="outline"
                className={`rounded-full h-14 w-14 border-2 transition-all ${
                  !isVideoEnabled 
                    ? 'bg-red-500 border-red-500 hover:bg-red-600 text-white' 
                    : 'bg-white/20 border-white/30 hover:bg-white/30 text-white backdrop-blur-md'
                }`}
                onClick={() => setIsVideoEnabled(!isVideoEnabled)}
              >
                {!isVideoEnabled ? (
                  <VideoOff className="w-6 h-6" />
                ) : (
                  <Video className="w-6 h-6" />
                )}
              </Button>
            )}

            {/* End Call Button */}
            <Button
              size="icon"
              className="rounded-full h-16 w-16 bg-red-500 hover:bg-red-600 shadow-lg"
              onClick={handleEndCall}
            >
              <PhoneOff className="w-7 h-7 text-white" />
            </Button>
          </motion.div>
        </div>
      </div>
    );
  }

  // Regular 1-on-1 Call View
  return (
    <div className="fixed inset-0 bg-gradient-to-br from-accent/20 via-background to-secondary/20 flex flex-col z-50">
      {/* Video Background (if video call) */}
      {isVideo && callStatus === 'connected' && (
        <div className="absolute inset-0 bg-gradient-to-br from-gray-800 to-gray-900">
          {/* Simulated video feed */}
          <div className="absolute inset-0 flex items-center justify-center">
            <div 
              className="w-full h-full flex items-center justify-center text-white opacity-30"
              style={{
                fontSize: '120px',
                fontWeight: '600',
              }}
            >
              {callerInitials}
            </div>
          </div>
          
          {/* Self video (small preview) */}
          {isVideoEnabled && (
            <motion.div
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              className="absolute top-6 right-6 bg-gray-700 rounded-2xl overflow-hidden shadow-2xl"
              style={{
                width: isFullScreen ? '120px' : '100px',
                height: isFullScreen ? '160px' : '140px',
              }}
            >
              <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-gray-600 to-gray-800">
                <span className="text-white" style={{ fontSize: '24px', fontWeight: '600' }}>
                  {language === 'bn' ? 'আপনি' : 'You'}
                </span>
              </div>
            </motion.div>
          )}
        </div>
      )}

      {/* Header Info */}
      <div className={`relative z-10 flex flex-col items-center justify-center flex-1 ${isVideo && callStatus === 'connected' ? 'text-white' : 'text-foreground'}`}>
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5 }}
          className="flex flex-col items-center"
        >
          {/* Avatar */}
          <div 
            className={`flex items-center justify-center text-white shadow-2xl mb-6 ${callStatus === 'ringing' ? 'animate-pulse' : ''}`}
            style={{
              width: isVideo && callStatus === 'connected' ? '80px' : '140px',
              height: isVideo && callStatus === 'connected' ? '80px' : '140px',
              borderRadius: '50%',
              backgroundColor: callerColor,
              fontSize: isVideo && callStatus === 'connected' ? '28px' : '48px',
              fontWeight: '600',
              boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)',
              transition: 'all 0.3s ease',
            }}
          >
            {callerInitials}
          </div>

          {/* Caller Name */}
          <h1 
            className={`mb-2 tracking-tight ${isVideo && callStatus === 'connected' ? 'text-white' : 'text-foreground'}`}
            style={{ 
              fontSize: isVideo && callStatus === 'connected' ? '22px' : '28px',
              fontWeight: '600',
              lineHeight: '1.3',
              textShadow: isVideo && callStatus === 'connected' ? '0 2px 8px rgba(0,0,0,0.5)' : 'none',
              transition: 'all 0.3s ease',
            }}
          >
            {callerName}
          </h1>

          {/* Call Status */}
          <p 
            className={`${isVideo && callStatus === 'connected' ? 'text-white/80' : 'text-muted-foreground'}`}
            style={{
              fontSize: '16px',
              fontWeight: '400',
              textShadow: isVideo && callStatus === 'connected' ? '0 2px 8px rgba(0,0,0,0.5)' : 'none',
            }}
          >
            {callStatus === 'ringing' 
              ? (isIncoming 
                  ? (language === 'bn' ? 'আগত কল...' : 'Incoming call...')
                  : (language === 'bn' ? 'কল করা হচ্ছে...' : 'Calling...'))
              : displayDuration
            }
          </p>

          {/* Call Type Badge */}
          <div 
            className={`mt-3 px-4 py-1.5 rounded-full ${isVideo && callStatus === 'connected' ? 'bg-white/20 text-white' : 'bg-muted text-foreground'}`}
            style={{
              fontSize: '13px',
              fontWeight: '500',
              backdropFilter: isVideo && callStatus === 'connected' ? 'blur(10px)' : 'none',
            }}
          >
            {isVideo 
              ? (language === 'bn' ? 'ভিডিও কল' : 'Video Call')
              : (language === 'bn' ? 'ভয়েস কল' : 'Voice Call')
            }
          </div>

          {/* Ringing Animation */}
          {callStatus === 'ringing' && (
            <motion.div
              className="mt-8"
              animate={{
                scale: [1, 1.2, 1],
                opacity: [0.5, 1, 0.5],
              }}
              transition={{
                duration: 1.5,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            >
              {isVideo ? (
                <Video className="w-12 h-12 text-accent" />
              ) : (
                <Phone className="w-12 h-12 text-accent" />
              )}
            </motion.div>
          )}
        </motion.div>
      </div>

      {/* Call Controls */}
      <div className="relative z-10 pb-12 px-6">
        <motion.div
          initial={{ y: 100, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.2, duration: 0.4 }}
          className="flex flex-col items-center gap-6"
        >
          {/* Main Controls (only show when connected) */}
          {callStatus === 'connected' && (
            <div className="flex items-center justify-center gap-4 mb-4">
              {/* Mute Button */}
              <Button
                size="icon"
                variant="outline"
                className={`rounded-full h-14 w-14 border-2 transition-all ${
                  isMuted 
                    ? 'bg-red-500 border-red-500 hover:bg-red-600 text-white' 
                    : isVideo && callStatus === 'connected'
                    ? 'bg-white/20 border-white/30 hover:bg-white/30 text-white backdrop-blur-md'
                    : 'bg-muted/80 border-border hover:bg-muted text-foreground'
                }`}
                onClick={() => setIsMuted(!isMuted)}
              >
                {isMuted ? (
                  <MicOff className="w-6 h-6" />
                ) : (
                  <Mic className="w-6 h-6" />
                )}
              </Button>

              {/* Speaker Button */}
              <Button
                size="icon"
                variant="outline"
                className={`rounded-full h-14 w-14 border-2 transition-all ${
                  isSpeakerOn 
                    ? 'bg-accent border-accent hover:bg-accent/90 text-white' 
                    : isVideo && callStatus === 'connected'
                    ? 'bg-white/20 border-white/30 hover:bg-white/30 text-white backdrop-blur-md'
                    : 'bg-muted/80 border-border hover:bg-muted text-foreground'
                }`}
                onClick={() => setIsSpeakerOn(!isSpeakerOn)}
              >
                {isSpeakerOn ? (
                  <Volume2 className="w-6 h-6" />
                ) : (
                  <VolumeX className="w-6 h-6" />
                )}
              </Button>

              {/* Video Toggle (only for video calls) */}
              {isVideo && (
                <Button
                  size="icon"
                  variant="outline"
                  className={`rounded-full h-14 w-14 border-2 transition-all ${
                    !isVideoEnabled 
                      ? 'bg-red-500 border-red-500 hover:bg-red-600 text-white' 
                      : 'bg-white/20 border-white/30 hover:bg-white/30 text-white backdrop-blur-md'
                  }`}
                  onClick={() => setIsVideoEnabled(!isVideoEnabled)}
                >
                  <Video className="w-6 h-6" />
                </Button>
              )}

              {/* Fullscreen Toggle (video only) */}
              {isVideo && (
                <Button
                  size="icon"
                  variant="outline"
                  className="rounded-full h-14 w-14 border-2 bg-white/20 border-white/30 hover:bg-white/30 text-white backdrop-blur-md"
                  onClick={() => setIsFullScreen(!isFullScreen)}
                >
                  {isFullScreen ? (
                    <Minimize2 className="w-6 h-6" />
                  ) : (
                    <Maximize2 className="w-6 h-6" />
                  )}
                </Button>
              )}
            </div>
          )}

          {/* End Call / Accept Buttons */}
          <div className="flex items-center gap-4">
            {callStatus === 'ringing' && isIncoming && (
              <>
                {/* Accept Button */}
                <Button
                  size="icon"
                  className="rounded-full h-16 w-16 bg-green-500 hover:bg-green-600 shadow-lg"
                  onClick={handleAcceptCall}
                >
                  <Phone className="w-7 h-7 text-white" />
                </Button>
              </>
            )}

            {/* End Call Button */}
            <Button
              size="icon"
              className="rounded-full h-16 w-16 bg-red-500 hover:bg-red-600 shadow-lg"
              onClick={handleEndCall}
            >
              <PhoneOff className="w-7 h-7 text-white" />
            </Button>
          </div>

          {/* Button Labels */}
          <div className="flex items-center gap-4">
            {callStatus === 'ringing' && isIncoming && (
              <span 
                className={`${isVideo && callStatus === 'connected' ? 'text-white' : 'text-foreground'}`}
                style={{ fontSize: '13px', fontWeight: '500', minWidth: '80px', textAlign: 'center' }}
              >
                {language === 'bn' ? 'গ্রহণ করুন' : 'Accept'}
              </span>
            )}
            <span 
              className="text-red-500"
              style={{ fontSize: '13px', fontWeight: '500', minWidth: '80px', textAlign: 'center' }}
            >
              {language === 'bn' ? 'কল শেষ' : 'End Call'}
            </span>
          </div>
        </motion.div>
      </div>
    </div>
  );
};