import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Send, Heart, MessageCircle, Share2 } from 'lucide-react';

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

interface TorkoCommentsModalProps {
  isOpen: boolean;
  onClose: () => void;
  postId: number | null;
  postAuthor?: string;
  postContent?: string;
  language?: 'bn' | 'en';
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
  const avatarSize = level === 0 ? 40 : level === 1 ? 36 : 32;
  
  // Only show connecting lines for level 1 and 2 (not level 3)
  const showThreadLine = level > 0 && level < 3;
  
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

  return (
    <div className="relative">
      {/* Thread Line System - Only for Level 1 & 2 */}
      {showThreadLine && (
        <>
          {/* Curved connector from parent to child */}
          <svg
            className="absolute pointer-events-none z-0"
            style={{
              left: level === 1 ? '-24px' : '-20px',
              top: '-12px',
              width: '48px',
              height: '52px',
            }}
          >
            {/* Curved L-shape: Vertical line curving into horizontal line */}
            <path
              d="M 20 0 V 32 Q 20 40, 28 40 H 48"
              stroke="#CBD5E0"
              strokeWidth="2"
              fill="none"
              className="dark:stroke-[#3E3E40]"
            />
          </svg>

          {/* Vertical line extending down if there are siblings below */}
          {!isLast && (
            <div
              className="absolute pointer-events-none z-0 bg-[#CBD5E0] dark:bg-[#3E3E40]"
              style={{
                left: level === 1 ? '-4px' : '0px',
                top: '-12px',
                width: '2px',
                height: 'calc(100% + 12px)',
              }}
            />
          )}
        </>
      )}

      {/* Comment Content */}
      <div 
        className="flex gap-2.5 relative z-10"
        style={{ 
          marginLeft: level === 1 ? '24px' : level === 2 ? '48px' : level === 3 ? '72px' : '0px'
        }}
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
              <div className="p-1.5 rounded-full group-hover:bg-[#d6775c]/10 transition-colors duration-200">
                <MessageCircle className="w-[16px] h-[16px] text-[#687684] group-hover:text-[#d6775c] transition-colors dark:text-[#8E8E93]" />
              </div>
              {comment.replies > 0 && (
                <span className="text-[13px] text-[#687684] group-hover:text-[#d6775c] transition-colors dark:text-[#8E8E93]">
                  {formatNumber(comment.replies)}
                </span>
              )}
            </button>

            {/* Like */}
            <button 
              onClick={handleLike}
              className="flex items-center gap-1.5 group"
            >
              <div className="p-1.5 rounded-full group-hover:bg-[#d6775c]/10 transition-colors duration-200">
                <Heart 
                  className={`w-[16px] h-[16px] transition-all duration-200 ${
                    isLiked 
                      ? 'fill-[#d6775c] text-[#d6775c]' 
                      : 'text-[#687684] group-hover:text-[#d6775c] dark:text-[#8E8E93]'
                  }`}
                />
              </div>
              {likesCount > 0 && (
                <span 
                  className={`text-[13px] transition-colors duration-200 ${
                    isLiked 
                      ? 'text-[#d6775c]' 
                      : 'text-[#687684] group-hover:text-[#d6775c] dark:text-[#8E8E93]'
                  }`}
                >
                  {formatNumber(likesCount)}
                </span>
              )}
            </button>

            {/* Share */}
            <button className="flex items-center gap-1.5 group">
              <div className="p-1.5 rounded-full group-hover:bg-[#d6775c]/10 transition-colors duration-200">
                <Share2 className="w-[16px] h-[16px] text-[#687684] group-hover:text-[#d6775c] transition-colors dark:text-[#8E8E93]" />
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

export const TorkoCommentsModal: React.FC<TorkoCommentsModalProps> = ({
  isOpen,
  onClose,
  postId,
  postAuthor,
  postContent,
  language = 'bn',
}) => {
  const [newComment, setNewComment] = useState('');

  const t = {
    comments: language === 'bn' ? 'মন্তব্যসমূহ' : 'Comments',
    writeComment: language === 'bn' ? 'একটি মন্তব্য লিখুন...' : 'Write a comment...',
    post: language === 'bn' ? 'পোস্ট করুন' : 'Post',
  };

  // Don't render if not open or no post ID
  if (!isOpen || !postId) return null;

  // Mock comments with Twitter-style structure
  const mockComments: CommentData[] = [
    {
      id: '1',
      author: {
        name: language === 'bn' ? 'সারাহ জনসন' : 'Sarah Johnson',
        username: 'sarahjdev',
        avatar: 'https://images.unsplash.com/photo-1623594675959-02360202d4d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400',
      },
      text: language === 'bn' 
        ? 'এই প্রকল্পটি সত্যিই গেম চেঞ্জার হবে! ঢাকার ট্রাফিক সমস্যা অনেকটাই কমে যাবে। দুর্দান্ত উদ্যোগ!' 
        : 'This project will truly be a game changer! Dhaka traffic problem will reduce significantly. Great initiative!',
      timestamp: language === 'bn' ? '২ ঘণ্টা' : '2h',
      likes: 156,
      replies: 2,
      isLiked: false,
      children: [
        {
          id: '2',
          author: {
            name: language === 'bn' ? 'আলেক্স চেন' : 'Alex Chen',
            username: 'alexchen',
            avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400',
          },
          text: language === 'bn' 
            ? 'একদম সঠিক বলেছেন! আমি প্রতিদিন ২ ঘণ্টা ট্রাফিকে নষ্ট করি। মেট্রো চালু হলে অনেক সময় বাঁচবে।' 
            : 'Absolutely right! I waste 2 hours daily in traffic. Metro will save so much time.',
          timestamp: language === 'bn' ? '১ ঘণ্টা' : '1h',
          likes: 42,
          replies: 1,
          isLiked: true,
          children: [
            {
              id: '4',
              author: {
                name: language === 'bn' ? 'সারাহ জনসন' : 'Sarah Johnson',
                username: 'sarahjdev',
                avatar: 'https://images.unsplash.com/photo-1623594675959-02360202d4d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400',
              },
              text: language === 'bn' 
                ? 'হ্যাঁ! আর পরিবেশের জন্যও ভালো। কম গাড়ি মানে কম দূষণ।' 
                : 'Yes! And good for environment too. Fewer cars means less pollution.',
              timestamp: language === 'bn' ? '৪৫ মিনিট' : '45m',
              likes: 28,
              replies: 0,
              isLiked: false,
            },
          ],
        },
        {
          id: '3',
          author: {
            name: language === 'bn' ? 'এমা রদ্রিগেজ' : 'Emma Rodriguez',
            username: 'emmarodriguez',
            avatar: 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400',
          },
          text: language === 'bn' 
            ? 'আশা করি টিকিটের দাম সাধারণ মানুষের নাগালে থাকবে। তাহলেই সবাই উপকৃত হবে।' 
            : 'Hope ticket prices remain affordable for common people. Then everyone will benefit.',
          timestamp: language === 'bn' ? '৫০ মিনিট' : '50m',
          likes: 67,
          replies: 0,
          isLiked: false,
        },
      ],
    },
  ];

  const handlePostComment = () => {
    if (newComment.trim()) {
      console.log('New comment:', newComment);
      setNewComment('');
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center"
      onClick={onClose}
    >
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" />

      {/* Modal */}
      <motion.div
        initial={{ y: '100%', opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        exit={{ y: '100%', opacity: 0 }}
        transition={{ type: 'spring', damping: 30, stiffness: 300 }}
        className="relative w-full max-w-[768px] bg-white dark:bg-[#052029] rounded-t-[24px] sm:rounded-[24px] max-h-[90vh] flex flex-col shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex-shrink-0 flex items-center justify-between px-5 py-4 border-b border-[#E4E6EA] dark:border-[#38383A]">
          <h2 className="font-['Noto_Sans_Bengali',sans-serif] text-[18px] font-bold text-[#0F1419] dark:text-white">
            {t.comments}
          </h2>
          <button
            onClick={onClose}
            className="p-2 -mr-2 rounded-full hover:bg-gray-100 dark:hover:bg-[#1C1C1E] transition-colors"
          >
            <X className="w-5 h-5 text-[#687684] dark:text-[#8E8E93]" />
          </button>
        </div>

        {/* Comments List - Scrollable */}
        <div className="flex-1 overflow-y-auto px-4 py-3">
          <div className="space-y-3">
            {mockComments.map((comment, index) => (
              <div key={comment.id} className={index > 0 ? 'pt-3 border-t border-[#E4E6EA] dark:border-[#38383A]' : ''}>
                <CommentItem 
                  comment={comment} 
                  isLast={index === mockComments.length - 1}
                  language={language}
                />
              </div>
            ))}
          </div>
        </div>

        {/* Comment Input - Fixed at bottom */}
        <div className="flex-shrink-0 border-t border-[#E4E6EA] dark:border-[#38383A] p-4 bg-white dark:bg-[#052029]">
          <div className="flex gap-3 items-end">
            <div className="flex-1 bg-[#F5F5F5] dark:bg-[#1C1C1E] rounded-[20px] px-4 py-2.5 min-h-[44px] max-h-[120px] overflow-y-auto">
              <textarea
                value={newComment}
                onChange={(e) => setNewComment(e.target.value)}
                placeholder={t.writeComment}
                className="w-full bg-transparent font-['Noto_Sans_Bengali',sans-serif] text-[15px] text-[#1A1A1A] dark:text-white outline-none resize-none placeholder:text-[#9AA1A9]"
                rows={1}
                style={{ minHeight: '24px' }}
              />
            </div>
            <button
              onClick={handlePostComment}
              disabled={!newComment.trim()}
              className="flex-shrink-0 w-[44px] h-[44px] rounded-full bg-[#d6775c] flex items-center justify-center hover:bg-[#c96647] transition-all duration-200 disabled:opacity-40 disabled:cursor-not-allowed shadow-sm"
            >
              <Send className="w-5 h-5 text-white" />
            </button>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
};