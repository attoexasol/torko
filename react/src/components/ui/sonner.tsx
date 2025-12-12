"use client";

import * as React from "react";

interface Toast {
  id: string;
  message: string;
  type?: "success" | "error" | "info" | "warning";
  duration?: number;
}

const ToasterContext = React.createContext<{
  toasts: Toast[];
  addToast: (toast: Omit<Toast, "id">) => void;
  removeToast: (id: string) => void;
} | undefined>(undefined);

export function ToasterProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = React.useState<Toast[]>([]);

  const addToast = React.useCallback((toast: Omit<Toast, "id">) => {
    const id = Math.random().toString(36).substring(7);
    const newToast = { ...toast, id };
    setToasts((prev) => [...prev, newToast]);

    const duration = toast.duration || 3000;
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, duration);
  }, []);

  const removeToast = React.useCallback((id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  }, []);

  return (
    <ToasterContext.Provider value={{ toasts, addToast, removeToast }}>
      {children}
    </ToasterContext.Provider>
  );
}

export function Toaster() {
  const context = React.useContext(ToasterContext);
  if (!context) return null;

  const { toasts, removeToast } = context;

  if (toasts.length === 0) return null;

  return (
    <div className="fixed top-4 right-4 z-[100] flex flex-col gap-2">
      {toasts.map((toast) => (
        <div
          key={toast.id}
          className={`
            min-w-[300px] rounded-lg border bg-background p-4 shadow-lg animate-in slide-in-from-top-5
            ${toast.type === "success" ? "border-green-500" : ""}
            ${toast.type === "error" ? "border-red-500" : ""}
            ${toast.type === "warning" ? "border-yellow-500" : ""}
            ${toast.type === "info" ? "border-blue-500" : ""}
          `}
          onClick={() => removeToast(toast.id)}
        >
          <div className="flex items-start gap-2">
            {toast.type && (
              <div className="mt-0.5">
                {toast.type === "success" && <span className="text-green-500">✓</span>}
                {toast.type === "error" && <span className="text-red-500">✕</span>}
                {toast.type === "warning" && <span className="text-yellow-500">⚠</span>}
                {toast.type === "info" && <span className="text-blue-500">ℹ</span>}
              </div>
            )}
            <div className="flex-1 text-sm">{toast.message}</div>
          </div>
        </div>
      ))}
    </div>
  );
}

// Export a toast function for convenience
export function toast(message: string, options?: { type?: Toast["type"]; duration?: number }) {
  // This will be used via context
  console.log("Toast:", message, options);
}
