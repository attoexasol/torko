import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Send } from 'lucide-react';
import { CommentThread, Comment } from './CommentThread';
import imgFrame from "figma:asset/a6746284f9589fbc91a471b3324f42c0ddd746b7.png";

interface CommentsModalProps {
  isOpen: boolean;
  onClose: () => void;
  postId: number;
  language?: 'bn' | 'en';
}

export const CommentsModal: React.FC<CommentsModalProps> = ({
  isOpen,
  onClose,
  postId,
  language = 'bn',
}) => {
  const [newComment, setNewComment] = useState('');
  
  const t = {
    comments: language === 'bn' ? 'মন্তব্যসমূহ' : 'Comments',
    writeComment: language === 'bn' ? 'একটি মন্তব্য লিখুন...' : 'Write a comment...',
    post: language === 'bn' ? 'পোস্ট করুন' : 'Post',
  };

  // Mock comments data with nested structure
  const mockComments: Comment[] = [
    {
      id: '1',
      author: language === 'bn' ? 'রাফি আহমেদ' : 'Rafi Ahmed',
      username: '@rafi_ahmed',
      content: language === 'bn' 
        ? 'এটি সত্যিই একটি দুর্দান্ত উদ্যোগ! আমরা এটির জন্য অপেক্ষা করছিলাম।'
        : 'This is really a great initiative! We were waiting for this.',
      time: language === 'bn' ? '১০ মিনিট আগে' : '10 min ago',
      likes: 45,
      isLiked: false,
      replies: [
        {
          id: '1-1',
          author: language === 'bn' ? 'সাকিব হোসেন' : 'Sakib Hosen',
          username: '@sakib_h',
          content: language === 'bn'
            ? 'একদম সহমত! এটি আমাদের এলাকার জন্য অনেক প্রয়োজনীয় ছিল।'
            : 'Totally agree! This was much needed for our area.',
          time: language === 'bn' ? '৮ মিনিট আগে' : '8 min ago',
          likes: 12,
          isLiked: true,
          replies: [
            {
              id: '1-1-1',
              author: language === 'bn' ? 'তানিয়া ইসলাম' : 'Tania Islam',
              username: '@tania_i',
              content: language === 'bn'
                ? 'হ্যাঁ, আশা করি শীঘ্রই আরও উন্নতি দেখতে পাব।'
                : 'Yes, hope to see more improvements soon.',
              time: language === 'bn' ? '৫ মিনিট আগে' : '5 min ago',
              likes: 8,
              isLiked: false,
              replies: [
                {
                  id: '1-1-1-1',
                  author: language === 'bn' ? 'কামাল উদ্দিন' : 'Kamal Uddin',
                  username: '@kamal_u',
                  content: language === 'bn'
                    ? 'এটি শুধু শুরু। আরও অনেক পরিকল্পনা আছে বলে শুনেছি।'
                    : 'This is just the beginning. I heard there are many more plans.',
                  time: language === 'bn' ? '৩ মিনিট আগে' : '3 min ago',
                  likes: 5,
                  isLiked: false,
                  replies: [
                    {
                      id: '1-1-1-1-1',
                      author: language === 'bn' ? 'নাসিমা খাতুন' : 'Nasima Khatun',
                      username: '@nasima_k',
                      content: language === 'bn'
                        ? 'সত্যিই? এটা খুব আশার কথা!'
                        : 'Really? That\'s very hopeful!',
                      time: language === 'bn' ? '১ মিনিট আগে' : '1 min ago',
                      likes: 3,
                      isLiked: false,
                    },
                  ],
                },
              ],
            },
            {
              id: '1-1-2',
              author: language === 'bn' ? 'ফারহান রহমান' : 'Farhan Rahman',
              username: '@farhan_r',
              content: language === 'bn'
                ? 'সরকার এবং স্থানীয় প্রশাসনকে ধন্যবাদ এই উদ্যোগের জন্য।'
                : 'Thanks to the government and local administration for this initiative.',
              time: language === 'bn' ? '৬ মিনিট আগে' : '6 min ago',
              likes: 15,
              isLiked: true,
            },
          ],
        },
        {
          id: '1-2',
          author: language === 'bn' ? 'মাহমুদা আক্তার' : 'Mahmuda Akter',
          username: '@mahmuda_a',
          content: language === 'bn'
            ? 'আমার পরিবারের সবাই এটির জন্য অপেক্ষা করছিল। অসাধারণ খবর!'
            : 'My whole family was waiting for this. Amazing news!',
          time: language === 'bn' ? '৭ মিনিট আগে' : '7 min ago',
          likes: 23,
          isLiked: false,
        },
      ],
    },
    {
      id: '2',
      author: language === 'bn' ? 'জুবায়ের খান' : 'Jubayer Khan',
      username: '@jubayer_k',
      content: language === 'bn'
        ? 'কখন থেকে এটি কার্যকর হবে? কেউ জানেন?'
        : 'When will this be effective? Does anyone know?',
      time: language === 'bn' ? '১৫ মিনিট আগে' : '15 min ago',
      likes: 18,
      isLiked: false,
      replies: [
        {
          id: '2-1',
          author: language === 'bn' ? 'রিতা দাস' : 'Rita Das',
          username: '@rita_d',
          content: language === 'bn'
            ? 'আগামী মাস থেকে শুরু হবে বলে খবরে দেখেছি।'
            : 'I saw in the news it will start from next month.',
          time: language === 'bn' ? '১২ মিনিট আগে' : '12 min ago',
          likes: 9,
          isLiked: true,
        },
      ],
    },
    {
      id: '3',
      author: language === 'bn' ? 'শাহরিয়ার কবির' : 'Shahriar Kabir',
      username: '@shahriar_k',
      content: language === 'bn'
        ? 'এটি আমাদের দৈনন্দিন যাতায়াত অনেক সহজ করে দেবে। দুর্দান্ত!'
        : 'This will make our daily commute much easier. Excellent!',
      time: language === 'bn' ? '২০ মিনিট আগে' : '20 min ago',
      likes: 56,
      isLiked: true,
      replies: [
        {
          id: '3-1',
          author: language === 'bn' ? 'নাহিদ হাসান' : 'Nahid Hasan',
          username: '@nahid_h',
          content: language === 'bn'
            ? 'একদম ঠিক বলেছেন। সময় এবং খরচ দুটোই বাঁচবে।'
            : 'Absolutely right. Will save both time and money.',
          time: language === 'bn' ? '১৮ মিনিট আগে' : '18 min ago',
          likes: 22,
          isLiked: false,
          replies: [
            {
              id: '3-1-1',
              author: language === 'bn' ? 'শিউলি বেগম' : 'Shiuli Begum',
              username: '@shiuli_b',
              content: language === 'bn'
                ? 'এবং পরিবেশবান্ধবও হবে। কম গাড়ি মানে কম দূষণ।'
                : 'And it will be eco-friendly too. Less cars means less pollution.',
              time: language === 'bn' ? '১৫ মিনিট আগে' : '15 min ago',
              likes: 31,
              isLiked: true,
            },
          ],
        },
      ],
    },
    {
      id: '4',
      author: language === 'bn' ? 'আমিনুল ইসলাম' : 'Aminul Islam',
      username: '@aminul_i',
      content: language === 'bn'
        ? 'দীর্ঘদিনের প্রতীক্ষার পর এই সুসংবাদ! ধন্যবাদ সংশ্লিষ্ট সবাইকে।'
        : 'This good news after a long wait! Thanks to everyone involved.',
      time: language === 'bn' ? '২৫ মিনিট আগে' : '25 min ago',
      likes: 67,
      isLiked: false,
    },
    {
      id: '5',
      author: language === 'bn' ? 'সুমাইয়া খানম' : 'Sumaiya Khanam',
      username: '@sumaiya_k',
      content: language === 'bn'
        ? 'আশা করি রক্ষণাবেক্ষণ ভালো হবে এবং সেবার মান উন্নত থাকবে।'
        : 'Hope the maintenance will be good and service quality will remain high.',
      time: language === 'bn' ? '৩০ মিনিট আগে' : '30 min ago',
      likes: 42,
      isLiked: false,
      replies: [
        {
          id: '5-1',
          author: language === 'bn' ? 'রাকিব হোসেন' : 'Rakib Hosen',
          username: '@rakib_h',
          content: language === 'bn'
            ? 'এটা একটা গুরুত্বপূর্ণ বিষয়। সঠিক রক্ষণাবেক্ষণ ছাড়া কিছুই দীর্ঘস্থায়ী হয় না।'
            : 'This is an important point. Nothing lasts without proper maintenance.',
          time: language === 'bn' ? '২৮ মিনিট আগে' : '28 min ago',
          likes: 19,
          isLiked: true,
        },
      ],
    },
  ];

  const [comments, setComments] = useState<Comment[]>(mockComments);

  const handleAddComment = () => {
    if (!newComment.trim()) return;

    const newCommentObj: Comment = {
      id: Date.now().toString(),
      author: language === 'bn' ? 'আপনি' : 'You',
      username: '@you',
      content: newComment,
      time: language === 'bn' ? 'এখন' : 'now',
      likes: 0,
      isLiked: false,
    };

    setComments([newCommentObj, ...comments]);
    setNewComment('');
  };

  const handleReply = (commentId: string, content: string) => {
    console.log('Reply to:', commentId, 'Content:', content);
    // You can implement reply logic here
  };

  const handleLike = (commentId: string) => {
    console.log('Like comment:', commentId);
    // You can implement like logic here
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="fixed inset-0 bg-black/40 backdrop-blur-sm z-40"
            onClick={onClose}
          />

          {/* Modal */}
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 300 }}
            className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[430px] bg-white dark:bg-card rounded-t-[24px] shadow-2xl z-50 max-h-[85vh] flex flex-col"
          >
            {/* Header */}
            <div className="flex items-center justify-between px-[20px] py-[16px] border-b border-[#E5E7EB] dark:border-border">
              <h2 className="font-['Noto_Sans_Bengali',sans-serif] text-[18px] font-semibold text-[#0f1419] dark:text-white">
                {t.comments}
              </h2>
              <button
                onClick={onClose}
                className="w-[32px] h-[32px] rounded-full bg-neutral-100 dark:bg-muted flex items-center justify-center hover:bg-neutral-200 dark:hover:bg-[#104050] transition-colors"
              >
                <X className="w-[18px] h-[18px] text-[#8E8E8E]" />
              </button>
            </div>

            {/* Comments List */}
            <div className="flex-1 overflow-y-auto px-[20px] py-[16px]">
              <CommentThread
                comments={comments}
                language={language}
                level={0}
                maxLevel={3}
                onReply={handleReply}
                onLike={handleLike}
              />
            </div>

            {/* New Comment Input */}
            <div className="border-t border-[#E5E7EB] dark:border-border p-[16px] bg-white dark:bg-card">
              <div className="flex items-end gap-[12px]">
                {/* Avatar */}
                <div className="w-[36px] h-[36px] rounded-full overflow-hidden bg-neutral-100 flex-shrink-0">
                  <img 
                    src={imgFrame} 
                    alt="You"
                    className="w-full h-full object-cover"
                  />
                </div>

                {/* Input */}
                <div className="flex-1 bg-[#F7F7F7] dark:bg-muted rounded-[20px] px-[16px] py-[10px] border border-[#E5E7EB] dark:border-border focus-within:border-[#d6775c] dark:focus-within:border-[#d6775c] transition-colors">
                  <input
                    type="text"
                    value={newComment}
                    onChange={(e) => setNewComment(e.target.value)}
                    onKeyPress={(e) => {
                      if (e.key === 'Enter' && !e.shiftKey) {
                        e.preventDefault();
                        handleAddComment();
                      }
                    }}
                    placeholder={t.writeComment}
                    className="w-full bg-transparent font-['Noto_Sans_Bengali',sans-serif] text-[14px] text-[#0f1419] dark:text-white outline-none placeholder:text-[#8E8E8E]"
                  />
                </div>

                {/* Send Button */}
                <button
                  onClick={handleAddComment}
                  disabled={!newComment.trim()}
                  className="w-[40px] h-[40px] rounded-full bg-[#d6775c] flex items-center justify-center hover:bg-[#c96647] transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex-shrink-0"
                >
                  <Send className="w-[18px] h-[18px] text-white" />
                </button>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};