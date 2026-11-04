import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TouchableOpacity,
  Pressable,
  ActivityIndicator,
  Platform,
} from 'react-native';
import { ScanFace, Fingerprint, Delete, ShieldCheck, X } from 'lucide-react-native';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import { formatNaira } from '../utils/formatters';
import { triggerHaptic } from '../utils/haptics';
import {
  promptBiometricAuth,
  getStoredBiometricPin,
  getMobileBiometricInfo,
  enableMobileBiometrics,
  MobileBiometricInfo,
} from '../utils/biometrics';

interface BiometricPinModalProps {
  visible: boolean;
  onClose: () => void;
  onSuccess: (pin: string) => void;
  title: string;
  amount: number;
  recipient?: string;
  subtitle?: string;
  loading?: boolean;
}

export const BiometricPinModal: React.FC<BiometricPinModalProps> = ({
  visible,
  onClose,
  onSuccess,
  title,
  amount,
  recipient,
  subtitle,
  loading = false,
}) => {
  const { colors, isDark } = useTheme();
  const { user } = useAuth();
  const [pin, setPin] = useState<string>('');
  const [bioInfo, setBioInfo] = useState<MobileBiometricInfo | null>(null);
  const [bioNotice, setBioNotice] = useState<string | null>(null);

  useEffect(() => {
    if (visible) {
      setPin('');
      setBioNotice(null);
      checkBiometrics();
    }
  }, [visible]);

  const checkBiometrics = async () => {
    try {
      const info = await getMobileBiometricInfo();
      setBioInfo(info);
      const stored = await getStoredBiometricPin(user?.id);
      // If hardware is available and stored PIN exists, auto-prompt Face ID immediately
      if (stored.pin && info.isAvailable) {
        setTimeout(() => {
          handleBiometricAuth(stored.pin!);
        }, 350);
      }
    } catch {}
  };

  const handleBiometricAuth = async (autoPin?: string) => {
    try {
      const stored = await getStoredBiometricPin(user?.id);
      const pinToUse = autoPin || stored.pin;

      const authenticated = await promptBiometricAuth(
        `Authorize ${formatNaira(amount)} for ${title}`
      );

      if (authenticated) {
        triggerHaptic('success');
        if (pinToUse) {
          onSuccess(pinToUse);
        } else {
          // If no PIN stored yet, notify user to enter it once to link
          triggerHaptic('light');
          setBioNotice(
            `${bioInfo?.sensorName || 'Face ID'} verified! Enter your 4-digit PIN once to link it for 1-tap payments.`
          );
        }
      } else {
        triggerHaptic('error');
      }
    } catch {
      triggerHaptic('error');
    }
  };

  const handleNumberPress = async (num: string) => {
    if (pin.length >= 4) return;
    triggerHaptic('light');
    const newPin = pin + num;
    setPin(newPin);
    if (newPin.length === 4) {
      triggerHaptic('medium');
      // Save for future Face ID authorizations seamlessly
      try {
        await enableMobileBiometrics(user?.id || 'current', newPin);
      } catch {}
      onSuccess(newPin);
    }
  };

  const handleDelete = () => {
    if (pin.length > 0) {
      triggerHaptic('light');
      setPin(pin.slice(0, -1));
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
                    onPress={() => handleBiometricAuth()}
                    activeOpacity={0.7}
                  >
                    {bioInfo?.sensorName === 'Apple Face ID' ? (
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
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={onClose}
    >
      <Pressable style={styles.overlay} onPress={onClose}>
        <Pressable
          style={[
            styles.modalContent,
            { backgroundColor: colors.surface, borderTopColor: colors.cardBorder },
          ]}
          onPress={(e) => e.stopPropagation()}
        >
          <View style={styles.header}>
            <View style={styles.headerLeft}>
              <View style={[styles.iconCircle, { backgroundColor: colors.primaryBg }]}>
                <ShieldCheck size={20} color={colors.primary} />
              </View>
              <Text style={[styles.headerTitle, { color: colors.text }]}>Authorize Payment</Text>
            </View>
            <TouchableOpacity
              onPress={onClose}
              style={[styles.closeBtn, { backgroundColor: colors.inputBg }]}
              hitSlop={10}
            >
              <X size={18} color={colors.textSecondary} />
            </TouchableOpacity>
          </View>

          {/* Transaction Summary Card */}
          <View
            style={[
              styles.summaryCard,
              { backgroundColor: colors.card, borderColor: colors.cardBorder },
            ]}
          >
            <Text style={[styles.summaryTitle, { color: colors.textSecondary }]}>{title}</Text>
            {recipient ? (
              <Text style={[styles.summaryRecipient, { color: colors.text }]}>{recipient}</Text>
            ) : null}
            {subtitle ? (
              <Text style={[styles.summarySub, { color: colors.textMuted }]}>{subtitle}</Text>
            ) : null}
            <Text style={[styles.summaryAmount, { color: colors.primary }]}>
              {formatNaira(amount)}
            </Text>
          </View>

          {/* Biometric 1-Tap Quick Trigger Banner */}
          <TouchableOpacity
            style={[
              styles.quickBioBanner,
              { backgroundColor: colors.primaryBg, borderColor: colors.primary },
            ]}
            onPress={() => handleBiometricAuth()}
            activeOpacity={0.8}
          >
            {bioInfo?.sensorName === 'Apple Face ID' ? (
              <ScanFace size={22} color={colors.primary} />
            ) : (
              <Fingerprint size={22} color={colors.primary} />
            )}
            <Text style={[styles.quickBioText, { color: colors.primary }]}>
              1-Tap Authorize with {bioInfo?.sensorName || 'Face ID'}
            </Text>
          </TouchableOpacity>

          {/* Interactive Bio Notice if PIN not yet linked */}
          {bioNotice ? (
            <View
              style={[
                styles.bioNoticeBanner,
                { backgroundColor: colors.primaryBg, borderColor: colors.primary },
              ]}
            >
              <ShieldCheck size={18} color={colors.primary} />
              <Text style={[styles.bioNoticeText, { color: colors.primary }]}>{bioNotice}</Text>
            </View>
          ) : null}

          {/* PIN Indicator Dots */}
          <View style={styles.pinSection}>
            <Text style={[styles.pinPrompt, { color: colors.textSecondary }]}>
              Or Enter 4-Digit Security PIN
            </Text>
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
          </View>

          {/* Loading Indicator or Keypad */}
          {loading ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color={colors.primary} />
              <Text style={[styles.loadingText, { color: colors.textSecondary }]}>
                Processing Secure Transaction...
              </Text>
            </View>
          ) : (
            renderKeypad()
          )}
        </Pressable>
      </Pressable>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(15, 23, 42, 0.75)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    paddingHorizontal: 22,
    paddingTop: 18,
    paddingBottom: Platform.OS === 'ios' ? 38 : 22,
    borderTopWidth: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 14,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  iconCircle: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 17,
    fontWeight: '800',
  },
  closeBtn: {
    padding: 6,
    borderRadius: 16,
  },
  summaryCard: {
    borderRadius: 18,
    padding: 14,
    alignItems: 'center',
    marginBottom: 14,
    borderWidth: 1,
  },
  summaryTitle: {
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  summaryRecipient: {
    fontSize: 15,
    fontWeight: '800',
    marginTop: 2,
  },
  summarySub: {
    fontSize: 12,
    marginTop: 2,
  },
  summaryAmount: {
    fontSize: 26,
    fontWeight: '800',
    marginTop: 6,
  },
  quickBioBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 14,
    paddingVertical: 12,
    borderWidth: 1.5,
    gap: 10,
    marginBottom: 16,
  },
  quickBioText: {
    fontSize: 14,
    fontWeight: '700',
  },
  bioNoticeBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 12,
    borderWidth: 1,
    gap: 8,
    marginBottom: 14,
  },
  bioNoticeText: {
    fontSize: 12,
    fontWeight: '600',
    flex: 1,
    lineHeight: 16,
  },
  pinSection: {
    alignItems: 'center',
    marginBottom: 16,
  },
  pinPrompt: {
    fontSize: 12,
    fontWeight: '600',
    marginBottom: 10,
  },
  dotsContainer: {
    flexDirection: 'row',
    gap: 14,
  },
  dot: {
    width: 14,
    height: 14,
    borderRadius: 7,
  },
  dotEmpty: {
    borderWidth: 2,
  },
  dotFilled: {
    transform: [{ scale: 1.15 }],
  },
  keypad: {
    width: '100%',
    paddingBottom: 6,
  },
  keypadRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 10,
  },
  keyButton: {
    width: 72,
    height: 56,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  keyText: {
    fontSize: 22,
    fontWeight: '800',
  },
  loadingContainer: {
    height: 220,
    justifyContent: 'center',
    alignItems: 'center',
    gap: 14,
  },
  loadingText: {
    fontSize: 14,
    fontWeight: '600',
  },
});
