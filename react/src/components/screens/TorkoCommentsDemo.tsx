import React from 'react';
import { ChevronLeft } from 'lucide-react';
import { TorkoThreadedComments, sampleComments } from '../TorkoThreadedComments';

interface TorkoCommentsDemoProps {
  onNavigate?: (screen: string) => void;
  language?: 'bn' | 'en';
}

export const TorkoCommentsDemo: React.FC<TorkoCommentsDemoProps> = ({
  onNavigate,
  language = 'bn'
}) => {
  const t = {
    title: language === 'bn' ? 'থ্রেডেড মন্তব্য' : 'Threaded Comments',
    back: language === 'bn' ? 'ফিরে যান' : 'Back',
  };

  return (
    <div className="w-full h-screen bg-white dark:bg-[#052029] flex flex-col">
      {/* Header */}
      <div className="flex-shrink-0 bg-white dark:bg-[#052029] border-b border-[#E4E6EA] dark:border-[#38383A]">
        <div className="flex items-center gap-3 px-4 py-3">
          <button
            onClick={() => onNavigate?.('localCommunity')}
            className="p-2 -ml-2 rounded-full hover:bg-gray-100 dark:hover:bg-[#1C1C1E] transition-colors"
          >
            <ChevronLeft className="w-6 h-6 text-[#0F1419] dark:text-white" />
          </button>
          <h1 className="font-['Noto_Sans_Bengali',sans-serif] text-[20px] font-bold text-[#0F1419] dark:text-white">
            {t.title}
          </h1>
        </div>
      </div>

      {/* Original Post */}
      <div className="flex-shrink-0 px-4 py-4 border-b border-[#E4E6EA] dark:border-[#38383A] bg-white dark:bg-[#052029]">
        <div className="flex gap-3">
          <div className="flex-shrink-0">
            <div className="w-[48px] h-[48px] rounded-full overflow-hidden bg-gray-100 dark:bg-[#2a2a2a]">
              <img 
                src="https://images.unsplash.com/photo-1576558656222-ba66febe3dec?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400" 
                alt="রিফাত হাসান"
                className="w-full h-full object-cover"
              />
            </div>
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-1.5 mb-1">
              <span className="font-['Noto_Sans_Bengali',sans-serif] text-[16px] font-semibold text-[#0F1419] dark:text-white">
                রিফাত হাসান
              </span>
              <span className="text-[14px] text-[#687684] dark:text-[#8E8E93]">
                @rifat_hassan
              </span>
              <span className="text-[#9AA1A9] dark:text-[#636366]">·</span>
              <span className="text-[13px] text-[#9AA1A9] dark:text-[#636366]">২ ঘণ্টা</span>
            </div>
            <p className="font-['Noto_Sans_Bengali',sans-serif] text-[16px] text-[#1A1A1A] dark:text-[#E5E5E7] leading-[1.5]">
              ঢাকার ট্রাফিক সমস্যা সমাধানে নতুন মেট্রো লাইন চালু হবে আগামী মাসে। এটি যাত্রীদের জন্য একটি দুর্দান্ত সংবাদ! 🚇
            </p>
          </div>
        </div>
      </div>

      {/* Scrollable Comments */}
      <div className="flex-1 overflow-y-auto">
        <TorkoThreadedComments 
          comments={sampleComments} 
          language={language}
        />
      </div>
    </div>
  );
};
