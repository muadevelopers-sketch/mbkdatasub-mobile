import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  StatusBar,
  TouchableOpacity,
  Switch,
  Alert,
  Linking,
  Share,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';;
import { useFocusEffect } from '@react-navigation/native';
import * as Clipboard from 'expo-clipboard';
import {
  User,
  ShieldCheck,
  CreditCard,
  KeyRound,
  ScanFace,
  Fingerprint,
  Share2,
  Copy,
  Check,
  MessageCircle,
  LogOut,
  ChevronRight,
  Sparkles,
  ExternalLink,
  Sun,
  Moon,
  RefreshCw,
  Sliders,
  CheckCircle2,
  Mail,
  Phone,
} from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { apiClient } from '../../api/client';
import { triggerHaptic } from '../../utils/haptics';
import { promptBiometricAuth, enableMobileBiometrics } from '../../utils/biometrics';

export const ProfileScreen = ({ navigation }: any) => {
  const {
    user,
    wallet,
    biometricInfo,
    isBiometricsActive,
    enableBiometricsWithPin,
    disableBiometrics,
    generateDedicatedAccounts,
    logout,
  } = useAuth();
  const { colors, isDark, toggleTheme } = useTheme();

  const [copiedCode, setCopiedCode] = useState(false);
  const [copiedPalm, setCopiedPalm] = useState(false);
  const [copiedPaga, setCopiedPaga] = useState(false);
  const [testingBio, setTestingBio] = useState(false);
  const [generatingAccounts, setGeneratingAccounts] = useState(false);

  const palmpayAccount = wallet.accounts.find(
    (a) => (a.bankName || '').toLowerCase().includes('palm') || a.type === 'palmpay'
  ) || { bankName: 'PalmPay', accountNumber: '', accountName: '' };

  const pagaAccount = wallet.accounts.find(
    (a) => (a.bankName || '').toLowerCase().includes('paga') || a.type === 'paga'
  ) || { bankName: 'Paga', accountNumber: '', accountName: '' };

  const handleCopy = async (text: string, type: 'code' | 'palm' | 'paga') => {
    if (!text) return;
    await Clipboard.setStringAsync(text);
    triggerHaptic('success');
    if (type === 'code') {
      setCopiedCode(true);
      setTimeout(() => setCopiedCode(false), 2000);
    } else if (type === 'palm') {
      setCopiedPalm(true);
      setTimeout(() => setCopiedPalm(false), 2000);
    } else if (type === 'paga') {
      setCopiedPaga(true);
      setTimeout(() => setCopiedPaga(false), 2000);
    }
  };

  const [supportPhone, setSupportPhone] = useState('2349047050681');
  const [supportEmail, setSupportEmail] = useState('support@mbkdatasub.com.ng');

  useFocusEffect(
    useCallback(() => {
      fetchLiveBrandingAndContact();
    }, [])
  );

  const fetchLiveBrandingAndContact = async () => {
    try {
      const [brandRes, bankRes] = await Promise.all([
        apiClient.get('/admin/branding').catch(() => null),
        apiClient.get('/admin/bank').catch(() => null),
      ]);
      const p =
        brandRes?.data?.branding?.supportWhatsapp ||
        brandRes?.data?.supportWhatsapp ||
        brandRes?.data?.branding?.supportPhone ||
        bankRes?.data?.bank?.whatsappNotificationPhone ||
        bankRes?.data?.data?.whatsappNotificationPhone;
      if (p) {
        setSupportPhone(p.replace(/[^0-9]/g, ''));
      }
      const em = brandRes?.data?.branding?.supportEmail || brandRes?.data?.supportEmail;
      if (em) {
        setSupportEmail(em.trim());
      }
    } catch {}
  };

  const handleShareReferral = async () => {
    triggerHaptic('light');
    const msg = `Join MBK DATASUB for the cheapest automated mobile data bundles, airtime discount and 0% wallet funding! Use my referral code: ${user?.referralCode || 'MBK1000'}\nDownload app at https://mbkdatasub.com.ng`;
    try {
      await Share.share({ message: msg });
    } catch {}
  };

  const handleWhatsAppSupport = () => {
    triggerHaptic('light');
    Linking.openURL(`https://wa.me/${supportPhone}?text=Hello%20MBK%20DATASUB%20Support,%20I%20need%20assistance.`);
  };

  const handleToggleBiometrics = async (value: boolean) => {
    triggerHaptic('selection');
    if (value) {
      if (!biometricInfo?.isAvailable) {
        Alert.alert(
          'Biometrics Unavailable',
          'Biometric hardware is not available or not enrolled in your device settings.'
        );
        return;
      }

      // Prompt biometrics to verify user
      const authenticated = await promptBiometricAuth(
        `Authorize ${biometricInfo.sensorName} for MBK DATASUB`
      );

      if (authenticated) {
        // If user already has a transaction PIN configured on their account
        if (user?.hasTransactionPin) {
          Alert.prompt
            ? Alert.prompt(
                'Enter Transaction PIN',
                'Enter your 4-digit PIN to securely link with Face ID:',
                async (enteredPin) => {
                  if (enteredPin && enteredPin.length === 4) {
                    await enableBiometricsWithPin(enteredPin);
                    Alert.alert('Success', `${biometricInfo.sensorName} is now active for 1-tap checkout and login!`);
                  } else {
                    Alert.alert('Invalid PIN', 'Please enter a valid 4-digit PIN.');
                  }
                },
                'secure-text'
              )
            : navigation.navigate('PinSetup');
        } else {
          Alert.alert(
            'Set Security PIN First',
            'Please create your 4-digit transaction PIN first to link it with Face ID.',
            [
              { text: 'Cancel', style: 'cancel' },
              { text: 'Set PIN', onPress: () => navigation.navigate('PinSetup') },
            ]
          );
        }
      }
    } else {
      await disableBiometrics();
      triggerHaptic('light');
    }
  };

  const handleTestFaceId = async () => {
    triggerHaptic('medium');
    setTestingBio(true);
    const success = await promptBiometricAuth(
      `Verifying ${biometricInfo?.sensorName || 'Apple Face ID'} Sensor`
    );
    setTestingBio(false);

    if (success) {
      triggerHaptic('success');
      Alert.alert(
        `🎉 ${biometricInfo?.sensorName || 'Face ID'} Verified!`,
        `Your biometric hardware responded successfully. 1-tap authentication is active.`
      );
    } else {
      triggerHaptic('error');
      Alert.alert(
        'Authentication Cancelled',
        `Biometric verification was cancelled or did not recognize. You can always use your 4-digit PIN.`
      );
    }
  };

  const handleGenerateAccounts = async () => {
    triggerHaptic('medium');
    setGeneratingAccounts(true);
    const res = await generateDedicatedAccounts();
    setGeneratingAccounts(false);
    if (res.success) {
      triggerHaptic('success');
      Alert.alert('Accounts Ready', 'Your dedicated PalmPay and Paga funding accounts are now active!');
    } else {
      triggerHaptic('error');
      Alert.alert('Notice', res.message || 'Accounts are being synced with the bank.');
    }
  };

  const handleLogout = () => {
    triggerHaptic('medium');
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out of your account on this device?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Sign Out',
          style: 'destructive',
          onPress: async () => {
            await logout();
          },
        },
      ]
    );
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.bg }]}>
      <StatusBar
        barStyle={colors.statusBar === 'dark' ? 'dark-content' : 'light-content'}
        backgroundColor={colors.bg}
      />
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Profile Card Header */}
        <View style={[styles.userCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <View style={[styles.avatar, { backgroundColor: colors.primary }]}>
            <Text style={styles.avatarText}>
              {user?.fullName ? user.fullName.charAt(0).toUpperCase() : 'M'}
            </Text>
          </View>
          <View style={styles.userInfo}>
            <View style={styles.nameRow}>
              <Text style={[styles.userName, { color: colors.text }]}>
                {user?.fullName || 'Valued Customer'}
              </Text>
              <View style={[styles.tierBadge, { backgroundColor: colors.successBg }]}>
                <ShieldCheck size={12} color={colors.success} />
                <Text style={[styles.tierText, { color: colors.success }]}>Tier {user?.kycTier || 1}</Text>
              </View>
            </View>
            <Text style={[styles.userPhone, { color: colors.textSecondary }]}>{user?.phone || '08000000000'}</Text>
            <Text style={[styles.userEmail, { color: colors.textMuted }]}>{user?.email || 'user@mbkdatasub.com.ng'}</Text>
          </View>
        </View>

        {/* Appearance & Theme Mode Section */}
        <View style={styles.section}>
          <Text style={[styles.sectionHeader, { color: colors.textMuted }]}>Appearance & Theme</Text>
          <View style={[styles.cardGroup, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <View style={styles.menuItem}>
              <View style={[styles.menuIconBox, { backgroundColor: isDark ? 'rgba(56, 189, 248, 0.15)' : '#FEF3C7' }]}>
                {isDark ? <Moon size={20} color={colors.primary} /> : <Sun size={20} color="#D97706" />}
              </View>
              <View style={styles.menuInfo}>
                <Text style={[styles.menuTitle, { color: colors.text }]}>
                  {isDark ? 'Dark Mode' : 'Light Mode'}
                </Text>
                <Text style={[styles.menuDesc, { color: colors.textSecondary }]}>
                  {isDark ? 'High contrast OLED dark theme' : 'Crisp high daylight theme'}
                </Text>
              </View>
              <Switch
                value={isDark}
                onValueChange={toggleTheme}
                trackColor={{ false: '#CBD5E1', true: colors.primary }}
                thumbColor="#FFFFFF"
              />
            </View>
          </View>
        </View>

        {/* Security & Hardware Face ID Section */}
        <View style={styles.section}>
          <Text style={[styles.sectionHeader, { color: colors.textMuted }]}>Security & Biometrics</Text>
          <View style={[styles.cardGroup, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            {/* Biometrics Toggle Switch */}
            <View style={[styles.menuItem, styles.rowBorder, { borderBottomColor: colors.cardBorder }]}>
              <View style={[styles.menuIconBox, { backgroundColor: colors.primaryBg }]}>
                {biometricInfo?.sensorName === 'Apple Face ID' ? (
                  <ScanFace size={22} color={colors.primary} />
                ) : (
                  <Fingerprint size={22} color={colors.primary} />
                )}
              </View>
              <View style={styles.menuInfo}>
                <Text style={[styles.menuTitle, { color: colors.text }]}>
                  {biometricInfo?.sensorName || 'Apple Face ID'}
                </Text>
                <Text style={[styles.menuDesc, { color: colors.textSecondary }]}>
                  1-Tap instant checkout & account login
                </Text>
              </View>
              <Switch
                value={isBiometricsActive}
                onValueChange={handleToggleBiometrics}
                trackColor={{ false: '#CBD5E1', true: colors.primary }}
                thumbColor="#FFFFFF"
              />
            </View>

            {/* Test Face ID Sensor Button */}
            <TouchableOpacity
              style={[styles.menuItem, styles.rowBorder, { borderBottomColor: colors.cardBorder }]}
              onPress={handleTestFaceId}
              disabled={testingBio}
              activeOpacity={0.7}
            >
              <View style={[styles.menuIconBox, { backgroundColor: colors.successBg }]}>
                {testingBio ? (
                  <ActivityIndicator size="small" color={colors.success} />
                ) : (
                  <CheckCircle2 size={20} color={colors.success} />
                )}
              </View>
              <View style={styles.menuInfo}>
                <Text style={[styles.menuTitle, { color: colors.text }]}>
                  Test {biometricInfo?.sensorName || 'Face ID'} Sensor
                </Text>
                <Text style={[styles.menuDesc, { color: colors.textSecondary }]}>
                  Trigger native iOS biometric sensor to verify hardware
                </Text>
              </View>
              <ChevronRight size={18} color={colors.textMuted} />
            </TouchableOpacity>

            {/* Reset / Change PIN */}
            <TouchableOpacity
              style={styles.menuItem}
              onPress={() => {
                triggerHaptic('selection');
                navigation.navigate('PinSetup');
              }}
              activeOpacity={0.7}
            >
              <View style={[styles.menuIconBox, { backgroundColor: 'rgba(168, 85, 247, 0.15)' }]}>
                <KeyRound size={20} color="#A855F7" />
              </View>
              <View style={styles.menuInfo}>
                <Text style={[styles.menuTitle, { color: colors.text }]}>Transaction Security PIN</Text>
                <Text style={[styles.menuDesc, { color: colors.textSecondary }]}>
                  {user?.hasTransactionPin ? 'Change your 4-digit payment PIN' : 'Setup your 4-digit payment PIN'}
                </Text>
              </View>
              <ChevronRight size={18} color={colors.textMuted} />
            </TouchableOpacity>
          </View>
        </View>

        {/* Dedicated Funding Accounts */}
        <View style={styles.section}>
          <View style={styles.sectionHeaderRow}>
            <Text style={[styles.sectionHeader, { color: colors.textMuted, marginBottom: 0 }]}>
              Dedicated Virtual Accounts
            </Text>
            {(!palmpayAccount.accountNumber || !pagaAccount.accountNumber) && (
              <TouchableOpacity
                onPress={handleGenerateAccounts}
                disabled={generatingAccounts}
                style={styles.refreshAccountsBtn}
              >
                {generatingAccounts ? (
                  <ActivityIndicator size="small" color={colors.primary} />
                ) : (
                  <RefreshCw size={13} color={colors.primary} />
                )}
                <Text style={[styles.refreshAccountsText, { color: colors.primary }]}>
                  {generatingAccounts ? 'Assigning...' : 'Assign Accounts'}
                </Text>
              </TouchableOpacity>
            )}
          </View>

          <View style={[styles.cardGroup, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            {/* PalmPay Account */}
            <View style={[styles.accountRow, styles.rowBorder, { borderBottomColor: colors.cardBorder }]}>
              <View style={[styles.bankTag, { backgroundColor: colors.surface }]}>
                <Text style={styles.bankTagPalm}>PALMPAY</Text>
              </View>
              <View style={styles.accountCol}>
                <Text style={[styles.accountNumber, { color: colors.text }]}>
                  {palmpayAccount.accountNumber || 'Assigning PalmPay...'}
                </Text>
                <Text style={[styles.accountName, { color: colors.textSecondary }]}>
                  {palmpayAccount.accountName || user?.fullName || 'MBK Customer'}
                </Text>
              </View>
              {palmpayAccount.accountNumber ? (
                <TouchableOpacity
                  style={[styles.copyBtn, { backgroundColor: colors.primaryBg }]}
                  onPress={() => handleCopy(palmpayAccount.accountNumber, 'palm')}
                >
                  {copiedPalm ? (
                    <Check size={16} color={colors.success} />
                  ) : (
                    <Copy size={16} color={colors.primary} />
                  )}
                </TouchableOpacity>
              ) : null}
            </View>

            {/* Paga Account */}
            <View style={styles.accountRow}>
              <View style={[styles.bankTag, { backgroundColor: colors.surface }]}>
                <Text style={styles.bankTagPaga}>PAGA</Text>
              </View>
              <View style={styles.accountCol}>
                <Text style={[styles.accountNumber, { color: colors.text }]}>
                  {pagaAccount.accountNumber || 'Assigning Paga...'}
                </Text>
                <Text style={[styles.accountName, { color: colors.textSecondary }]}>
                  {pagaAccount.accountName || user?.fullName || 'MBK Customer'}
                </Text>
              </View>
              {pagaAccount.accountNumber ? (
                <TouchableOpacity
                  style={[styles.copyBtn, { backgroundColor: colors.primaryBg }]}
                  onPress={() => handleCopy(pagaAccount.accountNumber, 'paga')}
                >
                  {copiedPaga ? (
                    <Check size={16} color={colors.success} />
                  ) : (
                    <Copy size={16} color={colors.primary} />
                  )}
                </TouchableOpacity>
              ) : null}
            </View>
          </View>
        </View>

        {/* Referral Program */}
        <View style={styles.section}>
          <Text style={[styles.sectionHeader, { color: colors.textMuted }]}>Referral Rewards</Text>
          <View style={[styles.referralCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <View style={styles.referralHeader}>
              <Sparkles size={20} color="#F59E0B" />
              <Text style={[styles.referralTitle, { color: colors.text }]}>Refer & Earn Airtime/Data</Text>
            </View>
            <Text style={[styles.referralDesc, { color: colors.textSecondary }]}>
              Share your code with friends and earn commission on every bundle they buy forever.
            </Text>

            <View style={styles.codeRow}>
              <View style={[styles.codeBox, { backgroundColor: colors.surface, borderColor: colors.cardBorder }]}>
                <Text style={[styles.codeText, { color: colors.primary }]}>{user?.referralCode || 'MBK1000'}</Text>
              </View>
              <TouchableOpacity
                style={[styles.codeCopyBtn, { backgroundColor: colors.primaryBg }]}
                onPress={() => handleCopy(user?.referralCode || 'MBK1000', 'code')}
              >
                {copiedCode ? <Check size={18} color={colors.success} /> : <Copy size={18} color={colors.primary} />}
              </TouchableOpacity>
              <TouchableOpacity style={[styles.shareCodeBtn, { backgroundColor: colors.primary }]} onPress={handleShareReferral}>
                <Share2 size={18} color="#FFFFFF" />
                <Text style={styles.shareCodeText}>Share</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>

        {/* Support & Community */}
        <View style={styles.section}>
          <Text style={[styles.sectionHeader, { color: colors.textMuted }]}>Support & Assistance</Text>
          <View style={[styles.cardGroup, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <TouchableOpacity
              style={[styles.menuItem, styles.rowBorder, { borderBottomColor: colors.cardBorder }]}
              onPress={handleWhatsAppSupport}
              activeOpacity={0.7}
            >
              <View style={[styles.menuIconBox, { backgroundColor: 'rgba(16, 185, 129, 0.15)' }]}>
                <MessageCircle size={20} color="#10B981" />
              </View>
              <View style={styles.menuInfo}>
                <Text style={[styles.menuTitle, { color: colors.text }]}>24/7 WhatsApp Support</Text>
                <Text style={[styles.menuDesc, { color: colors.textSecondary }]}>Fast response from our dedicated support agents</Text>
              </View>
              <ExternalLink size={16} color={colors.textMuted} />
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.menuItem}
              onPress={() => Linking.openURL('https://mbkdatasub.com.ng')}
              activeOpacity={0.7}
            >
              <View style={[styles.menuIconBox, { backgroundColor: 'rgba(37, 99, 235, 0.15)' }]}>
                <CreditCard size={20} color="#3B82F6" />
              </View>
              <View style={styles.menuInfo}>
                <Text style={[styles.menuTitle, { color: colors.text }]}>Visit Web Portal</Text>
                <Text style={[styles.menuDesc, { color: colors.textSecondary }]}>mbkdatasub.com.ng</Text>
              </View>
              <ExternalLink size={16} color={colors.textMuted} />
            </TouchableOpacity>
          </View>
        </View>

        {/* Logout Button */}
        <TouchableOpacity
          style={[styles.logoutBtn, { backgroundColor: colors.errorBg, borderColor: colors.error }]}
          onPress={handleLogout}
          activeOpacity={0.8}
        >
          <LogOut size={18} color={colors.error} />
          <Text style={[styles.logoutText, { color: colors.error }]}>Sign Out</Text>
        </TouchableOpacity>
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
    paddingTop: 16,
    paddingBottom: 40,
  },
  userCard: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 20,
    padding: 18,
    borderWidth: 1,
    marginBottom: 24,
    gap: 16,
  },
  avatar: {
    width: 56,
    height: 56,
    borderRadius: 28,
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 24,
    fontWeight: '800',
    color: '#FFFFFF',
  },
  userInfo: {
    flex: 1,
  },
  nameRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  userName: {
    fontSize: 17,
    fontWeight: '800',
  },
  tierBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
    gap: 4,
  },
  tierText: {
    fontSize: 10,
    fontWeight: '700',
  },
  userPhone: {
    fontSize: 13,
    marginTop: 2,
  },
  userEmail: {
    fontSize: 12,
    marginTop: 1,
  },
  section: {
    marginBottom: 22,
  },
  sectionHeaderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  sectionHeader: {
    fontSize: 13,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 0.6,
    marginBottom: 10,
  },
  refreshAccountsBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingVertical: 2,
    paddingHorizontal: 6,
  },
  refreshAccountsText: {
    fontSize: 12,
    fontWeight: '700',
  },
  cardGroup: {
    borderRadius: 20,
    borderWidth: 1,
    overflow: 'hidden',
  },
  accountRow: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    gap: 12,
  },
  rowBorder: {
    borderBottomWidth: 1,
  },
  bankTag: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
  },
  bankTagPalm: {
    fontSize: 11,
    fontWeight: '800',
    color: '#0284C7',
  },
  bankTagPaga: {
    fontSize: 11,
    fontWeight: '800',
    color: '#F59E0B',
  },
  accountCol: {
    flex: 1,
  },
  accountNumber: {
    fontSize: 16,
    fontWeight: '800',
    letterSpacing: 1,
  },
  accountName: {
    fontSize: 12,
    marginTop: 2,
  },
  copyBtn: {
    padding: 8,
    borderRadius: 10,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    gap: 14,
  },
  menuIconBox: {
    width: 42,
    height: 42,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
  },
  menuInfo: {
    flex: 1,
  },
  menuTitle: {
    fontSize: 15,
    fontWeight: '700',
    marginBottom: 2,
  },
  menuDesc: {
    fontSize: 12,
  },
  referralCard: {
    borderRadius: 20,
    borderWidth: 1,
    padding: 18,
  },
  referralHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 6,
  },
  referralTitle: {
    fontSize: 15,
    fontWeight: '700',
  },
  referralDesc: {
    fontSize: 13,
    lineHeight: 18,
    marginBottom: 14,
  },
  codeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  codeBox: {
    flex: 1,
    borderWidth: 1,
    borderRadius: 12,
    paddingVertical: 10,
    paddingHorizontal: 14,
    alignItems: 'center',
  },
  codeText: {
    fontSize: 16,
    fontWeight: '800',
    letterSpacing: 2,
  },
  codeCopyBtn: {
    padding: 10,
    borderRadius: 12,
  },
  shareCodeBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 12,
  },
  shareCodeText: {
    color: '#FFFFFF',
    fontWeight: '700',
    fontSize: 13,
  },
  logoutBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderRadius: 16,
    paddingVertical: 14,
    gap: 8,
    marginTop: 10,
    marginBottom: 16,
  },
  logoutText: {
    fontSize: 15,
    fontWeight: '700',
  },
  versionText: {
    fontSize: 12,
    textAlign: 'center',
    marginBottom: 20,
  },
});
