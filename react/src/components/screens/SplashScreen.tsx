import React, { useEffect } from 'react';
import { useApp } from '../contexts/AppContext';
import torkoLogo from 'figma:asset/54b40a5db169e3bbfb66dd47ad9182426b12a2e8.png';

interface SplashScreenProps {
  onComplete: () => void;
}

export const SplashScreen: React.FC<SplashScreenProps> = ({ onComplete }) => {
  useEffect(() => {
    const timer = setTimeout(onComplete, 2500);
    return () => clearTimeout(timer);
  }, [onComplete]);

  return (
    <div className="fixed inset-0 flex items-center justify-center px-6" style={{ backgroundColor: '#B8DED6' }}>
      <div className="text-center">
        <img 
          src={torkoLogo} 
          alt="Torko Logo" 
          className="drop-shadow-2xl"
          style={{ width: '200px', height: '200px' }}
        />
      </div>
    </div>
  );
};