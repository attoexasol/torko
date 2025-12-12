import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Upload, MapPin, Calendar, Clock, DollarSign, Star, Phone, MessageCircle, Copy, Check, Radio } from 'lucide-react';

interface CreateGroupModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: any) => void;
  language?: 'bn' | 'en';
}

export const CreateGroupModal: React.FC<CreateGroupModalProps> = ({ isOpen, onClose, onSubmit, language = 'bn' }) => {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    type: 'public',
    image: '',
  });
  const [imagePreview, setImagePreview] = useState<string | null>(null);

  console.log('CreateGroupModal rendered, isOpen:', isOpen);

  const t = {
    createGroup: language === 'bn' ? 'গ্রুপ তৈরি করুন' : 'Create Group',
    groupName: language === 'bn' ? 'গ্রুপের নাম' : 'Group Name',
    description: language === 'bn' ? 'বিবরণ' : 'Description',
    public: language === 'bn' ? 'পাবলিক' : 'Public',
    private: language === 'bn' ? 'ব্যক্তিগত' : 'Private',
    uploadImage: language === 'bn' ? 'ছবি আপলোড করুন' : 'Upload Image',
    changePhoto: language === 'bn' ? 'ছবি পরিবর্তন করুন' : 'Change Photo',
    create: language === 'bn' ? 'তৈরি করুন' : 'Create',
    cancel: language === 'bn' ? 'বাতিল' : 'Cancel',
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        const result = reader.result as string;
        setImagePreview(result);
        setFormData({ ...formData, image: result });
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
    setFormData({ name: '', description: '', type: 'public', image: '' });
    setImagePreview(null);
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
              <h2 className="text-[20px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                {t.createGroup}
              </h2>
              <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#F5F5F5] dark:bg-[#0d3a4a] flex items-center justify-center">
                <X className="w-5 h-5 text-[#555e67] dark:text-[#9e9e9e]" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.groupName}
                </label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
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
                  className="w-full h-[100px] px-4 py-3 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c] resize-none"
                  required
                />
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {language === 'bn' ? 'ধরন' : 'Type'}
                </label>
                <div className="flex gap-2">
                  <button
                    type="button"
                    onClick={() => setFormData({ ...formData, type: 'public' })}
                    className={`flex-1 h-[44px] rounded-[10px] text-[14px] font-['Roboto:SemiBold',sans-serif] transition-colors ${
                      formData.type === 'public'
                        ? 'bg-[#d6775c] text-white'
                        : 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
                    }`}
                  >
                    {t.public}
                  </button>
                  <button
                    type="button"
                    onClick={() => setFormData({ ...formData, type: 'private' })}
                    className={`flex-1 h-[44px] rounded-[10px] text-[14px] font-['Roboto:SemiBold',sans-serif] transition-colors ${
                      formData.type === 'private'
                        ? 'bg-[#d6775c] text-white'
                        : 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
                    }`}
                  >
                    {t.private}
                  </button>
                </div>
              </div>

              <div className="relative">
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.uploadImage}
                </label>
                <div className="relative w-full h-[120px] rounded-[12px] border-2 border-dashed border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] overflow-hidden">
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleImageChange}
                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
                  />
                  {imagePreview ? (
                    <div className="relative w-full h-full">
                      <img src={imagePreview} alt="Preview" className="w-full h-full object-cover" />
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          setImagePreview(null);
                          setFormData({ ...formData, image: '' });
                        }}
                        className="absolute top-2 right-2 w-7 h-7 rounded-full bg-black/50 backdrop-blur-sm flex items-center justify-center hover:bg-black/70 transition-colors z-20"
                      >
                        <X className="w-4 h-4 text-white" />
                      </button>
                    </div>
                  ) : (
                    <div className="absolute inset-0 flex flex-col items-center justify-center gap-2">
                      <Upload className="w-8 h-8 text-[#9D9D9D]" />
                      <p className="text-[13px] text-[#9D9D9D] font-['Roboto',sans-serif]">
                        {language === 'bn' ? 'ছবি নির্বাচন করুন' : 'Select Photo'}
                      </p>
                    </div>
                  )}
                </div>
              </div>

              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={onClose}
                  className="flex-1 h-[48px] rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#ebebeb] dark:hover:bg-[#104050] transition-colors"
                >
                  {t.cancel}
                </button>
                <button
                  type="submit"
                  className="flex-1 h-[48px] rounded-[12px] bg-[#d6775c] text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#c96647] transition-colors"
                >
                  {t.create}
                </button>
              </div>
            </form>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

interface CreateEventModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: any) => void;
  language?: 'bn' | 'en';
}

export const CreateEventModal: React.FC<CreateEventModalProps> = ({ isOpen, onClose, onSubmit, language = 'bn' }) => {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    date: '',
    time: '',
    location: '',
  });

  const t = {
    createEvent: language === 'bn' ? 'ইভেন্ট তৈরি করুন' : 'Create Event',
    title: language === 'bn' ? 'শিরোনাম' : 'Title',
    description: language === 'bn' ? 'বিবরণ' : 'Description',
    date: language === 'bn' ? 'তারিখ' : 'Date',
    time: language === 'bn' ? 'সময়' : 'Time',
    location: language === 'bn' ? 'অবস্থান' : 'Location',
    create: language === 'bn' ? 'তৈরি করুন' : 'Create',
    cancel: language === 'bn' ? 'বাতিল' : 'Cancel',
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
    setFormData({ title: '', description: '', date: '', time: '', location: '' });
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
              <h2 className="text-[20px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                {t.createEvent}
              </h2>
              <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#F5F5F5] dark:bg-[#0d3a4a] flex items-center justify-center">
                <X className="w-5 h-5 text-[#555e67] dark:text-[#9e9e9e]" />
              </button>
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
                  className="w-full h-[80px] px-4 py-3 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c] resize-none"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                    {t.date}
                  </label>
                  <input
                    type="date"
                    value={formData.date}
                    onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                    className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white focus:outline-none focus:border-[#d6775c]"
                    required
                  />
                </div>
                <div>
                  <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                    {t.time}
                  </label>
                  <input
                    type="time"
                    value={formData.time}
                    onChange={(e) => setFormData({ ...formData, time: e.target.value })}
                    className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white focus:outline-none focus:border-[#d6775c]"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.location}
                </label>
                <input
                  type="text"
                  value={formData.location}
                  onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                  className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c]"
                  required
                />
              </div>

              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={onClose}
                  className="flex-1 h-[48px] rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#ebebeb] dark:hover:bg-[#104050] transition-colors"
                >
                  {t.cancel}
                </button>
                <button
                  type="submit"
                  className="flex-1 h-[48px] rounded-[12px] bg-[#d6775c] text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#c96647] transition-colors"
                >
                  {t.create}
                </button>
              </div>
            </form>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

interface CreateListingModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: any) => void;
  language?: 'bn' | 'en';
}

export const CreateListingModal: React.FC<CreateListingModalProps> = ({ isOpen, onClose, onSubmit, language = 'bn' }) => {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    price: '',
    isFree: false,
    negotiable: false,
    location: '',
    condition: 'good',
  });

  const t = {
    createListing: language === 'bn' ? 'বিজ্ঞাপন তৈরি করুন' : 'Create Listing',
    title: language === 'bn' ? 'শিরোনাম' : 'Title',
    description: language === 'bn' ? 'বিবরণ' : 'Description',
    price: language === 'bn' ? 'মূল্য' : 'Price',
    free: language === 'bn' ? 'ফ্রি' : 'Free',
    negotiable: language === 'bn' ? 'দর নির্ধারণযোগ্য' : 'Negotiable',
    location: language === 'bn' ? 'অবস্থান' : 'Location',
    condition: language === 'bn' ? 'অবস্থা' : 'Condition',
    good: language === 'bn' ? 'ভালো' : 'Good',
    likeNew: language === 'bn' ? 'প্রায় নতুন' : 'Like New',
    used: language === 'bn' ? 'ব্যবহৃত' : 'Used',
    create: language === 'bn' ? 'তৈরি করুন' : 'Create',
    cancel: language === 'bn' ? 'বাতিল' : 'Cancel',
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
    setFormData({ title: '', description: '', price: '', isFree: false, negotiable: false, location: '', condition: 'good' });
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
              <h2 className="text-[20px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                {t.createListing}
              </h2>
              <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#F5F5F5] dark:bg-[#0d3a4a] flex items-center justify-center">
                <X className="w-5 h-5 text-[#555e67] dark:text-[#9e9e9e]" />
              </button>
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
                  className="w-full h-[80px] px-4 py-3 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c] resize-none"
                  required
                />
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.price}
                </label>
                <input
                  type="text"
                  value={formData.price}
                  onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                  disabled={formData.isFree}
                  className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c] disabled:opacity-50"
                  required={!formData.isFree}
                />
              </div>

              <div className="flex gap-4">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={formData.isFree}
                    onChange={(e) => setFormData({ ...formData, isFree: e.target.checked, price: e.target.checked ? 'Free' : '' })}
                    className="w-5 h-5 rounded border-[#CCCCCC] text-[#d6775c] focus:ring-[#d6775c]"
                  />
                  <span className="text-[14px] text-[#555e67] dark:text-[#9e9e9e]">{t.free}</span>
                </label>
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={formData.negotiable}
                    onChange={(e) => setFormData({ ...formData, negotiable: e.target.checked })}
                    className="w-5 h-5 rounded border-[#CCCCCC] text-[#d6775c] focus:ring-[#d6775c]"
                  />
                  <span className="text-[14px] text-[#555e67] dark:text-[#9e9e9e]">{t.negotiable}</span>
                </label>
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.location}
                </label>
                <input
                  type="text"
                  value={formData.location}
                  onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                  className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c]"
                  required
                />
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.condition}
                </label>
                <select
                  value={formData.condition}
                  onChange={(e) => setFormData({ ...formData, condition: e.target.value })}
                  className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white focus:outline-none focus:border-[#d6775c]"
                >
                  <option value="good">{t.good}</option>
                  <option value="likeNew">{t.likeNew}</option>
                  <option value="used">{t.used}</option>
                </select>
              </div>

              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={onClose}
                  className="flex-1 h-[48px] rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#ebebeb] dark:hover:bg-[#104050] transition-colors"
                >
                  {t.cancel}
                </button>
                <button
                  type="submit"
                  className="flex-1 h-[48px] rounded-[12px] bg-[#d6775c] text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#c96647] transition-colors"
                >
                  {t.create}
                </button>
              </div>
            </form>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

interface CreateAlertModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: any) => void;
  language?: 'bn' | 'en';
}

export const CreateAlertModal: React.FC<CreateAlertModalProps> = ({ isOpen, onClose, onSubmit, language = 'bn' }) => {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    location: '',
    contact: '',
    urgency: 'medium',
  });

  const t = {
    createAlert: language === 'bn' ? 'সতর্কতা পোস্ট করুন' : 'Post Alert',
    title: language === 'bn' ? 'শিরোনাম' : 'Title',
    description: language === 'bn' ? 'বিবরণ' : 'Description',
    location: language === 'bn' ? 'অবস্থান' : 'Location',
    contact: language === 'bn' ? 'যোগাযোগ' : 'Contact',
    urgency: language === 'bn' ? 'জরুরিতা' : 'Urgency',
    high: language === 'bn' ? 'উচ্চ' : 'High',
    medium: language === 'bn' ? 'মাঝারি' : 'Medium',
    low: language === 'bn' ? 'কম' : 'Low',
    create: language === 'bn' ? 'পোস্ট করুন' : 'Post',
    cancel: language === 'bn' ? 'বাতিল' : 'Cancel',
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
    setFormData({ title: '', description: '', location: '', contact: '', urgency: 'medium' });
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
              <h2 className="text-[20px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                {t.createAlert}
              </h2>
              <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#F5F5F5] dark:bg-[#0d3a4a] flex items-center justify-center">
                <X className="w-5 h-5 text-[#555e67] dark:text-[#9e9e9e]" />
              </button>
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
                  className="w-full h-[80px] px-4 py-3 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c] resize-none"
                  required
                />
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.urgency}
                </label>
                <div className="flex gap-2">
                  <button
                    type="button"
                    onClick={() => setFormData({ ...formData, urgency: 'low' })}
                    className={`flex-1 h-[44px] rounded-[10px] text-[14px] font-['Roboto:SemiBold',sans-serif] transition-colors ${
                      formData.urgency === 'low'
                        ? 'bg-blue-500 text-white'
                        : 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
                    }`}
                  >
                    {t.low}
                  </button>
                  <button
                    type="button"
                    onClick={() => setFormData({ ...formData, urgency: 'medium' })}
                    className={`flex-1 h-[44px] rounded-[10px] text-[14px] font-['Roboto:SemiBold',sans-serif] transition-colors ${
                      formData.urgency === 'medium'
                        ? 'bg-orange-500 text-white'
                        : 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
                    }`}
                  >
                    {t.medium}
                  </button>
                  <button
                    type="button"
                    onClick={() => setFormData({ ...formData, urgency: 'high' })}
                    className={`flex-1 h-[44px] rounded-[10px] text-[14px] font-['Roboto:SemiBold',sans-serif] transition-colors ${
                      formData.urgency === 'high'
                        ? 'bg-red-500 text-white'
                        : 'bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-[#9e9e9e]'
                    }`}
                  >
                    {t.high}
                  </button>
                </div>
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.location}
                </label>
                <input
                  type="text"
                  value={formData.location}
                  onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                  className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c]"
                  required
                />
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.contact}
                </label>
                <input
                  type="text"
                  value={formData.contact}
                  onChange={(e) => setFormData({ ...formData, contact: e.target.value })}
                  className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c]"
                  required
                />
              </div>

              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={onClose}
                  className="flex-1 h-[48px] rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#ebebeb] dark:hover:bg-[#104050] transition-colors"
                >
                  {t.cancel}
                </button>
                <button
                  type="submit"
                  className="flex-1 h-[48px] rounded-[12px] bg-[#d6775c] text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#c96647] transition-colors"
                >
                  {t.create}
                </button>
              </div>
            </form>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

interface ContactSellerModalProps {
  isOpen: boolean;
  onClose: () => void;
  itemTitle: string;
  sellerContact: string;
  language?: 'bn' | 'en';
}

export const ContactSellerModal: React.FC<ContactSellerModalProps> = ({ 
  isOpen, 
  onClose, 
  itemTitle, 
  sellerContact,
  language = 'bn' 
}) => {
  const [copied, setCopied] = useState(false);

  const t = {
    contactSeller: language === 'bn' ? 'বিক্রেতার সাথে যোগাযোগ' : 'Contact Seller',
    item: language === 'bn' ? 'পণ্য' : 'Item',
    phoneNumber: language === 'bn' ? 'ফোন নম্বর' : 'Phone Number',
    callNow: language === 'bn' ? 'কল করুন' : 'Call Now',
    sendMessage: language === 'bn' ? 'মেসেজ পাঠান' : 'Send Message',
    copyNumber: language === 'bn' ? 'নম্বর কপি করুন' : 'Copy Number',
    copied: language === 'bn' ? 'কপি হয়েছে!' : 'Copied!',
    close: language === 'bn' ? 'বন্ধ করুন' : 'Close',
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(sellerContact);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleCall = () => {
    window.location.href = `tel:${sellerContact}`;
  };

  const handleMessage = () => {
    window.location.href = `sms:${sellerContact}`;
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
            className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[90%] max-w-[400px] bg-white dark:bg-[#0a2f3d] rounded-[20px] p-6 z-50"
          >
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-[20px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                {t.contactSeller}
              </h2>
              <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#F5F5F5] dark:bg-[#0d3a4a] flex items-center justify-center">
                <X className="w-5 h-5 text-[#555e67] dark:text-[#9e9e9e]" />
              </button>
            </div>

            <div className="space-y-4">
              <div className="p-3 rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a]">
                <p className="text-[12px] text-[#9D9D9D] mb-1">{t.item}</p>
                <p className="text-[14px] text-[#0f1419] dark:text-white font-['Roboto:SemiBold',sans-serif]">
                  {itemTitle}
                </p>
              </div>

              <div className="p-4 rounded-[12px] border-2 border-[#d6775c] bg-[#d6775c]/5">
                <p className="text-[12px] text-[#555e67] dark:text-[#9e9e9e] mb-2">{t.phoneNumber}</p>
                <div className="flex items-center justify-between">
                  <p className="text-[20px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                    {sellerContact}
                  </p>
                  <button
                    onClick={handleCopy}
                    className="w-[36px] h-[36px] rounded-full bg-[#d6775c] flex items-center justify-center hover:bg-[#c96647] transition-colors"
                  >
                    {copied ? (
                      <Check className="w-5 h-5 text-white" />
                    ) : (
                      <Copy className="w-5 h-5 text-white" />
                    )}
                  </button>
                </div>
                {copied && (
                  <motion.p
                    initial={{ opacity: 0, y: -5 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-[12px] text-[#d6775c] mt-1"
                  >
                    {t.copied}
                  </motion.p>
                )}
              </div>

              <div className="grid grid-cols-2 gap-2">
                <button
                  onClick={handleCall}
                  className="h-[48px] rounded-[12px] bg-[#d6775c] text-white flex items-center justify-center gap-2 hover:bg-[#c96647] transition-colors"
                >
                  <Phone className="w-5 h-5" />
                  <span className="font-['Roboto:SemiBold',sans-serif]">{t.callNow}</span>
                </button>
                <button
                  onClick={handleMessage}
                  className="h-[48px] rounded-[12px] border-2 border-[#d6775c] text-[#d6775c] flex items-center justify-center gap-2 hover:bg-[#d6775c]/10 transition-colors"
                >
                  <MessageCircle className="w-5 h-5" />
                  <span className="font-['Roboto:SemiBold',sans-serif]">{t.sendMessage}</span>
                </button>
              </div>

              <button
                onClick={onClose}
                className="w-full h-[44px] rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#EBEBEB] dark:hover:bg-[#104050] transition-colors"
              >
                {t.close}
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

interface ContactProModalProps {
  isOpen: boolean;
  onClose: () => void;
  proName: string;
  proPhone: string;
  proProfession: string;
  language?: 'bn' | 'en';
}

export const ContactProModal: React.FC<ContactProModalProps> = ({ 
  isOpen, 
  onClose, 
  proName,
  proPhone,
  proProfession,
  language = 'bn' 
}) => {
  const [copied, setCopied] = useState(false);

  const t = {
    contactPro: language === 'bn' ? 'প্রফেশনালের সাথে যোগাযোগ' : 'Contact Professional',
    profession: language === 'bn' ? 'পেশা' : 'Profession',
    phoneNumber: language === 'bn' ? 'ফোন নম্বর' : 'Phone Number',
    callNow: language === 'bn' ? 'কল করুন' : 'Call Now',
    sendMessage: language === 'bn' ? 'মেসেজ পাঠান' : 'Send Message',
    copyNumber: language === 'bn' ? 'নম্বর কপি করুন' : 'Copy Number',
    copied: language === 'bn' ? 'কপি হয়েছে!' : 'Copied!',
    close: language === 'bn' ? 'বন্ধ করুন' : 'Close',
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(proPhone);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleCall = () => {
    window.location.href = `tel:${proPhone}`;
  };

  const handleMessage = () => {
    window.location.href = `sms:${proPhone}`;
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
            className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[90%] max-w-[400px] bg-white dark:bg-[#0a2f3d] rounded-[20px] p-6 z-50"
          >
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-[20px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                {t.contactPro}
              </h2>
              <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#F5F5F5] dark:bg-[#0d3a4a] flex items-center justify-center">
                <X className="w-5 h-5 text-[#555e67] dark:text-[#9e9e9e]" />
              </button>
            </div>

            <div className="space-y-4">
              <div className="p-3 rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a]">
                <p className="text-[12px] text-[#9D9D9D] mb-1">{t.profession}</p>
                <p className="text-[16px] text-[#0f1419] dark:text-white font-['Roboto:Bold',sans-serif]">
                  {proName}
                </p>
                <p className="text-[13px] text-[#d6775c] font-['Roboto:Medium',sans-serif]">
                  {proProfession}
                </p>
              </div>

              <div className="p-4 rounded-[12px] border-2 border-[#d6775c] bg-[#d6775c]/5">
                <p className="text-[12px] text-[#555e67] dark:text-[#9e9e9e] mb-2">{t.phoneNumber}</p>
                <div className="flex items-center justify-between">
                  <p className="text-[20px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                    {proPhone}
                  </p>
                  <button
                    onClick={handleCopy}
                    className="w-[36px] h-[36px] rounded-full bg-[#d6775c] flex items-center justify-center hover:bg-[#c96647] transition-colors"
                  >
                    {copied ? (
                      <Check className="w-5 h-5 text-white" />
                    ) : (
                      <Copy className="w-5 h-5 text-white" />
                    )}
                  </button>
                </div>
                {copied && (
                  <motion.p
                    initial={{ opacity: 0, y: -5 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-[12px] text-[#d6775c] mt-1"
                  >
                    {t.copied}
                  </motion.p>
                )}
              </div>

              <div className="grid grid-cols-2 gap-2">
                <button
                  onClick={handleCall}
                  className="h-[48px] rounded-[12px] bg-[#d6775c] text-white flex items-center justify-center gap-2 hover:bg-[#c96647] transition-colors"
                >
                  <Phone className="w-5 h-5" />
                  <span className="font-['Roboto:SemiBold',sans-serif]">{t.callNow}</span>
                </button>
                <button
                  onClick={handleMessage}
                  className="h-[48px] rounded-[12px] border-2 border-[#d6775c] text-[#d6775c] flex items-center justify-center gap-2 hover:bg-[#d6775c]/10 transition-colors"
                >
                  <MessageCircle className="w-5 h-5" />
                  <span className="font-['Roboto:SemiBold',sans-serif]">{t.sendMessage}</span>
                </button>
              </div>

              <button
                onClick={onClose}
                className="w-full h-[44px] rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#EBEBEB] dark:hover:bg-[#104050] transition-colors"
              >
                {t.close}
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

interface ViewProProfileModalProps {
  isOpen: boolean;
  onClose: () => void;
  pro: any;
  language?: 'bn' | 'en';
}

export const ViewProProfileModal: React.FC<ViewProProfileModalProps> = ({ 
  isOpen, 
  onClose, 
  pro,
  language = 'bn' 
}) => {
  const t = {
    profile: language === 'bn' ? 'প্রোফাইল' : 'Profile',
    experience: language === 'bn' ? 'অভিজ্ঞতা' : 'Experience',
    rating: language === 'bn' ? 'রেটিং' : 'Rating',
    reviews: language === 'bn' ? 'রিভিউ' : 'Reviews',
    about: language === 'bn' ? 'সম্পর্কে' : 'About',
    contact: language === 'bn' ? 'যোগাযোগ করুন' : 'Contact',
    close: language === 'bn' ? 'বন্ধ করুন' : 'Close',
    verified: language === 'bn' ? 'যাচাইকৃত প্রফেশনাল' : 'Verified Professional',
  };

  if (!pro) return null;

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
            className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[90%] max-w-[400px] bg-white dark:bg-[#0a2f3d] rounded-[20px] overflow-hidden z-50 max-h-[90vh] overflow-y-auto"
          >
            {/* Header with Image */}
            <div className="relative h-[200px]">
              <img src={pro.image} alt={pro.name} className="w-full h-full object-cover" />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
              <button 
                onClick={onClose} 
                className="absolute top-4 right-4 w-8 h-8 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center"
              >
                <X className="w-5 h-5 text-white" />
              </button>
            </div>

            <div className="p-6 space-y-4">
              {/* Name and Profession */}
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <h2 className="text-[22px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                    {pro.name}
                  </h2>
                  {pro.verified && (
                    <svg className="w-5 h-5 text-[#d6775c]" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                    </svg>
                  )}
                </div>
                <p className="text-[16px] text-[#d6775c] font-['Roboto:SemiBold',sans-serif]">
                  {pro.profession}
                </p>
                {pro.verified && (
                  <p className="text-[12px] text-[#9D9D9D] mt-1">{t.verified}</p>
                )}
              </div>

              {/* Stats */}
              <div className="grid grid-cols-3 gap-3">
                <div className="p-3 rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-center">
                  <div className="flex items-center justify-center gap-1 mb-1">
                    <Star className="w-4 h-4 fill-[#FFA500] text-[#FFA500]" />
                    <span className="font-['Roboto:Bold',sans-serif] text-[16px] text-[#0f1419] dark:text-white">
                      {pro.rating}
                    </span>
                  </div>
                  <p className="text-[11px] text-[#9D9D9D]">{t.rating}</p>
                </div>
                <div className="p-3 rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-center">
                  <p className="font-['Roboto:Bold',sans-serif] text-[16px] text-[#0f1419] dark:text-white mb-1">
                    {pro.reviews}
                  </p>
                  <p className="text-[11px] text-[#9D9D9D]">{t.reviews}</p>
                </div>
                <div className="p-3 rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-center">
                  <p className="font-['Roboto:Bold',sans-serif] text-[16px] text-[#0f1419] dark:text-white mb-1">
                    {pro.experience}
                  </p>
                  <p className="text-[11px] text-[#9D9D9D]">{t.experience}</p>
                </div>
              </div>

              {/* About */}
              <div>
                <h3 className="text-[14px] font-['Roboto:SemiBold',sans-serif] text-[#0f1419] dark:text-white mb-2">
                  {t.about}
                </h3>
                <p className="text-[14px] text-[#555e67] dark:text-[#9e9e9e] leading-relaxed">
                  {pro.description}
                </p>
              </div>

              {/* Contact Button */}
              <button
                onClick={onClose}
                className="w-full h-[48px] rounded-[12px] bg-[#d6775c] text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#c96647] transition-colors"
              >
                {t.close}
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

interface JoinAsProModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: any) => void;
  language?: 'bn' | 'en';
}

export const JoinAsProModal: React.FC<JoinAsProModalProps> = ({ isOpen, onClose, onSubmit, language = 'bn' }) => {
  const [formData, setFormData] = useState({
    name: '',
    profession: '',
    experience: '',
    description: '',
    phone: '',
  });

  const t = {
    joinAsPro: language === 'bn' ? 'প্রফেশনাল হিসেবে যোগ দিন' : 'Join as Professional',
    name: language === 'bn' ? 'আপনার নাম' : 'Your Name',
    profession: language === 'bn' ? 'পেশা' : 'Profession',
    experience: language === 'bn' ? 'অভিজ্ঞতা (বছর)' : 'Experience (Years)',
    description: language === 'bn' ? 'আপনার সেবা সম্পর্কে বর্ণনা' : 'Description of Your Services',
    phone: language === 'bn' ? 'ফোন নম্বর' : 'Phone Number',
    submit: language === 'bn' ? 'আবেদন জমা দিন' : 'Submit Application',
    cancel: language === 'bn' ? 'বাতিল' : 'Cancel',
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
    setFormData({ name: '', profession: '', experience: '', description: '', phone: '' });
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
              <h2 className="text-[20px] font-['Roboto:Bold',sans-serif] text-[#0f1419] dark:text-white">
                {t.joinAsPro}
              </h2>
              <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#F5F5F5] dark:bg-[#0d3a4a] flex items-center justify-center">
                <X className="w-5 h-5 text-[#555e67] dark:text-[#9e9e9e]" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.name}
                </label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c]"
                  required
                />
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.profession}
                </label>
                <input
                  type="text"
                  value={formData.profession}
                  onChange={(e) => setFormData({ ...formData, profession: e.target.value })}
                  placeholder={language === 'bn' ? 'উদাহরণ: প্লাম্বার, ইলেকট্রিশিয়ান' : 'e.g. Plumber, Electrician'}
                  className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c]"
                  required
                />
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.experience}
                </label>
                <input
                  type="text"
                  value={formData.experience}
                  onChange={(e) => setFormData({ ...formData, experience: e.target.value })}
                  placeholder={language === 'bn' ? 'উদাহরণ: ১০ বছর' : 'e.g. 10 Years'}
                  className="w-full h-[48px] px-4 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c]"
                  required
                />
              </div>

              <div>
                <label className="block text-[14px] text-[#555e67] dark:text-[#9e9e9e] mb-2">
                  {t.phone}
                </label>
                <input
                  type="tel"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  placeholder={language === 'bn' ? '০১৭XXXXXXXX' : '01700000000'}
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
                  className="w-full h-[100px] px-4 py-3 rounded-[12px] border border-[#CCCCCC] dark:border-[#0d3a4a] bg-white dark:bg-[#052029] text-[#0f1419] dark:text-white placeholder:text-[#999] dark:placeholder:text-[#666] focus:outline-none focus:border-[#d6775c] resize-none"
                  required
                />
              </div>

              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={onClose}
                  className="flex-1 h-[48px] rounded-[12px] bg-[#F5F5F5] dark:bg-[#0d3a4a] text-[#555e67] dark:text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#ebebeb] dark:hover:bg-[#104050] transition-colors"
                >
                  {t.cancel}
                </button>
                <button
                  type="submit"
                  className="flex-1 h-[48px] rounded-[12px] bg-[#d6775c] text-white font-['Roboto:SemiBold',sans-serif] hover:bg-[#c96647] transition-colors"
                >
                  {t.submit}
                </button>
              </div>
            </form>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};