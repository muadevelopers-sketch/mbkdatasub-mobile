import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  StatusBar,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';;
import { LinearGradient } from 'expo-linear-gradient';
import { ShieldCheck, Delete, ScanFace, Fingerprint, CheckCircle2 } from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { triggerHaptic } from '../../utils/haptics';

export const PinSetupScreen = () => {
  const { setTransactionPin, biometricInfo } = useAuth();
  const [step, setStep] = useState<'create' | 'confirm' | 'success'>('create');
  const [firstPin, setFirstPin] = useState('');
  const [confirmPin, setConfirmPin] = useState('');
  const [errorMsg, setErrorMsg] = useState('');
  const [loading, setLoading] = useState(false);

  const activePin = step === 'create' ? firstPin : confirmPin;

  const handleKeyPress = async (key: string) => {
    if (activePin.length >= 4) return;
    triggerHaptic('light');

    const nextPin = activePin + key;

    if (step === 'create') {
      setFirstPin(nextPin);
      if (nextPin.length === 4) {
        triggerHaptic('medium');
        setTimeout(() => {
          setStep('confirm');
        }, 200);
      }
    } else if (step === 'confirm') {
      setConfirmPin(nextPin);
      if (nextPin.length === 4) {
        if (nextPin === firstPin) {
          triggerHaptic('success');
          await submitPin(nextPin);
        } else {
          triggerHaptic('error');
          setErrorMsg('PINs do not match. Please try again.');
          setTimeout(() => {
            setStep('create');
            setFirstPin('');
            setConfirmPin('');
            setErrorMsg('');
          }, 1200);
        }
      }
    }
  };

  const handleDelete = () => {
    triggerHaptic('light');
    if (step === 'create' && firstPin.length > 0) {
      setFirstPin(firstPin.slice(0, -1));
    } else if (step === 'confirm' && confirmPin.length > 0) {
      setConfirmPin(confirmPin.slice(0, -1));
    }
  };

  const submitPin = async (finalPin: string) => {
    setLoading(true);
    const ok = await setTransactionPin(finalPin);
    setLoading(false);
    if (ok) {
      setStep('success');
      triggerHaptic('success');
    } else {
      setErrorMsg('Could not save PIN. Please retry.');
      setStep('create');
      setFirstPin('');
      setConfirmPin('');
    }
  };

  const renderKeypad = () => {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return (
      <View style={styles.keypad}>
        {rows.map((row, rIdx) => (
          <View key={`row-${rIdx}`} style={styles.keypadRow}>
            {row.map((item, cIdx) => {
              if (item === '') {
                return <View key={`empty-${cIdx}`} style={styles.keyButton} />;
              }
              if (item === 'del') {
                return (
                  <TouchableOpacity
                    key={`del-${cIdx}`}
                    style={styles.keyButton}
                    onPress={handleDelete}
                    activeOpacity={0.6}
                  >
                    <Delete size={26} color="#94A3B8" />
                  </TouchableOpacity>
                );
              }
              return (
                <TouchableOpacity
                  key={`key-${item}`}
                  style={styles.keyButton}
                  onPress={() => handleKeyPress(item)}
                  activeOpacity={0.6}
                >
                  <Text style={styles.keyText}>{item}</Text>
                </TouchableOpacity>
              );
            })}
          </View>
        ))}
      </View>
    );
  };

  if (step === 'success') {
    return (
      <SafeAreaView style={styles.container}>
        <StatusBar barStyle="light-content" backgroundColor="#0F172A" />
        <View style={styles.successWrapper}>
          <View style={styles.successIconBox}>
            <CheckCircle2 size={64} color="#10B981" />
          </View>
          <Text style={styles.successTitle}>Security PIN Activated!</Text>
          <Text style={styles.successSubtitle}>
            Your 4-digit PIN and {biometricInfo?.sensorName || 'biometric'} security are now linked
            to your wallet for instant 1-tap checkout.
          </Text>

          {biometricInfo?.isAvailable && (
            <View style={styles.bioPromoCard}>
              {biometricInfo.sensorName === 'Apple Face ID' ? (
                <ScanFace size={32} color="#38BDF8" />
              ) : (
                <Fingerprint size={32} color="#38BDF8" />
              )}
              <Text style={styles.bioPromoText}>
                {biometricInfo.sensorName} enabled automatically for this device!
              </Text>
            </View>
          )}
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#0F172A" />
      <View style={styles.content}>
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.iconCircle}>
            <ShieldCheck size={28} color="#38BDF8" />
          </View>
          <Text style={styles.title}>
            {step === 'create' ? 'Create Transaction PIN' : 'Confirm Your PIN'}
          </Text>
          <Text style={styles.subtitle}>
            {step === 'create'
              ? 'Choose a 4-digit PIN to authorize purchases and logins'
              : 'Re-enter your 4-digit PIN to confirm'}
          </Text>
        </View>

        {/* Error notification */}
        {errorMsg ? (
          <View style={styles.errorBanner}>
            <Text style={styles.errorText}>{errorMsg}</Text>
          </View>
        ) : null}

        {/* PIN Indicators */}
        <View style={styles.dotsRow}>
          {[0, 1, 2, 3].map((idx) => {
            const filled = activePin.length > idx;
            return (
              <View
                key={idx}
                style={[styles.dot, filled ? styles.dotFilled : styles.dotEmpty]}
              />
            );
          })}
        </View>

        {/* Loading Indicator or Keypad */}
        {loading ? (
          <View style={styles.loadingBox}>
            <ActivityIndicator size="large" color="#38BDF8" />
            <Text style={styles.loadingText}>Securing your wallet...</Text>
          </View>
        ) : (
          renderKeypad()
        )}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0F172A',
  },
  content: {
    flex: 1,
    justifyContent: 'space-between',
    paddingHorizontal: 24,
    paddingTop: 40,
    paddingBottom: 24,
  },
  header: {
    alignItems: 'center',
  },
  iconCircle: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: 'rgba(56, 189, 248, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
    borderWidth: 1,
    borderColor: 'rgba(56, 189, 248, 0.3)',
  },
  title: {
    fontSize: 22,
    fontWeight: '800',
    color: '#F8FAFC',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 14,
    color: '#94A3B8',
    textAlign: 'center',
    marginTop: 8,
    paddingHorizontal: 20,
    lineHeight: 20,
  },
  errorBanner: {
    backgroundColor: 'rgba(239, 68, 68, 0.15)',
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(239, 68, 68, 0.3)',
  },
  errorText: {
    color: '#EF4444',
    fontSize: 13,
    fontWeight: '600',
    textAlign: 'center',
  },
  dotsRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 20,
    marginVertical: 20,
  },
  dot: {
    width: 18,
    height: 18,
    borderRadius: 9,
  },
  dotEmpty: {
    backgroundColor: '#1E293B',
    borderWidth: 2,
    borderColor: '#334155',
  },
  dotFilled: {
    backgroundColor: '#38BDF8',
    transform: [{ scale: 1.15 }],
  },
  keypad: {
    width: '100%',
  },
  keypadRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 16,
  },
  keyButton: {
    width: 76,
    height: 68,
    borderRadius: 20,
    backgroundColor: '#1E293B',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#334155',
  },
  keyText: {
    fontSize: 26,
    fontWeight: '700',
    color: '#F8FAFC',
  },
  loadingBox: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 250,
    gap: 16,
  },
  loadingText: {
    fontSize: 15,
    color: '#94A3B8',
    fontWeight: '500',
  },
  successWrapper: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 30,
  },
  successIconBox: {
    marginBottom: 20,
  },
  successTitle: {
    fontSize: 24,
    fontWeight: '800',
    color: '#F8FAFC',
    textAlign: 'center',
  },
  successSubtitle: {
    fontSize: 15,
    color: '#94A3B8',
    textAlign: 'center',
    marginTop: 10,
    lineHeight: 22,
  },
  bioPromoCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1E293B',
    padding: 16,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(56, 189, 248, 0.3)',
    marginTop: 30,
    gap: 14,
  },
  bioPromoText: {
    flex: 1,
    fontSize: 13,
    color: '#38BDF8',
    fontWeight: '600',
  },
});
