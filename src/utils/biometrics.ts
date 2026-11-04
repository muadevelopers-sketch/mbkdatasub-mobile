import * as LocalAuthentication from 'expo-local-authentication';
import { Platform } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface MobileBiometricInfo {
  isAvailable: boolean;
  isEnrolled: boolean;
  biometricType: 'face-id' | 'touch-id' | 'fingerprint' | 'none';
  sensorName: string;
  shortName: string;
  payPromptText: string;
  loginPromptText: string;
}

export const getMobileBiometricInfo = async (): Promise<MobileBiometricInfo> => {
  try {
    const hasHardware = await LocalAuthentication.hasHardwareAsync();
    const isEnrolled = await LocalAuthentication.isEnrolledAsync();
    const types = await LocalAuthentication.supportedAuthenticationTypesAsync();

    const isFace = types.includes(LocalAuthentication.AuthenticationType.FACIAL_RECOGNITION);
    const isFingerprint = types.includes(LocalAuthentication.AuthenticationType.FINGERPRINT);

    if (Platform.OS === 'ios') {
      if (isFace) {
        return {
          isAvailable: hasHardware,
          isEnrolled,
          biometricType: 'face-id',
          sensorName: 'Apple Face ID',
          shortName: 'Face ID',
          payPromptText: '1-Tap Pay with Apple Face ID',
          loginPromptText: 'Sign In with Apple Face ID',
        };
      }
      return {
        isAvailable: hasHardware,
        isEnrolled,
        biometricType: 'touch-id',
        sensorName: 'Apple Touch ID',
        shortName: 'Touch ID',
        payPromptText: '1-Tap Pay with Touch ID',
        loginPromptText: 'Sign In with Touch ID',
      };
    }

    // Android
    return {
      isAvailable: hasHardware,
      isEnrolled,
      biometricType: isFingerprint ? 'fingerprint' : 'none',
      sensorName: 'Biometric / Fingerprint',
      shortName: 'Fingerprint',
      payPromptText: '1-Tap Pay with Fingerprint',
      loginPromptText: 'Sign In with Fingerprint',
    };
  } catch {
    return {
      isAvailable: false,
      isEnrolled: false,
      biometricType: 'none',
      sensorName: 'Biometrics',
      shortName: 'Biometrics',
      payPromptText: '1-Tap Pay with Biometrics',
      loginPromptText: 'Sign In with Biometrics',
    };
  }
};

export const promptBiometricAuth = async (
  promptMessage: string = 'Authorize with your device biometrics'
): Promise<boolean> => {
  try {
    const hasHardware = await LocalAuthentication.hasHardwareAsync();
    if (!hasHardware) return false;

    const res = await LocalAuthentication.authenticateAsync({
      promptMessage,
      cancelLabel: 'Use PIN Instead',
      fallbackLabel: 'Enter PIN',
      disableDeviceFallback: false,
    });

    return res.success;
  } catch (err) {
    console.warn('[Local Biometric Auth Error]', err);
    return false;
  }
};

export const enableMobileBiometrics = async (
  userId: string | number,
  pin: string,
  identifier?: string
): Promise<void> => {
  try {
    const uid = String(userId);
    await AsyncStorage.setItem(`mbk_bio_enabled_${uid}`, 'true');
    await AsyncStorage.setItem(`mbk_bio_pin_${uid}`, pin);
    await AsyncStorage.setItem('mbk_bio_last_uid', uid);
    await AsyncStorage.setItem('mbk_bio_global_pin', pin);
    await AsyncStorage.setItem('mbk_bio_enabled_global', 'true');
    if (identifier) {
      await AsyncStorage.setItem('mbk_bio_last_identifier', identifier);
    }
  } catch (e) {
    console.warn('[Enable Mobile Biometrics Error]', e);
  }
};

export const getStoredBiometricPin = async (
  userId?: string | number
): Promise<{ pin: string | null; identifier: string | null; isEnabled: boolean }> => {
  try {
    let uid = userId ? String(userId) : await AsyncStorage.getItem('mbk_bio_last_uid');
    let pin: string | null = null;
    let isEnabled = false;

    if (uid) {
      const userEnabled = await AsyncStorage.getItem(`mbk_bio_enabled_${uid}`);
      if (userEnabled === 'true') {
        pin = await AsyncStorage.getItem(`mbk_bio_pin_${uid}`);
        isEnabled = true;
      }
    }

    // Fallback to global PIN
    if (!pin) {
      const globalEnabled = await AsyncStorage.getItem('mbk_bio_enabled_global');
      if (globalEnabled === 'true') {
        pin = await AsyncStorage.getItem('mbk_bio_global_pin');
        isEnabled = !!pin;
      }
    }

    let identifier = await AsyncStorage.getItem('mbk_bio_last_identifier');
    if (!identifier) {
      identifier = await AsyncStorage.getItem('mbk_mobile_identifier');
    }

    return { pin, identifier, isEnabled };
  } catch {
    return { pin: null, identifier: null, isEnabled: false };
  }
};

export const disableMobileBiometrics = async (userId?: string | number): Promise<void> => {
  try {
    if (userId) {
      const uid = String(userId);
      await AsyncStorage.removeItem(`mbk_bio_enabled_${uid}`);
      await AsyncStorage.removeItem(`mbk_bio_pin_${uid}`);
    }
    await AsyncStorage.removeItem('mbk_bio_enabled_global');
    await AsyncStorage.removeItem('mbk_bio_global_pin');
  } catch (e) {
    console.warn('[Disable Mobile Biometrics Error]', e);
  }
};

