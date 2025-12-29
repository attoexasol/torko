import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Button } from './ui/button';
import { Textarea } from './ui/textarea';
import { 
  Heart, 
  MessageCircle, 
  MoreHorizontal,
  Send,
  Smile,
  Image as ImageIcon
} from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from './ui/dropdown-menu';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from './ui/popover';

interface Reply {
  id: string;
  author: string;
  authorHandle?: string;
  avatar?: string;
  avatarColor?: string;
  initials: string;
  text: string;
  timestamp: string;
  likes: number;
  isLiked: boolean;
  replies?: Reply[];
}

interface CommentSectionProps {
  postId: string;
  language?: 'bn' | 'en';
  onAddComment?: (text: string, replyTo?: string) => void;
}

const EmojiPicker: React.FC<{ onSelect: (emoji: string) => void }> = ({ onSelect }) => {
  const emojis = ['😀', '😂', '🥰', '😍', '🤔', '👍', '❤️', '🔥', '💯', '👏', '🙌', '💪', '🎉', '✨', '🙏', '😊'];
  
  return (
    <div className="grid grid-cols-8 gap-1 p-2 w-64">
      {emojis.map((emoji) => (
        <button
          key={emoji}
          onClick={() => onSelect(emoji)}
          className="text-2xl hover:bg-accent/50 rounded p-1 transition-colors"
        >
          {emoji}
        </button>
      ))}
    </div>
  );
};

const CommentItem: React.FC<{
  comment: Reply;
  language: 'bn' | 'en';
  onReply: (comment: Reply) => void;
  onLike: (commentId: string) => void;
  onDelete?: (commentId: string) => void;
  level?: number;
  isLastChild?: boolean;
}> = ({ comment, language, onReply, onLike, onDelete, level = 0, isLastChild = false }) => {
  const [isHovered, setIsHovered] = useState(false);
  
  const hasReplies = comment.replies && comment.replies.length > 0;
  const avatarSize = level === 0 ? 40 : 36;

  return (
    <div className="relative">
      <div
        className="flex gap-3 py-1.5 relative"
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        {/* Avatar */}
        <div className="relative flex-shrink-0" style={{ width: `${avatarSize}px` }}>
          <Avatar style={{ width: `${avatarSize}px`, height: `${avatarSize}px` }}>
            {comment.avatar ? (
              <AvatarImage src={comment.avatar} alt={comment.author} />
            ) : (
              <AvatarFallback
                style={{
                  background: comment.avatarColor || `linear-gradient(135deg, #d97757 0%, #B8DED6 100%)`,
                  fontSize: level === 0 ? '14px' : '13px',
                }}
                className="text-white"
              >
                {comment.initials}
              </AvatarFallback>
            )}
          </Avatar>

          {/* Vertical Threading Line extending from avatar bottom */}
          {hasReplies && (
            <div
              className="absolute"
              style={{
                width: '2px',
                left: '50%',
                transform: 'translateX(-50%)',
                top: `${avatarSize}px`,
                height: '100%',
                backgroundColor: '#808080',
              }}
            />
          )}
        </div>

        {/* Comment Content */}
        <div className="flex-1 min-w-0">
          {/* Comment Bubble */}
          <div className="bg-muted/50 rounded-2xl px-3 py-2 inline-block max-w-full">
            {/* Author Name */}
            <div className="flex items-center gap-1.5 mb-0.5">
              <span className="font-semibold text-sm text-foreground">
                {comment.author}
              </span>
              {comment.authorHandle && (
                <span className="text-xs text-muted-foreground">
                  {comment.authorHandle}
                </span>
              )}
            </div>

            {/* Comment Text */}
            <p className="text-sm text-foreground break-words whitespace-pre-wrap">
              {comment.text}
            </p>
          </div>

          {/* Action Bar */}
          <div className="flex items-center gap-3 mt-1 ml-3">
            <span className="text-xs text-muted-foreground">
              {comment.timestamp}
            </span>

            <button
              onClick={() => onLike(comment.id)}
              className={`text-xs font-semibold transition-colors ${
                comment.isLiked
                  ? 'text-accent'
                  : 'text-muted-foreground hover:text-foreground'
              }`}
            >
              {language === 'bn' ? 'পছন্দ' : 'Like'}
              {comment.likes > 0 && ` · ${comment.likes}`}
            </button>

            <button
              onClick={() => onReply(comment)}
              className="text-xs font-semibold text-muted-foreground hover:text-foreground transition-colors"
            >
              {language === 'bn' ? 'উত্তর দিন' : 'Reply'}
            </button>

            <div className={`transition-opacity duration-150 ${isHovered ? 'opacity-100' : 'opacity-0'}`}>
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-6 w-6 rounded-full"
                  >
                    <MoreHorizontal className="w-4 h-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="start">
                  <DropdownMenuItem>
                    {language === 'bn' ? 'সম্পাদনা' : 'Edit'}
                  </DropdownMenuItem>
                  {onDelete && (
                    <>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem
                        className="text-destructive"
                        onClick={() => onDelete(comment.id)}
                      >
                        {language === 'bn' ? 'মুছে ফেলুন' : 'Delete'}
                      </DropdownMenuItem>
                    </>
                  )}
                  <DropdownMenuSeparator />
                  <DropdownMenuItem>
                    {language === 'bn' ? 'রিপোর্ট করুন' : 'Report'}
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          </div>
        </div>
      </div>

      {/* Nested Replies with Rounded L-Shape Threading */}
      {hasReplies && (
        <div className="relative" style={{ marginLeft: `${avatarSize / 2}px` }}>
          {comment.replies!.map((reply, index) => {
            const isLast = index === comment.replies!.length - 1;
            const childAvatarSize = 36;
            const borderRadius = 8;
            
            // Direct measurements for precise connection
            const verticalLength = 24; // Height to avatar center (py-1.5 + half avatar)
            const horizontalToAvatar = 44; // Distance to child avatar edge
            
            return (
              <div key={reply.id} className="relative mt-[0px] mr-[0px] mb-[0px] ml-[1px] m-[0px]">
                {/* Rounded L-Shape Connector using SVG */}
                <svg
                  className="absolute pointer-events-none"
                  style={{
                    left: 0,
                    top: 0,
                    width: '60px',
                    height: '40px',
                    overflow: 'visible',
                  }}
                >
                  {/* Vertical line down */}
                  <line
                    x1="1"
                    y1="0"
                    x2="1"
                    y2={verticalLength - borderRadius}
                    stroke="#808080"
                    strokeWidth="2"
                    strokeLinecap="round"
                  />
                  
                  {/* Rounded corner */}
                  <path
                    d={`M 1 ${verticalLength - borderRadius} 
                        Q 1 ${verticalLength} ${1 + borderRadius} ${verticalLength}`}
                    stroke="#808080"
                    strokeWidth="2"
                    fill="none"
                    strokeLinecap="round"
                  />
                  
                  {/* Horizontal line to avatar with rounded end */}
                  <line
                    x1={1 + borderRadius}
                    y1={verticalLength}
                    x2={horizontalToAvatar}
                    y2={verticalLength}
                    stroke="#808080"
                    strokeWidth="2"
                    strokeLinecap="round"
                  />
                </svg>

                {/* Continuing vertical line for non-last children */}
                {!isLast && (
                  <div
                    className="absolute pointer-events-none"
                    style={{
                      width: '2px',
                      left: '0',
                      top: `${verticalLength}px`,
                      height: '100%',
                      backgroundColor: '#808080',
                    }}
                  />
                )}

                {/* Child Comment */}
                <div style={{ marginLeft: `${avatarSize / 2 + 8}px` }}>
                  <CommentItem
                    comment={reply}
                    language={language}
                    onReply={onReply}
                    onLike={onLike}
                    onDelete={onDelete}
                    level={level + 1}
                    isLastChild={isLast}
                  />
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

const CommentInput: React.FC<{
  language: 'bn' | 'en';
  onSubmit: (text: string) => void;
  replyTo?: Reply;
  onCancelReply?: () => void;
  placeholder?: string;
  avatar?: string;
  avatarColor?: string;
  initials?: string;
}> = ({
  language,
  onSubmit,
  replyTo,
  onCancelReply,
  placeholder,
  avatar,
  avatarColor = '#d97757',
  initials = 'A',
}) => {
  const [text, setText] = useState('');
  const [isFocused, setIsFocused] = useState(false);

  const handleSubmit = () => {
    if (!text.trim()) return;
    onSubmit(text);
    setText('');
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  return (
    <div className="space-y-2">
      {/* Reply To Banner */}
      {replyTo && (
        <div className="flex items-center gap-2 px-3 py-2 bg-muted/30 rounded-lg">
          <MessageCircle className="w-4 h-4 text-muted-foreground" />
          <span className="text-sm text-muted-foreground flex-1">
            {language === 'bn' ? 'উত্তর দিচ্ছেন' : 'Replying to'}{' '}
            <span className="font-semibold text-foreground">{replyTo.author}</span>
          </span>
          <Button
            variant="ghost"
            size="sm"
            onClick={onCancelReply}
            className="h-6 px-2 text-xs"
          >
            {language === 'bn' ? 'বাতিল' : 'Cancel'}
          </Button>
        </div>
      )}

      {/* Input Area */}
      <div className="flex gap-2 sm:gap-3">
        <Avatar className="w-9 h-9 flex-shrink-0">
          {avatar ? (
            <AvatarImage src={avatar} alt="You" />
          ) : (
            <AvatarFallback
              style={{ background: avatarColor }}
              className="text-white text-sm"
            >
              {initials}
            </AvatarFallback>
          )}
        </Avatar>

        <div className="flex-1 relative">
          <div
            className={`bg-muted/50 rounded-3xl transition-all ${
              isFocused ? 'ring-2 ring-accent/50' : ''
            }`}
          >
            <Textarea
              value={text}
              onChange={(e) => setText(e.target.value)}
              onKeyDown={handleKeyDown}
              onFocus={() => setIsFocused(true)}
              onBlur={() => setIsFocused(false)}
              placeholder={
                placeholder ||
                (language === 'bn' ? 'মন্তব্য লিখুন...' : 'Write a comment...')
              }
              className="min-h-[44px] max-h-[120px] resize-none border-0 bg-transparent px-4 py-3 text-sm focus-visible:ring-0 focus-visible:ring-offset-0"
              rows={1}
            />

            {text.length === 0 && (
              <div className="absolute bottom-2 right-2 flex items-center gap-1">
                <Popover>
                  <PopoverTrigger asChild>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8 rounded-full text-muted-foreground hover:text-foreground"
                    >
                      <Smile className="w-5 h-5" />
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-auto p-0" align="end">
                    <EmojiPicker onSelect={(emoji) => setText(text + emoji)} />
                  </PopoverContent>
                </Popover>

                <Button
                  variant="ghost"
                  size="icon"
                  className="h-8 w-8 rounded-full text-muted-foreground hover:text-foreground"
                >
                  <ImageIcon className="w-5 h-5" />
                </Button>
              </div>
            )}
          </div>

          <AnimatePresence>
            {text.trim().length > 0 && (
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.8 }}
                transition={{ duration: 0.15 }}
                className="absolute bottom-2 right-2"
              >
                <Button
                  onClick={handleSubmit}
                  size="icon"
                  className="h-8 w-8 rounded-full bg-accent hover:bg-accent/90"
                >
                  <Send className="w-4 h-4" />
                </Button>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
};

export const ModernCommentSection: React.FC<CommentSectionProps> = ({
  postId,
  language = 'bn',
  onAddComment,
}) => {
  const [comments, setComments] = useState<Reply[]>([
    {
      id: '1',
      author: language === 'bn' ? 'সাকিব হাসান' : 'Sakib Hasan',
      authorHandle: '@sakibhasan',
      initials: language === 'bn' ? 'সা' : 'SH',
      avatarColor: '#d97757',
      text:
        language === 'bn'
          ? 'দারুণ পোস্ট! আমি সম্পূর্ণ একমত আপনার সাথে। এই বিষয়ে আরো বিস্তারিত জানতে চাই।'
          : 'Great post! I completely agree with you. Would love to know more about this topic.',
      timestamp: language === 'bn' ? '২ ঘণ্টা আগে' : '2h ago',
      likes: 24,
      isLiked: true,
      replies: [
        {
          id: '1-1',
          author: language === 'bn' ? 'তানিয়া আক্তার' : 'Tania Akter',
          authorHandle: '@taniaakter',
          initials: language === 'bn' ? 'তা' : 'TA',
          avatarColor: '#6B9BD1',
          text:
            language === 'bn'
              ? 'আমি একই কথা ভাবছিলাম! খুব ভালো লাগলো।'
              : 'I was thinking the same thing! Really glad to see this.',
          timestamp: language === 'bn' ? '১ ঘণ্টা আগে' : '1h ago',
          likes: 8,
          isLiked: false,
          replies: [
            {
              id: '1-1-1',
              author: language === 'bn' ? 'রাফি খান' : 'Rafi Khan',
              authorHandle: '@rafikhan',
              initials: language === 'bn' ? 'রা' : 'RK',
              avatarColor: '#9333ea',
              text:
                language === 'bn'
                  ? 'একদম সঠিক বলেছেন দুজনেই!'
                  : 'Both of you are absolutely right!',
              timestamp: language === 'bn' ? '৩০ মিনিট আগে' : '30m ago',
              likes: 3,
              isLiked: false,
            },
          ],
        },
        {
          id: '1-2',
          author: language === 'bn' ? 'নাফিস রহমান' : 'Nafis Rahman',
          authorHandle: '@nafisrahman',
          initials: language === 'bn' ? 'না' : 'NR',
          avatarColor: '#16a34a',
          text:
            language === 'bn'
              ? 'চমৎকার insight! আরো এমন content চাই।'
              : 'Amazing insight! Need more content like this.',
          timestamp: language === 'bn' ? '৪৫ মিনিট আগে' : '45m ago',
          likes: 5,
          isLiked: false,
        },
      ],
    },
    {
      id: '2',
      author: language === 'bn' ? 'মাহমুদা খাতুন' : 'Mahmuda Khatun',
      authorHandle: '@mahmudakhatun',
      initials: language === 'bn' ? 'মা' : 'MK',
      avatarColor: '#ea580c',
      text:
        language === 'bn'
          ? 'এই তথ্যটা অনেক কাজের! শেয়ার করার জন্য ধন্যবাদ।'
          : 'This information is very useful! Thanks for sharing.',
      timestamp: language === 'bn' ? '৩ ঘণ্টা আগে' : '3h ago',
      likes: 15,
      isLiked: false,
    },
    {
      id: '3',
      author: language === 'bn' ? 'ইমরান হোসেন' : 'Imran Hossain',
      authorHandle: '@imranhossain',
      initials: language === 'bn' ? 'ই' : 'IH',
      avatarColor: '#8B9FA8',
      text:
        language === 'bn'
          ? 'খুবই informative post। আমার অনেক confusion clear হলো।'
          : 'Very informative post. Cleared a lot of my confusion.',
      timestamp: language === 'bn' ? '৫ ঘণ্টা আগে' : '5h ago',
      likes: 32,
      isLiked: false,
      replies: [
        {
          id: '3-1',
          author: language === 'bn' ? 'সায়মা বেগম' : 'Sayma Begum',
          authorHandle: '@saymabegum',
          initials: language === 'bn' ? 'সা' : 'SB',
          avatarColor: '#ec4899',
          text:
            language === 'bn'
              ? 'আমারও! অনেক কিছু শিখলাম।'
              : 'Mine too! Learned a lot.',
          timestamp: language === 'bn' ? '৪ ঘণ্টা আগে' : '4h ago',
          likes: 7,
          isLiked: false,
        },
      ],
    },
  ]);

  const [replyTo, setReplyTo] = useState<Reply | undefined>();

  const handleAddComment = (text: string) => {
    const newComment: Reply = {
      id: Date.now().toString(),
      author: language === 'bn' ? 'আপনি' : 'You',
      authorHandle: '@you',
      initials: language === 'bn' ? 'আ' : 'Y',
      avatarColor: '#d97757',
      text,
      timestamp: language === 'bn' ? 'এইমাত্র' : 'Just now',
      likes: 0,
      isLiked: false,
    };

    if (replyTo) {
      const addReplyToComment = (comments: Reply[]): Reply[] => {
        return comments.map((comment) => {
          if (comment.id === replyTo.id) {
            return {
              ...comment,
              replies: [...(comment.replies || []), newComment],
            };
          } else if (comment.replies) {
            return {
              ...comment,
              replies: addReplyToComment(comment.replies),
            };
          }
          return comment;
        });
      };

      setComments(addReplyToComment(comments));
      setReplyTo(undefined);
    } else {
      setComments([newComment, ...comments]);
    }

    onAddComment?.(text, replyTo?.id);
  };

  const handleLike = (commentId: string) => {
    const toggleLike = (comments: Reply[]): Reply[] => {
      return comments.map((comment) => {
        if (comment.id === commentId) {
          return {
            ...comment,
            isLiked: !comment.isLiked,
            likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
          };
        } else if (comment.replies) {
          return {
            ...comment,
            replies: toggleLike(comment.replies),
          };
        }
        return comment;
      });
    };

    setComments(toggleLike(comments));
  };

  const handleReply = (comment: Reply) => {
    setReplyTo(comment);
  };

  const handleDelete = (commentId: string) => {
    const deleteComment = (comments: Reply[]): Reply[] => {
      return comments
        .filter((comment) => comment.id !== commentId)
        .map((comment) => ({
          ...comment,
          replies: comment.replies ? deleteComment(comment.replies) : undefined,
        }));
    };

    setComments(deleteComment(comments));
  };

  return (
    <div className="w-full space-y-4">
      <CommentInput
        language={language}
        onSubmit={handleAddComment}
        replyTo={replyTo}
        onCancelReply={() => setReplyTo(undefined)}
        avatar={undefined}
        avatarColor="#d97757"
        initials={language === 'bn' ? 'আ' : 'Y'}
      />

      <div className="space-y-1">
        {comments.length > 0 ? (
          comments.map((comment) => (
            <CommentItem
              key={comment.id}
              comment={comment}
              language={language}
              onReply={handleReply}
              onLike={handleLike}
              onDelete={handleDelete}
              level={0}
            />
          ))
        ) : (
          <div className="text-center py-8">
            <MessageCircle className="w-12 h-12 mx-auto mb-3 text-muted-foreground opacity-40" />
            <p className="text-muted-foreground">
              {language === 'bn' ? 'এখনও কোন মন্তব্য নেই' : 'No comments yet'}
            </p>
            <p className="text-sm text-muted-foreground mt-1">
              {language === 'bn' ? 'প্রথম মন্তব্য করুন' : 'Be the first to comment'}
            </p>
          </div>
        )}
      </div>

      {comments.length >= 3 && (
        <Button variant="ghost" className="w-full rounded-xl">
          {language === 'bn' ? 'আরো মন্তব্য দেখুন' : 'Load more comments'}
        </Button>
      )}
    </div>
  );
};