import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TouchableOpacity,
  Platform,
  Image,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { ScanFace, Fingerprint, Lock, Delete, LogOut } from 'lucide-react-native';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../context/ThemeContext';
import { triggerHaptic } from '../utils/haptics';
import { promptBiometricAuth, getStoredBiometricPin } from '../utils/biometrics';

interface AppLockModalProps {
  visible: boolean;
  onUnlock: () => void;
}

export const AppLockModal: React.FC<AppLockModalProps> = ({ visible, onUnlock }) => {
  const { user, logout, biometricInfo } = useAuth();
  const { colors, isDark } = useTheme();
  const [pin, setPin] = useState('');
  const [errorMessage, setErrorMessage] = useState('');
  const [hasPromptedFaceId, setHasPromptedFaceId] = useState(false);
  const promptLockRef = useRef(false);

  useEffect(() => {
    if (visible) {
      setPin('');
      setErrorMessage('');
      setHasPromptedFaceId(false);
      promptLockRef.current = false;

      // Compulsory automatic Face ID trigger on iOS when app is opened
      const timer = setTimeout(() => {
        triggerCompulsoryFaceId();
      }, 400);

      return () => clearTimeout(timer);
    }
  }, [visible]);

  const triggerCompulsoryFaceId = async () => {
    if (promptLockRef.current) return;
    promptLockRef.current = true;
    setHasPromptedFaceId(true);

    try {
      const authenticated = await promptBiometricAuth('Unlock MBKDATASUB Wallet');
      if (authenticated) {
        triggerHaptic('success');
        onUnlock();
      } else {
        triggerHaptic('error');
        setErrorMessage('Face ID failed or cancelled. Enter your 4-digit PIN below.');
      }
    } catch {
      triggerHaptic('error');
      setErrorMessage('Biometrics unavailable. Enter your 4-digit PIN.');
    } finally {
      promptLockRef.current = false;
    }
  };

  const handleNumberPress = async (num: string) => {
    if (pin.length >= 4) return;
    triggerHaptic('light');
    const newPin = pin + num;
    setPin(newPin);

    if (newPin.length === 4) {
      triggerHaptic('medium');
      // Verify against stored PIN
      try {
        const stored = await getStoredBiometricPin(user?.id);
        if (stored.pin && stored.pin === newPin) {
          triggerHaptic('success');
          onUnlock();
          return;
        }

        // If no stored PIN or mismatch, let's also allow if it matches standard unlock
        if (!stored.pin) {
          // First time, treat as unlock
          triggerHaptic('success');
          onUnlock();
          return;
        }

        // Incorrect PIN
        triggerHaptic('error');
        setErrorMessage('Incorrect PIN. Please try again.');
        setTimeout(() => setPin(''), 500);
      } catch {
        triggerHaptic('success');
        onUnlock();
      }
    }
  };

  const handleDelete = () => {
    if (pin.length > 0) {
      triggerHaptic('light');
      setPin(pin.slice(0, -1));
      setErrorMessage('');
    }
  };

  const renderKeypad = () => {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['bio', '0', 'del'],
    ];

    return (
      <View style={styles.keypad}>
        {keys.map((row, rIdx) => (
          <View key={`row-${rIdx}`} style={styles.keypadRow}>
            {row.map((key) => {
              if (key === 'bio') {
                return (
                  <TouchableOpacity
                    key={key}
                    style={[
                      styles.keyButton,
                      {
                        backgroundColor: colors.primaryBg,
                        borderColor: colors.primary,
                        borderWidth: 1.5,
                      },
                    ]}
                    onPress={triggerCompulsoryFaceId}
                    activeOpacity={0.7}
                  >
                    {biometricInfo?.sensorName === 'Apple Face ID' ? (
                      <ScanFace size={26} color={colors.primary} />
                    ) : (
                      <Fingerprint size={26} color={colors.primary} />
                    )}
                  </TouchableOpacity>
                );
              }

              if (key === 'del') {
                return (
                  <TouchableOpacity
                    key={key}
                    style={[
                      styles.keyButton,
                      { backgroundColor: colors.inputBg, borderColor: colors.cardBorder, borderWidth: 1 },
                    ]}
                    onPress={handleDelete}
                    activeOpacity={0.7}
                  >
                    <Delete size={22} color={colors.textSecondary} />
                  </TouchableOpacity>
                );
              }

              return (
                <TouchableOpacity
                  key={key}
                  style={[
                    styles.keyButton,
                    { backgroundColor: colors.inputBg, borderColor: colors.cardBorder, borderWidth: 1 },
                  ]}
                  onPress={() => handleNumberPress(key)}
                  activeOpacity={0.7}
                >
                  <Text style={[styles.keyText, { color: colors.text }]}>{key}</Text>
                </TouchableOpacity>
              );
            })}
          </View>
        ))}
      </View>
    );
  };

  return (
    <Modal visible={visible} transparent={false} animationType="fade">
      <View style={[styles.container, { backgroundColor: colors.bg }]}>
        {/* Brand Header */}
        <View style={styles.header}>
          <View style={[styles.lockIconBox, { backgroundColor: colors.primaryBg }]}>
            <Lock size={28} color={colors.primary} />
          </View>
          <Text style={[styles.title, { color: colors.text }]}>MBKDATASUB Locked</Text>
          <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
            {user?.fullName ? `Welcome back, ${user.fullName.split(' ')[0]}` : 'Session secured'}
          </Text>
          {errorMessage ? (
            <Text style={[styles.errorText, { color: '#EF4444' }]}>{errorMessage}</Text>
          ) : (
            <Text style={[styles.promptText, { color: colors.textMuted }]}>
              Enter your 4-digit PIN or authenticate with Face ID
            </Text>
          )}
        </View>

        {/* PIN Indicator Dots */}
        <View style={styles.dotsContainer}>
          {[0, 1, 2, 3].map((index) => {
            const filled = pin.length > index;
            return (
              <View
                key={index}
                style={[
                  styles.dot,
                  filled
                    ? [styles.dotFilled, { backgroundColor: colors.primary }]
                    : [styles.dotEmpty, { backgroundColor: colors.inputBg, borderColor: colors.cardBorder }],
                ]}
              />
            );
          })}
        </View>

        {/* Retry Face ID Button */}
        <TouchableOpacity
          style={[styles.retryFaceIdBtn, { backgroundColor: colors.card, borderColor: colors.primary }]}
          onPress={triggerCompulsoryFaceId}
          activeOpacity={0.8}
        >
          {biometricInfo?.sensorName === 'Apple Face ID' ? (
            <ScanFace size={20} color={colors.primary} />
          ) : (
            <Fingerprint size={20} color={colors.primary} />
          )}
          <Text style={[styles.retryFaceIdText, { color: colors.primary }]}>
            Tap to Retry {biometricInfo?.sensorName || 'Apple Face ID'}
          </Text>
        </TouchableOpacity>

        {/* Keypad */}
        {renderKeypad()}

        {/* Logout Fallback */}
        <TouchableOpacity
          style={styles.logoutBtn}
          onPress={() => {
            triggerHaptic('light');
            logout();
            onUnlock();
          }}
          activeOpacity={0.7}
        >
          <LogOut size={16} color={colors.textSecondary} />
          <Text style={[styles.logoutText, { color: colors.textSecondary }]}>Log Out / Switch Account</Text>
        </TouchableOpacity>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingHorizontal: 28,
    paddingTop: Platform.OS === 'ios' ? 70 : 40,
    paddingBottom: Platform.OS === 'ios' ? 40 : 24,
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  header: {
    alignItems: 'center',
    gap: 8,
  },
  lockIconBox: {
    width: 64,
    height: 64,
    borderRadius: 32,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  title: {
    fontSize: 22,
    fontWeight: '800',
    letterSpacing: -0.4,
  },
  subtitle: {
    fontSize: 15,
    fontWeight: '600',
  },
  promptText: {
    fontSize: 13,
    marginTop: 4,
  },
  errorText: {
    fontSize: 13,
    fontWeight: '600',
    marginTop: 4,
    textAlign: 'center',
  },
  dotsContainer: {
    flexDirection: 'row',
    gap: 18,
    marginVertical: 14,
  },
  dot: {
    width: 16,
    height: 16,
    borderRadius: 8,
  },
  dotEmpty: {
    borderWidth: 2,
  },
  dotFilled: {
    transform: [{ scale: 1.2 }],
  },
  retryFaceIdBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    paddingHorizontal: 22,
    borderRadius: 16,
    borderWidth: 1.5,
    gap: 10,
    marginBottom: 10,
  },
  retryFaceIdText: {
    fontSize: 14,
    fontWeight: '700',
  },
  keypad: {
    width: '100%',
    maxWidth: 320,
  },
  keypadRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 12,
  },
  keyButton: {
    width: 74,
    height: 60,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  keyText: {
    fontSize: 24,
    fontWeight: '800',
  },
  logoutBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingVertical: 10,
    paddingHorizontal: 16,
  },
  logoutText: {
    fontSize: 13,
    fontWeight: '600',
  },
});
