import React, { useState } from 'react';
import { ModernCommentSection } from '../ModernCommentSection';
import { Button } from '../ui/button';
import { Moon, Sun, Languages, ChevronLeft } from 'lucide-react';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';
import { Heart, MessageCircle, Share2, Bookmark } from 'lucide-react';
import { useApp } from '../contexts/AppContext';

export const ModernCommentDemo: React.FC = () => {
  const { language, theme, toggleTheme, toggleLanguage } = useApp();
  const [postLiked, setPostLiked] = useState(false);
  const [postSaved, setPostSaved] = useState(false);

  const mockPost = {
    author: language === 'bn' ? 'আহমেদ রহমান' : 'Ahmed Rahman',
    handle: '@ahmedrahman',
    initials: language === 'bn' ? 'আ' : 'AR',
    avatar: undefined,
    text:
      language === 'bn'
        ? 'বাংলাদেশে টেক ইন্ডাস্ট্রির ভবিষ্যৎ খুবই উজ্জ্বল। AI, Machine Learning এবং Software Development এ আমরা দ্রুত এগিয়ে যাচ্ছি। আগামী ৫ বছরে আমরা দেখব বিশাল পরিবর্তন। \n\nআপনারা কি মনে করেন? কমেন্টে জানান আপনার মতামত!'
        : 'The future of the tech industry in Bangladesh is very bright. We are rapidly advancing in AI, Machine Learning, and Software Development. We will see huge changes in the next 5 years.\n\nWhat do you think? Share your thoughts in the comments!',
    timestamp: language === 'bn' ? '২ ঘণ্টা আগে' : '2h ago',
    likes: 342,
    comments: 87,
    shares: 23,
  };

  return (
    <div className="h-full w-full bg-background flex flex-col">
      {/* Header */}
      <div className="sticky top-0 z-50 bg-background/80 backdrop-blur-md border-b border-border">
        <div className="flex items-center justify-between px-4 py-3">
          <div className="flex items-center gap-3">
            <Button variant="ghost" size="icon" className="rounded-full">
              <ChevronLeft className="w-5 h-5" />
            </Button>
            <h1 className="font-semibold text-lg">
              {language === 'bn' ? 'পোস্ট' : 'Post'}
            </h1>
          </div>

          <div className="flex items-center gap-2">
            <Button
              variant="ghost"
              size="icon"
              className="rounded-full"
              onClick={toggleLanguage}
            >
              <Languages className="w-5 h-5" />
            </Button>

            <Button
              variant="ghost"
              size="icon"
              className="rounded-full"
              onClick={toggleTheme}
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

      {/* Scrollable Content */}
      <div className="flex-1 overflow-y-auto">
        <div className="max-w-2xl mx-auto">
          {/* Post Card */}
          <div className="border-b border-border pb-4">
            <div className="flex gap-3 p-4">
              {/* Avatar */}
              <Avatar className="w-12 h-12 flex-shrink-0">
                <AvatarFallback
                  style={{
                    background: 'linear-gradient(135deg, #d97757 0%, #B8DED6 100%)',
                  }}
                  className="text-white"
                >
                  {mockPost.initials}
                </AvatarFallback>
              </Avatar>

              {/* Post Content */}
              <div className="flex-1 min-w-0">
                {/* Author Info */}
                <div className="flex items-center gap-2 mb-2">
                  <span className="font-semibold text-foreground">
                    {mockPost.author}
                  </span>
                  <span className="text-muted-foreground text-sm">
                    {mockPost.handle}
                  </span>
                  <span className="text-muted-foreground text-sm">·</span>
                  <span className="text-muted-foreground text-sm">
                    {mockPost.timestamp}
                  </span>
                </div>

                {/* Post Text */}
                <p className="text-foreground whitespace-pre-wrap mb-3 leading-relaxed">
                  {mockPost.text}
                </p>

                {/* Engagement Stats */}
                <div className="flex items-center gap-4 py-2 border-y border-border mb-2">
                  <span className="text-sm text-muted-foreground">
                    <span className="font-semibold text-foreground">
                      {postLiked ? mockPost.likes + 1 : mockPost.likes}
                    </span>{' '}
                    {language === 'bn' ? 'পছন্দ' : 'Likes'}
                  </span>
                  <span className="text-sm text-muted-foreground">
                    <span className="font-semibold text-foreground">
                      {mockPost.comments}
                    </span>{' '}
                    {language === 'bn' ? 'মন্তব্য' : 'Comments'}
                  </span>
                  <span className="text-sm text-muted-foreground">
                    <span className="font-semibold text-foreground">
                      {mockPost.shares}
                    </span>{' '}
                    {language === 'bn' ? 'শেয়ার' : 'Shares'}
                  </span>
                </div>

                {/* Action Buttons */}
                <div className="flex items-center justify-around -ml-2">
                  <Button
                    variant="ghost"
                    size="sm"
                    className={`h-9 px-3 gap-2 rounded-full flex-1 transition-colors ${
                      postLiked
                        ? 'text-[#f91880] hover:bg-[#f91880]/10'
                        : 'hover:bg-[#f91880]/10 hover:text-[#f91880]'
                    }`}
                    onClick={() => setPostLiked(!postLiked)}
                  >
                    <Heart
                      className={`w-5 h-5 transition-all ${
                        postLiked ? 'fill-current' : ''
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
                      postSaved
                        ? 'text-accent'
                        : 'hover:bg-accent/10 hover:text-accent'
                    }`}
                    onClick={() => setPostSaved(!postSaved)}
                  >
                    <Bookmark
                      className={`w-5 h-5 ${postSaved ? 'fill-current' : ''}`}
                    />
                  </Button>
                </div>
              </div>
            </div>
          </div>

          {/* Comments Section */}
          <div className="p-4">
            <ModernCommentSection
              postId="demo-post-1"
              language={language}
              onAddComment={(text, replyTo) => {
                console.log('New comment:', text, 'Reply to:', replyTo);
              }}
            />
          </div>
        </div>

        {/* Feature Info Panel */}
        <div className="max-w-2xl mx-auto p-4 pb-8">
          <div className="bg-muted/30 rounded-2xl p-6 space-y-4">
            <h3 className="font-semibold text-foreground">
              {language === 'bn'
                ? '✨ Facebook & Twitter Inspired Features'
                : '✨ Facebook & Twitter Inspired Features'}
            </h3>
            <ul className="space-y-2 text-sm text-muted-foreground">
              <li>
                {language === 'bn'
                  ? '💬 Facebook-style rounded comment bubbles'
                  : '💬 Facebook-style rounded comment bubbles'}
              </li>
              <li>
                {language === 'bn'
                  ? '🧵 Twitter-style threading lines'
                  : '🧵 Twitter-style threading lines'}
              </li>
              <li>
                {language === 'bn'
                  ? '❤️ Like/Unlike with counts'
                  : '❤️ Like/Unlike with counts'}
              </li>
              <li>
                {language === 'bn'
                  ? '↩️ Nested reply system'
                  : '↩️ Nested reply system'}
              </li>
              <li>
                {language === 'bn'
                  ? '📂 Expand/collapse nested replies'
                  : '📂 Expand/collapse nested replies'}
              </li>
              <li>
                {language === 'bn'
                  ? '⋯ Hover to show action menu (Edit/Delete/Report)'
                  : '⋯ Hover to show action menu (Edit/Delete/Report)'}
              </li>
              <li>
                {language === 'bn'
                  ? '😊 Emoji picker'
                  : '😊 Emoji picker'}
              </li>
              <li>
                {language === 'bn'
                  ? '📤 Send button appears when typing'
                  : '📤 Send button appears when typing'}
              </li>
              <li>
                {language === 'bn'
                  ? '⌨️ Enter to send, Shift+Enter for new line'
                  : '⌨️ Enter to send, Shift+Enter for new line'}
              </li>
              <li>
                {language === 'bn'
                  ? '🎨 Smooth animations throughout'
                  : '🎨 Smooth animations throughout'}
              </li>
              <li>
                {language === 'bn'
                  ? '🌓 Full Light/Dark mode support'
                  : '🌓 Full Light/Dark mode support'}
              </li>
              <li>
                {language === 'bn'
                  ? '🌐 Bengali & English language support'
                  : '🌐 Bengali & English language support'}
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};
