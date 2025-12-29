import React, { useState } from 'react';
import svgPaths from '../imports/svg-c9lk6172rh';
import { Share2, Copy, MessageCircle, Bookmark, Flag, UserX, Trash2, Edit3, Link, BarChart3 } from 'lucide-react';
import { toast } from 'sonner@2.0.3';
import { MultiMediaGrid } from './MultiMediaGrid';
import { MediaViewer } from './MediaViewer';

interface PollOption {
  id: number;
  text: string;
  votes: number;
}

interface Poll {
  question: string;
  options: PollOption[];
  totalVotes: number;
  endTime?: string;
  hasVoted?: boolean;
  votedOptionId?: number;
}

interface PostCardProps {
  author: string;
  username: string; // Will be replaced by groupName in display
  groupName?: string; // Group/Community name
  verified?: boolean;
  timestamp: string;
  content: string;
  avatar?: string;
  image?: string;
  video?: string;
  images?: string[];
  videos?: string[];
  type?: 'text' | 'image' | 'video' | 'gradient' | 'multiImage' | 'multiVideo' | 'poll';
  gradient?: string;
  poll?: Poll;
  likes: number;
  comments: number;
  isLiked?: boolean;
  onLike?: () => void;
  onComment?: () => void;
  onShare?: () => void;
  onMenuClick?: () => void;
  language?: 'bn' | 'en';
}

export const PostCard: React.FC<PostCardProps> = ({
  author,
  username,
  groupName,
  verified = false,
  timestamp,
  content,
  avatar,
  image,
  video,
  images,
  videos,
  type,
  gradient,
  poll,
  likes,
  comments,
  isLiked = false,
  onLike,
  onComment,
  onShare,
  onMenuClick,
  language = 'bn',
}) => {
  const [showShareMenu, setShowShareMenu] = useState(false);
  const [showPostMenu, setShowPostMenu] = useState(false);
  const [showMediaViewer, setShowMediaViewer] = useState(false);
  const [mediaViewerIndex, setMediaViewerIndex] = useState(0);
  const shareMenuRef = React.useRef<HTMLDivElement>(null);
  const postMenuRef = React.useRef<HTMLDivElement>(null);

  // Poll state
  const [pollState, setPollState] = useState<Poll | undefined>(poll);
  const [selectedOption, setSelectedOption] = useState<number | null>(poll?.votedOptionId || null);

  // Update poll state when prop changes
  React.useEffect(() => {
    setPollState(poll);
    setSelectedOption(poll?.votedOptionId || null);
  }, [poll]);

  // Close menus when clicking outside
  React.useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (shareMenuRef.current && !shareMenuRef.current.contains(event.target as Node)) {
        setShowShareMenu(false);
      }
      if (postMenuRef.current && !postMenuRef.current.contains(event.target as Node)) {
        setShowPostMenu(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Handle share options
  const handleShare = (type: string) => {
    const postUrl = `https://torko.app/post/${username}/${Date.now()}`;
    
    switch(type) {
      case 'native':
        // Try native share first (mobile devices)
        if (navigator.share) {
          navigator.share({
            title: author,
            text: content,
            url: postUrl,
          }).catch((error) => {
            console.log('Share cancelled or failed:', error);
            // Show URL in alert as fallback
            alert(language === 'bn' 
              ? `লিঙ্ক:\n${postUrl}\n\n(লং প্রেস করে কপি করুন)` 
              : `Link:\n${postUrl}\n\n(Long press to copy)`
            );
          });
        }
        break;
      case 'copy':
        // Fallback method for clipboard copy
        const textArea = document.createElement('textarea');
        textArea.value = postUrl;
        textArea.style.position = 'fixed';
        textArea.style.left = '-999999px';
        textArea.style.top = '-999999px';
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        
        try {
          const successful = document.execCommand('copy');
          document.body.removeChild(textArea);
          if (successful) {
            toast.success(language === 'bn' ? 'লিংক কপি হয়েছে' : 'Link copied');
          } else {
            // Show URL in alert if copy fails
            alert(language === 'bn' 
              ? `লিঙ্ক:\n${postUrl}\n\n(লং প্রেস করে কপি করুন)` 
              : `Link:\n${postUrl}\n\n(Long press to copy)`
            );
          }
        } catch (err) {
          console.error('Failed to copy:', err);
          document.body.removeChild(textArea);
          // Show URL in alert as ultimate fallback
          alert(language === 'bn' 
            ? `লিঙ্ক:\n${postUrl}\n\n(লং প্রেস করে কপি করুন)` 
            : `Link:\n${postUrl}\n\n(Long press to copy)`
          );
        }
        break;
      case 'whatsapp':
        window.open(`https://wa.me/?text=${encodeURIComponent(content + ' - ' + postUrl)}`, '_blank');
        toast.success(language === 'bn' ? 'ওয়াটসঅ্যাপে শেয়ার করা হচ্ছে' : 'Sharing to WhatsApp');
        break;
      case 'facebook':
        window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(postUrl)}`, '_blank');
        toast.success(language === 'bn' ? 'ফেসবুকে শেয়ার করা হচ্ছে' : 'Sharing to Facebook');
        break;
      case 'twitter':
        window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(content)}&url=${encodeURIComponent(postUrl)}`, '_blank');
        toast.success(language === 'bn' ? 'এক্সে শেয়ার করা হচ্ছে' : 'Sharing to X');
        break;
    }
    setShowShareMenu(false);
    onShare?.();
  };

  // Handle post menu options
  const handlePostMenu = (action: string) => {
    switch(action) {
      case 'edit':
        toast.info(language === 'bn' ? 'পোস্ট সম্পাদনা করুন' : 'Edit post');
        break;
      case 'delete':
        toast.error(language === 'bn' ? 'পোস্ট মুছে ফেলা হয়েছে' : 'Post deleted');
        break;
      case 'bookmark':
        toast.success(language === 'bn' ? 'বুকমার্ক করা হয়েছে' : 'Bookmarked');
        break;
      case 'report':
        toast.info(language === 'bn' ? 'রিপোর্ট করা হয়েছে' : 'Reported');
        break;
      case 'block':
        toast.warning(language === 'bn' ? `${author} ব্লক করা হয়েছে` : `${author} blocked`);
        break;
    }
    setShowPostMenu(false);
    onMenuClick?.();
  };

  return (
    <div className="relative w-full max-w-[100%] mx-auto">
      {/* Card Background - No horizontal padding */}
      <div className="relative bg-white dark:bg-[#0a2f3d] border border-[#e6e6e6] dark:border-[#0d3a4a] rounded-[20px] overflow-hidden shadow-sm p-[0px]">
        
        {/* Header Section - With horizontal padding */}
        <div className="px-[18px] pt-[18px]">
          <div className="flex items-start gap-[10px] mb-[12px]">
            {/* Avatar */}
            <div className="w-[40px] h-[40px] rounded-full overflow-hidden flex-shrink-0">
              <img 
                src={avatar || `https://ui-avatars.com/api/?name=${encodeURIComponent(author)}&background=d97757&color=fff&size=128`} 
                alt={author}
                className="w-full h-full object-cover"
              />
            </div>

            {/* Author Info */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-[6px]">
                <span className="font-['Noto_Sans_Bengali',sans-serif] font-semibold text-[15px] text-[#0f1419] dark:text-white truncate">
                  {author}
                </span>
              </div>
              {groupName && (
                <span className="font-['Roboto',sans-serif] font-normal text-[13px] text-[#536471] dark:text-[#8e8e8e]">
                  {groupName} · {timestamp}
                </span>
              )}
              {!groupName && (
                <span className="font-['Roboto',sans-serif] font-normal text-[13px] text-[#536471] dark:text-[#8e8e8e]">
                  {timestamp}
                </span>
              )}
            </div>

            {/* Three-dot Menu Button */}
            <div className="relative">
              <button 
                onClick={() => setShowPostMenu(!showPostMenu)}
                className="w-[32px] h-[32px] rounded-full flex items-center justify-center hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors"
              >
                <svg className="w-[20px] h-[20px]" viewBox="0 0 24 24" fill="#8E8E8E">
                  <circle cx="12" cy="5" r="2" />
                  <circle cx="12" cy="12" r="2" />
                  <circle cx="12" cy="19" r="2" />
                </svg>
              </button>
            </div>
          </div>
        </div>

        {/* Content Section */}
        <div className="mb-[24px]">
          {/* Text Content - With horizontal padding */}
          {type !== 'gradient' && (
            <p 
              className="font-['Roboto',sans-serif] font-normal text-[15px] leading-[19px] text-[#0f1419] dark:text-white w-full mb-[12px] px-[18px]"
              style={{ fontVariationSettings: "'wdth' 100" }}
            >
              {content}
            </p>
          )}

          {/* Gradient Text Post (Facebook style) - NO horizontal padding (edge-to-edge) */}
          {type === 'gradient' && gradient && (
            <div 
              className="p-[50px] flex items-center justify-center min-h-[300px]"
              style={{ background: gradient }}
            >
              <p 
                className="font-['Noto_Sans_Bengali',sans-serif] text-white text-center"
                style={{ 
                  fontSize: '30px',
                  fontWeight: '600',
                  lineHeight: '1.4',
                  textShadow: '0 2px 8px rgba(0,0,0,0.3)'
                }}
              >
                {content}
              </p>
            </div>
          )}

          {/* Image Post - NO horizontal padding (edge-to-edge) - Only show if image exists */}
          {type === 'image' && image && (
            <div className="overflow-hidden cursor-pointer">
              <img 
                src={image} 
                alt="Post content" 
                className="w-full h-auto object-cover"
                style={{ maxHeight: '500px' }}
                onClick={() => {
                  setShowMediaViewer(true);
                  setMediaViewerIndex(0);
                }}
                onError={(e) => {
                  // Hide image if it fails to load
                  (e.target as HTMLImageElement).style.display = 'none';
                }}
              />
            </div>
          )}

          {/* Video Post - NO horizontal padding (edge-to-edge) */}
          {type === 'video' && video && (
            <div className="overflow-hidden">
              <video 
                src={video}
                controls
                className="w-full h-auto"
                style={{ maxHeight: '500px' }}
              />
            </div>
          )}

          {/* Multi Image Post - NO horizontal padding (edge-to-edge) */}
          {type === 'multiImage' && images && (
            <MultiMediaGrid 
              images={images}
              onMediaClick={(index) => {
                setMediaViewerIndex(index);
                setShowMediaViewer(true);
              }}
            />
          )}

          {/* Multi Video Post - NO horizontal padding (edge-to-edge) */}
          {type === 'multiVideo' && videos && (
            <MultiMediaGrid 
              videos={videos}
              onMediaClick={(index) => {
                setMediaViewerIndex(index);
                setShowMediaViewer(true);
              }}
            />
          )}

          {/* Poll Post - NO horizontal padding (edge-to-edge) */}
          {type === 'poll' && pollState && (
            <div className="px-[18px]">
              <div className="bg-[#f7f8fa] dark:bg-[#0d3a4a] rounded-[12px] p-[16px] border border-[#e6e6e6] dark:border-[#104050]">
                {/* Poll Question */}
                <div className="mb-[16px]">
                  <h3 className="font-['Noto_Sans_Bengali',sans-serif] text-[15px] text-[#0f1419] dark:text-white">
                    {pollState.question}
                  </h3>
                </div>

                {/* Poll Options */}
                <div className="space-y-[10px] mb-[12px]">
                  {pollState.options.map(option => {
                    const percentage = pollState.totalVotes > 0 
                      ? Math.round((option.votes / pollState.totalVotes) * 100) 
                      : 0;
                    const isVoted = pollState.hasVoted && pollState.votedOptionId === option.id;
                    const isWinning = pollState.hasVoted && option.votes === Math.max(...pollState.options.map(o => o.votes));

                    return (
                      <button
                        key={option.id}
                        disabled={pollState.hasVoted}
                        onClick={() => {
                          if (!pollState.hasVoted) {
                            const newPoll = {
                              ...pollState,
                              hasVoted: true,
                              votedOptionId: option.id,
                              options: pollState.options.map(opt => ({
                                ...opt,
                                votes: opt.id === option.id ? opt.votes + 1 : opt.votes
                              })),
                              totalVotes: pollState.totalVotes + 1
                            };
                            setPollState(newPoll);
                            setSelectedOption(option.id);
                            toast.success(language === 'bn' ? 'ভোট দিয়েছি!' : 'Voted!');
                          }
                        }}
                        className={`w-full relative overflow-hidden rounded-[8px] border transition-all ${
                          pollState.hasVoted
                            ? 'cursor-default'
                            : 'cursor-pointer hover:border-[#d97757] hover:shadow-sm'
                        } ${
                          isVoted
                            ? 'border-[#d97757] bg-[#d97757]/5 dark:bg-[#d97757]/10'
                            : 'border-[#e1e4e8] dark:border-[#104050] bg-white dark:bg-[#104050]'
                        }`}
                      >
                        {/* Progress Bar Background */}
                        {pollState.hasVoted && (
                          <div 
                            className={`absolute left-0 top-0 h-full transition-all duration-500 ${
                              isWinning 
                                ? 'bg-[#d97757]/20' 
                                : 'bg-[#e1e4e8] dark:bg-[#0d3a4a]'
                            }`}
                            style={{ width: `${percentage}%` }}
                          />
                        )}

                        {/* Option Content */}
                        <div className="relative z-10 px-[14px] py-[12px] flex items-center justify-between">
                          <div className="flex items-center gap-[10px]">
                            {/* Checkmark for voted option */}
                            {isVoted && (
                              <svg className="w-[18px] h-[18px] text-[#d97757]" fill="currentColor" viewBox="0 0 20 20">
                                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                              </svg>
                            )}
                            <span className={`font-['Roboto',sans-serif] text-[14px] ${
                              isVoted 
                                ? 'text-[#d97757] font-medium' 
                                : 'text-[#0f1419] dark:text-white'
                            }`}>
                              {option.text}
                            </span>
                          </div>
                          
                          {/* Percentage */}
                          {pollState.hasVoted && (
                            <span className={`font-['Roboto',sans-serif] text-[13px] font-medium ${
                              isWinning 
                                ? 'text-[#d97757]' 
                                : 'text-[#536471] dark:text-[#8e8e8e]'
                            }`}>
                              {percentage}%
                            </span>
                          )}
                        </div>
                      </button>
                    );
                  })}
                </div>

                {/* Poll Footer */}
                <div className="flex items-center justify-between pt-[8px] border-t border-[#e1e4e8] dark:border-[#0d3a4a]">
                  <span className="font-['Roboto',sans-serif] text-[12px] text-[#536471] dark:text-[#8e8e8e]">
                    {pollState.totalVotes} {language === 'bn' ? 'ভোট' : 'votes'}
                  </span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Action Buttons Section - React, Comment, Share - With horizontal padding */}
        <div className="px-[18px]">
          <div className="flex items-center gap-3 pt-3 pb-[20px]">
            {/* Like Button - Pill Shape */}
            <button 
              onClick={onLike}
              className={`flex items-center gap-2 px-4 py-2.5 rounded-full border transition-all ${
                isLiked 
                  ? 'bg-[#d97757]/10 border-[#d97757] text-[#d97757]' 
                  : 'bg-[#f5f5f5] dark:bg-[#0d3a4a] border-[#e6e6e6] dark:border-[#104050] text-[#9D9D9D] hover:border-[#d97757] hover:text-[#d97757]'
              }`}
            >
              {isLiked ? (
                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
                </svg>
              ) : (
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
              )}
              <span className="font-['Roboto',sans-serif] text-[14px] font-medium">
                {likes >= 1000 ? `${(likes / 1000).toFixed(1)}k` : likes}
              </span>
            </button>

            {/* Comment Button - Pill Shape */}
            <button 
              onClick={onComment}
              className="flex items-center gap-2 px-4 py-2.5 rounded-full border bg-[#f5f5f5] dark:bg-[#0d3a4a] border-[#e6e6e6] dark:border-[#104050] text-[#9D9D9D] hover:border-[#B8DED6] hover:text-[#B8DED6] transition-all"
            >
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
              </svg>
              <span className="font-['Roboto',sans-serif] text-[14px] font-medium">
                {comments}
              </span>
            </button>

            {/* Share Button - Pill Shape */}
            <button 
              onClick={() => setShowShareMenu(!showShareMenu)}
              className="flex items-center gap-2 px-4 py-2.5 rounded-full border bg-[#f5f5f5] dark:bg-[#0d3a4a] border-[#e6e6e6] dark:border-[#104050] text-[#9D9D9D] hover:border-[#B8DED6] hover:text-[#B8DED6] transition-all ml-auto"
            >
              <Share2 className="w-5 h-5" />
              <span className="font-['Roboto',sans-serif] text-[14px] font-medium">
                {language === 'bn' ? 'শেয়ার' : 'Share'}
              </span>
            </button>
          </div>
        </div>
      </div>

      {/* Share Menu Dropdown - Outside card to avoid overflow clipping */}
      {showShareMenu && (
        <div ref={shareMenuRef} className="absolute right-[18px] bottom-[70px] bg-white dark:bg-[#0a2f3d] border border-[#e6e6e6] dark:border-[#0d3a4a] rounded-[10px] shadow-lg z-50 min-w-[200px]">
          <button 
            onClick={() => handleShare('native')}
            className="w-full px-[16px] py-[12px] flex items-center gap-[10px] hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors rounded-t-[10px]"
          >
            <Share2 className="w-[18px] h-[18px] text-[#536471]" />
            <span className="font-['Noto_Sans_Bengali',sans-serif] font-normal text-[14px] text-[#0f1419] dark:text-white">
              {language === 'bn' ? 'নেটিভ শেয়ার' : 'Native Share'}
            </span>
          </button>
          <button 
            onClick={() => handleShare('copy')}
            className="w-full px-[16px] py-[12px] flex items-center gap-[10px] hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors"
          >
            <Copy className="w-[18px] h-[18px] text-[#536471]" />
            <span className="font-['Noto_Sans_Bengali',sans-serif] font-normal text-[14px] text-[#0f1419] dark:text-white">
              {language === 'bn' ? 'লিংক কপি করুন' : 'Copy link'}
            </span>
          </button>
          <button 
            onClick={() => handleShare('whatsapp')}
            className="w-full px-[16px] py-[12px] flex items-center gap-[10px] hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors"
          >
            <MessageCircle className="w-[18px] h-[18px] text-[#536471]" />
            <span className="font-['Noto_Sans_Bengali',sans-serif] font-normal text-[14px] text-[#0f1419] dark:text-white">
              {language === 'bn' ? 'ওয়াটসঅ্যাপ' : 'WhatsApp'}
            </span>
          </button>
          <button 
            onClick={() => handleShare('facebook')}
            className="w-full px-[16px] py-[12px] flex items-center gap-[10px] hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors"
          >
            <Share2 className="w-[18px] h-[18px] text-[#536471]" />
            <span className="font-['Noto_Sans_Bengali',sans-serif] font-normal text-[14px] text-[#0f1419] dark:text-white">
              {language === 'bn' ? 'ফেসবুক' : 'Facebook'}
            </span>
          </button>
          <button 
            onClick={() => handleShare('twitter')}
            className="w-full px-[16px] py-[12px] flex items-center gap-[10px] hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors rounded-b-[10px]"
          >
            <svg className="w-[18px] h-[18px]" fill="currentColor" viewBox="0 0 24 24">
              <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
            </svg>
            <span className="font-['Noto_Sans_Bengali',sans-serif] font-normal text-[14px] text-[#0f1419] dark:text-white">
              {language === 'bn' ? 'এক্স (টুইটার)' : 'X (Twitter)'}
            </span>
          </button>
        </div>
      )}

      {/* Post Menu Dropdown - Outside card to avoid overflow clipping */}
      {showPostMenu && (
        <div ref={postMenuRef} className="absolute right-0 top-[50px] bg-white dark:bg-[#0a2f3d] border border-[#e6e6e6] dark:border-[#0d3a4a] rounded-[10px] shadow-lg z-50 min-w-[200px]">
          <button 
            onClick={() => handlePostMenu('bookmark')}
            className="w-full px-[16px] py-[12px] flex items-center gap-[10px] hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors rounded-t-[10px]"
          >
            <Bookmark className="w-[18px] h-[18px] text-[#536471]" />
            <span className="font-['Noto_Sans_Bengali',sans-serif] font-normal text-[14px] text-[#0f1419] dark:text-white">
              {language === 'bn' ? 'বুকমার্ক করুন' : 'Bookmark'}
            </span>
          </button>
          <button 
            onClick={() => handlePostMenu('edit')}
            className="w-full px-[16px] py-[12px] flex items-center gap-[10px] hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors"
          >
            <Edit3 className="w-[18px] h-[18px] text-[#536471]" />
            <span className="font-['Noto_Sans_Bengali',sans-serif] font-normal text-[14px] text-[#0f1419] dark:text-white">
              {language === 'bn' ? 'সম্পাদনা করুন' : 'Edit'}
            </span>
          </button>
          <button 
            onClick={() => handlePostMenu('delete')}
            className="w-full px-[16px] py-[12px] flex items-center gap-[10px] hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors"
          >
            <Trash2 className="w-[18px] h-[18px] text-[#536471]" />
            <span className="font-['Noto_Sans_Bengali',sans-serif] font-normal text-[14px] text-[#0f1419] dark:text-white">
              {language === 'bn' ? 'মুছে ফেলুন' : 'Delete'}
            </span>
          </button>
          <button 
            onClick={() => handlePostMenu('report')}
            className="w-full px-[16px] py-[12px] flex items-center gap-[10px] hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors"
          >
            <Flag className="w-[18px] h-[18px] text-[#536471]" />
            <span className="font-['Noto_Sans_Bengali',sans-serif] font-normal text-[14px] text-[#0f1419] dark:text-white">
              {language === 'bn' ? 'রিপোর্ট করুন' : 'Report'}
            </span>
          </button>
          <button 
            onClick={() => handlePostMenu('block')}
            className="w-full px-[16px] py-[12px] flex items-center gap-[10px] hover:bg-[#f5f5f5] dark:hover:bg-[#0d3a4a] transition-colors rounded-b-[10px]"
          >
            <UserX className="w-[18px] h-[18px] text-[#536471]" />
            <span className="font-['Noto_Sans_Bengali',sans-serif] font-normal text-[14px] text-[#0f1419] dark:text-white">
              {language === 'bn' ? 'ব্লক করুন' : 'Block'}
            </span>
          </button>
        </div>
      )}

      {/* Media Viewer Modal */}
      {(images || videos || (image && type === 'image')) && (
        <MediaViewer
          isOpen={showMediaViewer}
          onClose={() => setShowMediaViewer(false)}
          media={(images || videos || (image ? [image] : [])) as string[]}
          type={images || (image && type === 'image') ? 'image' : 'video'}
          initialIndex={mediaViewerIndex}
          author={author}
          avatar={avatar || `https://ui-avatars.com/api/?name=${encodeURIComponent(author)}&background=d97757&color=fff&size=128`}
          timestamp={timestamp}
          content={content}
          likes={likes}
          comments={comments}
          isLiked={isLiked}
          onLike={onLike}
          onComment={onComment}
          onShare={onShare}
          language={language}
        />
      )}
    </div>
  );
};