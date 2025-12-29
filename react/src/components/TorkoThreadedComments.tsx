import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Heart, MessageCircle, Share2 } from 'lucide-react';

interface CommentData {
  id: string;
  author: {
    name: string;
    username: string;
    avatar: string;
  };
  text: string;
  timestamp: string;
  likes: number;
  replies: number;
  isLiked?: boolean;
  children?: CommentData[];
}

interface CommentItemProps {
  comment: CommentData;
  level?: number;
  isLast?: boolean;
  language?: 'bn' | 'en';
}

const CommentItem: React.FC<CommentItemProps> = ({ 
  comment, 
  level = 0, 
  isLast = false,
  language = 'bn'
}) => {
  const [isLiked, setIsLiked] = useState(comment.isLiked || false);
  const [likesCount, setLikesCount] = useState(comment.likes);
  
  // Avatar sizes based on level
  const avatarSize = level === 0 ? 40 : level === 1 ? 32 : 28;
  const indent = level * 16;
  
  // Typography sizes based on level
  const nameSize = level === 0 ? 'text-[15px]' : 'text-[14px]';
  const usernameSize = level === 0 ? 'text-[14px]' : 'text-[13px]';
  const textSize = level === 0 ? 'text-[15px]' : 'text-[14px]';
  
  const formatNumber = (num: number): string => {
    if (num >= 1000) {
      return (num / 1000).toFixed(1) + 'k';
    }
    return num.toString();
  };

  const handleLike = () => {
    setIsLiked(!isLiked);
    setLikesCount(prev => isLiked ? prev - 1 : prev + 1);
  };

  const t = {
    reply: language === 'bn' ? 'উত্তর' : 'Reply',
    like: language === 'bn' ? 'পছন্দ' : 'Like',
    share: language === 'bn' ? 'শেয়ার' : 'Share',
  };

  return (
    <div className="relative">
      {/* Thread Line System */}
      {level > 0 && (
        <div 
          className="absolute pointer-events-none" 
          style={{ 
            left: `${indent - 16}px`,
            top: 0,
            bottom: 0,
          }}
        >
          {/* Vertical thread line */}
          <div
            className="absolute bg-[#E4E6EA] dark:bg-[#3A3A3C]"
            style={{
              left: `${level === 1 ? '20px' : '16px'}`,
              top: level === 1 ? '-12px' : '-12px',
              width: '1.5px',
              height: isLast && !comment.children?.length 
                ? `${avatarSize / 2 + 12}px` 
                : 'calc(100% + 12px)',
            }}
          />
          
          {/* Curved elbow connector */}
          <svg
            className="absolute overflow-visible"
            style={{
              left: `${level === 1 ? '20px' : '16px'}`,
              top: `${avatarSize / 2 - 8}px`,
            }}
            width="24"
            height="20"
            viewBox="0 0 24 20"
          >
            <path
              d="M 0.75 0 L 0.75 12 Q 0.75 20, 8.75 20 L 24 20"
              stroke="#E4E6EA"
              strokeWidth="1.5"
              fill="none"
              className="dark:stroke-[#3A3A3C]"
            />
          </svg>
        </div>
      )}

      {/* Comment Content */}
      <div 
        className="flex gap-2"
        style={{ paddingLeft: `${indent}px` }}
      >
        {/* Avatar */}
        <div className="flex-shrink-0 relative z-10">
          <div 
            className="rounded-full overflow-hidden bg-gray-100 dark:bg-[#2a2a2a]"
            style={{ 
              width: `${avatarSize}px`, 
              height: `${avatarSize}px`,
            }}
          >
            <img 
              src={comment.author.avatar} 
              alt={comment.author.name}
              className="w-full h-full object-cover"
            />
          </div>
        </div>

        {/* Comment Body */}
        <div className="flex-1 min-w-0">
          {/* Header: Name, Username, Time */}
          <div className="flex items-center gap-1 mb-0.5 flex-wrap">
            <span 
              className={`font-['Noto_Sans_Bengali',sans-serif] ${nameSize} font-semibold text-[#0F1419] dark:text-white`}
            >
              {comment.author.name}
            </span>
            <span 
              className={`font-['Noto_Sans_Bengali',sans-serif] ${usernameSize} text-[#687684] dark:text-[#8E8E93]`}
            >
              @{comment.author.username}
            </span>
            <span className="text-[#9AA1A9] dark:text-[#636366]">·</span>
            <span className="text-[12px] text-[#9AA1A9] dark:text-[#636366]">
              {comment.timestamp}
            </span>
          </div>

          {/* Comment Text */}
          <p 
            className={`font-['Noto_Sans_Bengali',sans-serif] ${textSize} text-[#1A1A1A] dark:text-[#E5E5E7] leading-[1.4] mb-2.5`}
            style={{
              display: '-webkit-box',
              WebkitLineClamp: 6,
              WebkitBoxOrient: 'vertical',
              overflow: 'hidden',
            }}
          >
            {comment.text}
          </p>

          {/* Action Row */}
          <div className="flex items-center gap-5 mb-3">
            {/* Reply */}
            <button className="flex items-center gap-1.5 group">
              <div className="p-1.5 rounded-full group-hover:bg-[#247CFF]/10 transition-colors duration-200">
                <MessageCircle className="w-[16px] h-[16px] text-[#687684] group-hover:text-[#247CFF] transition-colors dark:text-[#8E8E93]" />
              </div>
              {comment.replies > 0 && (
                <span className="text-[13px] text-[#687684] group-hover:text-[#247CFF] transition-colors dark:text-[#8E8E93]">
                  {formatNumber(comment.replies)}
                </span>
              )}
            </button>

            {/* Like */}
            <button 
              onClick={handleLike}
              className="flex items-center gap-1.5 group"
            >
              <div className="p-1.5 rounded-full group-hover:bg-[#FF3B30]/10 transition-colors duration-200">
                <Heart 
                  className={`w-[16px] h-[16px] transition-all duration-200 ${
                    isLiked 
                      ? 'fill-[#FF3B30] text-[#FF3B30]' 
                      : 'text-[#687684] group-hover:text-[#FF3B30] dark:text-[#8E8E93]'
                  }`}
                />
              </div>
              {likesCount > 0 && (
                <span 
                  className={`text-[13px] transition-colors duration-200 ${
                    isLiked 
                      ? 'text-[#FF3B30]' 
                      : 'text-[#687684] group-hover:text-[#FF3B30] dark:text-[#8E8E93]'
                  }`}
                >
                  {formatNumber(likesCount)}
                </span>
              )}
            </button>

            {/* Share */}
            <button className="flex items-center gap-1.5 group">
              <div className="p-1.5 rounded-full group-hover:bg-[#247CFF]/10 transition-colors duration-200">
                <Share2 className="w-[16px] h-[16px] text-[#687684] group-hover:text-[#247CFF] transition-colors dark:text-[#8E8E93]" />
              </div>
            </button>
          </div>
        </div>
      </div>

      {/* Nested Replies */}
      {comment.children && comment.children.length > 0 && (
        <div className="mt-3">
          {comment.children.map((child, index) => (
            <div key={child.id} className={index > 0 ? 'mt-3' : ''}>
              <CommentItem 
                comment={child} 
                level={level + 1}
                isLast={index === comment.children!.length - 1}
                language={language}
              />
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

interface TorkoThreadedCommentsProps {
  comments: CommentData[];
  language?: 'bn' | 'en';
}

export const TorkoThreadedComments: React.FC<TorkoThreadedCommentsProps> = ({ 
  comments,
  language = 'bn'
}) => {
  return (
    <div className="bg-white dark:bg-[#052029] px-4 py-3">
      {/* Comments Section Title */}
      <div className="mb-4">
        <h2 className="font-['Noto_Sans_Bengali',sans-serif] text-[17px] font-semibold text-[#0F1419] dark:text-white">
          {language === 'bn' ? 'মন্তব্যসমূহ' : 'Comments'}
        </h2>
      </div>

      {/* Comments List */}
      <div className="space-y-3">
        {comments.map((comment, index) => (
          <div key={comment.id} className={index > 0 ? 'pt-3 border-t border-[#E4E6EA] dark:border-[#38383A]' : ''}>
            <CommentItem 
              comment={comment} 
              isLast={index === comments.length - 1}
              language={language}
            />
          </div>
        ))}
      </div>
    </div>
  );
};

// Sample data for demo
export const sampleComments: CommentData[] = [
  {
    id: '1',
    author: {
      name: 'সারাহ জনসন',
      username: 'sarahjdev',
      avatar: 'https://images.unsplash.com/photo-1649589244330-09ca58e4fa64?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400',
    },
    text: 'এই মেট্রো প্রকল্পটি সত্যিই গেম চেঞ্জার হবে! ঢাকার ট্রাফিক সমস্যা অনেকটাই কমে যাবে। দুর্দান্ত উদ্যোগ!',
    timestamp: '২ ঘণ্টা',
    likes: 156,
    replies: 8,
    isLiked: false,
    children: [
      {
        id: '2',
        author: {
          name: 'আলেক্স চেন',
          username: 'alexchen',
          avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400',
        },
        text: 'একদম সঠিক বলেছেন! আমি প্রতিদিন ২ ঘণ্টা ট্রাফিকে নষ্ট করি। মেট্রো চালু হলে অনেক সময় বাঁচবে।',
        timestamp: '১ ঘণ্টা',
        likes: 42,
        replies: 1,
        isLiked: true,
        children: [
          {
            id: '4',
            author: {
              name: 'সারাহ জনসন',
              username: 'sarahjdev',
              avatar: 'https://images.unsplash.com/photo-1649589244330-09ca58e4fa64?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400',
            },
            text: 'হ্যাঁ! আর পরিবেশের জন্যও ভালো। কম গাড়ি মানে কম দূষণ।',
            timestamp: '৪৫ মিনিট',
            likes: 28,
            replies: 0,
            isLiked: false,
          },
        ],
      },
      {
        id: '3',
        author: {
          name: 'এমা রদ্রিগেজ',
          username: 'emmarodriguez',
          avatar: 'https://images.unsplash.com/photo-1606416041875-c020fd6cd16c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400',
        },
        text: 'আশা করি টিকিটের দাম সাধারণ মানুষের নাগালে থাকবে। তাহলেই সবাই উপকৃত হবে।',
        timestamp: '৫০ মিনিট',
        likes: 67,
        replies: 0,
        isLiked: false,
      },
    ],
  },
];
