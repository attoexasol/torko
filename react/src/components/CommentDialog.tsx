import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Avatar, AvatarFallback } from './ui/avatar';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { ScrollArea } from './ui/scroll-area';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from './ui/dialog';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from './ui/popover';
import { X, Send, Smile, Reply, Heart, MessageCircle, Share2, MoreHorizontal } from 'lucide-react';
import { MultiMediaGrid } from './MultiMediaGrid';

interface CommentReaction {
  emoji: string;
  count: number;
  reacted: boolean;
}

interface Comment {
  id: string;
  author: string;
  authorInitial: string;
  avatarColor: string;
  content: string;
  timestamp: string;
  likes: number;
  isLiked: boolean;
  reactions: CommentReaction[];
  replies?: Comment[];
  replyingTo?: string;
}

interface Post {
  id: string;
  author: string;
  authorAvatar: string;
  timestamp: string;
  content: string;
  image?: string;
  video?: string;
  images?: string[];
  videos?: string[];
  type: 'text' | 'image' | 'video' | 'gradient' | 'multiImage' | 'multiVideo';
  gradient?: string;
  likes: number;
  comments: number;
  shares: number;
  isLiked: boolean;
}

interface CommentDialogProps {
  open: boolean;
  onClose: () => void;
  comments: Comment[];
  postId: string;
  post?: Post; // Post data to show above comments
  language: 'bn' | 'en';
  onAddComment: (text: string, replyTo?: Comment) => void;
  onLikeComment: (commentId: string) => void;
  onAddReaction: (commentId: string, emoji: string) => void;
}

const emojiReactions = ['👍', '❤️', '😂', '😮', '😢', '😡', '🎉', '🔥'];

// Full emoji picker categories (same as ConversationScreen)
const emojis = {
  smileys: ['😊', '😂', '🥰', '😍', '🤗', '😘', '😁', '😎', '🤔', '😅', '😢', '😭', '😡', '🥺', '😴', '🤩'],
  gestures: ['👍', '👎', '👏', '🙏', '💪', '✌️', '🤝', '👋', '🤚', '✋', '🙌', '👊', '✊', '🤲', '💅', '🤞'],
  hearts: ['❤️', '💕', '💖', '💗', '💓', '💞', '💝', '💘', '💙', '💚', '💛', '🧡', '💜', '🖤', '🤍', '🤎'],
  celebrations: ['🎉', '🎊', '🎈', '🎁', '🏆', '🥇', '🎯', '⭐', '✨', '💫', '🌟', '🔥', '💯', '🎆', '🎇', '🌈'],
};

export const CommentDialog: React.FC<CommentDialogProps> = ({
  open,
  onClose,
  comments,
  postId,
  post,
  language,
  onAddComment,
  onLikeComment,
  onAddReaction,
}) => {
  const [newCommentText, setNewCommentText] = useState('');
  const [replyingTo, setReplyingTo] = useState<Comment | null>(null);
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);
  const [expandedReplies, setExpandedReplies] = useState<Set<string>>(new Set());

  const handleClose = () => {
    setNewCommentText('');
    setReplyingTo(null);
    setShowEmojiPicker(false);
    setExpandedReplies(new Set());
    onClose();
  };

  const handleSubmit = () => {
    if (!newCommentText.trim()) return;
    onAddComment(newCommentText, replyingTo || undefined);
    setNewCommentText('');
    setReplyingTo(null);
    setShowEmojiPicker(false);
  };

  const handleEmojiSelect = (emoji: string) => {
    setNewCommentText(prev => prev + emoji);
  };

  const handleInsertEmoji = (emoji: string) => {
    setNewCommentText(prev => prev + emoji);
    setShowEmojiPicker(false);
  };

  const toggleReplies = (commentId: string) => {
    const newExpanded = new Set(expandedReplies);
    if (newExpanded.has(commentId)) {
      newExpanded.delete(commentId);
    } else {
      newExpanded.add(commentId);
    }
    setExpandedReplies(newExpanded);
  };

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="max-w-full w-full h-full max-h-full p-0 flex flex-col gap-0 [&>button]:hidden m-0 rounded-none">
        <DialogHeader className="px-6 pt-6 pb-4 border-b border-border/40 flex-shrink-0">
          <div className="flex items-center justify-between">
            <DialogTitle style={{ fontSize: '20px', fontWeight: '700' }}>
              {language === 'bn' ? 'মন্তব্য' : 'Comments'}
            </DialogTitle>
            <Button
              variant="ghost"
              size="icon"
              className="rounded-full h-9 w-9"
              onClick={handleClose}
            >
              <X className="w-5 h-5" />
            </Button>
          </div>
          <DialogDescription style={{ fontSize: '14px' }}>
            {language === 'bn' 
              ? `${comments.length} টি মন্তব্য` 
              : `${comments.length} comment${comments.length !== 1 ? 's' : ''}`}
          </DialogDescription>
        </DialogHeader>

        {/* Comments List */}
        <ScrollArea className="flex-1 overflow-y-auto">
          <div className="space-y-0">
            {/* Post Display (if provided) */}
            {post && (
              <div className="px-6 py-4 border-b border-border/20">
                {/* Post Header */}
                <div className="flex items-start gap-3 mb-3">
                  <Avatar className="w-11 h-11 flex-shrink-0">
                    <AvatarFallback 
                      style={{ 
                        backgroundColor: '#d97757',
                        color: 'white',
                        fontSize: '14px',
                        fontWeight: '600'
                      }}
                    >
                      {post.author.charAt(0)}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <div>
                        <h3 className="font-semibold text-foreground" style={{ fontSize: '15px' }}>
                          {post.author}
                        </h3>
                        <p className="text-muted-foreground" style={{ fontSize: '13px', opacity: 0.7 }}>
                          {post.timestamp}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Post Content */}
                <div className="space-y-3">
                  {/* Text Content */}
                  {post.content && (
                    <p 
                      className="text-foreground whitespace-pre-wrap break-words" 
                      style={{ fontSize: '15px', lineHeight: '1.5' }}
                    >
                      {post.content}
                    </p>
                  )}

                  {/* Single Image */}
                  {post.type === 'image' && post.image && (
                    <div className="rounded-xl overflow-hidden">
                      <img 
                        src={post.image} 
                        alt="Post" 
                        className="w-full h-auto"
                        style={{ maxHeight: '400px', objectFit: 'cover' }}
                      />
                    </div>
                  )}

                  {/* Multiple Images */}
                  {post.type === 'multiImage' && post.images && post.images.length > 0 && (
                    <MultiMediaGrid 
                      items={post.images.map(url => ({ type: 'image' as const, url }))}
                      onItemClick={() => {}}
                    />
                  )}

                  {/* Video */}
                  {post.type === 'video' && post.video && (
                    <div className="rounded-xl overflow-hidden">
                      <video 
                        src={post.video}
                        controls
                        className="w-full h-auto"
                        style={{ maxHeight: '400px' }}
                      />
                    </div>
                  )}

                  {/* Multiple Videos */}
                  {post.type === 'multiVideo' && post.videos && post.videos.length > 0 && (
                    <MultiMediaGrid 
                      items={post.videos.map(url => ({ type: 'video' as const, url }))}
                      onItemClick={() => {}}
                    />
                  )}

                  {/* Gradient Text Post */}
                  {post.type === 'gradient' && post.gradient && (
                    <div 
                      className="rounded-xl p-8 flex items-center justify-center text-center"
                      style={{ 
                        background: post.gradient,
                        minHeight: '200px'
                      }}
                    >
                      <p 
                        className="text-white font-semibold break-words max-w-full"
                        style={{ 
                          fontSize: '20px',
                          lineHeight: '1.4',
                          textShadow: '0 2px 8px rgba(0,0,0,0.3)'
                        }}
                      >
                        {post.content}
                      </p>
                    </div>
                  )}
                </div>

                {/* Post Stats */}
                <div className="flex items-center gap-6 mt-4 pt-3 border-t border-border/20">
                  <div className="flex items-center gap-1.5 text-muted-foreground">
                    <Heart 
                      className={post.isLiked ? 'fill-accent text-accent' : ''} 
                      style={{ width: '18px', height: '18px' }} 
                    />
                    <span style={{ fontSize: '14px' }}>{post.likes}</span>
                  </div>
                  <div className="flex items-center gap-1.5 text-muted-foreground">
                    <MessageCircle style={{ width: '18px', height: '18px' }} />
                    <span style={{ fontSize: '14px' }}>{post.comments}</span>
                  </div>
                  <div className="flex items-center gap-1.5 text-muted-foreground">
                    <Share2 style={{ width: '18px', height: '18px' }} />
                    <span style={{ fontSize: '14px' }}>{post.shares}</span>
                  </div>
                </div>
              </div>
            )}

            {/* Comments Section */}
            <div className="px-6 py-4 space-y-5">
            {comments.map((comment) => (
              <div key={comment.id}>
                {/* Main Comment */}
                <div className="flex gap-3">
                  <Avatar className="w-10 h-10 flex-shrink-0" style={{ backgroundColor: comment.avatarColor }}>
                    <AvatarFallback style={{ backgroundColor: comment.avatarColor, color: 'white', fontSize: '14px', fontWeight: '600' }}>
                      {comment.authorInitial}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1 min-w-0">
                    {/* Comment Bubble */}
                    <div className="rounded-2xl px-4 py-3 bg-[rgba(241,222,217,0.4)] dark:bg-[rgba(217,119,87,0.15)]">
                      <p className="font-semibold mb-1" style={{ fontSize: '14px' }}>
                        {comment.author}
                      </p>
                      {comment.replyingTo && (
                        <p className="text-muted-foreground mb-1.5" style={{ fontSize: '12px' }}>
                          {language === 'bn' ? 'উত্তর দিচ্ছেন' : 'Replying to'}{' '}
                          <span className="text-accent font-medium">{comment.replyingTo}</span>
                        </p>
                      )}
                      <p className="text-foreground" style={{ fontSize: '14px', lineHeight: '1.5' }}>
                        {comment.content}
                      </p>
                    </div>
                    
                    {/* Reactions */}
                    {comment.reactions.length > 0 && (
                      <div className="flex items-center gap-1.5 mt-2 px-2">
                        {comment.reactions.map((reaction, idx) => (
                          <motion.button
                            key={idx}
                            whileTap={{ scale: 0.95 }}
                            onClick={() => onAddReaction(comment.id, reaction.emoji)}
                            className={`flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium transition-all ${
                              reaction.reacted 
                                ? 'bg-accent/15 text-accent border border-accent/30' 
                                : 'bg-muted/60 text-muted-foreground hover:bg-muted border border-transparent'
                            }`}
                          >
                            <span style={{ fontSize: '14px' }}>{reaction.emoji}</span>
                            <span>{reaction.count}</span>
                          </motion.button>
                        ))}
                      </div>
                    )}
                    
                    {/* Comment Actions */}
                    <div className="flex items-center gap-4 mt-2 px-2">
                      <Popover>
                        <PopoverTrigger asChild>
                          <button
                            className="text-muted-foreground hover:text-accent transition-colors font-medium"
                            style={{ fontSize: '13px' }}
                          >
                            {language === 'bn' ? 'রিঅ্যাক্ট' : 'React'}
                          </button>
                        </PopoverTrigger>
                        <PopoverContent 
                          className="w-auto p-2 border-border/40" 
                          style={{ borderRadius: '16px' }}
                          side="top"
                          align="start"
                          sideOffset={8}
                        >
                          <div className="flex gap-1 max-w-[240px] overflow-x-auto" style={{ scrollbarWidth: 'thin' }}>
                            {emojiReactions.map((emoji) => (
                              <motion.button
                                key={emoji}
                                whileHover={{ scale: 1.15 }}
                                whileTap={{ scale: 0.9 }}
                                onClick={() => {
                                  onAddReaction(comment.id, emoji);
                                }}
                                className="w-11 h-11 flex-shrink-0 flex items-center justify-center rounded-xl hover:bg-muted/80 transition-colors"
                                style={{ fontSize: '22px' }}
                              >
                                {emoji}
                              </motion.button>
                            ))}
                          </div>
                        </PopoverContent>
                      </Popover>
                      
                      <button
                        className="text-muted-foreground hover:text-accent transition-colors font-medium"
                        style={{ fontSize: '13px' }}
                        onClick={() => setReplyingTo(comment)}
                      >
                        {language === 'bn' ? 'উত্তর' : 'Reply'}
                      </button>
                      
                      {comment.replies && comment.replies.length > 0 && (
                        <button
                          className="text-accent hover:text-accent/80 transition-colors font-semibold"
                          style={{ fontSize: '13px' }}
                          onClick={() => toggleReplies(comment.id)}
                        >
                          {expandedReplies.has(comment.id) 
                            ? (language === 'bn' ? 'উত্তর লুকান' : 'Hide replies')
                            : (language === 'bn' ? `${comment.replies.length} টি উত্তর দেখুন` : `View ${comment.replies.length} ${comment.replies.length === 1 ? 'reply' : 'replies'}`)}
                        </button>
                      )}
                      
                      <span className="text-muted-foreground ml-auto" style={{ fontSize: '12px' }}>
                        {comment.timestamp}
                      </span>
                    </div>
                    
                    {/* Replies */}
                    <AnimatePresence>
                      {comment.replies && comment.replies.length > 0 && expandedReplies.has(comment.id) && (
                        <motion.div 
                          initial={{ opacity: 0, height: 0 }}
                          animate={{ opacity: 1, height: 'auto' }}
                          exit={{ opacity: 0, height: 0 }}
                          transition={{ duration: 0.2 }}
                          className="mt-4 space-y-3 pl-3 border-l-2 border-border/30"
                        >
                          {comment.replies.map((reply) => (
                            <div key={reply.id} className="flex gap-2.5">
                              <Avatar className="w-8 h-8 flex-shrink-0" style={{ backgroundColor: reply.avatarColor }}>
                                <AvatarFallback style={{ backgroundColor: reply.avatarColor, color: 'white', fontSize: '12px', fontWeight: '600' }}>
                                  {reply.authorInitial}
                                </AvatarFallback>
                              </Avatar>
                              <div className="flex-1 min-w-0">
                                <div className="rounded-xl px-3.5 py-2.5 bg-[rgba(241,222,217,0.4)]">
                                  <p className="font-semibold mb-0.5" style={{ fontSize: '13px' }}>
                                    {reply.author}
                                  </p>
                                  <p className="text-foreground" style={{ fontSize: '13px', lineHeight: '1.5' }}>
                                    {reply.content}
                                  </p>
                                </div>
                                
                                {/* Reply Reactions */}
                                {reply.reactions && reply.reactions.length > 0 && (
                                  <div className="flex items-center gap-1.5 mt-1.5 px-2">
                                    {reply.reactions.map((reaction, idx) => (
                                      <motion.button
                                        key={idx}
                                        whileTap={{ scale: 0.95 }}
                                        onClick={() => onAddReaction(reply.id, reaction.emoji)}
                                        className={`flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium transition-all ${
                                          reaction.reacted 
                                            ? 'bg-accent/15 text-accent border border-accent/30' 
                                            : 'bg-muted/60 text-muted-foreground hover:bg-muted border border-transparent'
                                        }`}
                                      >
                                        <span style={{ fontSize: '13px' }}>{reaction.emoji}</span>
                                        <span style={{ fontSize: '11px' }}>{reaction.count}</span>
                                      </motion.button>
                                    ))}
                                  </div>
                                )}
                                
                                <div className="flex items-center gap-3 mt-1.5 px-2">
                                  <Popover>
                                    <PopoverTrigger asChild>
                                      <button
                                        className="text-muted-foreground hover:text-accent transition-colors font-medium"
                                        style={{ fontSize: '12px' }}
                                      >
                                        {language === 'bn' ? 'রিঅ্যাক্ট' : 'React'}
                                      </button>
                                    </PopoverTrigger>
                                    <PopoverContent 
                                      className="w-auto p-2 border-border/40" 
                                      style={{ borderRadius: '16px' }}
                                      side="top"
                                      align="start"
                                      sideOffset={8}
                                    >
                                      <div className="flex gap-1 max-w-[220px] overflow-x-auto" style={{ scrollbarWidth: 'thin' }}>
                                        {emojiReactions.map((emoji) => (
                                          <motion.button
                                            key={emoji}
                                            whileHover={{ scale: 1.15 }}
                                            whileTap={{ scale: 0.9 }}
                                            onClick={() => onAddReaction(reply.id, emoji)}
                                            className="w-10 h-10 flex-shrink-0 flex items-center justify-center rounded-xl hover:bg-muted/80 transition-colors"
                                            style={{ fontSize: '20px' }}
                                          >
                                            {emoji}
                                          </motion.button>
                                        ))}
                                      </div>
                                    </PopoverContent>
                                  </Popover>
                                  
                                  <span className="text-muted-foreground ml-auto" style={{ fontSize: '11px' }}>
                                    {reply.timestamp}
                                  </span>
                                </div>
                              </div>
                            </div>
                          ))}
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </div>
                </div>
              </div>
            ))}
            
            {comments.length === 0 && (
              <div className="text-center py-12">
                <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-muted/40 flex items-center justify-center">
                  <Smile className="w-8 h-8 text-muted-foreground opacity-40" />
                </div>
                <p className="text-muted-foreground font-medium" style={{ fontSize: '15px' }}>
                  {language === 'bn' ? 'কোনো মন্তব্য নেই' : 'No comments yet'}
                </p>
                <p className="text-muted-foreground mt-1" style={{ fontSize: '13px' }}>
                  {language === 'bn' ? 'প্রথম মন্তব্য করুন!' : 'Be the first to comment!'}
                </p>
              </div>
            )}
            </div>
          </div>
        </ScrollArea>

        {/* Comment Input */}
        <div className="border-t border-border/40 bg-muted/20 p-[24px] px-[24px] py-[18px]">
      
          <AnimatePresence>
            {replyingTo && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className="mb-3 px-3 py-2.5 bg-accent/10 rounded-xl flex items-center justify-between"
              >
                <div className="flex items-center gap-2">
                  <Reply className="w-4 h-4 text-accent" />
                  <span style={{ fontSize: '13px', fontWeight: '500' }}>
                    {language === 'bn' ? 'উত্তর দিচ্ছেন' : 'Replying to'}{' '}
                    <span className="text-accent font-semibold">{replyingTo.author}</span>
                  </span>
                </div>
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-6 w-6 rounded-full hover:bg-accent/20"
                  onClick={() => setReplyingTo(null)}
                >
                  <X className="w-4 h-4" />
                </Button>
              </motion.div>
            )}
          </AnimatePresence>
          
          {/* Emoji Picker Panel */}
          <AnimatePresence>
            {showEmojiPicker && (
              <motion.div 
                className="px-6 pb-2"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: 20 }}
                transition={{ duration: 0.25, ease: 'easeOut' }}
              >
                <div 
                  className="rounded-xl p-4 bg-muted/30 border border-border/20"
                  style={{
                    maxHeight: '240px',
                    overflowY: 'auto',
                  }}
                >
                  {/* Smileys */}
                  <div className="mb-3">
                    <p 
                      className="text-muted-foreground"
                      style={{
                        fontSize: '11px',
                        fontWeight: '600',
                        marginBottom: '8px',
                        textTransform: 'uppercase',
                        letterSpacing: '0.5px',
                      }}
                    >
                      {language === 'bn' ? 'স্মাইলি' : 'Smileys'}
                    </p>
                    <div className="grid grid-cols-8 gap-2">
                      {emojis.smileys.map((emoji, index) => (
                        <motion.button
                          key={index}
                          initial={{ opacity: 0, scale: 0.8 }}
                          animate={{ opacity: 1, scale: 1 }}
                          transition={{ delay: index * 0.02, duration: 0.15 }}
                          className="flex items-center justify-center rounded-lg p-2 transition-all hover:bg-muted/60 active:scale-90"
                          onClick={() => handleEmojiSelect(emoji)}
                          style={{
                            fontSize: '24px',
                          }}
                        >
                          {emoji}
                        </motion.button>
                      ))}
                    </div>
                  </div>

                  {/* Gestures */}
                  <div className="mb-3">
                    <p 
                      className="text-muted-foreground"
                      style={{
                        fontSize: '11px',
                        fontWeight: '600',
                        marginBottom: '8px',
                        textTransform: 'uppercase',
                        letterSpacing: '0.5px',
                      }}
                    >
                      {language === 'bn' ? 'ইশারা' : 'Gestures'}
                    </p>
                    <div className="grid grid-cols-8 gap-2">
                      {emojis.gestures.map((emoji, index) => (
                        <motion.button
                          key={index}
                          initial={{ opacity: 0, scale: 0.8 }}
                          animate={{ opacity: 1, scale: 1 }}
                          transition={{ delay: index * 0.02, duration: 0.15 }}
                          className="flex items-center justify-center rounded-lg p-2 transition-all hover:bg-muted/60 active:scale-90"
                          onClick={() => handleEmojiSelect(emoji)}
                          style={{
                            fontSize: '24px',
                          }}
                        >
                          {emoji}
                        </motion.button>
                      ))}
                    </div>
                  </div>

                  {/* Hearts */}
                  <div className="mb-3">
                    <p 
                      className="text-muted-foreground"
                      style={{
                        fontSize: '11px',
                        fontWeight: '600',
                        marginBottom: '8px',
                        textTransform: 'uppercase',
                        letterSpacing: '0.5px',
                      }}
                    >
                      {language === 'bn' ? 'হার্ট' : 'Hearts'}
                    </p>
                    <div className="grid grid-cols-8 gap-2">
                      {emojis.hearts.map((emoji, index) => (
                        <motion.button
                          key={index}
                          initial={{ opacity: 0, scale: 0.8 }}
                          animate={{ opacity: 1, scale: 1 }}
                          transition={{ delay: index * 0.02, duration: 0.15 }}
                          className="flex items-center justify-center rounded-lg p-2 transition-all hover:bg-muted/60 active:scale-90"
                          onClick={() => handleEmojiSelect(emoji)}
                          style={{
                            fontSize: '24px',
                          }}
                        >
                          {emoji}
                        </motion.button>
                      ))}
                    </div>
                  </div>

                  {/* Celebrations */}
                  <div>
                    <p 
                      className="text-muted-foreground"
                      style={{
                        fontSize: '11px',
                        fontWeight: '600',
                        marginBottom: '8px',
                        textTransform: 'uppercase',
                        letterSpacing: '0.5px',
                      }}
                    >
                      {language === 'bn' ? 'উদযাপন' : 'Celebrations'}
                    </p>
                    <div className="grid grid-cols-8 gap-2">
                      {emojis.celebrations.map((emoji, index) => (
                        <motion.button
                          key={index}
                          initial={{ opacity: 0, scale: 0.8 }}
                          animate={{ opacity: 1, scale: 1 }}
                          transition={{ delay: index * 0.02, duration: 0.15 }}
                          className="flex items-center justify-center rounded-lg p-2 transition-all hover:bg-muted/60 active:scale-90"
                          onClick={() => handleEmojiSelect(emoji)}
                          style={{
                            fontSize: '24px',
                          }}
                        >
                          {emoji}
                        </motion.button>
                      ))}
                    </div>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Comment Input */}
          <div className="flex gap-3 items-center">
            <Avatar className="w-10 h-10 bg-accent/10 flex-shrink-0">
              <AvatarFallback className="bg-accent/10 text-accent" style={{ fontSize: '14px', fontWeight: '600' }}>
                {language === 'bn' ? 'আ' : 'Y'}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 flex gap-2 items-center">
              <Button
                variant="ghost"
                size="icon"
                className="rounded-full h-10 w-10 hover:bg-muted/40 flex-shrink-0"
                onClick={() => setShowEmojiPicker(!showEmojiPicker)}
              >
                <Smile className={`w-5 h-5 transition-colors ${showEmojiPicker ? 'text-accent' : 'text-muted-foreground'}`} />
              </Button>
              
              <div className="flex-1 relative">
                <Input
                  value={newCommentText}
                  onChange={(e) => setNewCommentText(e.target.value)}
                  placeholder={
                    replyingTo 
                      ? (language === 'bn' ? 'একটি উত্তর লিখুন...' : 'Write a reply...')
                      : (language === 'bn' ? 'একটি মন্তব্য লিখুন...' : 'Write a comment...')
                  }
                  className="w-full rounded-xl bg-background border-border/40 pr-3"
                  style={{ height: '44px', fontSize: '14px' }}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' && !e.shiftKey) {
                      e.preventDefault();
                      handleSubmit();
                    }
                  }}
                />
              </div>
              
              <Button
                onClick={handleSubmit}
                disabled={!newCommentText.trim()}
                className="rounded-xl bg-accent hover:bg-accent/90 text-white disabled:opacity-50 flex-shrink-0"
                style={{ height: '44px', width: '44px', padding: '0' }}
              >
                <Send className="w-5 h-5" />
              </Button>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
};