import React, { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { apiClient } from '../api/client';
import {
  promptBiometricAuth,
  getStoredBiometricPin,
  enableMobileBiometrics,
  disableMobileBiometrics,
  getMobileBiometricInfo,
  MobileBiometricInfo,
} from '../utils/biometrics';
import { triggerHaptic } from '../utils/haptics';

export interface MobileUser {
  id: number | string;
  fullName: string;
  email: string;
  phone: string;
  role: string;
  kycTier: number;
  referralCode: string;
  hasTransactionPin: boolean;
}

export interface BankAccount {
  bankName: string;
  accountNumber: string;
  accountName: string;
  provider?: string;
  type?: string;
}

export interface MobileWallet {
  balance: number;
  totalFunded: number;
  totalSpent: number;
  accounts: BankAccount[];
  virtualAccount: BankAccount;
}

export interface MobileTransaction {
  id: string;
  reference: string;
  title: string;
  serviceCode: string;
  type: 'credit' | 'debit';
  amount: number;
  status: 'success' | 'pending' | 'failed';
  date: string;
  recipient?: string;
  description?: string;
  balanceAfter?: number;
}

interface AuthContextType {
  user: MobileUser | null;
  wallet: MobileWallet;
  transactions: MobileTransaction[];
  token: string | null;
  isLoading: boolean;
  biometricInfo: MobileBiometricInfo | null;
  isBiometricsActive: boolean;
  login: (phoneOrEmail: string, pass: string) => Promise<{ success: boolean; message?: string }>;
  loginWithPin: (pin: string, identifier?: string) => Promise<{ success: boolean; message?: string }>;
  loginWithBiometrics: () => Promise<{ success: boolean; message?: string }>;
  enableBiometricsWithPin: (pin: string) => Promise<{ success: boolean; message?: string }>;
  disableBiometrics: () => Promise<void>;
  generateDedicatedAccounts: () => Promise<{ success: boolean; message?: string }>;
  register: (data: any) => Promise<{ success: boolean; message?: string }>;
  setTransactionPin: (pin: string) => Promise<boolean>;
  refreshData: () => Promise<void>;
  logout: () => Promise<void>;
}

const defaultWallet: MobileWallet = {
  balance: 0,
  totalFunded: 0,
  totalSpent: 0,
  accounts: [],
  virtualAccount: { bankName: 'PalmPay', accountNumber: '', accountName: '', type: 'palmpay' },
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<MobileUser | null>(null);
  const [wallet, setWallet] = useState<MobileWallet>(defaultWallet);
  const [transactions, setTransactions] = useState<MobileTransaction[]>([]);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [biometricInfo, setBiometricInfo] = useState<MobileBiometricInfo | null>(null);
  const [isBiometricsActive, setIsBiometricsActive] = useState(false);

  useEffect(() => {
    bootstrapAuth();
  }, []);

  const bootstrapAuth = async () => {
    try {
      const bio = await getMobileBiometricInfo();
      setBiometricInfo(bio);

      const stored = await getStoredBiometricPin();
      if (stored.pin) {
        setIsBiometricsActive(true);
      }

      const savedToken = await AsyncStorage.getItem('mbk_mobile_token');
      if (savedToken) {
        setToken(savedToken);
        await fetchUserData();
      }
    } catch (e) {
      console.warn('[Bootstrap Auth Notice]', e);
    } finally {
      setIsLoading(false);
    }
  };

  const fetchUserData = async () => {
    try {
      const [meRes, walletRes, txRes] = await Promise.all([
        apiClient.get('/auth/me').catch(() => null),
        apiClient.get('/wallet').catch(() => null),
        apiClient.get('/wallet/transactions').catch(() => ({ data: { transactions: [] } })),
      ]);

      if (meRes?.data?.user) {
        const u = meRes.data.user;
        setUser({
          id: u.id,
          fullName: u.fullName,
          phone: u.phone,
          email: u.email,
          role: u.role,
          kycTier: u.kycTier || 1,
          referralCode: u.referralCode || 'MBK1000',
          hasTransactionPin: !!u.hasTransactionPin,
        });
      }

      if (walletRes?.data?.success && walletRes.data.wallet) {
        const w = walletRes.data.wallet;
        const rawAccounts: BankAccount[] =
          w.accounts && w.accounts.length > 0
            ? w.accounts
            : (w.virtualAccount ? [w.virtualAccount] : []);

        const palmpay = rawAccounts.find(
          (a) => (a.bankName || '').toLowerCase().includes('palm') || a.type === 'palmpay'
        ) || {
          bankName: 'PalmPay',
          accountNumber: '',
          accountName: meRes?.data?.user?.fullName || 'MBK Customer',
          type: 'palmpay',
        };

        const paga = rawAccounts.find(
          (a) => (a.bankName || '').toLowerCase().includes('paga') || a.type === 'paga'
        ) || {
          bankName: 'Paga',
          accountNumber: '',
          accountName: meRes?.data?.user?.fullName || 'MBK Customer',
          type: 'paga',
        };

        const accounts = [palmpay, paga];

        setWallet({
          balance: Number(w.balance || 0),
          totalFunded: Number(w.totalFunded || 0),
          totalSpent: Number(w.totalSpent || 0),
          accounts,
          virtualAccount: palmpay.accountNumber ? palmpay : (paga.accountNumber ? paga : palmpay),
        });

        // Trigger background generation if accounts are not assigned yet
        const hasValidAccounts = accounts.some((a) => a.accountNumber && a.accountNumber.length > 6);
        if (!hasValidAccounts) {
          apiClient.post('/wallet/generate-virtual-account').then(() => {
            setTimeout(fetchUserData, 2500);
          }).catch(() => {});
        }
      }

      if (txRes?.data?.transactions) {
        setTransactions(txRes.data.transactions);
      }
    } catch (e) {
      console.warn('[Fetch User Data Notice]', e);
    }
  };

  const login = async (phoneOrEmail: string, pass: string) => {
    try {
      const res = await apiClient.post('/auth/login', {
        identifier: phoneOrEmail.trim(),
        password: pass,
      });

      if (res.data?.success && res.data.token) {
        await AsyncStorage.setItem('mbk_mobile_token', res.data.token);
        await AsyncStorage.setItem('mbk_mobile_identifier', phoneOrEmail.trim());
        await AsyncStorage.setItem('mbk_bio_last_identifier', phoneOrEmail.trim());
        setToken(res.data.token);

        const u = res.data.user;
        setUser({
          id: u.id,
          fullName: u.fullName,
          phone: u.phone,
          email: u.email,
          role: u.role,
          kycTier: u.kycTier || 1,
          referralCode: u.referralCode || 'MBK1000',
          hasTransactionPin: !!u.hasTransactionPin,
        });

        await AsyncStorage.setItem('mbk_bio_last_uid', String(u.id));

        await fetchUserData();
        triggerHaptic('success');
        return { success: true };
      }
      return { success: false, message: res.data?.message || 'Login failed.' };
    } catch (err: any) {
      triggerHaptic('error');
      return {
        success: false,
        message: err.response?.data?.message || err.message || 'Invalid email or password.',
      };
    }
  };

  const loginWithPin = async (pin: string, identifier?: string) => {
    try {
      const idToUse =
        identifier ||
        (await AsyncStorage.getItem('mbk_mobile_identifier')) ||
        (user?.phone || user?.email);

      if (!idToUse) {
        return { success: false, message: 'Please enter your phone number or email first.' };
      }

      const res = await apiClient.post('/auth/login-pin', {
        identifier: idToUse,
        pin,
      });

      if (res.data?.success && res.data.token) {
        await AsyncStorage.setItem('mbk_mobile_token', res.data.token);
        await AsyncStorage.setItem('mbk_mobile_identifier', idToUse);
        setToken(res.data.token);

        const u = res.data.user;
        setUser({
          id: u.id,
          fullName: u.fullName,
          phone: u.phone,
          email: u.email,
          role: u.role,
          kycTier: u.kycTier || 1,
          referralCode: u.referralCode || 'MBK1000',
          hasTransactionPin: true,
        });

        // Store biometrics credentials for this device
        await enableMobileBiometrics(u.id, pin, idToUse);
        setIsBiometricsActive(true);

        await fetchUserData();
        triggerHaptic('success');
        return { success: true };
      }
      return { success: false, message: res.data?.message || 'Invalid PIN.' };
    } catch (err: any) {
      triggerHaptic('error');
      return {
        success: false,
        message: err.response?.data?.message || err.message || 'Invalid 4-digit security PIN.',
      };
    }
  };

  const enableBiometricsWithPin = async (
    pin: string
  ): Promise<{ success: boolean; message?: string }> => {
    try {
      const bio = await getMobileBiometricInfo();
      if (!bio.isAvailable) {
        return { success: false, message: 'Biometrics sensor not available on this device.' };
      }

      const authenticated = await promptBiometricAuth(
        `Link ${bio.sensorName} for 1-Tap Login and Checkout`
      );

      if (authenticated) {
        const uid = user?.id || (await AsyncStorage.getItem('mbk_bio_last_uid')) || '1';
        const idToUse =
          user?.phone ||
          user?.email ||
          (await AsyncStorage.getItem('mbk_mobile_identifier')) ||
          '';

        await enableMobileBiometrics(uid, pin, idToUse);
        setIsBiometricsActive(true);
        triggerHaptic('success');
        return { success: true, message: `${bio.sensorName} is now active!` };
      }
      return { success: false, message: 'Biometric authorization was cancelled.' };
    } catch (e: any) {
      return { success: false, message: e.message || 'Could not link biometrics.' };
    }
  };

  const loginWithBiometrics = async () => {
    try {
      const bio = await getMobileBiometricInfo();
      if (!bio.isAvailable) {
        return { success: false, message: 'Biometrics sensor not available on this device.' };
      }

      const authenticated = await promptBiometricAuth(
        `Sign in to MBKDATASUB with ${bio.sensorName}`
      );

      if (!authenticated) {
        return { success: false, message: 'Biometric authorization was cancelled.' };
      }

      const stored = await getStoredBiometricPin();
      if (stored.pin && stored.identifier) {
        return await loginWithPin(stored.pin, stored.identifier);
      }

      // Check if existing token exists
      const savedToken = await AsyncStorage.getItem('mbk_mobile_token');
      if (savedToken) {
        setToken(savedToken);
        await fetchUserData();
        triggerHaptic('success');
        return { success: true };
      }

      return {
        success: false,
        message: `${bio.sensorName} verified! Log in with your password or PIN once to activate 1-tap sign in.`,
      };
    } catch (e: any) {
      return { success: false, message: e.message || 'Biometric verification failed.' };
    }
  };

  const register = async (data: any) => {
    try {
      const res = await apiClient.post('/auth/register', data);
      if (res.data?.success && res.data.token) {
        await AsyncStorage.setItem('mbk_mobile_token', res.data.token);
        if (data.phone) {
          await AsyncStorage.setItem('mbk_mobile_identifier', data.phone);
          await AsyncStorage.setItem('mbk_bio_last_identifier', data.phone);
        }
        setToken(res.data.token);

        const u = res.data.user;
        setUser({
          id: u.id,
          fullName: u.fullName,
          phone: u.phone,
          email: u.email,
          role: u.role,
          kycTier: u.kycTier || 1,
          referralCode: u.referralCode || 'MBK1000',
          hasTransactionPin: false,
        });

        await AsyncStorage.setItem('mbk_bio_last_uid', String(u.id));

        await fetchUserData();
        triggerHaptic('success');
        return { success: true };
      }
      return { success: false, message: res.data?.message || 'Registration failed.' };
    } catch (err: any) {
      triggerHaptic('error');
      return {
        success: false,
        message: err.response?.data?.message || err.message || 'Could not create account.',
      };
    }
  };

  const setTransactionPin = async (pin: string): Promise<boolean> => {
    try {
      const res = await apiClient.post('/auth/set-pin', { pin });
      if (res.data?.success) {
        if (user) {
          setUser({ ...user, hasTransactionPin: true });
          await enableMobileBiometrics(user.id, pin, user.phone || user.email);
          setIsBiometricsActive(true);
        }
        triggerHaptic('success');
        return true;
      }
      return false;
    } catch {
      return false;
    }
  };

  const generateDedicatedAccounts = async (): Promise<{ success: boolean; message?: string }> => {
    try {
      const res = await apiClient.post('/wallet/generate-virtual-account');
      await fetchUserData();
      if (res.data?.success) {
        return { success: true, message: 'Dedicated accounts generated successfully!' };
      }
      return { success: false, message: res.data?.message || 'Could not assign account.' };
    } catch (e: any) {
      await fetchUserData();
      return { success: false, message: e.response?.data?.message || 'Failed to generate accounts.' };
    }
  };

  const disableBiometrics = async () => {
    await disableMobileBiometrics(user?.id);
    setIsBiometricsActive(false);
  };

  const refreshData = async () => {
    await fetchUserData();
  };

  const logout = async () => {
    try {
      await AsyncStorage.removeItem('mbk_mobile_token');
      setToken(null);
      setUser(null);
      setWallet(defaultWallet);
      setTransactions([]);
      triggerHaptic('light');
    } catch {}
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        wallet,
        transactions,
        token,
        isLoading,
        biometricInfo,
        isBiometricsActive,
        login,
        loginWithPin,
        loginWithBiometrics,
        enableBiometricsWithPin,
        disableBiometrics,
        generateDedicatedAccounts,
        register,
        setTransactionPin,
        refreshData,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within an AuthProvider');
  return context;
};
