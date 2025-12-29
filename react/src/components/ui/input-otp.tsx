"use client";

import * as React from "react";
import { MinusIcon } from "lucide-react";
import { cn } from "./utils";

interface InputOTPContextValue {
  slots: Array<{
    char: string;
    hasFakeCaret: boolean;
    isActive: boolean;
  }>;
  focusInput: () => void;
}

const OTPInputContext = React.createContext<InputOTPContextValue | undefined>(undefined);

function InputOTP({ 
  className,
  containerClassName,
  maxLength = 6,
  value = "",
  onChange,
  children,
  autoFocus,
  ...props
}: {
  className?: string;
  containerClassName?: string;
  maxLength?: number;
  value?: string;
  onChange?: (value: string) => void;
  children?: React.ReactNode;
  autoFocus?: boolean;
} & Omit<React.InputHTMLAttributes<HTMLInputElement>, 'onChange' | 'children'>) {
  const inputRef = React.useRef<HTMLInputElement>(null);

  const slots = Array.from({ length: maxLength }, (_, index) => ({
    char: value[index] || '',
    hasFakeCaret: index === value.length,
    isActive: index === value.length,
  }));

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value.replace(/\D/g, '').slice(0, maxLength);
    onChange?.(newValue);
  };

  const focusInput = React.useCallback(() => {
    inputRef.current?.focus();
  }, []);

  // Auto-focus on mount if autoFocus is true
  React.useEffect(() => {
    if (autoFocus) {
      setTimeout(() => focusInput(), 100);
    }
  }, [autoFocus, focusInput]);

  // Handle keydown for better UX
  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && value.length > 0) {
      onChange?.(value.slice(0, -1));
      e.preventDefault();
    }
  };

  return (
    <OTPInputContext.Provider value={{ slots, focusInput }}>
      <div
        className={cn("relative flex items-center gap-2", containerClassName)}
        onClick={focusInput}
      >
        <input
          ref={inputRef}
          type="text"
          inputMode="numeric"
          pattern="[0-9]*"
          value={value}
          onChange={handleChange}
          onKeyDown={handleKeyDown}
          maxLength={maxLength}
          className="absolute opacity-0 pointer-events-none"
          {...props}
        />
        {children}
      </div>
    </OTPInputContext.Provider>
  );
}

function InputOTPGroup({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  const context = React.useContext(OTPInputContext);

  return (
    <div
      className={cn("flex items-center gap-1", className)}
      onClick={context?.focusInput}
      {...props}
    />
  );
}

function InputOTPSlot({ 
  index,
  className,
  ...props
}: React.HTMLAttributes<HTMLDivElement> & {
  index: number;
}) {
  const inputOTPContext = React.useContext(OTPInputContext);
  const { char, hasFakeCaret, isActive } = inputOTPContext?.slots[index] ?? {};

  return (
    <div
      data-active={isActive}
      className={cn(
        "relative flex h-9 w-9 items-center justify-center border text-sm transition-all cursor-text",
        "border-input bg-background rounded-md",
        isActive && "ring-2 ring-primary ring-offset-2 ring-offset-background border-primary",
        className
      )}
      onClick={inputOTPContext?.focusInput}
      {...props}
    >
      <span className={cn(
        "text-center",
        !char && "opacity-0"
      )}>
        {char || "0"}
      </span>
      {hasFakeCaret && (
        <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
          <div className="h-4 w-px animate-pulse bg-foreground duration-1000" />
        </div>
      )}
    </div>
  );
}

function InputOTPSeparator({ ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div role="separator" {...props}>
      <MinusIcon className="h-4 w-4" />
    </div>
  );
}

export { InputOTP, InputOTPGroup, InputOTPSlot, InputOTPSeparator };
