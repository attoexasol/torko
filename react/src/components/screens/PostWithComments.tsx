import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';
import { Button } from '../ui/button';
import { 
  ChevronLeft, 
  Heart, 
  MessageCircle, 
  Share2, 
  Bookmark,
  MoreHorizontal,
  Play,
  Pause,
  Volume2,
  VolumeX
} from 'lucide-react';
import { ScrollZoomImage } from '../ScrollZoomImage';
import { ModernCommentSection } from '../ModernCommentSection';
import { MultiMediaGrid } from '../MultiMediaGrid';

interface PostData {
  id: string;
  author: string;
  authorAvatar?: string;
  timestamp: string;
  content: string;
  type: 'text' | 'image' | 'video' | 'gradient' | 'multiImage' | 'multiVideo';
  image?: string;
  images?: string[];
  video?: string;
  videos?: string[];
  gradient?: string;
  likes: number;
  comments: number;
  shares: number;
  isLiked: boolean;
}

interface PostWithCommentsProps {
  post: PostData;
  language?: 'bn' | 'en';
  onBack: () => void;
  onAddComment?: (text: string, replyTo?: string) => void;
}

export const PostWithComments: React.FC<PostWithCommentsProps> = ({
  post,
  language = 'bn',
  onBack,
  onAddComment,
}) => {
  const [isLiked, setIsLiked] = useState(post.isLiked);
  const [isSaved, setIsSaved] = useState(false);
  const [likesCount, setLikesCount] = useState(post.likes);

  const handleLike = () => {
    if (isLiked) {
      setLikesCount(likesCount - 1);
    } else {
      setLikesCount(likesCount + 1);
    }
    setIsLiked(!isLiked);
  };

  const getAuthorInitials = (name: string) => {
    const words = name.split(' ');
    if (words.length >= 2) {
      return words[0][0] + words[1][0];
    }
    return name[0];
  };

  return (
    <div className="h-full w-full bg-background flex flex-col">
      {/* Header */}
      <div className="sticky top-0 z-50 bg-background/80 backdrop-blur-md border-b border-border">
        <div className="flex items-center gap-4 px-4 py-3">
          <Button
            variant="ghost"
            size="icon"
            className="rounded-full"
            onClick={onBack}
          >
            <ChevronLeft className="w-5 h-5" />
          </Button>
          <h1 className="font-semibold text-lg">
            {language === 'bn' ? 'পোস্ট' : 'Post'}
          </h1>
        </div>
      </div>

      {/* Scrollable Content */}
      <div className="flex-1 overflow-y-auto">
        <div className="max-w-2xl mx-auto">
          {/* Main Post */}
          <div className="border-b border-border">
            <div className="flex gap-3 p-4 pb-3">
              {/* Avatar */}
              <div className="flex-shrink-0">
                <Avatar className="w-12 h-12">
                  {post.authorAvatar ? (
                    <AvatarImage src={post.authorAvatar} alt={post.author} />
                  ) : (
                    <AvatarFallback
                      className="text-white"
                      style={{
                        background: `linear-gradient(135deg, #d97757 0%, #B8DED6 100%)`,
                      }}
                    >
                      {getAuthorInitials(post.author)}
                    </AvatarFallback>
                  )}
                </Avatar>
              </div>

              {/* Post Body */}
              <div className="flex-1 min-w-0">
                {/* Header */}
                <div className="flex items-start justify-between mb-2">
                  <div className="flex flex-col">
                    <span className="font-semibold text-foreground">
                      {post.author}
                    </span>
                    <span className="text-muted-foreground text-sm">
                      @{post.author.toLowerCase().replace(/\s+/g, '')}
                    </span>
                  </div>

                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-9 w-9 rounded-full -mt-1 -mr-2"
                  >
                    <MoreHorizontal className="w-5 h-5 text-muted-foreground" />
                  </Button>
                </div>

                {/* Post Text */}
                <p className="mb-3 text-foreground break-words leading-relaxed whitespace-pre-wrap">
                  {post.content}
                </p>

                {/* Post Media */}
                {post.type === 'image' && post.image && (
                  <div className="mb-3 rounded-xl overflow-hidden">
                    <ScrollZoomImage src={post.image} alt="Post image" />
                  </div>
                )}

                {post.type === 'multiImage' && post.images && post.images.length > 0 && (
                  <div className="mb-3">
                    <MultiMediaGrid media={post.images} type="image" />
                  </div>
                )}

                {post.type === 'video' && post.video && (
                  <div className="mb-3 rounded-xl overflow-hidden relative">
                    <video
                      src={post.video}
                      className="w-full rounded-xl"
                      controls
                      playsInline
                    />
                  </div>
                )}

                {post.type === 'multiVideo' && post.videos && post.videos.length > 0 && (
                  <div className="mb-3">
                    <MultiMediaGrid media={post.videos} type="video" />
                  </div>
                )}

                {post.type === 'gradient' && post.gradient && (
                  <div
                    className="mb-3 rounded-xl p-8 min-h-[200px] flex items-center justify-center"
                    style={{ background: post.gradient }}
                  >
                    <p className="text-white text-center font-medium text-lg">
                      {post.content}
                    </p>
                  </div>
                )}

                {/* Timestamp */}
                <div className="mb-3">
                  <span className="text-muted-foreground text-sm">
                    {post.timestamp}
                  </span>
                </div>

                {/* Stats */}
                <div className="flex items-center gap-4 py-3 border-y border-border mb-2">
                  <button className="text-sm text-muted-foreground hover:underline">
                    <span className="text-foreground font-semibold">{post.comments}</span>{' '}
                    {language === 'bn' ? 'মন্তব্য' : 'Comments'}
                  </button>
                  <button className="text-sm text-muted-foreground hover:underline">
                    <span className="text-foreground font-semibold">{likesCount}</span>{' '}
                    {language === 'bn' ? 'পছন্দ' : 'Likes'}
                  </button>
                  <button className="text-sm text-muted-foreground hover:underline">
                    <span className="text-foreground font-semibold">{post.shares}</span>{' '}
                    {language === 'bn' ? 'শেয়ার' : 'Shares'}
                  </button>
                </div>

                {/* Action Buttons */}
                <div className="flex items-center justify-around pb-3">
                  <Button
                    variant="ghost"
                    size="sm"
                    className={`h-9 px-3 gap-2 rounded-full flex-1 transition-colors ${
                      isLiked
                        ? 'text-[#f91880] hover:bg-[#f91880]/10'
                        : 'hover:bg-[#f91880]/10 hover:text-[#f91880]'
                    }`}
                    onClick={handleLike}
                  >
                    <Heart
                      className={`w-5 h-5 transition-all ${
                        isLiked ? 'fill-current' : ''
                      }`}
                    />
                    <span className="text-sm">
                      {language === 'bn' ? 'পছন্দ' : 'Like'}
                    </span>
                  </Button>

                  <Button
                    variant="ghost"
                    size="sm"
                    className="h-9 px-3 gap-2 hover:bg-blue-500/10 hover:text-blue-500 rounded-full flex-1"
                  >
                    <MessageCircle className="w-5 h-5" />
                    <span className="text-sm">
                      {language === 'bn' ? 'মন্তব্য' : 'Comment'}
                    </span>
                  </Button>

                  <Button
                    variant="ghost"
                    size="sm"
                    className="h-9 px-3 gap-2 hover:bg-green-500/10 hover:text-green-500 rounded-full flex-1"
                  >
                    <Share2 className="w-5 h-5" />
                    <span className="text-sm">
                      {language === 'bn' ? 'শেয়ার' : 'Share'}
                    </span>
                  </Button>

                  <Button
                    variant="ghost"
                    size="icon"
                    className={`h-9 w-9 rounded-full transition-colors ${
                      isSaved
                        ? 'text-accent'
                        : 'hover:bg-accent/10 hover:text-accent'
                    }`}
                    onClick={() => setIsSaved(!isSaved)}
                  >
                    <Bookmark
                      className={`w-5 h-5 ${isSaved ? 'fill-current' : ''}`}
                    />
                  </Button>
                </div>
              </div>
            </div>
          </div>

          {/* Comments Section */}
          <div className="p-4">
            <ModernCommentSection
              postId={post.id}
              language={language}
              onAddComment={onAddComment}
            />
          </div>
        </div>
      </div>
    </div>
  );
};
