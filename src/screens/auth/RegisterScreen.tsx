import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  SafeAreaView,
  StatusBar,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import {
  User,
  Phone,
  Mail,
  Lock,
  Gift,
  Eye,
  EyeOff,
  ArrowRight,
  ArrowLeft,
  ShieldAlert,
} from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { triggerHaptic } from '../../utils/haptics';

export const RegisterScreen = ({ navigation }: any) => {
  const { register } = useAuth();
  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [referralCode, setReferralCode] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const handleRegister = async () => {
    if (!fullName.trim()) {
      setErrorMessage('Please enter your full name.');
      triggerHaptic('error');
      return;
    }
    if (!phone.trim() || phone.trim().length < 11) {
      setErrorMessage('Please enter a valid 11-digit Nigerian phone number.');
      triggerHaptic('error');
      return;
    }
    if (!email.trim() || !email.includes('@')) {
      setErrorMessage('Please enter a valid email address.');
      triggerHaptic('error');
      return;
    }
    // Enforce compulsory strong password criteria
    if (!password || password.length < 8) {
      setErrorMessage('Password must be at least 8 characters long.');
      triggerHaptic('error');
      return;
    }
    if (!/[A-Z]/.test(password)) {
      setErrorMessage('Password must contain at least one uppercase letter (A-Z).');
      triggerHaptic('error');
      return;
    }
    if (!/[a-z]/.test(password)) {
      setErrorMessage('Password must contain at least one lowercase letter (a-z).');
      triggerHaptic('error');
      return;
    }
    if (!/[0-9]/.test(password)) {
      setErrorMessage('Password must contain at least one number (0-9).');
      triggerHaptic('error');
      return;
    }
    if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~`]/.test(password)) {
      setErrorMessage('Password must contain at least one special character (e.g. !@#$%^&*).');
      triggerHaptic('error');
      return;
    }

    setErrorMessage('');
    setLoading(true);
    triggerHaptic('selection');

    const res = await register({
      fullName: fullName.trim(),
      phone: phone.trim(),
      email: email.trim().toLowerCase(),
      password,
      referralCode: referralCode.trim() || undefined,
    });

    setLoading(false);

    if (res.success) {
      triggerHaptic('success');
      navigation.navigate('PinSetup');
    } else {
      setErrorMessage(res.message || 'Registration failed. Phone or email may already be registered.');
      triggerHaptic('error');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#0F172A" />
      <ScrollView contentContainerStyle={styles.scrollContent} keyboardShouldPersistTaps="handled">
        {/* Navigation Bar */}
        <View style={styles.navBar}>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => {
              triggerHaptic('light');
              navigation.goBack();
            }}
          >
            <ArrowLeft size={22} color="#F8FAFC" />
          </TouchableOpacity>
          <Text style={styles.navTitle}>Create Account</Text>
          <View style={{ width: 40 }} />
        </View>

        {/* Header Block */}
        <View style={styles.headerBlock}>
          <Text style={styles.title}>Join MBK DATASUB</Text>
          <Text style={styles.subtitle}>Get instantaneous discounts, zero wallet fees and automated telecom services.</Text>
        </View>

        {/* Error Alert */}
        {errorMessage ? (
          <View style={styles.errorBox}>
            <ShieldAlert size={18} color="#EF4444" />
            <Text style={styles.errorText}>{errorMessage}</Text>
          </View>
        ) : null}

        {/* Form Fields */}
        <View style={styles.formGroup}>
          <Text style={styles.inputLabel}>Full Name</Text>
          <View style={styles.inputWrapper}>
            <User size={18} color="#64748B" style={styles.inputIcon} />
            <TextInput
              style={styles.textInput}
              placeholder="e.g. John Doe"
              placeholderTextColor="#64748B"
              value={fullName}
              onChangeText={setFullName}
              autoCapitalize="words"
            />
          </View>
        </View>

        <View style={styles.formGroup}>
          <Text style={styles.inputLabel}>Phone Number</Text>
          <View style={styles.inputWrapper}>
            <Phone size={18} color="#64748B" style={styles.inputIcon} />
            <TextInput
              style={styles.textInput}
              placeholder="08012345678"
              placeholderTextColor="#64748B"
              value={phone}
              onChangeText={(t) => setPhone(t.replace(/[^0-9]/g, '').slice(0, 11))}
              keyboardType="phone-pad"
            />
          </View>
        </View>

        <View style={styles.formGroup}>
          <Text style={styles.inputLabel}>Email Address</Text>
          <View style={styles.inputWrapper}>
            <Mail size={18} color="#64748B" style={styles.inputIcon} />
            <TextInput
              style={styles.textInput}
              placeholder="you@email.com"
              placeholderTextColor="#64748B"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
            />
          </View>
        </View>

        <View style={styles.formGroup}>
          <Text style={styles.inputLabel}>Create Strong Password</Text>
          <View style={styles.inputWrapper}>
            <Lock size={18} color="#64748B" style={styles.inputIcon} />
            <TextInput
              style={styles.textInput}
              placeholder="Create strong password"
              placeholderTextColor="#64748B"
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
                <EyeOff size={18} color="#64748B" />
              ) : (
                <Eye size={18} color="#64748B" />
              )}
            </TouchableOpacity>
          </View>
          <Text style={{ fontSize: 11, color: '#94A3B8', marginTop: 4 }}>
            Must be 8+ characters with uppercase, lowercase, number & symbol.
          </Text>
        </View>

        <View style={styles.formGroup}>
          <Text style={styles.inputLabel}>Referral Code (Optional)</Text>
          <View style={styles.inputWrapper}>
            <Gift size={18} color="#64748B" style={styles.inputIcon} />
            <TextInput
              style={styles.textInput}
              placeholder="e.g. MBK1234"
              placeholderTextColor="#64748B"
              value={referralCode}
              onChangeText={setReferralCode}
              autoCapitalize="characters"
            />
          </View>
        </View>

        {/* Submit Button */}
        <TouchableOpacity
          style={styles.submitBtn}
          onPress={handleRegister}
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
                <Text style={styles.submitBtnText}>Create Account</Text>
                <ArrowRight size={20} color="#FFFFFF" />
              </>
            )}
          </LinearGradient>
        </TouchableOpacity>

        {/* Switch to Login */}
        <View style={styles.footerRow}>
          <Text style={styles.footerLead}>Already registered? </Text>
          <TouchableOpacity
            onPress={() => {
              triggerHaptic('light');
              navigation.navigate('Login');
            }}
          >
            <Text style={styles.footerLink}>Sign In here</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0F172A',
  },
  scrollContent: {
    paddingHorizontal: 20,
    paddingTop: 10,
    paddingBottom: 40,
  },
  navBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  backButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#1E293B',
    justifyContent: 'center',
    alignItems: 'center',
  },
  navTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#F8FAFC',
  },
  headerBlock: {
    marginBottom: 24,
  },
  title: {
    fontSize: 26,
    fontWeight: '800',
    color: '#F8FAFC',
    letterSpacing: -0.5,
  },
  subtitle: {
    fontSize: 14,
    color: '#94A3B8',
    marginTop: 6,
    lineHeight: 20,
  },
  errorBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(239, 68, 68, 0.1)',
    borderWidth: 1,
    borderColor: 'rgba(239, 68, 68, 0.3)',
    borderRadius: 14,
    padding: 12,
    marginBottom: 16,
    gap: 10,
  },
  errorText: {
    flex: 1,
    fontSize: 13,
    color: '#EF4444',
    fontWeight: '500',
  },
  formGroup: {
    marginBottom: 16,
  },
  inputLabel: {
    fontSize: 13,
    fontWeight: '600',
    color: '#CBD5E1',
    marginBottom: 8,
  },
  inputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1E293B',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#334155',
    paddingHorizontal: 14,
    height: 52,
  },
  inputIcon: {
    marginRight: 10,
  },
  textInput: {
    flex: 1,
    fontSize: 15,
    color: '#F8FAFC',
  },
  eyeBtn: {
    padding: 6,
  },
  submitBtn: {
    borderRadius: 16,
    overflow: 'hidden',
    marginTop: 10,
    marginBottom: 20,
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
  footerRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  footerLead: {
    fontSize: 14,
    color: '#94A3B8',
  },
  footerLink: {
    fontSize: 14,
    fontWeight: '700',
    color: '#38BDF8',
  },
});
