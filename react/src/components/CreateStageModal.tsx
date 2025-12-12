import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Radio } from 'lucide-react';

interface CreateStageModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: any) => void;
  language?: 'bn' | 'en';
}

export const CreateStageModal: React.FC<CreateStageModalProps> = ({ isOpen, onClose, onSubmit, language = 'bn' }) => {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    category: 'general',
  });

  const t = {
    createStage: language === 'bn' ? 'স্টেজ শুরু করুন' : 'Start Stage',
    title: language === 'bn' ? 'স্টেজের শিরোনাম' : 'Stage Title',
    description: language === 'bn' ? 'বিবরণ' : 'Description',
    category: language === 'bn' ? 'বিভাগ' : 'Category',
    general: language === 'bn' ? 'সাধারণ' : 'General',
    tech: language === 'bn' ? 'প্রযুক্তি' : 'Tech',
    business: language === 'bn' ? 'ব্যবসা' : 'Business',
    education: language === 'bn' ? 'শিক্ষা' : 'Education',
    entertainment: language === 'bn' ? 'বিনোদন' : 'Entertainment',
    sports: language === 'bn' ? 'খেলাধুলা' : 'Sports',
    start: language === 'bn' ? 'শুরু করুন' : 'Start',
    cancel: language === 'bn' ? 'বাতিল' : 'Cancel',
    info: language === 'bn' 
      ? 'আপনি একজন হোস্ট হিসাবে স্টেজ শুরু করবেন এবং অন্যরা আপনার সাথে যুক্ত হতে পারবে।' 
      : 'You will start the stage as a host and others can join you.',
  };

  const categories = [
    { value: 'general', label: t.general },
    { value: 'tech', label: t.tech },
    { value: 'business', label: t.business },
    { value: 'education', label: t.education },
    { value: 'entertainment', label: t.entertainment },
    { value: 'sports', label: t.sports },
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
    setFormData({ title: '', description: '', category: 'general' });
    onClose();
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/50 z-50"
          />
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[90%] max-w-[400px] bg-white dark:bg-[#0a2f3d] rounded-[20px] p-6 z-50 max-h-[90vh] overflow-y-auto"
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#d6775c]/10 dark:bg-[#d6775c]/20 flex items-center justify-center">
                  <Radio className="w-5 h-5 text-[#d6775c]" strokeWidth={2} />
                </div>
                <h2 className="text-[20px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                  {t.createStage}
                </h2>
              </div>
              <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#F5F5F5] dark:bg-[#0d3a4a] flex items-center justify-center">
                <X className="w-5 h-5 text-[#555e67] dark:text-[#9e9e9e]" />
              </button>
            </div>

            {/* Info Banner */}
            <div className="mb-4 p-3 rounded-[12px] bg-[#d6775c]/10 dark:bg-[#d6775c]/20 border border-transparent dark:border-[#d6775c]/30">
              <p className="text-[13px] text-[#0f1419] dark:text-[#e8e8e8] leading-relaxed">
                {t.info}
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.title}
                </label>
                <input
                  type="text"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  placeholder={language === 'bn' ? 'উদাহরণ: আজকের খবরের আলোচনা' : "e.g. Today's News Discussion"}
                  className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c]"
                  required
                />
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.description}
                </label>
                <textarea
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  placeholder={language === 'bn' ? 'এই স্টেজটি সম্পর্কে কিছু লিখুন...' : 'Write something about this stage...'}
                  className="w-full h-[100px] px-4 py-3 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c] resize-none"
                  required
                />
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.category}
                </label>
                <div className="grid grid-cols-3 gap-2">
                  {categories.map((cat) => (
                    <button
                      key={cat.value}
                      type="button"
                      onClick={() => setFormData({ ...formData, category: cat.value })}
                      className={`h-[44px] rounded-[10px] text-[13px] font-['Roboto:SemiBold',sans-serif] transition-colors ${
                        formData.category === cat.value
                          ? 'bg-[#d6775c] text-white'
                          : 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
                      }`}
                    >
                      {cat.label}
                    </button>
                  ))}
                </div>
              </div>

              <div className="flex gap-2 pt-2">
                <button
                  type="button"
                  onClick={onClose}
                  className="flex-1 h-[48px] rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#ebebeb] dark:hover:bg-[#104050] transition-colors"
                >
                  {t.cancel}
                </button>
                <button
                  type="submit"
                  className="flex-1 h-[48px] rounded-[12px] bg-[#d6775c] text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#c96647] transition-colors flex items-center justify-center gap-2"
                >
                  <Radio className="w-5 h-5" strokeWidth={2} />
                  {t.start}
                </button>
              </div>
            </form>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};