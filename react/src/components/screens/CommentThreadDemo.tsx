import React, { useState } from 'react';
import { CommentThread } from '../CommentThread';
import { Button } from '../ui/button';
import { Moon, Sun, Languages } from 'lucide-react';

export const CommentThreadDemo: React.FC = () => {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [language, setLanguage] = useState<'bn' | 'en'>('bn');

  // Mock data for the parent post
  const parentPost = {
    author: language === 'bn' ? 'আহমেদ রহমান' : 'Ahmed Rahman',
    handle: '@ahmedrahman',
    initials: language === 'bn' ? 'আ' : 'AR',
    text:
      language === 'bn'
        ? 'বাংলাদেশে AI এবং মেশিন লার্নিং এর ভবিষ্যৎ কেমন হতে পারে? আপনাদের মতামত জানতে চাই। আমি মনে করি আগামী ৫ বছরে এই সেক্টরে বিশাল পরিবর্তন আসবে।'
        : 'What do you think about the future of AI and Machine Learning in Bangladesh? I believe we will see massive changes in this sector in the next 5 years.',
    timestamp: language === 'bn' ? '২ ঘণ্টা আগে' : '2h ago',
    likes: 342,
    comments: 87,
  };

  // Mock nested comments data
  const comments = [
    {
      id: '1',
      author: language === 'bn' ? 'ফাতিমা খান' : 'Fatima Khan',
      handle: '@fatimakhan',
      initials: language === 'bn' ? 'ফ' : 'FK',
      text:
        language === 'bn'
          ? 'একদম সহমত! বিশেষ করে হেলথকেয়ার এবং এডুকেশন সেক্টরে AI এর ব্যবহার বাড়বে।'
          : 'Totally agree! Especially in healthcare and education sectors, AI usage will increase significantly.',
      timestamp: language === 'bn' ? '১ ঘণ্টা আগে' : '1h ago',
      likes: 45,
      replies: 2,
      isLiked: false,
      children: [
        {
          id: '1-1',
          author: language === 'bn' ? 'মাহমুদ হাসান' : 'Mahmud Hasan',
          handle: '@mahmudhasan',
          initials: language === 'bn' ? 'ম' : 'MH',
          text:
            language === 'bn'
              ? 'হেলথকেয়ারে ইতিমধ্যে কিছু হসপিটাল AI ব্যবহার শুরু করেছে। ডায়াগনসিসে অনেক সাহায্য হচ্ছে।'
              : 'Some hospitals have already started using AI in healthcare. It helps a lot in diagnosis.',
          timestamp: language === 'bn' ? '৪৫ মিনিট আগে' : '45m ago',
          likes: 12,
          replies: 1,
          children: [
            {
              id: '1-1-1',
              author: language === 'bn' ? 'নাফিসা আক্তার' : 'Nafisa Akter',
              handle: '@nafisaakter',
              initials: language === 'bn' ? 'না' : 'NA',
              text:
                language === 'bn'
                  ? 'কোন হসপিটালগুলো? জানতে চাই, আমার বাবার চিকিৎসার জন্য দরকার।'
                  : 'Which hospitals? I need to know for my father\'s treatment.',
              timestamp: language === 'bn' ? '৩০ মিনিট আগে' : '30m ago',
              likes: 3,
              replies: 0,
            },
          ],
        },
        {
          id: '1-2',
          author: language === 'bn' ? 'রাকিব ইসলাম' : 'Rakib Islam',
          handle: '@rakibislam',
          initials: language === 'bn' ? 'রা' : 'RI',
          text:
            language === 'bn'
              ? 'এডুকেশনে AI টিউটর সিস্টেম খুবই কার্যকর হতে পারে।'
              : 'AI tutor systems can be very effective in education.',
          timestamp: language === 'bn' ? '৫০ মিনিট আগে' : '50m ago',
          likes: 8,
          replies: 0,
        },
      ],
    },
    {
      id: '2',
      author: language === 'bn' ? 'তানভীর আহমেদ' : 'Tanvir Ahmed',
      handle: '@tanvirahmed',
      initials: language === 'bn' ? 'ত' : 'TA',
      text:
        language === 'bn'
          ? 'কিন্তু আমাদের দেশে AI এক্সপার্টদের সংখ্যা কম। প্রথমে দক্ষ জনশক্তি তৈরি করতে হবে।'
          : 'But we have limited AI experts in our country. We need to build skilled workforce first.',
      timestamp: language === 'bn' ? '১ ঘণ্টা আগে' : '1h ago',
      likes: 67,
      replies: 3,
      isLiked: true,
      children: [
        {
          id: '2-1',
          author: language === 'bn' ? 'সাবিনা রহমান' : 'Sabina Rahman',
          handle: '@sabinarahman',
          initials: language === 'bn' ? 'সা' : 'SR',
          text:
            language === 'bn'
              ? 'এজন্যই ভালো AI কোর্স এবং ট্রেনিং প্রোগ্রাম দরকার।'
              : 'That\'s why we need good AI courses and training programs.',
          timestamp: language === 'bn' ? '৪০ মিনিট আগে' : '40m ago',
          likes: 15,
          replies: 0,
        },
        {
          id: '2-2',
          author: language === 'bn' ? 'কামরুল হাসান' : 'Kamrul Hasan',
          handle: '@kamrulhasan',
          initials: language === 'bn' ? 'ক' : 'KH',
          text:
            language === 'bn'
              ? 'বিশ্ববিদ্যালয়গুলোতে AI রিসার্চ ল্যাব খোলা উচিত।'
              : 'Universities should open AI research labs.',
          timestamp: language === 'bn' ? '৩৫ মিনিট আগে' : '35m ago',
          likes: 22,
          replies: 0,
        },
        {
          id: '2-3',
          author: language === 'bn' ? 'জান্নাত আরা' : 'Jannat Ara',
          handle: '@jannatara',
          initials: language === 'bn' ? 'জা' : 'JA',
          text:
            language === 'bn'
              ? 'অনলাইন প্ল্যাটফর্মে অনেক ভালো ভালো রিসোর্স আছে। সেলফ-লার্নিং এর সুযোগ আছে।'
              : 'There are many good resources on online platforms. Self-learning opportunities exist.',
          timestamp: language === 'bn' ? '২৫ মিনিট আগে' : '25m ago',
          likes: 9,
          replies: 0,
        },
      ],
    },
    {
      id: '3',
      author: language === 'bn' ? 'রিফাত করিম' : 'Rifat Karim',
      handle: '@rifatkarim',
      initials: language === 'bn' ? 'রি' : 'RK',
      text:
        language === 'bn'
          ? 'আমি মনে করি এগ্রিকালচার সেক্টরে AI সবচেয়ে বেশি ইমপ্যাক্ট ফেলবে। ক্রপ মনিটরিং, ওয়েদার প্রেডিকশন - সব কিছুতেই।'
          : 'I think AI will have the biggest impact in the agriculture sector. Crop monitoring, weather prediction - everything.',
      timestamp: language === 'bn' ? '৫৫ মিনিট আগে' : '55m ago',
      likes: 89,
      replies: 1,
      children: [
        {
          id: '3-1',
          author: language === 'bn' ? 'শাকিল আহমেদ' : 'Shakil Ahmed',
          handle: '@shakilahmed',
          initials: language === 'bn' ? 'শা' : 'SA',
          text:
            language === 'bn'
              ? 'একদম ঠিক! আমাদের দেশ কৃষিপ্রধান, তাই এখানে AI এর ব্যবহার গেম চেঞ্জার হবে।'
              : 'Absolutely right! Our country is agriculture-based, so AI usage here will be a game changer.',
          timestamp: language === 'bn' ? '২০ মিনিট আগে' : '20m ago',
          likes: 18,
          replies: 0,
        },
      ],
    },
  ];

  return (
    <div
      className={`min-h-screen transition-colors duration-300 ${
        theme === 'dark' ? 'bg-black' : 'bg-[#f7f9fa]'
      }`}
    >
      {/* Header Controls */}
      <div
        className={`sticky top-0 z-50 border-b ${
          theme === 'dark'
            ? 'bg-black/80 border-[#2f3336]'
            : 'bg-white/80 border-[#eff3f4]'
        } backdrop-blur-md`}
      >
        <div className="max-w-2xl mx-auto px-4 py-3 flex items-center justify-between">
          <h1
            className={`font-semibold ${
              theme === 'dark' ? 'text-white' : 'text-[#0f1419]'
            }`}
            style={{ fontSize: '20px' }}
          >
            {language === 'bn' ? 'মন্তব্য থ্রেড ডেমো' : 'Comment Thread Demo'}
          </h1>

          <div className="flex items-center gap-2">
            {/* Language Toggle */}
            <Button
              variant="ghost"
              size="icon"
              className="rounded-full"
              onClick={() => setLanguage(language === 'bn' ? 'en' : 'bn')}
            >
              <Languages className="w-5 h-5" />
            </Button>

            {/* Theme Toggle */}
            <Button
              variant="ghost"
              size="icon"
              className="rounded-full"
              onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}
            >
              {theme === 'light' ? (
                <Moon className="w-5 h-5" />
              ) : (
                <Sun className="w-5 h-5" />
              )}
            </Button>
          </div>
        </div>
      </div>

      {/* Comment Thread */}
      <div className="py-4">
        <CommentThread
          language={language}
          theme={theme}
          parentPost={parentPost}
          comments={comments}
        />
      </div>

      {/* Info Panel */}
      <div
        className={`max-w-2xl mx-auto mt-8 p-6 rounded-2xl ${
          theme === 'dark' ? 'bg-[#16181c]' : 'bg-white'
        }`}
      >
        <h3
          className={`mb-3 font-semibold ${
            theme === 'dark' ? 'text-white' : 'text-[#0f1419]'
          }`}
          style={{ fontSize: '17px' }}
        >
          {language === 'bn' ? '✨ বৈশিষ্ট্যসমূহ' : '✨ Features'}
        </h3>
        <ul
          className={`space-y-2 ${
            theme === 'dark' ? 'text-[#71767b]' : 'text-[#536471]'
          }`}
          style={{ fontSize: '15px', lineHeight: '20px' }}
        >
          <li>
            {language === 'bn'
              ? '🎨 Light এবং Dark Mode সাপোর্ট'
              : '🎨 Light and Dark Mode Support'}
          </li>
          <li>
            {language === 'bn'
              ? '🔄 Accordion-style nested comments (expandable/collapsible)'
              : '🔄 Accordion-style nested comments (expandable/collapsible)'}
          </li>
          <li>
            {language === 'bn'
              ? '📏 20px indentation per nesting level'
              : '📏 20px indentation per nesting level'}
          </li>
          <li>
            {language === 'bn'
              ? '🧵 Vertical reply lines showing thread structure'
              : '🧵 Vertical reply lines showing thread structure'}
          </li>
          <li>
            {language === 'bn'
              ? '💬 Avatar, name, handle, timestamp for each comment'
              : '💬 Avatar, name, handle, timestamp for each comment'}
          </li>
          <li>
            {language === 'bn'
              ? '❤️ Interactive like and reply buttons'
              : '❤️ Interactive like and reply buttons'}
          </li>
          <li>
            {language === 'bn'
              ? '🎭 Smooth animations with Motion/Framer'
              : '🎭 Smooth animations with Motion/Framer'}
          </li>
          <li>
            {language === 'bn'
              ? '🌐 Full Bengali and English support'
              : '🌐 Full Bengali and English support'}
          </li>
        </ul>
      </div>
    </div>
  );
};
