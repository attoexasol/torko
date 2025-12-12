import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Info, CheckCircle, AlertCircle, AlertTriangle } from 'lucide-react';
import { Button } from './ui/button';

export type NotificationType = 'info' | 'success' | 'warning' | 'error';

export interface Notification {
  id: string;
  type: NotificationType;
  message: string;
  duration?: number; // milliseconds, 0 for persistent
  action?: {
    label: string;
    onClick: () => void;
  };
}

interface NotificationBarProps {
  notification: Notification | null;
  onDismiss: (id: string) => void;
}

const getNotificationStyles = (type: NotificationType) => {
  switch (type) {
    case 'success':
      return {
        bg: 'bg-green-50 dark:bg-green-950/30',
        border: 'border-green-200 dark:border-green-800',
        text: 'text-green-800 dark:text-green-200',
        icon: CheckCircle,
        iconColor: 'text-green-600 dark:text-green-400',
      };
    case 'warning':
      return {
        bg: 'bg-yellow-50 dark:bg-yellow-950/30',
        border: 'border-yellow-200 dark:border-yellow-800',
        text: 'text-yellow-800 dark:text-yellow-200',
        icon: AlertTriangle,
        iconColor: 'text-yellow-600 dark:text-yellow-400',
      };
    case 'error':
      return {
        bg: 'bg-red-50 dark:bg-red-950/30',
        border: 'border-red-200 dark:border-red-800',
        text: 'text-red-800 dark:text-red-200',
        icon: AlertCircle,
        iconColor: 'text-red-600 dark:text-red-400',
      };
    case 'info':
    default:
      return {
        bg: 'bg-accent/10 dark:bg-accent/20',
        border: 'border-accent/30',
        text: 'text-foreground',
        icon: Info,
        iconColor: 'text-accent',
      };
  }
};

export const NotificationBar: React.FC<NotificationBarProps> = ({ notification, onDismiss }) => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    if (notification) {
      setIsVisible(true);
      
      // Auto dismiss if duration is set
      if (notification.duration && notification.duration > 0) {
        const timer = setTimeout(() => {
          handleDismiss();
        }, notification.duration);
        
        return () => clearTimeout(timer);
      }
    } else {
      setIsVisible(false);
    }
  }, [notification]);

  const handleDismiss = () => {
    setIsVisible(false);
    setTimeout(() => {
      if (notification) {
        onDismiss(notification.id);
      }
    }, 300); // Wait for animation to complete
  };

  if (!notification) return null;

  const styles = getNotificationStyles(notification.type);
  const Icon = styles.icon;

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          initial={{ y: -100, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: -100, opacity: 0 }}
          transition={{ type: 'spring', stiffness: 500, damping: 30 }}
          className="fixed top-0 left-0 right-0 z-50 px-4 pt-4"
        >
          <div className="max-w-2xl mx-auto">
            <div
              className={`${styles.bg} ${styles.border} border-2 rounded-2xl shadow-lg overflow-hidden`}
            >
              <div className="flex items-start gap-3 p-4">
                {/* Icon */}
                <div className="flex-shrink-0 mt-0.5">
                  <Icon className={`w-5 h-5 ${styles.iconColor}`} strokeWidth={2} />
                </div>

                {/* Message */}
                <div className={`flex-1 ${styles.text}`}>
                  <p className="text-sm leading-relaxed font-['Noto_Sans_Bengali:Regular',sans-serif]">{notification.message}</p>
                </div>

                {/* Action Button */}
                {notification.action && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => {
                      notification.action?.onClick();
                      handleDismiss();
                    }}
                    className="h-8 px-3 rounded-xl text-accent hover:bg-accent/10 flex-shrink-0"
                  >
                    {notification.action.label}
                  </Button>
                )}

                {/* Close Button */}
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={handleDismiss}
                  className="h-8 w-8 rounded-full flex-shrink-0 hover:bg-black/5 dark:hover:bg-white/5"
                >
                  <X className="w-4 h-4" />
                </Button>
              </div>

              {/* Progress bar for timed notifications */}
              {notification.duration && notification.duration > 0 && (
                <motion.div
                  className="h-1 bg-accent/30"
                  initial={{ width: '100%' }}
                  animate={{ width: '0%' }}
                  transition={{ duration: notification.duration / 1000, ease: 'linear' }}
                />
              )}
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};