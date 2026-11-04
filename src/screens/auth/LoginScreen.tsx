import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  StatusBar,
  ScrollView,
  ActivityIndicator,
  Linking,
  Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';;
import { LinearGradient } from 'expo-linear-gradient';
import {
  Lock,
  Mail,
  Eye,
  EyeOff,
  ScanFace,
  Fingerprint,
  ArrowRight,
  ShieldAlert,
  ArrowLeft,
  KeyRound,
  Sun,
  Moon,
} from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { triggerHaptic } from '../../utils/haptics';
import { getStoredBiometricPin } from '../../utils/biometrics';
import { apiClient } from '../../api/client';

export const LoginScreen = ({ navigation }: any) => {
  const { login, loginWithPin, loginWithBiometrics, biometricInfo } = useAuth();
  const { colors, isDark, toggleTheme } = useTheme();
  const [authMode, setAuthMode] = useState<'password' | 'pin'>('password');
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [pin, setPin] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [supportPhone, setSupportPhone] = useState('2349047050681');

  useEffect(() => {
    checkStoredBiometrics();
    apiClient.get('/admin/branding').then((res) => {
      const p = res.data?.branding?.supportWhatsapp || res.data?.branding?.supportPhone || res.data?.supportWhatsapp || res.data?.supportPhone;
      if (p) setSupportPhone(p.replace(/[^0-9]/g, ''));
    }).catch(() => {});
  }, []);

  const checkStoredBiometrics = async () => {
    const stored = await getStoredBiometricPin();
    if (stored.identifier) {
      setIdentifier(stored.identifier);
    }
  };

  const handlePasswordLogin = async () => {
    if (!identifier.trim()) {
      setErrorMessage('Please enter your phone number or email.');
      triggerHaptic('error');
      return;
    }
    if (!password) {
      setErrorMessage('Please enter your account password.');
      triggerHaptic('error');
      return;
    }

    setErrorMessage('');
    setLoading(true);
    triggerHaptic('selection');

    const res = await login(identifier.trim(), password);
    setLoading(false);

    if (!res.success) {
      setErrorMessage(res.message || 'Login failed. Please verify your credentials.');
      triggerHaptic('error');
    }
  };

  const handlePinLogin = async () => {
    if (!identifier.trim()) {
      setErrorMessage('Please enter your phone number or email.');
      triggerHaptic('error');
      return;
    }
    if (pin.length !== 4) {
      setErrorMessage('Please enter your 4-digit security PIN.');
      triggerHaptic('error');
      return;
    }

    setErrorMessage('');
    setLoading(true);
    triggerHaptic('selection');

    const res = await loginWithPin(pin, identifier.trim());
    setLoading(false);

    if (!res.success) {
      setErrorMessage(res.message || 'Invalid PIN.');
      triggerHaptic('error');
    }
  };

  const handleBiometricAuth = async () => {
    setErrorMessage('');
    triggerHaptic('medium');
    const res = await loginWithBiometrics();
    if (!res.success) {
      setErrorMessage(res.message || 'Biometric authentication was cancelled.');
    }
  };

  const handleSupport = () => {
    triggerHaptic('light');
    Linking.openURL(`https://wa.me/${supportPhone}?text=Hello%20MBKDATASUB%20Support,%20I%20need%20assistance%20logging%20in.`);
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.bg }]}>
      <StatusBar barStyle={colors.statusBar === 'dark' ? 'dark-content' : 'light-content'} />
      <ScrollView contentContainerStyle={styles.scrollContent} keyboardShouldPersistTaps="handled">
        {/* Navigation Bar */}
        <View style={styles.navBar}>
          <TouchableOpacity
            style={[styles.backButton, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}
            onPress={() => {
              triggerHaptic('light');
              navigation.goBack();
            }}
          >
            <ArrowLeft size={22} color={colors.text} />
          </TouchableOpacity>
          <Text style={[styles.navTitle, { color: colors.text }]}>Sign In</Text>
          <TouchableOpacity
            style={[styles.themeToggle, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}
            onPress={toggleTheme}
          >
            {isDark ? <Sun size={18} color="#F59E0B" /> : <Moon size={18} color="#0284C7" />}
          </TouchableOpacity>
        </View>

        {/* Header */}
        <View style={styles.headerBlock}>
          <Text style={[styles.title, { color: colors.text }]}>Welcome Back</Text>
          <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
            Enter your details to access your MBKDATASUB wallet.
          </Text>
        </View>

        {/* Error Alert */}
        {errorMessage ? (
          <View style={[styles.errorBox, { backgroundColor: colors.errorBg, borderColor: colors.error }]}>
            <ShieldAlert size={18} color={colors.error} />
            <Text style={[styles.errorText, { color: colors.error }]}>{errorMessage}</Text>
          </View>
        ) : null}

        {/* Mode Selector (Password vs PIN) */}
        <View style={[styles.modeTabs, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <TouchableOpacity
            style={[styles.tabButton, authMode === 'password' && { backgroundColor: colors.inputBg }]}
            onPress={() => {
              triggerHaptic('selection');
              setAuthMode('password');
            }}
          >
            <Lock size={16} color={authMode === 'password' ? colors.primary : colors.textMuted} />
            <Text
              style={[
                styles.tabButtonText,
                { color: authMode === 'password' ? colors.primary : colors.textMuted },
              ]}
            >
              Password
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.tabButton, authMode === 'pin' && { backgroundColor: colors.inputBg }]}
            onPress={() => {
              triggerHaptic('selection');
              setAuthMode('pin');
            }}
          >
            <KeyRound size={16} color={authMode === 'pin' ? colors.primary : colors.textMuted} />
            <Text
              style={[
                styles.tabButtonText,
                { color: authMode === 'pin' ? colors.primary : colors.textMuted },
              ]}
            >
              4-Digit PIN
            </Text>
          </TouchableOpacity>
        </View>

        {/* Form Fields */}
        <View style={styles.formGroup}>
          <Text style={[styles.inputLabel, { color: colors.textSecondary }]}>Phone Number or Email</Text>
          <View
            style={[
              styles.inputWrapper,
              { backgroundColor: colors.inputBg, borderColor: colors.inputBorder },
            ]}
          >
            <Mail size={18} color={colors.textSecondary} style={styles.inputIcon} />
            <TextInput
              style={[styles.textInput, { color: colors.text }]}
              placeholder="08012345678 or you@email.com"
              placeholderTextColor={colors.textMuted}
              value={identifier}
              onChangeText={setIdentifier}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
            />
          </View>
        </View>

        {authMode === 'password' ? (
          <View style={styles.formGroup}>
            <Text style={[styles.inputLabel, { color: colors.textSecondary }]}>Password</Text>
            <View
              style={[
                styles.inputWrapper,
                { backgroundColor: colors.inputBg, borderColor: colors.inputBorder },
              ]}
            >
              <Lock size={18} color={colors.textSecondary} style={styles.inputIcon} />
              <TextInput
                style={[styles.textInput, { color: colors.text }]}
                placeholder="••••••••••••"
                placeholderTextColor={colors.textMuted}
                value={password}
                onChangeText={setPassword}
                secureTextEntry={!showPassword}
                autoCapitalize="none"
              />
              <TouchableOpacity
                onPress={() => setShowPassword(!showPassword)}
                style={styles.eyeBtn}
              >
                {showPassword ? (
                  <EyeOff size={18} color={colors.textSecondary} />
                ) : (
                  <Eye size={18} color={colors.textSecondary} />
                )}
              </TouchableOpacity>
            </View>
          </View>
        ) : (
          <View style={styles.formGroup}>
            <Text style={[styles.inputLabel, { color: colors.textSecondary }]}>4-Digit Security PIN</Text>
            <View
              style={[
                styles.inputWrapper,
                { backgroundColor: colors.inputBg, borderColor: colors.inputBorder },
              ]}
            >
              <KeyRound size={18} color={colors.textSecondary} style={styles.inputIcon} />
              <TextInput
                style={[styles.textInput, { color: colors.text }]}
                placeholder="••••"
                placeholderTextColor={colors.textMuted}
                value={pin}
                onChangeText={(val) => setPin(val.replace(/[^0-9]/g, '').slice(0, 4))}
                keyboardType="numeric"
                secureTextEntry
                maxLength={4}
              />
            </View>
          </View>
        )}

        {/* 1-Tap Face ID Authentication (Positioned between Password and Sign In Wallet) */}
        {biometricInfo?.isAvailable && (
          <TouchableOpacity
            style={[
              styles.bioPrimaryBtn,
              { backgroundColor: colors.primaryBg, borderColor: colors.primary },
            ]}
            onPress={handleBiometricAuth}
            activeOpacity={0.8}
          >
            {biometricInfo.sensorName === 'Apple Face ID' ? (
              <ScanFace size={24} color={colors.primary} />
            ) : (
              <Fingerprint size={24} color={colors.primary} />
            )}
            <View style={styles.bioTextCol}>
              <Text style={[styles.bioPrimaryTitle, { color: colors.primary }]}>
                1-Tap Sign In with {biometricInfo.sensorName}
              </Text>
              <Text style={[styles.bioPrimarySub, { color: colors.textSecondary }]}>
                Instant biometric unlock without typing
              </Text>
            </View>
          </TouchableOpacity>
        )}

        {/* Submit Button */}
        <TouchableOpacity
          style={styles.submitBtn}
          onPress={authMode === 'password' ? handlePasswordLogin : handlePinLogin}
          disabled={loading}
          activeOpacity={0.8}
        >
          <LinearGradient
            colors={['#2563EB', '#1D4ED8']}
            style={styles.submitGradient}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
          >
            {loading ? (
              <ActivityIndicator color="#FFFFFF" />
            ) : (
              <>
                <Text style={styles.submitBtnText}>
                  {authMode === 'password' ? 'Sign In to Wallet' : 'Authorize with PIN'}
                </Text>
                <ArrowRight size={20} color="#FFFFFF" />
              </>
            )}
          </LinearGradient>
        </TouchableOpacity>

        {/* Footer Support & Register Links */}
        <View style={styles.footerLinks}>
          <TouchableOpacity onPress={handleSupport}>
            <Text style={[styles.forgotText, { color: colors.primary }]}>
              Forgot credentials? Contact WhatsApp
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.registerRow}
            onPress={() => {
              triggerHaptic('light');
              navigation.navigate('Register');
            }}
          >
            <Text style={[styles.registerLead, { color: colors.textSecondary }]}>
              Don't have an account?{' '}
            </Text>
            <Text style={[styles.registerLink, { color: colors.primary }]}>Create one free</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    maxWidth: 640,
    width: '100%',
    alignSelf: 'center',
    paddingHorizontal: 20,
    paddingTop: 10,
    paddingBottom: 40,
  },
  navBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  backButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
  },
  navTitle: {
    fontSize: 16,
    fontWeight: '700',
  },
  themeToggle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
  },
  headerBlock: {
    marginBottom: 20,
  },
  title: {
    fontSize: 26,
    fontWeight: '800',
    letterSpacing: -0.5,
  },
  subtitle: {
    fontSize: 14,
    marginTop: 6,
    lineHeight: 20,
  },
  bioPrimaryBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 18,
    borderWidth: 1.5,
    padding: 16,
    gap: 14,
    marginBottom: 20,
  },
  bioTextCol: {
    flex: 1,
  },
  bioPrimaryTitle: {
    fontSize: 15,
    fontWeight: '800',
  },
  bioPrimarySub: {
    fontSize: 12,
    marginTop: 2,
  },
  dividerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginBottom: 20,
  },
  dividerLine: {
    flex: 1,
    height: 1,
  },
  dividerText: {
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 0.8,
  },
  errorBox: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderRadius: 14,
    padding: 12,
    marginBottom: 16,
    gap: 10,
  },
  errorText: {
    flex: 1,
    fontSize: 13,
    fontWeight: '500',
  },
  modeTabs: {
    flexDirection: 'row',
    borderRadius: 14,
    padding: 4,
    marginBottom: 20,
    borderWidth: 1,
  },
  tabButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 10,
    borderRadius: 10,
    gap: 8,
  },
  tabButtonText: {
    fontSize: 14,
    fontWeight: '700',
  },
  formGroup: {
    marginBottom: 16,
  },
  inputLabel: {
    fontSize: 13,
    fontWeight: '600',
    marginBottom: 8,
  },
  inputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 14,
    borderWidth: 1,
    paddingHorizontal: 14,
    height: 52,
  },
  inputIcon: {
    marginRight: 10,
  },
  textInput: {
    flex: 1,
    fontSize: 15,
  },
  eyeBtn: {
    padding: 6,
  },
  submitBtn: {
    borderRadius: 16,
    overflow: 'hidden',
    marginTop: 8,
    marginBottom: 16,
  },
  submitGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    height: 54,
    gap: 10,
  },
  submitBtnText: {
    fontSize: 16,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  footerLinks: {
    alignItems: 'center',
    gap: 16,
    marginTop: 8,
  },
  forgotText: {
    fontSize: 13,
    fontWeight: '600',
  },
  registerRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  registerLead: {
    fontSize: 14,
  },
  registerLink: {
    fontSize: 14,
    fontWeight: '700',
  },
});
