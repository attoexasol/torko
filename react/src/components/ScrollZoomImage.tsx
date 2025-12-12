import React, { useRef } from 'react';
import { motion, useScroll, useTransform } from 'motion/react';

interface ScrollZoomImageProps {
  src: string;
  alt: string;
  className?: string;
}

export const ScrollZoomImage: React.FC<ScrollZoomImageProps> = ({ src, alt, className }) => {
  const ref = useRef<HTMLDivElement>(null);
  
  // Track scroll progress of this specific image
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start end', 'end start'], // Start when image enters bottom, end when it leaves top
  });

  // Map scroll progress to scale
  // When entering (0 to 0.35): scale from 1 to 1.06
  // When centered (0.35 to 0.65): stay at 1.06
  // When leaving (0.65 to 1): scale from 1.06 to 1
  const scale = useTransform(scrollYProgress, 
    [0, 0.35, 0.65, 1],
    [1, 1.06, 1.06, 1]
  );

  return (
    <div ref={ref} className="overflow-hidden" style={{ borderRadius: '12px' }}>
      <motion.img 
        src={src} 
        alt={alt} 
        className={className}
        style={{ 
          scale,
          transformOrigin: 'center center',
        }}
        transition={{
          type: 'spring',
          stiffness: 100,
          damping: 30,
        }}
      />
    </div>
  );
};
