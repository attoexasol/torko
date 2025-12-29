import React, { useState } from 'react';
import { motion } from 'motion/react';
import { ChevronLeft, Radio, Mic, MicOff, Users, MessageCircle, UserPlus, Hand, Volume2, VolumeX, MoreVertical, X, Share2 } from 'lucide-react';

interface StageRoomScreenProps {
  onNavigate: (screen: string) => void;
  language?: 'bn' | 'en';
  stageData?: any;
}

export const StageRoomScreen: React.FC<StageRoomScreenProps> = ({ 
  onNavigate, 
  language = 'bn',
  stageData 
}) => {
  const [isMuted, setIsMuted] = useState(false);
  const [showChat, setShowChat] = useState(false);
  const [speakers, setSpeakers] = useState([
    { id: 1, name: language === 'bn' ? 'আপনি (হোস্ট)' : 'You (Host)', isMuted: false, isHost: true },
  ]);
  const [listeners, setListeners] = useState([
    { id: 1, name: language === 'bn' ? 'সাদিয়া আহমেদ' : 'Sadia Ahmed', hasHandRaised: false },
    { id: 2, name: language === 'bn' ? 'তানভীর রহমান' : 'Tanvir Rahman', hasHandRaised: true },
    { id: 3, name: language === 'bn' ? 'নুসরাত জাহান' : 'Nusrat Jahan', hasHandRaised: false },
  ]);
  const [showEndConfirm, setShowEndConfirm] = useState(false);

  const t = {
    back: language === 'bn' ? 'ফিরে যান' : 'Back',
    live: language === 'bn' ? 'লাইভ' : 'LIVE',
    listeners: language === 'bn' ? 'শ্রোতা' : 'Listeners',
    speakers: language === 'bn' ? 'স্পিকার' : 'Speakers',
    mute: language === 'bn' ? 'মিউট' : 'Mute',
    unmute: language === 'bn' ? 'আনমিউট' : 'Unmute',
    invite: language === 'bn' ? 'আমন্ত্রণ' : 'Invite',
    chat: language === 'bn' ? 'চ্যাট' : 'Chat',
    endStage: language === 'bn' ? 'স্টেজ শেষ করুন' : 'End Stage',
    endStageConfirm: language === 'bn' ? 'আপনি কি নিশ্চিত যে এই স্টেজ শেষ করতে চান?' : 'Are you sure you want to end this stage?',
    cancel: language === 'bn' ? 'বাতিল' : 'Cancel',
    confirm: language === 'bn' ? 'নিশ্চিত' : 'Confirm',
    raisedHand: language === 'bn' ? 'হাত তুলেছে' : 'Hand Raised',
    inviteToSpeak: language === 'bn' ? 'স্পিকার করুন' : 'Invite to Speak',
    share: language === 'bn' ? 'শেয়ার' : 'Share',
  };

  const stage = stageData || {
    title: language === 'bn' ? 'আজকের খবরের আলোচনা' : "Today's News Discussion",
    description: language === 'bn' ? 'আজকের গুরুত্বপূর্ণ খবর নিয়ে আলোচনা' : 'Discussion about today\'s important news',
    category: language === 'bn' ? 'সাধারণ' : 'General',
  };

  const handleInviteToSpeak = (listenerId: number) => {
    const listener = listeners.find(l => l.id === listenerId);
    if (listener) {
      setSpeakers([...speakers, { id: speakers.length + 1, name: listener.name, isMuted: false, isHost: false }]);
      setListeners(listeners.filter(l => l.id !== listenerId));
    }
  };

  const handleEndStage = () => {
    setShowEndConfirm(false);
    onNavigate('localCommunity');
  };

  return (
    <div className="h-screen bg-[#F5F5F5] dark:bg-[#052029] flex flex-col overflow-hidden">
      {/* Header */}
      <div className="bg-white dark:bg-[#0a2f3d] border-b border-[#EBEBEB] dark:border-[#0d3a4a]">
        <div className="px-[20px] h-[56px] flex items-center justify-between">
          <button
            onClick={() => {
              if (window.confirm(language === 'bn' ? 'স্টেজ ছেড়ে যেতে চান?' : 'Leave stage?')) {
                onNavigate('localCommunity');
              }
            }}
            className="w-9 h-9 rounded-full bg-[#F5F5F5] dark:bg-[#0d3a4a] flex items-center justify-center"
          >
            <ChevronLeft className="w-5 h-5 text-[#0f1419] dark:text-white" />
          </button>

          <div className="flex items-center gap-2">
            <div className="flex items-center gap-1.5 bg-red-500 px-2.5 h-[26px] rounded-[13px]">
              <div className="w-2 h-2 bg-white rounded-full animate-pulse" />
              <span className="text-[12px] text-white font-['Roboto:SemiBold',sans-serif]">
                {t.live}
              </span>
            </div>
            <div className="flex items-center gap-1 text-[#555e67] dark:text-[#9e9e9e]">
              <Users className="w-4 h-4" />
              <span className="text-[13px] font-['Roboto:SemiBold',sans-serif]">
                {speakers.length + listeners.length}
              </span>
            </div>
          </div>

          <button
            onClick={() => {
              alert(language === 'bn' ? 'শেয়ার ফিচার শীঘ্রই আসছে!' : 'Share feature coming soon!');
            }}
            className="w-9 h-9 rounded-full bg-[#F5F5F5] dark:bg-[#0d3a4a] flex items-center justify-center"
          >
            <Share2 className="w-5 h-5 text-[#0f1419] dark:text-white" />
          </button>
        </div>
      </div>

      {/* Stage Info */}
      <div className="bg-white dark:bg-[#0a2f3d] px-[20px] py-4 border-b border-[#EBEBEB] dark:border-[#0d3a4a]">
        <div className="flex items-start gap-3">
          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#d6775c] to-[#c96647] flex items-center justify-center flex-shrink-0">
            <Radio className="w-6 h-6 text-white" strokeWidth={2} />
          </div>
          <div className="flex-1 min-w-0">
            <h1 className="text-[18px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white mb-1 line-clamp-2">
              {stage.title}
            </h1>
            <p className="text-[13px] text-[#555e67] dark:text-[#9e9e9e] line-clamp-2">
              {stage.description}
            </p>
            <div className="mt-2 inline-block px-2.5 py-1 rounded-[6px] bg-[#d6775c]/10 dark:bg-[#d6775c]/20">
              <span className="text-[11px] text-[#d6775c] font-['Roboto:SemiBold',sans-serif]">
                {stage.category}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 overflow-y-auto">
        {/* Speakers Section */}
        <div className="bg-white dark:bg-[#0a2f3d] px-[20px] py-4 mb-2">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-[14px] font-['Roboto:SemiBold',sans-serif] text-[#0f1419] dark:text-white">
              {t.speakers} ({speakers.length})
            </h2>
          </div>
          <div className="grid grid-cols-3 gap-3">
            {speakers.map((speaker) => (
              <div key={speaker.id} className="flex flex-col items-center">
                <div className="relative mb-2">
                  <div className={`w-16 h-16 rounded-full flex items-center justify-center ${
                    speaker.isHost 
                      ? 'bg-gradient-to-br from-[#d6775c] to-[#c96647]' 
                      : 'bg-[#F5F5F5] dark:bg-[#0d3a4a]'
                  }`}>
                    <span className="text-[20px] font-['Roboto:Bold',sans-serif] text-white">
                      {speaker.name.charAt(0)}
                    </span>
                  </div>
                  {!speaker.isMuted && (
                    <div className="absolute bottom-0 right-0 w-6 h-6 rounded-full bg-green-500 flex items-center justify-center border-2 border-white dark:border-[#0a2f3d]">
                      <Volume2 className="w-3.5 h-3.5 text-white" />
                    </div>
                  )}
                  {speaker.isMuted && (
                    <div className="absolute bottom-0 right-0 w-6 h-6 rounded-full bg-red-500 flex items-center justify-center border-2 border-white dark:border-[#0a2f3d]">
                      <MicOff className="w-3.5 h-3.5 text-white" />
                    </div>
                  )}
                  {speaker.isHost && (
                    <div className="absolute -top-1 -right-1 w-5 h-5 rounded-full bg-[#FFD700] flex items-center justify-center">
                      <span className="text-[10px]">⭐</span>
                    </div>
                  )}
                </div>
                <p className="text-[11px] text-center text-[#0f1419] dark:text-white font-['Roboto:Medium',sans-serif] line-clamp-1">
                  {speaker.name}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Listeners Section */}
        <div className="bg-white dark:bg-[#0a2f3d] px-[20px] py-4">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-[14px] font-['Roboto:SemiBold',sans-serif] text-[#0f1419] dark:text-white">
              {t.listeners} ({listeners.length})
            </h2>
          </div>
          <div className="space-y-2">
            {listeners.map((listener) => (
              <div
                key={listener.id}
                className="flex items-center justify-between p-3 rounded-[10px] bg-[#F5F5F5] dark:bg-[#052029]"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-[#d6775c]/20 flex items-center justify-center">
                    <span className="text-[16px] font-['Roboto:SemiBold',sans-serif] text-[#d6775c]">
                      {listener.name.charAt(0)}
                    </span>
                  </div>
                  <div>
                    <p className="text-[14px] text-[#0f1419] dark:text-white font-['Roboto:Medium',sans-serif]">
                      {listener.name}
                    </p>
                    {listener.hasHandRaised && (
                      <div className="flex items-center gap-1 mt-0.5">
                        <Hand className="w-3.5 h-3.5 text-[#d6775c]" />
                        <span className="text-[11px] text-[#d6775c] font-['Roboto:Medium',sans-serif]">
                          {t.raisedHand}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
                {listener.hasHandRaised && (
                  <button
                    onClick={() => handleInviteToSpeak(listener.id)}
                    className="px-3 py-1.5 rounded-[8px] bg-[#d6775c] text-white text-[12px] font-['Roboto:SemiBold',sans-serif] hover:bg-[#c96647] transition-colors"
                  >
                    {t.inviteToSpeak}
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom Controls */}
      <div className="bg-white dark:bg-[#0a2f3d] border-t border-[#EBEBEB] dark:border-[#0d3a4a] px-[20px] py-4">
        <div className="flex items-center justify-between gap-3">
          <button
            onClick={() => setIsMuted(!isMuted)}
            className={`flex-1 h-[48px] rounded-[12px] flex items-center justify-center gap-2 font-['Roboto:SemiBold',sans-serif] transition-colors ${
              isMuted
                ? 'bg-red-500 text-white'
                : 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#0f1419] dark:text-white'
            }`}
          >
            {isMuted ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5" />}
            <span className="text-[14px]">{isMuted ? t.unmute : t.mute}</span>
          </button>

          <button
            onClick={() => setShowEndConfirm(true)}
            className="flex-1 h-[48px] rounded-[12px] bg-red-500 text-white flex items-center justify-center gap-2 font-['Roboto:SemiBold',sans-serif] hover:bg-red-600 transition-colors"
          >
            <X className="w-5 h-5" />
            <span className="text-[14px]">{t.endStage}</span>
          </button>
        </div>
      </div>

      {/* End Stage Confirmation */}
      {showEndConfirm && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center px-4">
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="w-full max-w-[320px] bg-white dark:bg-[#0a2f3d] rounded-[16px] p-6"
          >
            <h3 className="text-[18px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white mb-2">
              {t.endStage}
            </h3>
            <p className="text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-4">
              {t.endStageConfirm}
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => setShowEndConfirm(false)}
                className="flex-1 h-[44px] rounded-[10px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#0f1419] dark:text-white font-['Roboto:SemiBold',sans-serif]"
              >
                {t.cancel}
              </button>
              <button
                onClick={handleEndStage}
                className="flex-1 h-[44px] rounded-[10px] bg-red-500 text-white font-['Roboto:SemiBold',sans-serif] hover:bg-red-600 transition-colors"
              >
                {t.confirm}
              </button>
            </div>
          </motion.div>
        </div>
      )}
    </div>
  );
};