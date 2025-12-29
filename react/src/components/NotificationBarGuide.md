# Notification Bar Usage Guide

The Notification Bar system provides a consistent way to display important app-wide notifications at the top of the screen.

## Features

- **4 Notification Types**: Info, Success, Warning, Error
- **Auto-dismiss**: Configurable duration or persistent notifications
- **Action Buttons**: Optional action buttons with callbacks
- **Smooth Animations**: Slide in/out animations with progress bar
- **Dark Mode Support**: Automatically adapts to theme
- **Bengali & English**: Fully bilingual support

## Basic Usage

### 1. Import the hook

```tsx
import { useApp } from '../contexts/AppContext';

const YourComponent = () => {
  const { showNotification } = useApp();
  // ...
};
```

### 2. Show a notification

```tsx
// Simple success notification
showNotification({
  type: 'success',
  message: 'Your post has been published!',
  duration: 3000, // Auto-dismiss after 3 seconds
});

// Info notification with custom duration
showNotification({
  type: 'info',
  message: 'New feature available: Localized Communities',
  duration: 5000,
});

// Warning notification
showNotification({
  type: 'warning',
  message: 'Your session will expire in 5 minutes',
  duration: 0, // Persistent (won't auto-dismiss)
});

// Error notification
showNotification({
  type: 'error',
  message: 'Failed to upload image. Please try again.',
  duration: 4000,
});
```

### 3. Notification with Action Button

```tsx
showNotification({
  type: 'info',
  message: 'Update available for Torko',
  duration: 0, // Persistent until user interacts
  action: {
    label: 'Update Now',
    onClick: () => {
      // Handle update logic
      console.log('Updating...');
    },
  },
});
```

### 4. Bilingual Messages

```tsx
const { language, showNotification } = useApp();

showNotification({
  type: 'success',
  message: language === 'bn' 
    ? 'আপনার পোস্ট সফলভাবে প্রকাশিত হয়েছে!'
    : 'Your post has been published successfully!',
  duration: 3000,
});
```

## Notification Types

### Info (Default)
- **Use for**: General information, tips, feature announcements
- **Color**: Coral accent color
- **Icon**: Info circle

### Success
- **Use for**: Completed actions, confirmations
- **Color**: Green
- **Icon**: Check circle

### Warning
- **Use for**: Important notices, cautions
- **Color**: Yellow
- **Icon**: Alert triangle

### Error
- **Use for**: Errors, failed operations
- **Color**: Red
- **Icon**: Alert circle

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `type` | `'info' \| 'success' \| 'warning' \| 'error'` | No | `'info'` | Visual style of notification |
| `message` | `string` | Yes | - | Text content to display |
| `duration` | `number` | No | `5000` | Auto-dismiss time in ms (0 = persistent) |
| `action` | `{ label: string, onClick: () => void }` | No | - | Optional action button |

## Best Practices

1. **Keep messages concise** - One or two sentences maximum
2. **Use appropriate types** - Match the notification type to the message urgency
3. **Consider timing** - Important messages should have longer durations
4. **Limit frequency** - Don't overwhelm users with too many notifications
5. **Provide actions when needed** - Use action buttons for actionable notifications
6. **Support both languages** - Always provide Bengali and English messages

## Examples from the App

### Login Success
```tsx
showNotification({
  type: 'success',
  message: language === 'bn' 
    ? `স্বাগতম ${username}! তর্কে আপনার যাত্রা শুরু হলো।`
    : `Welcome ${username}! Your journey on Torko begins.`,
  duration: 4000,
});
```

### Post Created
```tsx
showNotification({
  type: 'success',
  message: language === 'bn' 
    ? 'আপনার পোস্ট সফলভাবে প্রকাশিত হয়েছে!'
    : 'Your post has been published successfully!',
  duration: 3000,
});
```

### Location Permission Granted
```tsx
showNotification({
  type: 'info',
  message: language === 'bn' 
    ? 'লোকেশন অ্যাক্সেসের অনুমতি দেওয়া হয়েছে। এখন আপনার অঞ্চল নির্বাচন করুন।'
    : 'Location access granted. Now select your region.',
  duration: 3000,
});
```

### Network Error with Retry
```tsx
showNotification({
  type: 'error',
  message: language === 'bn'
    ? 'নেটওয়ার্ক সংযোগে ত্রুটি। অনুগ্রহ করে আবার চেষ্টা করুন।'
    : 'Network connection error. Please try again.',
  duration: 0,
  action: {
    label: language === 'bn' ? 'পুনরায় চেষ্টা করুন' : 'Retry',
    onClick: () => {
      // Retry logic
    },
  },
});
```

## Styling

The notification bar automatically:
- Adapts to light/dark theme
- Centers within the max-width container (mobile-first design)
- Shows a progress bar for timed notifications
- Uses rounded corners (rounded-2xl) for modern look
- Maintains proper z-index (z-50) to appear above other content
- Includes smooth slide animations

## Technical Details

- **Component Location**: `/components/NotificationBar.tsx`
- **Context Integration**: `/components/contexts/AppContext.tsx`
- **Rendered In**: `/App.tsx`
- **Animation Library**: Motion (Framer Motion)
- **Icons**: Lucide React
