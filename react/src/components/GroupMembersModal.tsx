import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { useApp } from './contexts/AppContext';
import { X, Crown, UserMinus } from 'lucide-react';
import { Button } from './ui/button';

interface GroupMember {
  id: number;
  name: string;
  initials: string;
  color: string;
  isAdmin: boolean;
  isOnline: boolean;
}

interface GroupMembersModalProps {
  isOpen: boolean;
  onClose: () => void;
  groupName: string;
  members: GroupMember[];
}

export const GroupMembersModal: React.FC<GroupMembersModalProps> = ({
  isOpen,
  onClose,
  groupName,
  members,
}) => {
  const { language, theme } = useApp();

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
            className="fixed inset-0 bg-black/50 z-50"
            onClick={onClose}
          />

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            transition={{ type: 'spring', damping: 25, stiffness: 300 }}
            className={`fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[90%] max-w-[500px] rounded-3xl shadow-2xl z-50 overflow-hidden ${
              theme === 'dark' ? 'bg-[#052029]' : 'bg-white'
            }`}
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div
              className={`px-6 py-5 border-b ${
                theme === 'dark' ? 'border-[rgba(255,255,255,0.1)]' : 'border-[rgba(44,44,46,0.12)]'
              }`}
            >
              <div className="flex items-center justify-between">
                <div>
                  <h2
                    className={theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}
                    style={{
                      fontSize: '20px',
                      fontWeight: '700',
                      lineHeight: '1.3',
                    }}
                  >
                    {groupName}
                  </h2>
                  <p
                    className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                    style={{
                      fontSize: '14px',
                      marginTop: '4px',
                    }}
                  >
                    {members.length} {language === 'bn' ? 'সদস্য' : 'members'}
                  </p>
                </div>
                <Button
                  variant="ghost"
                  size="icon"
                  className="rounded-full h-10 w-10 hover:bg-muted/80"
                  onClick={onClose}
                >
                  <X className="w-5 h-5" />
                </Button>
              </div>
            </div>

            {/* Members List */}
            <div
              className="overflow-y-auto"
              style={{
                maxHeight: '60vh',
              }}
            >
              <div className="px-4 py-2">
                {members.map((member, index) => (
                  <motion.div
                    key={member.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.05, duration: 0.2 }}
                    className={`flex items-center justify-between py-3 px-3 rounded-xl transition-all hover:bg-muted/30 ${
                      index !== members.length - 1 ? 'mb-1' : ''
                    }`}
                  >
                    <div className="flex items-center gap-3 flex-1 min-w-0">
                      {/* Avatar */}
                      <div className="relative flex-shrink-0">
                        <div
                          className="flex items-center justify-center text-white"
                          style={{
                            width: '48px',
                            height: '48px',
                            borderRadius: '50%',
                            backgroundColor: member.color,
                            fontSize: '16px',
                            fontWeight: '600',
                            boxShadow: '0 2px 6px rgba(0, 0, 0, 0.1)',
                          }}
                        >
                          {member.initials}
                        </div>

                        {/* Online indicator */}
                        {member.isOnline && (
                          <div
                            className={`absolute -bottom-0.5 -right-0.5 rounded-full flex items-center justify-center ${
                              theme === 'dark' ? 'bg-[#052029]' : 'bg-white'
                            }`}
                            style={{
                              width: '16px',
                              height: '16px',
                              padding: '2px',
                            }}
                          >
                            <div
                              className="w-full h-full rounded-full bg-green-500"
                              style={{
                                boxShadow: theme === 'dark' ? '0 0 0 2px #052029' : '0 0 0 2px white',
                              }}
                            />
                          </div>
                        )}

                        {/* Admin badge */}
                        {member.isAdmin && (
                          <div
                            className="absolute -top-1 -right-1 rounded-full flex items-center justify-center"
                            style={{
                              width: '20px',
                              height: '20px',
                              backgroundColor: '#d97757',
                              boxShadow: theme === 'dark' ? '0 0 0 2px #052029' : '0 0 0 2px white',
                            }}
                          >
                            <Crown className="w-3 h-3 text-white" />
                          </div>
                        )}
                      </div>

                      {/* Name and Status */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <p
                            className={`truncate ${theme === 'dark' ? 'text-[#f5f5f5]' : 'text-[#2c2c2e]'}`}
                            style={{
                              fontSize: '16px',
                              fontWeight: '600',
                              lineHeight: '1.3',
                            }}
                          >
                            {member.name}
                          </p>
                        </div>
                        <p
                          className={theme === 'dark' ? 'text-[#9b9b9b]' : 'text-[#6b6b6b]'}
                          style={{
                            fontSize: '13px',
                            marginTop: '2px',
                          }}
                        >
                          {member.isAdmin
                            ? language === 'bn'
                              ? 'গ্রুপ অ্যাডমিন'
                              : 'Group Admin'
                            : member.isOnline
                            ? language === 'bn'
                              ? 'অনলাইন'
                              : 'Online'
                            : language === 'bn'
                            ? 'অফলাইন'
                            : 'Offline'}
                        </p>
                      </div>
                    </div>

                    {/* Action Button (Only show for non-admin members) */}
                    {!member.isAdmin && (
                      <Button
                        variant="ghost"
                        size="icon"
                        className="rounded-full h-9 w-9 hover:bg-red-50 dark:hover:bg-red-950/20 flex-shrink-0"
                        onClick={() => console.log('Remove member:', member.id)}
                      >
                        <UserMinus className="w-4 h-4 text-red-600" />
                      </Button>
                    )}
                  </motion.div>
                ))}
              </div>
            </div>

            {/* Footer */}
            <div
              className={`px-6 py-4 border-t ${
                theme === 'dark' ? 'border-[rgba(255,255,255,0.1)]' : 'border-[rgba(44,44,46,0.12)]'
              }`}
            >
              <Button
                className="w-full rounded-full"
                style={{
                  backgroundColor: '#d97757',
                  color: 'white',
                  height: '48px',
                  fontSize: '16px',
                  fontWeight: '600',
                }}
                onClick={() => console.log('Add member')}
              >
                {language === 'bn' ? 'নতুন সদস্য যোগ করুন' : 'Add New Member'}
              </Button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};