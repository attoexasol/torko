import { useState, useEffect, useRef } from 'react';

interface UseScrollDirectionOptions {
  threshold?: number;
  initialDirection?: 'up' | 'down';
}

export const useScrollDirection = (
  elementRef: React.RefObject<HTMLElement>,
  options: UseScrollDirectionOptions = {}
) => {
  const { threshold = 10, initialDirection = 'up' } = options;
  const [scrollDirection, setScrollDirection] = useState<'up' | 'down'>(initialDirection);
  const [isAtTop, setIsAtTop] = useState(true);
  const lastScrollY = useRef(0);

  useEffect(() => {
    const element = elementRef.current;
    if (!element) return;

    const handleScroll = () => {
      const currentScrollY = element.scrollTop;
      
      // Check if at top
      setIsAtTop(currentScrollY <= 0);

      // Only update direction if scrolled past threshold
      if (Math.abs(currentScrollY - lastScrollY.current) < threshold) {
        return;
      }

      const direction = currentScrollY > lastScrollY.current ? 'down' : 'up';
      
      // Only update if direction changed and not at the very top
      if (direction !== scrollDirection && currentScrollY > 0) {
        setScrollDirection(direction);
      }

      lastScrollY.current = currentScrollY;
    };

    element.addEventListener('scroll', handleScroll, { passive: true });

    return () => {
      element.removeEventListener('scroll', handleScroll);
    };
  }, [elementRef, scrollDirection, threshold]);

  return { scrollDirection, isAtTop, isVisible: scrollDirection === 'up' || isAtTop };
};
