import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Heart, MessageCircle } from 'lucide-react';
import imgFrame from "figma:asset/a6746284f9589fbc91a471b3324f42c0ddd746b7.png";

export interface Comment {
  id: string;
  author: string;
  username: string;
  avatar?: string;
  content: string;
  time: string;
  likes: number;
  isLiked: boolean;
  replies?: Comment[];
}

interface CommentThreadProps {
  comments: Comment[];
  language?: 'bn' | 'en';
  level?: number;
  maxLevel?: number;
  onReply?: (commentId: string, content: string) => void;
  onLike?: (commentId: string) => void;
}

const CommentItem: React.FC<{
  comment: Comment;
  language: 'bn' | 'en';
  level: number;
  maxLevel: number;
  isLast: boolean;
  onReply?: (commentId: string, content: string) => void;
  onLike?: (commentId: string) => void;
  hasReplies: boolean;
}> = ({ comment, language, level, maxLevel, isLast, onReply, onLike, hasReplies }) => {
  const [isLiked, setIsLiked] = useState(comment.isLiked);
  const [showReplyInput, setShowReplyInput] = useState(false);
  const [replyText, setReplyText] = useState('');
  const [showReplies, setShowReplies] = useState(true);

  const t = {
    reply: language === 'bn' ? 'উত্তর দিন' : 'Reply',
    seeMore: language === 'bn' ? 'আরও দেখুন' : 'See More',
    seeLess: language === 'bn' ? 'কম দেখুন' : 'See Less',
    writeReply: language === 'bn' ? 'উত্তর লিখুন...' : 'Write a reply...',
    post: language === 'bn' ? 'পোস্ট করুন' : 'Post',
    cancel: language === 'bn' ? 'বাতিল' : 'Cancel',
  };

  const handleLike = () => {
    setIsLiked(!isLiked);
    if (onLike) {
      onLike(comment.id);
    }
  };

  const handleReplySubmit = () => {
    if (replyText.trim() && onReply) {
      onReply(comment.id, replyText);
      setReplyText('');
      setShowReplyInput(false);
    }
  };

  const formatNumber = (num: number): string => {
    if (num >= 1000) {
      return (num / 1000).toFixed(1) + 'k';
    }
    return num.toString();
  };

  return (
    <div className="relative">
      <div className="flex gap-3 relative">
        {/* Avatar */}
        <div className="relative flex-shrink-0">
          {/* Connecting line indicator - only for nested comments */}
          {level > 0 && (
            <div className="absolute -left-6 top-0 bottom-0 flex items-start pt-[17px]">
              {/* Vertical line from top */}
              {!isLast || hasReplies ? (
                <div className="absolute left-0 top-0 w-[2px] h-full bg-[#E5E7EB] dark:bg-[#374151]" />
              ) : (
                <div className="absolute left-0 top-0 w-[2px] h-[17px] bg-[#E5E7EB] dark:bg-[#374151]" />
              )}
              
              {/* Horizontal connector */}
              <div className="absolute left-0 top-0 h-[2px] w-6 bg-[#E5E7EB] dark:bg-[#374151]" 
                   style={{ top: '17px', borderRadius: '0 2px 2px 0' }} />
              
              {/* Corner curve */}
              <div className="absolute left-0 w-[2px] h-[17px] overflow-hidden">
                <div className="absolute left-0 bottom-0 w-6 h-6 border-l-2 border-b-2 border-[#E5E7EB] dark:border-[#374151] rounded-bl-md" />
              </div>
            </div>
          )}
          
          <div className="w-[34px] h-[34px] rounded-full overflow-hidden bg-white dark:bg-[#2a2a2a] border-[3px] border-white dark:border-[#0a0a0a] shadow-sm relative z-10">
            <img 
              src={comment.avatar || imgFrame} 
              alt={comment.author}
              className="w-full h-full object-cover"
            />
          </div>
        </div>

        {/* Comment Content */}
        <div className="flex-1 min-w-0 pt-[2px]">
          {/* Author and Time */}
          <div className="flex items-center gap-1.5 mb-1">
            <span className="font-['Noto_Sans_Bengali',sans-serif] text-[14px] font-semibold text-[#0f1419] dark:text-white">
              {comment.author}
            </span>
            <span className="text-[#9CA3AF] text-[12px]">·</span>
            <span className="text-[#9CA3AF] text-[12px]">{comment.time}</span>
          </div>

          {/* Comment Text */}
          <p className="font-['Noto_Sans_Bengali',sans-serif] text-[14px] text-[#374151] dark:text-[#D1D5DB] leading-[21px] mb-2.5">
            {comment.content}
          </p>

          {/* Actions */}
          <div className="flex items-center gap-4 mb-3">
            <button
              onClick={handleLike}
              className="flex items-center gap-1.5 group"
            >
              <Heart
                className={`w-4 h-4 transition-all duration-200 ${ 
                  isLiked
                    ? 'fill-[#d6775c] text-[#d6775c]'
                    : 'text-[#9CA3AF] group-hover:text-[#d6775c]'
                }`}
              />
              <span
                className={`text-[13px] font-medium transition-colors duration-200 ${
                  isLiked
                    ? 'text-[#d6775c]'
                    : 'text-[#9CA3AF] group-hover:text-[#d6775c]'
                }`}
              >
                {isLiked ? formatNumber(comment.likes + 1) : formatNumber(comment.likes)}
              </span>
            </button>

            <button
              onClick={() => setShowReplyInput(!showReplyInput)}
              className="flex items-center gap-1.5 group"
            >
              <MessageCircle className="w-4 h-4 text-[#9CA3AF] group-hover:text-[#d6775c] transition-all duration-200" />
              <span className="text-[13px] font-medium text-[#9CA3AF] group-hover:text-[#d6775c] transition-colors duration-200">
                {t.reply}
              </span>
            </button>
          </div>

          {/* Reply Input */}
          <AnimatePresence>
            {showReplyInput && (
              <motion.div
                initial={{ opacity: 0, height: 0, marginBottom: 0 }}
                animate={{ opacity: 1, height: 'auto', marginBottom: 14 }}
                exit={{ opacity: 0, height: 0, marginBottom: 0 }}
                transition={{ duration: 0.2 }}
              >
                <div className="bg-[#F9FAFB] dark:bg-[#1F2937] rounded-xl p-3.5 border border-[#E5E7EB] dark:border-[#374151]">
                  <textarea
                    value={replyText}
                    onChange={(e) => setReplyText(e.target.value)}
                    placeholder={t.writeReply}
                    className="w-full bg-transparent font-['Noto_Sans_Bengali',sans-serif] text-[14px] text-[#111827] dark:text-white outline-none resize-none min-h-[64px] placeholder:text-[#9CA3AF]"
                    autoFocus
                  />
                  <div className="flex items-center justify-end gap-2.5 mt-2.5">
                    <button
                      onClick={() => {
                        setShowReplyInput(false);
                        setReplyText('');
                      }}
                      className="px-4 py-2 rounded-lg text-[13px] font-semibold text-[#6B7280] hover:bg-[#F3F4F6] dark:hover:bg-[#374151] transition-colors"
                    >
                      {t.cancel}
                    </button>
                    <button
                      onClick={handleReplySubmit}
                      disabled={!replyText.trim()}
                      className="px-4 py-2 rounded-lg text-[13px] font-semibold bg-[#d6775c] text-white hover:bg-[#c96647] transition-all disabled:opacity-40 disabled:cursor-not-allowed"
                    >
                      {t.post}
                    </button>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* Nested Replies */}
      {comment.replies && comment.replies.length > 0 && (
        <div className="relative mt-4" style={{ marginLeft: level < maxLevel - 1 ? '40px' : '0' }}>
          <AnimatePresence>
            {showReplies && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                transition={{ duration: 0.2 }}
              >
                <CommentThread
                  comments={comment.replies}
                  language={language}
                  level={level + 1}
                  maxLevel={maxLevel}
                  onReply={onReply}
                  onLike={onLike}
                />
              </motion.div>
            )}
          </AnimatePresence>

          {/* Toggle Replies Button */}
          <button
            onClick={() => setShowReplies(!showReplies)}
            className="flex items-center gap-2 mt-2 px-3 py-1.5 rounded-lg text-[13px] font-semibold text-[#d6775c] hover:bg-[#FFF5F2] dark:hover:bg-[#2a1a16] transition-all"
          >
            <div className={`transition-transform duration-200 ${showReplies ? 'rotate-180' : ''}`}>
              {showReplies ? '−' : '+'}
            </div>
            <span>
              {showReplies 
                ? t.seeLess
                : `${comment.replies.length} ${t.seeMore}`
              }
            </span>
          </button>
        </div>
      )}
    </div>
  );
};

export const CommentThread: React.FC<CommentThreadProps> = ({
  comments,
  language = 'bn',
  level = 0,
  maxLevel = 3,
  onReply,
  onLike,
}) => {
  const t = {
    seeMore: language === 'bn' ? 'আরও মন্তব্য দেখুন' : 'See More Comments',
  };

  if (level >= maxLevel) {
    return (
      <button
        className="flex items-center gap-2.5 mt-3 px-4 py-2.5 rounded-lg text-[13px] font-semibold text-[#d6775c] hover:bg-[#FFF5F2] dark:hover:bg-[#2a1a16] transition-all border-2 border-dashed border-[#d6775c]/30"
      >
        <span>+</span>
        <span>{t.seeMore}</span>
      </button>
    );
  }

  return (
    <div className={`flex flex-col ${level === 0 ? 'gap-5' : 'gap-4'}`}>
      {comments.map((comment, index) => (
        <CommentItem
          key={comment.id}
          comment={comment}
          language={language}
          level={level}
          maxLevel={maxLevel}
          isLast={index === comments.length - 1}
          onReply={onReply}
          onLike={onLike}
          hasReplies={!!comment.replies && comment.replies.length > 0}
        />
      ))}
    </div>
  );
};
