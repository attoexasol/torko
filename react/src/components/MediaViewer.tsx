import React, { useState } from 'react';
import { X, ChevronLeft, ChevronRight, Heart, MessageCircle, Share2, MoreHorizontal } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import svgPaths from '../imports/svg-c9lk6172rh';

interface MediaViewerProps {
  isOpen: boolean;
  onClose: () => void;
  media: string[];
  type: 'image' | 'video';
  initialIndex?: number;
  author: string;
  avatar: string;
  timestamp: string;
  content: string;
  likes: number;
  comments: number;
  isLiked?: boolean;
  onLike?: () => void;
  onComment?: () => void;
  onShare?: () => void;
  language?: 'bn' | 'en';
}

interface Comment {
  id: string;
  author: string;
  avatar: string;
  content: string;
  timestamp: string;
  likes: number;
}

export const MediaViewer: React.FC<MediaViewerProps> = ({
  isOpen,
  onClose,
  media,
  type,
  initialIndex = 0,
  author,
  avatar,
  timestamp,
  content,
  likes,
  comments,
  isLiked = false,
  onLike,
  onComment,
  onShare,
  language = 'bn'
}) => {
  const [currentIndex, setCurrentIndex] = useState(initialIndex);
  const [liked, setLiked] = useState(isLiked);
  const [likeCount, setLikeCount] = useState(likes);

  const t = {
    like: language === 'bn' ? 'পছন্দ' : 'Like',
    comment: language === 'bn' ? 'মন্তব্য' : 'Comment',
    share: language === 'bn' ? 'শেয়ার' : 'Share',
    writeComment: language === 'bn' ? 'মন্তব্য লিখুন...' : 'Write a comment...',
    allComments: language === 'bn' ? 'সব মন্তব্য' : 'All Comments',
  };

  const handlePrevious = () => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
    }
  };

  const handleNext = () => {
    if (currentIndex < media.length - 1) {
      setCurrentIndex(currentIndex + 1);
    }
  };

  const handleLike = () => {
    setLiked(!liked);
    setLikeCount(liked ? likeCount - 1 : likeCount + 1);
    onLike?.();
  };

  // Mock comments
  const mockComments: Comment[] = [
    {
      id: '1',
      author: 'সাবিনা আক্তার',
      avatar: 'https://ui-avatars.com/api/?name=Sabina&background=d97757&color=fff&size=128',
      content: 'খুব সুন্দর ছবি!',
      timestamp: '২ ঘণ্টা আগে',
      likes: 12
    },
    {
      id: '2',
      author: 'রাফি আহমেদ',
      avatar: 'https://ui-avatars.com/api/?name=Rafi&background=6B9BD1&color=fff&size=128',
      content: 'Amazing shots! কোথায় তোলা?',
      timestamp: '১ ঘণ্টা আগে',
      likes: 5
    },
    {
      id: '3',
      author: 'নাদিয়া খান',
      avatar: 'https://ui-avatars.com/api/?name=Nadia&background=9333ea&color=fff&size=128',
      content: 'Beautiful! আমিও যেতে চাই',
      timestamp: '৩০ মিনিট আগে',
      likes: 8
    }
  ];

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-[100] bg-black/95 flex"
        onClick={onClose}
      >
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-[16px] right-[16px] z-[110] w-[40px] h-[40px] rounded-full bg-[#2a2a2a] hover:bg-[#3a3a3a] flex items-center justify-center transition-colors"
        >
          <X className="w-[24px] h-[24px] text-white" />
        </button>

        {/* Left side - Media viewer */}
        <div 
          className="flex-1 flex items-center justify-center relative"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Previous button */}
          {media.length > 1 && currentIndex > 0 && (
            <button
              onClick={handlePrevious}
              className="absolute left-[16px] z-[110] w-[48px] h-[48px] rounded-full bg-[#2a2a2a]/80 hover:bg-[#3a3a3a]/90 flex items-center justify-center transition-colors"
            >
              <ChevronLeft className="w-[28px] h-[28px] text-white" />
            </button>
          )}

          {/* Media content */}
          <div className="max-w-full max-h-[100vh] flex items-center justify-center">
            {type === 'image' ? (
              <img
                src={media[currentIndex]}
                alt="Viewer"
                className="max-w-full max-h-[100vh] object-contain"
              />
            ) : (
              <video
                src={media[currentIndex]}
                controls
                autoPlay
                className="max-w-full max-h-[100vh] object-contain"
              />
            )}
          </div>

          {/* Next button */}
          {media.length > 1 && currentIndex < media.length - 1 && (
            <button
              onClick={handleNext}
              className="absolute right-[16px] z-[110] w-[48px] h-[48px] rounded-full bg-[#2a2a2a]/80 hover:bg-[#3a3a3a]/90 flex items-center justify-center transition-colors"
            >
              <ChevronRight className="w-[28px] h-[28px] text-white" />
            </button>
          )}

          {/* Counter */}
          {media.length > 1 && (
            <div className="absolute bottom-[16px] left-1/2 transform -translate-x-1/2 px-[16px] py-[8px] rounded-full bg-[#2a2a2a]/80 text-white">
              {currentIndex + 1} / {media.length}
            </div>
          )}
        </div>

        {/* Right side - Post details and comments */}
        <div 
          className="w-[400px] bg-white dark:bg-[#1a1a1a] flex flex-col"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Post header */}
          <div className="p-[16px] border-b border-[#e5e7eb] dark:border-[#2a2a2a]">
            <div className="flex items-start gap-[12px]">
              <div 
                className="w-[40px] h-[40px] rounded-full overflow-hidden flex-shrink-0"
                style={{
                  background: `url(${avatar}) center/cover`
                }}
              />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-[6px]">
                  <span className="text-[#1a1a1a] dark:text-white">
                    {author}
                  </span>
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                    <path d={svgPaths.verifiedBadge} fill="#d97757" />
                  </svg>
                </div>
                <span className="text-[#6b7280] dark:text-[#9ca3af] text-[13px]">
                  {timestamp}
                </span>
              </div>
              <button className="p-[8px] hover:bg-[#f3f4f6] dark:hover:bg-[#2a2a2a] rounded-full transition-colors">
                <MoreHorizontal className="w-[20px] h-[20px] text-[#6b7280] dark:text-[#9ca3af]" />
              </button>
            </div>

            {/* Post content */}
            {content && (
              <div className="mt-[12px] text-[#1a1a1a] dark:text-white">
                {content}
              </div>
            )}
          </div>

          {/* Stats */}
          <div className="px-[16px] py-[12px] border-b border-[#e5e7eb] dark:border-[#2a2a2a] flex items-center justify-between">
            <div className="flex items-center gap-[6px]">
              <div className="w-[20px] h-[20px] rounded-full bg-[#d97757] flex items-center justify-center">
                <Heart className="w-[12px] h-[12px] text-white fill-white" />
              </div>
              <span className="text-[#6b7280] dark:text-[#9ca3af] text-[14px]">
                {likeCount}
              </span>
            </div>
            <span className="text-[#6b7280] dark:text-[#9ca3af] text-[14px]">
              {comments} {t.comment}
            </span>
          </div>

          {/* Action buttons */}
          <div className="px-[16px] py-[8px] border-b border-[#e5e7eb] dark:border-[#2a2a2a] grid grid-cols-3 gap-[8px]">
            <button
              onClick={handleLike}
              className={`flex items-center justify-center gap-[6px] py-[8px] rounded-[8px] transition-colors ${
                liked 
                  ? 'text-[#d97757]' 
                  : 'text-[#6b7280] dark:text-[#9ca3af] hover:bg-[#f3f4f6] dark:hover:bg-[#2a2a2a]'
              }`}
            >
              <Heart className={`w-[20px] h-[20px] ${liked ? 'fill-[#d97757]' : ''}`} />
              <span>{t.like}</span>
            </button>
            <button
              onClick={onComment}
              className="flex items-center justify-center gap-[6px] py-[8px] rounded-[8px] text-[#6b7280] dark:text-[#9ca3af] hover:bg-[#f3f4f6] dark:hover:bg-[#2a2a2a] transition-colors"
            >
              <MessageCircle className="w-[20px] h-[20px]" />
              <span>{t.comment}</span>
            </button>
            <button
              onClick={onShare}
              className="flex items-center justify-center gap-[6px] py-[8px] rounded-[8px] text-[#6b7280] dark:text-[#9ca3af] hover:bg-[#f3f4f6] dark:hover:bg-[#2a2a2a] transition-colors"
            >
              <Share2 className="w-[20px] h-[20px]" />
              <span>{t.share}</span>
            </button>
          </div>

          {/* Comments section */}
          <div className="flex-1 overflow-y-auto">
            <div className="p-[16px]">
              <h3 className="text-[#1a1a1a] dark:text-white mb-[16px]">
                {t.allComments}
              </h3>
              
              {mockComments.map((comment) => (
                <div key={comment.id} className="mb-[16px] flex gap-[12px]">
                  <div 
                    className="w-[36px] h-[36px] rounded-full overflow-hidden flex-shrink-0"
                    style={{
                      background: `url(${comment.avatar}) center/cover`
                    }}
                  />
                  <div className="flex-1">
                    <div className="bg-[#f3f4f6] dark:bg-[#2a2a2a] rounded-[16px] px-[12px] py-[8px]">
                      <div className="text-[#1a1a1a] dark:text-white">
                        {comment.author}
                      </div>
                      <div className="text-[#1a1a1a] dark:text-white text-[14px] mt-[4px]">
                        {comment.content}
                      </div>
                    </div>
                    <div className="flex items-center gap-[16px] mt-[6px] px-[12px]">
                      <button className="text-[#6b7280] dark:text-[#9ca3af] text-[13px] hover:underline">
                        {t.like}
                      </button>
                      <button className="text-[#6b7280] dark:text-[#9ca3af] text-[13px] hover:underline">
                        Reply
                      </button>
                      <span className="text-[#6b7280] dark:text-[#9ca3af] text-[13px]">
                        {comment.timestamp}
                      </span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Comment input */}
          <div className="p-[16px] border-t border-[#e5e7eb] dark:border-[#2a2a2a]">
            <div className="flex items-center gap-[12px]">
              <div 
                className="w-[36px] h-[36px] rounded-full overflow-hidden flex-shrink-0"
                style={{
                  background: `url(${avatar}) center/cover`
                }}
              />
              <input
                type="text"
                placeholder={t.writeComment}
                className="flex-1 bg-[#f3f4f6] dark:bg-[#2a2a2a] rounded-full px-[16px] py-[8px] outline-none text-[#1a1a1a] dark:text-white placeholder:text-[#9ca3af]"
              />
            </div>
          </div>
        </div>
      </motion.div>
    </AnimatePresence>
  );
};