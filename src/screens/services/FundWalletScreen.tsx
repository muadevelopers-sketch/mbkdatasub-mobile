import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  StatusBar,
  TouchableOpacity,
  Linking,
  ActivityIndicator,
  Alert,
  RefreshControl,
} from 'react-native';
import * as Clipboard from 'expo-clipboard';
import {
  ArrowLeft,
  Copy,
  Check,
  Zap,
  ShieldCheck,
  CreditCard,
  MessageCircle,
  Clock,
  Sparkles,
  RefreshCw,
  CheckCircle2,
} from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { apiClient } from '../../api/client';
import { formatNaira } from '../../utils/formatters';
import { triggerHaptic } from '../../utils/haptics';

export const FundWalletScreen = ({ navigation }: any) => {
  const { user, wallet, generateDedicatedAccounts, refreshData } = useAuth();
  const { colors, isDark } = useTheme();
  const [copiedPalm, setCopiedPalm] = useState(false);
  const [copiedPaga, setCopiedPaga] = useState(false);
  const [generating, setGenerating] = useState(false);
  const [checkingBalance, setCheckingBalance] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [newlyCredited, setNewlyCredited] = useState<number | null>(null);
  const [adminPhone, setAdminPhone] = useState('2349047050681');
  const lastBalanceRef = useRef(wallet.balance);

  useEffect(() => {
    apiClient.get('/admin/bank').then((res) => {
      const p = res.data?.bank?.whatsappNotificationPhone || res.data?.data?.whatsappNotificationPhone;
      if (p) setAdminPhone(p.replace(/[^0-9]/g, ''));
    }).catch(() => {});
  }, []);

  useEffect(() => {
    lastBalanceRef.current = wallet.balance;
  }, []);

  // Dedicated Account Auto-Polling (Checks balance every 5 seconds while user is on this screen)
  useEffect(() => {
    const timer = setInterval(async () => {
      try {
        await refreshData();
      } catch {}
    }, 5000);

    return () => clearInterval(timer);
  }, []);

  // Listen for newly arrived deposits
  useEffect(() => {
    if (wallet.balance > lastBalanceRef.current) {
      const added = wallet.balance - lastBalanceRef.current;
      triggerHaptic('success');
      setNewlyCredited(added);
      lastBalanceRef.current = wallet.balance;
      // Auto-hide banner after 8 seconds
      setTimeout(() => setNewlyCredited(null), 8000);
    } else {
      lastBalanceRef.current = wallet.balance;
    }
  }, [wallet.balance]);

  const onPullRefresh = async () => {
    setRefreshing(true);
    triggerHaptic('light');
    await refreshData();
    setRefreshing(false);
  };

  const handleManualCheck = async () => {
    triggerHaptic('medium');
    setCheckingBalance(true);
    await refreshData();
    setCheckingBalance(false);
    triggerHaptic('success');
  };

  const palmpayAccount = wallet.accounts.find(
    (a) => (a.bankName || '').toLowerCase().includes('palm') || a.type === 'palmpay'
  ) || { bankName: 'PalmPay', accountNumber: '', accountName: '' };

  const pagaAccount = wallet.accounts.find(
    (a) => (a.bankName || '').toLowerCase().includes('paga') || a.type === 'paga'
  ) || { bankName: 'Paga', accountNumber: '', accountName: '' };

  const handleCopy = async (num: string, type: 'palm' | 'paga') => {
    if (!num) return;
    await Clipboard.setStringAsync(num);
    triggerHaptic('success');
    if (type === 'palm') {
      setCopiedPalm(true);
      setTimeout(() => setCopiedPalm(false), 2000);
    } else {
      setCopiedPaga(true);
      setTimeout(() => setCopiedPaga(false), 2000);
    }
  };

  const handleGenerate = async () => {
    triggerHaptic('medium');
    setGenerating(true);
    const res = await generateDedicatedAccounts();
    setGenerating(false);
    if (res.success) {
      triggerHaptic('success');
      Alert.alert('Success', 'Your dedicated PalmPay and Paga funding accounts are now ready!');
    } else {
      triggerHaptic('error');
      Alert.alert('Notice', res.message || 'Accounts are being synced with the bank.');
    }
  };

  const handleWhatsAppProof = () => {
    triggerHaptic('light');
    const msg = encodeURIComponent(
      `Hello MBKDATASUB Admin, I just made a transfer to fund my wallet. My registered phone number is ${user?.phone || 'N/A'}.`
    );
    Linking.openURL(`https://wa.me/${adminPhone}?text=${msg}`);
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.bg }]}>
      <StatusBar
        barStyle={colors.statusBar === 'dark' ? 'dark-content' : 'light-content'}
        backgroundColor={colors.bg}
      />
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onPullRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
          />
        }
      >
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
          <Text style={[styles.navTitle, { color: colors.text }]}>Fund Wallet</Text>
          <View style={{ width: 40 }} />
        </View>

        {/* Current Balance Card */}
        <View style={[styles.balanceCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <Text style={[styles.balanceLabel, { color: colors.textSecondary }]}>Current Available Balance</Text>
          <Text style={[styles.balanceAmount, { color: colors.primary }]}>{formatNaira(wallet.balance)}</Text>
          <View style={[styles.speedPill, { backgroundColor: colors.successBg }]}>
            <Zap size={14} color={colors.success} />
            <Text style={[styles.speedText, { color: colors.success }]}>Instant Automated Credit • 0% Charges</Text>
          </View>
        </View>

        {/* Deposit Arrived Alert Banner */}
        {newlyCredited ? (
          <View
            style={[
              styles.depositAlertBanner,
              { backgroundColor: isDark ? 'rgba(16, 185, 129, 0.2)' : '#ECFDF5', borderColor: '#10B981' },
            ]}
          >
            <View style={styles.depositAlertLeft}>
              <CheckCircle2 size={24} color="#10B981" />
              <View style={{ flex: 1 }}>
                <Text style={styles.depositAlertTitle}>Payment Received & Credited!</Text>
                <Text style={[styles.depositAlertSub, { color: colors.textSecondary }]}>
                  +{formatNaira(newlyCredited)} has been added to your MBK balance.
                </Text>
              </View>
            </View>
          </View>
        ) : null}

        {/* Section Header */}
        <View style={styles.headerRow}>
          <View style={{ flex: 1 }}>
            <Text style={[styles.sectionHeader, { color: colors.text }]}>Your Dedicated Virtual Accounts</Text>
            <Text style={[styles.sectionSub, { color: colors.textSecondary }]}>
              Transfer funds from any bank app, USSD, OPay or Kuda directly to either account below. Your wallet will be credited automatically.
            </Text>
          </View>
          {(!palmpayAccount.accountNumber || !pagaAccount.accountNumber) && (
            <TouchableOpacity
              onPress={handleGenerate}
              disabled={generating}
              style={[styles.generatePill, { backgroundColor: colors.primaryBg, borderColor: colors.primary }]}
            >
              {generating ? (
                <ActivityIndicator size="small" color={colors.primary} />
              ) : (
                <RefreshCw size={13} color={colors.primary} />
              )}
              <Text style={[styles.generateText, { color: colors.primary }]}>
                {generating ? 'Assigning...' : 'Assign'}
              </Text>
            </TouchableOpacity>
          )}
        </View>

        {/* PalmPay Dedicated Card */}
        <View style={[styles.accountCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <View style={styles.cardTop}>
            <View style={styles.bankBadgePalm}>
              <Text style={styles.bankBadgeTextPalm}>PALMPAY VIRTUAL BANK</Text>
            </View>
            <View style={[styles.autoBadge, { backgroundColor: colors.successBg }]}>
              <View style={[styles.greenDot, { backgroundColor: colors.success }]} />
              <Text style={[styles.autoText, { color: colors.success }]}>AUTOMATED</Text>
            </View>
          </View>

          <View style={styles.accountNumberRow}>
            {palmpayAccount.accountNumber ? (
              <Text style={[styles.accountNumText, { color: colors.text }]}>
                {palmpayAccount.accountNumber}
              </Text>
            ) : (
              <TouchableOpacity
                onPress={handleGenerate}
                disabled={generating}
                style={styles.tapAssignRow}
              >
                {generating ? (
                  <ActivityIndicator size="small" color={colors.primary} />
                ) : (
                  <RefreshCw size={14} color={colors.primary} />
                )}
                <Text style={[styles.tapAssignText, { color: colors.primary }]}>
                  {generating ? 'Assigning Account...' : 'Tap to Assign Account'}
                </Text>
              </TouchableOpacity>
            )}

            {palmpayAccount.accountNumber ? (
              <TouchableOpacity
                style={[styles.copyBtn, { backgroundColor: colors.primaryBg }]}
                onPress={() => handleCopy(palmpayAccount.accountNumber, 'palm')}
                activeOpacity={0.7}
              >
                {copiedPalm ? (
                  <View style={styles.copyBtnInner}>
                    <Check size={14} color={colors.success} />
                    <Text style={[styles.copiedText, { color: colors.success }]}>Copied</Text>
                  </View>
                ) : (
                  <View style={styles.copyBtnInner}>
                    <Copy size={14} color={colors.primary} />
                    <Text style={[styles.copyText, { color: colors.primary }]}>Copy</Text>
                  </View>
                )}
              </TouchableOpacity>
            ) : null}
          </View>

          <View style={styles.cardFooter}>
            <Text style={[styles.footerLabel, { color: colors.textMuted }]}>Beneficiary:</Text>
            <Text style={[styles.footerVal, { color: colors.textSecondary }]}>
              {palmpayAccount.accountName || user?.fullName || 'MBKDATASUB'}
            </Text>
          </View>
        </View>

        {/* Paga Dedicated Card */}
        <View style={[styles.accountCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <View style={styles.cardTop}>
            <View style={styles.bankBadgePaga}>
              <Text style={styles.bankBadgeTextPaga}>PAGA VIRTUAL BANK</Text>
            </View>
            <View style={[styles.autoBadge, { backgroundColor: colors.successBg }]}>
              <View style={[styles.greenDot, { backgroundColor: colors.success }]} />
              <Text style={[styles.autoText, { color: colors.success }]}>AUTOMATED</Text>
            </View>
          </View>

          <View style={styles.accountNumberRow}>
            {pagaAccount.accountNumber ? (
              <Text style={[styles.accountNumText, { color: colors.text }]}>
                {pagaAccount.accountNumber}
              </Text>
            ) : (
              <TouchableOpacity
                onPress={handleGenerate}
                disabled={generating}
                style={styles.tapAssignRow}
              >
                {generating ? (
                  <ActivityIndicator size="small" color="#F59E0B" />
                ) : (
                  <RefreshCw size={14} color="#F59E0B" />
                )}
                <Text style={[styles.tapAssignText, { color: '#F59E0B' }]}>
                  {generating ? 'Assigning Account...' : 'Tap to Assign Account'}
                </Text>
              </TouchableOpacity>
            )}

            {pagaAccount.accountNumber ? (
              <TouchableOpacity
                style={[styles.copyBtn, { backgroundColor: 'rgba(245, 158, 11, 0.15)' }]}
                onPress={() => handleCopy(pagaAccount.accountNumber, 'paga')}
                activeOpacity={0.7}
              >
                {copiedPaga ? (
                  <View style={styles.copyBtnInner}>
                    <Check size={14} color={colors.success} />
                    <Text style={[styles.copiedText, { color: colors.success }]}>Copied</Text>
                  </View>
                ) : (
                  <View style={styles.copyBtnInner}>
                    <Copy size={14} color="#F59E0B" />
                    <Text style={[styles.copyText, { color: '#F59E0B' }]}>Copy</Text>
                  </View>
                )}
              </TouchableOpacity>
            ) : null}
          </View>

          <View style={styles.cardFooter}>
            <Text style={[styles.footerLabel, { color: colors.textMuted }]}>Beneficiary:</Text>
            <Text style={[styles.footerVal, { color: colors.textSecondary }]}>
              {pagaAccount.accountName || user?.fullName || 'MBKDATASUB'}
            </Text>
          </View>
        </View>

        {/* Step-by-Step Instructions */}
        <View style={[styles.stepsCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <Text style={[styles.stepsTitle, { color: colors.text }]}>How to Fund Your Wallet:</Text>
          <View style={styles.stepItem}>
            <View style={[styles.stepNumber, { backgroundColor: colors.primaryBg }]}>
              <Text style={[styles.stepNumText, { color: colors.primary }]}>1</Text>
            </View>
            <Text style={[styles.stepText, { color: colors.textSecondary }]}>
              Copy either the PalmPay or Paga account number above.
            </Text>
          </View>
          <View style={styles.stepItem}>
            <View style={[styles.stepNumber, { backgroundColor: colors.primaryBg }]}>
              <Text style={[styles.stepNumText, { color: colors.primary }]}>2</Text>
            </View>
            <Text style={[styles.stepText, { color: colors.textSecondary }]}>
              Open your mobile banking app or dial your bank USSD code.
            </Text>
          </View>
          <View style={styles.stepItem}>
            <View style={[styles.stepNumber, { backgroundColor: colors.primaryBg }]}>
              <Text style={[styles.stepNumText, { color: colors.primary }]}>3</Text>
            </View>
            <Text style={[styles.stepText, { color: colors.textSecondary }]}>
              Transfer the desired amount. Your MBK DATASUB balance updates in seconds.
            </Text>
          </View>
        </View>

        {/* Check Payment & Instant Balance Refresh Button */}
        <TouchableOpacity
          style={[styles.checkPaymentBtn, { backgroundColor: colors.primaryBg, borderColor: colors.primary }]}
          onPress={handleManualCheck}
          disabled={checkingBalance}
          activeOpacity={0.8}
        >
          {checkingBalance ? (
            <ActivityIndicator size="small" color={colors.primary} />
          ) : (
            <RefreshCw size={20} color={colors.primary} />
          )}
          <Text style={[styles.checkPaymentBtnText, { color: colors.primary }]}>
            {checkingBalance ? 'Checking Dedicated Accounts...' : 'I Have Sent the Money (Refresh Balance)'}
          </Text>
        </TouchableOpacity>

        {/* WhatsApp Notification Proof */}
        <TouchableOpacity
          style={styles.whatsappBtn}
          onPress={handleWhatsAppProof}
          activeOpacity={0.8}
        >
          <MessageCircle size={20} color="#FFFFFF" />
          <Text style={styles.whatsappBtnText}>Send Payment Proof on WhatsApp</Text>
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
    borderWidth: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  navTitle: {
    fontSize: 17,
    fontWeight: '700',
  },
  balanceCard: {
    borderRadius: 20,
    padding: 20,
    alignItems: 'center',
    borderWidth: 1,
    marginBottom: 20,
  },
  balanceLabel: {
    fontSize: 13,
    fontWeight: '500',
  },
  balanceAmount: {
    fontSize: 32,
    fontWeight: '800',
    marginTop: 6,
    marginBottom: 12,
  },
  speedPill: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 5,
    borderRadius: 20,
    gap: 6,
  },
  speedText: {
    fontSize: 11,
    fontWeight: '700',
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    gap: 12,
    marginBottom: 12,
  },
  generatePill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 10,
    borderWidth: 1,
  },
  generateText: {
    fontSize: 12,
    fontWeight: '700',
  },
  sectionHeader: {
    fontSize: 15,
    fontWeight: '700',
    marginBottom: 4,
  },
  sectionSub: {
    fontSize: 13,
    lineHeight: 18,
  },
  accountCard: {
    borderRadius: 20,
    padding: 18,
    borderWidth: 1.5,
    marginBottom: 14,
  },
  cardTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  bankBadgePalm: {
    backgroundColor: 'rgba(56, 189, 248, 0.15)',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
  },
  bankBadgeTextPalm: {
    color: '#0284C7',
    fontSize: 11,
    fontWeight: '800',
  },
  bankBadgePaga: {
    backgroundColor: 'rgba(245, 158, 11, 0.15)',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
  },
  bankBadgeTextPaga: {
    color: '#D97706',
    fontSize: 11,
    fontWeight: '800',
  },
  autoBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
    gap: 5,
  },
  greenDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  autoText: {
    fontSize: 10,
    fontWeight: '800',
  },
  accountNumberRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  accountNumText: {
    fontSize: 22,
    fontWeight: '900',
    letterSpacing: 2,
    fontFamily: 'monospace',
  },
  tapAssignRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingVertical: 4,
  },
  tapAssignText: {
    fontSize: 14,
    fontWeight: '700',
    textDecorationLine: 'underline',
  },
  copyBtn: {
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: 10,
  },
  copyBtnInner: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
  },
  copyText: {
    fontSize: 12,
    fontWeight: '700',
  },
  copiedText: {
    fontSize: 12,
    fontWeight: '700',
  },
  cardFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    borderTopWidth: 1,
    borderTopColor: 'rgba(150, 150, 150, 0.1)',
    paddingTop: 8,
  },
  footerLabel: {
    fontSize: 12,
  },
  footerVal: {
    fontSize: 12,
    fontWeight: '600',
  },
  stepsCard: {
    borderRadius: 20,
    padding: 18,
    borderWidth: 1,
    marginTop: 8,
    marginBottom: 16,
  },
  stepsTitle: {
    fontSize: 14,
    fontWeight: '700',
    marginBottom: 12,
  },
  stepItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 12,
    marginBottom: 10,
  },
  stepNumber: {
    width: 22,
    height: 22,
    borderRadius: 11,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 1,
  },
  stepNumText: {
    fontSize: 11,
    fontWeight: '800',
  },
  stepText: {
    fontSize: 13,
    flex: 1,
    lineHeight: 18,
  },
  whatsappBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#10B981',
    borderRadius: 16,
    paddingVertical: 14,
    gap: 8,
  },
  whatsappBtnText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '700',
  },
  depositAlertBanner: {
    borderRadius: 16,
    borderWidth: 1.5,
    padding: 14,
    marginBottom: 16,
  },
  depositAlertLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  depositAlertTitle: {
    fontSize: 14,
    fontWeight: '800',
    color: '#10B981',
  },
  depositAlertSub: {
    fontSize: 12,
    marginTop: 2,
  },
  checkPaymentBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 16,
    borderWidth: 1.5,
    paddingVertical: 14,
    gap: 10,
    marginBottom: 12,
  },
  checkPaymentBtnText: {
    fontSize: 14,
    fontWeight: '800',
  },
});
