import React, { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { triggerHaptic } from '../utils/haptics';

export interface ThemeColors {
  bg: string;
  surface: string;
  card: string;
  cardBorder: string;
  text: string;
  textSecondary: string;
  textMuted: string;
  primary: string;
  primaryBg: string;
  accent: string;
  border: string;
  inputBg: string;
  inputBorder: string;
  success: string;
  successBg: string;
  warning: string;
  warningBg: string;
  error: string;
  errorBg: string;
  statusBar: 'light' | 'dark';
}

export const darkColors: ThemeColors = {
  bg: '#0A0F1D',
  surface: '#131C31',
  card: '#1E293B',
  cardBorder: '#334155',
  text: '#F8FAFC',
  textSecondary: '#94A3B8',
  textMuted: '#64748B',
  primary: '#38BDF8',
  primaryBg: 'rgba(56, 189, 248, 0.12)',
  accent: '#2563EB',
  border: '#334155',
  inputBg: '#1E293B',
  inputBorder: '#334155',
  success: '#10B981',
  successBg: 'rgba(16, 185, 129, 0.15)',
  warning: '#F59E0B',
  warningBg: 'rgba(245, 158, 11, 0.15)',
  error: '#EF4444',
  errorBg: 'rgba(239, 68, 68, 0.15)',
  statusBar: 'light',
};

export const lightColors: ThemeColors = {
  bg: '#F8FAFC',
  surface: '#FFFFFF',
  card: '#FFFFFF',
  cardBorder: '#E2E8F0',
  text: '#0F172A',
  textSecondary: '#475569',
  textMuted: '#94A3B8',
  primary: '#0284C7',
  primaryBg: '#E0F2FE',
  accent: '#2563EB',
  border: '#E2E8F0',
  inputBg: '#F1F5F9',
  inputBorder: '#CBD5E1',
  success: '#059669',
  successBg: '#D1FAE5',
  warning: '#D97706',
  warningBg: '#FEF3C7',
  error: '#DC2626',
  errorBg: '#FEE2E2',
  statusBar: 'dark',
};

interface ThemeContextType {
  theme: 'dark' | 'light';
  isDark: boolean;
  colors: ThemeColors;
  toggleTheme: () => void;
  setTheme: (t: 'dark' | 'light') => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [theme, setThemeState] = useState<'dark' | 'light'>('dark');

  useEffect(() => {
    loadTheme();
  }, []);

  const loadTheme = async () => {
    try {
      const saved = await AsyncStorage.getItem('mbk_app_theme');
      if (saved === 'light' || saved === 'dark') {
        setThemeState(saved);
      }
    } catch {}
  };

  const toggleTheme = async () => {
    triggerHaptic('medium');
    const nextTheme = theme === 'dark' ? 'light' : 'dark';
    setThemeState(nextTheme);
    try {
      await AsyncStorage.setItem('mbk_app_theme', nextTheme);
    } catch {}
  };

  const setTheme = async (t: 'dark' | 'light') => {
    setThemeState(t);
    try {
      await AsyncStorage.setItem('mbk_app_theme', t);
    } catch {}
  };

  const colors = theme === 'dark' ? darkColors : lightColors;

  return (
    <ThemeContext.Provider
      value={{
        theme,
        isDark: theme === 'dark',
        colors,
        toggleTheme,
        setTheme,
      }}
    >
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within a ThemeProvider');
  return context;
};
