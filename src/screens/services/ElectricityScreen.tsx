import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  StatusBar,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
} from 'react-native';
import * as Clipboard from 'expo-clipboard';
import {
  ArrowLeft,
  Zap,
  Check,
  UserCheck,
  Copy,
  Receipt,
} from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { apiClient } from '../../api/client';
import { formatNaira } from '../../utils/formatters';
import { triggerHaptic } from '../../utils/haptics';
import { BiometricPinModal } from '../../components/BiometricPinModal';
import { InsufficientBalanceModal } from '../../components/InsufficientBalanceModal';
import { TransactionSuccessModal } from '../../components/TransactionSuccessModal';

const DISCOS = [
  { id: 'ikeja-electric', name: 'IKEDC (Ikeja)' },
  { id: 'eko-electric', name: 'EKEDC (Eko)' },
  { id: 'abuja-electric', name: 'AEDC (Abuja)' },
  { id: 'ibadan-electric', name: 'IBEDC (Ibadan)' },
  { id: 'port-harcourt-electric', name: 'PHED (Port Harcourt)' },
  { id: 'kano-electric', name: 'KEDCO (Kano)' },
  { id: 'enugu-electric', name: 'EEDC (Enugu)' },
  { id: 'jos-electric', name: 'JED (Jos)' },
  { id: 'kaduna-electric', name: 'KAEDCO (Kaduna)' },
];

const PRESETS = [1000, 2000, 5000, 10000, 20000];

export const ElectricityScreen = ({ navigation }: any) => {
  const { wallet, refreshData } = useAuth();
  const { colors, isDark } = useTheme();
  const [selectedDisco, setSelectedDisco] = useState(DISCOS[0].id);
  const [meterType, setMeterType] = useState<'prepaid' | 'postpaid'>('prepaid');
  const [meterNumber, setMeterNumber] = useState('');
  const [customerName, setCustomerName] = useState('');
  const [customerAddress, setCustomerAddress] = useState('');
  const [verifying, setVerifying] = useState(false);
  const [amountStr, setAmountStr] = useState('2000');
  const [generatedToken, setGeneratedToken] = useState<string | null>(null);
  const [copiedToken, setCopiedToken] = useState(false);
  const [isPinModalVisible, setIsPinModalVisible] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [insufficientModalVisible, setInsufficientModalVisible] = useState(false);
  const [successModalVisible, setSuccessModalVisible] = useState(false);
  const [lastTxData, setLastTxData] = useState<any>(null);

  const amount = parseInt(amountStr, 10) || 0;

  const handleVerifyMeter = async (num: string) => {
    if (num.length < 10) return;
    setVerifying(true);
    try {
      const res = await apiClient.post('/services/electricity/verify-meter', {
        disco: selectedDisco,
        meterNumber: num,
        meterType: meterType === 'prepaid' ? 1 : 2,
      });
      if (res.data?.name) {
        setCustomerName(res.data.name);
        setCustomerAddress(res.data.address || '');
        triggerHaptic('success');
      } else {
        setCustomerName('');
        setCustomerAddress('');
      }
    } catch {
      setCustomerName('');
      setCustomerAddress('');
    } finally {
      setVerifying(false);
    }
  };

  const handleInitPurchase = () => {
    if (!meterNumber || meterNumber.length < 10) {
      triggerHaptic('error');
      Alert.alert('Invalid Meter', 'Please enter a valid meter number (at least 10 digits).');
      return;
    }
    if (amount < 500) {
      triggerHaptic('error');
      Alert.alert('Minimum Amount', 'Minimum electricity payment is ₦500.');
      return;
    }

    triggerHaptic('medium');
    setIsPinModalVisible(true);
  };

  const handleAuthorizePurchase = async (pin: string) => {
    setIsSubmitting(true);
    try {
      if (wallet.balance < amount) {
        setIsSubmitting(false);
        setIsPinModalVisible(false);
        triggerHaptic('error');
        setInsufficientModalVisible(true);
        return;
      }

      const res = await apiClient.post('/services/electricity', {
        disco: selectedDisco,
        meterNumber,
        meterType: meterType === 'prepaid' ? 1 : 2,
        amount,
        pin,
      });

      setIsSubmitting(false);
      setIsPinModalVisible(false);

      if (res.data?.success) {
        triggerHaptic('success');
        await refreshData();
        const token = res.data.token || res.data.transaction?.token;
        if (token) {
          setGeneratedToken(token);
        }
        setLastTxData({
          amount,
          recipient: `${meterNumber} (${customerName || selectedDisco.toUpperCase()})`,
          reference: res.data.transaction?.reference || `ELE-${Date.now().toString().slice(-8)}`,
          title: `${selectedDisco.toUpperCase()} Electricity Bill`,
          balanceAfter: res.data.balance || (wallet.balance - amount),
          token,
        });
        setSuccessModalVisible(true);
      } else {
        triggerHaptic('error');
        if ((res.data?.message || '').toLowerCase().includes('balance')) {
          setInsufficientModalVisible(true);
        } else {
          Alert.alert('Payment Failed', res.data?.message || 'Transaction could not be completed.');
        }
      }
    } catch (err: any) {
      setIsSubmitting(false);
      setIsPinModalVisible(false);
      triggerHaptic('error');
      const msg = err.response?.data?.message || err.message || 'Transaction could not be completed.';
      if (msg.toLowerCase().includes('balance')) {
        setInsufficientModalVisible(true);
      } else {
        Alert.alert('Payment Failed', msg);
      }
    }
  };

  const handleCopyToken = async () => {
    if (!generatedToken) return;
    await Clipboard.setStringAsync(generatedToken);
    triggerHaptic('success');
    setCopiedToken(true);
    setTimeout(() => setCopiedToken(false), 2000);
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.bg }]}>
      <StatusBar
        barStyle={colors.statusBar === 'dark' ? 'dark-content' : 'light-content'}
        backgroundColor={colors.bg}
      />
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
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
          <Text style={[styles.navTitle, { color: colors.text }]}>Electricity Bill & Token</Text>
          <View style={{ width: 40 }} />
        </View>

        {/* Balance Row */}
        <View style={[styles.balanceRow, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <Text style={[styles.balanceLabel, { color: colors.textSecondary }]}>Wallet Balance:</Text>
          <Text style={[styles.balanceValue, { color: colors.primary }]}>{formatNaira(wallet.balance)}</Text>
        </View>

        {/* Token Alert Banner if generated */}
        {generatedToken && (
          <View style={[styles.tokenCard, { backgroundColor: colors.successBg, borderColor: colors.success }]}>
            <View style={styles.tokenHeader}>
              <Receipt size={18} color={colors.success} />
              <Text style={[styles.tokenLabel, { color: colors.success }]}>YOUR 20-DIGIT METER TOKEN</Text>
            </View>
            <Text style={[styles.tokenCode, { color: colors.text }]}>{generatedToken}</Text>
            <TouchableOpacity
              style={[styles.copyTokenBtn, { backgroundColor: colors.primaryBg }]}
              onPress={handleCopyToken}
            >
              {copiedToken ? (
                <Check size={14} color={colors.success} />
              ) : (
                <Copy size={14} color={colors.primary} />
              )}
              <Text style={[styles.copyTokenText, { color: colors.primary }]}>
                {copiedToken ? 'Copied' : 'Copy Token'}
              </Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Meter Type Selector */}
        <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Meter Type</Text>
        <View style={styles.typeRow}>
          <TouchableOpacity
            style={[
              styles.typeBtn,
              { backgroundColor: colors.card, borderColor: colors.cardBorder },
              meterType === 'prepaid' && { backgroundColor: colors.primary, borderColor: colors.primary },
            ]}
            onPress={() => {
              triggerHaptic('selection');
              setMeterType('prepaid');
            }}
          >
            <Text
              style={[
                styles.typeBtnText,
                { color: colors.textSecondary },
                meterType === 'prepaid' && { color: '#FFFFFF', fontWeight: '800' },
              ]}
            >
              PREPAID (TOKEN)
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[
              styles.typeBtn,
              { backgroundColor: colors.card, borderColor: colors.cardBorder },
              meterType === 'postpaid' && { backgroundColor: colors.primary, borderColor: colors.primary },
            ]}
            onPress={() => {
              triggerHaptic('selection');
              setMeterType('postpaid');
            }}
          >
            <Text
              style={[
                styles.typeBtnText,
                { color: colors.textSecondary },
                meterType === 'postpaid' && { color: '#FFFFFF', fontWeight: '800' },
              ]}
            >
              POSTPAID (BILL)
            </Text>
          </TouchableOpacity>
        </View>

        {/* Disco Selector */}
        <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Select Electricity Provider</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.discoScroll}>
          {DISCOS.map((d) => {
            const isSelected = selectedDisco === d.id;
            return (
              <TouchableOpacity
                key={d.id}
                style={[
                  styles.discoChip,
                  { backgroundColor: colors.card, borderColor: colors.cardBorder },
                  isSelected && { backgroundColor: colors.primary, borderColor: colors.primary },
                ]}
                onPress={() => {
                  triggerHaptic('selection');
                  setSelectedDisco(d.id);
                  if (meterNumber.length >= 10) handleVerifyMeter(meterNumber);
                }}
              >
                <Text
                  style={[
                    styles.discoChipText,
                    { color: colors.textSecondary },
                    isSelected && { color: '#FFFFFF', fontWeight: '800' },
                  ]}
                >
                  {d.name}
                </Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>

        {/* Meter Number Input */}
        <View style={styles.inputGroup}>
          <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Meter Number</Text>
          <View style={[styles.inputWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <Zap size={20} color="#F59E0B" />
            <TextInput
              style={[styles.meterInput, { color: colors.text }]}
              placeholder="e.g. 45019283746 (11-digit Meter Number)"
              placeholderTextColor={colors.textMuted}
              value={meterNumber}
              onChangeText={(t) => {
                const clean = t.replace(/[^0-9]/g, '');
                setMeterNumber(clean);
                if (clean.length >= 10) {
                  handleVerifyMeter(clean);
                } else {
                  setCustomerName('');
                  setCustomerAddress('');
                }
              }}
              keyboardType="numeric"
            />
            {verifying && <ActivityIndicator size="small" color={colors.primary} />}
          </View>
        </View>

        {/* Customer Validation Result */}
        {customerName ? (
          <View style={[styles.verifiedBox, { backgroundColor: colors.successBg, borderColor: colors.success }]}>
            <UserCheck size={20} color={colors.success} />
            <View style={{ flex: 1 }}>
              <Text style={[styles.verifiedLabel, { color: colors.success }]}>VERIFIED METER HOLDER</Text>
              <Text style={[styles.verifiedName, { color: colors.text }]}>{customerName}</Text>
              {customerAddress ? (
                <Text style={[styles.verifiedAddress, { color: colors.textSecondary }]}>{customerAddress}</Text>
              ) : null}
            </View>
          </View>
        ) : null}

        {/* Amount Input */}
        <View style={styles.inputGroup}>
          <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Amount to Pay (₦)</Text>
          <View style={[styles.amountInputWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <Text style={[styles.nairaSymbol, { color: colors.primary }]}>₦</Text>
            <TextInput
              style={[styles.amountInput, { color: colors.text }]}
              placeholder="2000"
              placeholderTextColor={colors.textMuted}
              value={amountStr}
              onChangeText={(t) => setAmountStr(t.replace(/[^0-9]/g, ''))}
              keyboardType="numeric"
            />
          </View>
        </View>

        {/* Amount Presets */}
        <View style={styles.chipsRow}>
          {PRESETS.map((p) => (
            <TouchableOpacity
              key={p}
              style={[
                styles.chip,
                { backgroundColor: colors.card, borderColor: colors.cardBorder },
                amount === p && { backgroundColor: colors.primary, borderColor: colors.primary },
              ]}
              onPress={() => {
                triggerHaptic('selection');
                setAmountStr(String(p));
              }}
            >
              <Text
                style={[
                  styles.chipText,
                  { color: colors.textSecondary },
                  amount === p && { color: '#FFFFFF', fontWeight: '800' },
                ]}
              >
                ₦{p.toLocaleString()}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Checkout Button */}
        <TouchableOpacity
          style={[styles.checkoutBtn, { backgroundColor: colors.primary }, (!meterNumber || amount < 500) && styles.checkoutBtnDisabled]}
          onPress={handleInitPurchase}
          disabled={!meterNumber || amount < 500}
          activeOpacity={0.8}
        >
          <Zap size={20} color="#FFFFFF" />
          <Text style={styles.checkoutBtnText}>
            Pay {formatNaira(amount)} with 1-Tap Biometric
          </Text>
        </TouchableOpacity>
      </ScrollView>

      {/* Biometric & 4-Digit PIN Authorization Modal */}
      <BiometricPinModal
        visible={isPinModalVisible}
        onClose={() => setIsPinModalVisible(false)}
        onSuccess={handleAuthorizePurchase}
        title="Electricity Payment"
        amount={amount}
        recipient={meterNumber}
        subtitle={`${selectedDisco} • ${customerName || 'Customer'}`}
        loading={isSubmitting}
      />

      {/* Insufficient Balance Attractive Modal */}
      <InsufficientBalanceModal
        visible={insufficientModalVisible}
        onClose={() => setInsufficientModalVisible(false)}
        onFundWallet={() => navigation.navigate('FundWallet')}
        requiredAmount={amount}
        currentBalance={wallet.balance}
        serviceTitle={`${selectedDisco.toUpperCase()} Bill`}
      />

      {/* Transaction Success Celebratory Modal */}
      <TransactionSuccessModal
        visible={successModalVisible}
        onClose={() => setSuccessModalVisible(false)}
        serviceTitle={lastTxData?.title || 'Electricity Payment'}
        amount={lastTxData?.amount || amount}
        recipient={lastTxData?.recipient}
        reference={lastTxData?.reference}
        balanceAfter={lastTxData?.balanceAfter}
        token={lastTxData?.token || generatedToken || undefined}
        onViewReceipt={() => navigation.navigate('History')}
      />
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
    marginBottom: 16,
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
    fontSize: 17,
    fontWeight: '700',
    color: '#F8FAFC',
  },
  balanceRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'rgba(56, 189, 248, 0.08)',
    borderRadius: 14,
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderWidth: 1,
    borderColor: 'rgba(56, 189, 248, 0.2)',
    marginBottom: 20,
  },
  balanceLabel: {
    fontSize: 13,
    color: '#94A3B8',
    fontWeight: '500',
  },
  balanceValue: {
    fontSize: 15,
    fontWeight: '800',
    color: '#38BDF8',
  },
  tokenCard: {
    backgroundColor: '#1E293B',
    borderRadius: 18,
    padding: 16,
    borderWidth: 1.5,
    borderColor: '#10B981',
    marginBottom: 20,
    alignItems: 'center',
  },
  tokenHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 8,
  },
  tokenLabel: {
    fontSize: 11,
    fontWeight: '800',
    color: '#34D399',
    letterSpacing: 0.5,
  },
  tokenCode: {
    fontSize: 22,
    fontWeight: '800',
    color: '#F8FAFC',
    letterSpacing: 2,
    marginVertical: 4,
  },
  copyTokenBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#0F172A',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 6,
    gap: 6,
    borderWidth: 1,
    borderColor: '#334155',
  },
  copyTokenText: {
    fontSize: 12,
    fontWeight: '700',
    color: '#38BDF8',
  },
  sectionTitle: {
    fontSize: 13,
    fontWeight: '700',
    color: '#94A3B8',
    textTransform: 'uppercase',
    letterSpacing: 0.6,
    marginBottom: 10,
  },
  typeRow: {
    flexDirection: 'row',
    gap: 10,
    marginBottom: 18,
  },
  typeBtn: {
    flex: 1,
    backgroundColor: '#1E293B',
    borderRadius: 12,
    paddingVertical: 12,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#334155',
  },
  typeBtnActive: {
    backgroundColor: '#2563EB',
    borderColor: '#3B82F6',
  },
  typeBtnText: {
    fontSize: 12,
    fontWeight: '700',
    color: '#94A3B8',
  },
  typeBtnTextActive: {
    color: '#FFFFFF',
  },
  discoScroll: {
    marginBottom: 20,
  },
  discoChip: {
    backgroundColor: '#1E293B',
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#334155',
    marginRight: 8,
  },
  discoChipActive: {
    backgroundColor: 'rgba(56, 189, 248, 0.15)',
    borderColor: '#38BDF8',
  },
  discoChipText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#94A3B8',
  },
  discoChipTextActive: {
    color: '#38BDF8',
    fontWeight: '800',
  },
  inputGroup: {
    marginBottom: 16,
  },
  inputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1E293B',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#334155',
    paddingHorizontal: 16,
    height: 52,
    gap: 10,
  },
  meterInput: {
    flex: 1,
    fontSize: 16,
    color: '#F8FAFC',
    fontWeight: '600',
  },
  verifiedBox: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    backgroundColor: 'rgba(16, 185, 129, 0.1)',
    borderRadius: 14,
    padding: 12,
    borderWidth: 1,
    borderColor: 'rgba(16, 185, 129, 0.3)',
    gap: 10,
    marginBottom: 16,
  },
  verifiedLabel: {
    fontSize: 10,
    fontWeight: '800',
    color: '#34D399',
    letterSpacing: 0.5,
  },
  verifiedName: {
    fontSize: 14,
    fontWeight: '700',
    color: '#F8FAFC',
    marginTop: 2,
  },
  verifiedAddress: {
    fontSize: 12,
    color: '#94A3B8',
    marginTop: 2,
  },
  amountInputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1E293B',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#334155',
    paddingHorizontal: 16,
    height: 54,
  },
  nairaSymbol: {
    fontSize: 20,
    fontWeight: '800',
    color: '#38BDF8',
    marginRight: 8,
  },
  amountInput: {
    flex: 1,
    fontSize: 20,
    fontWeight: '800',
    color: '#F8FAFC',
  },
  chipsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 24,
  },
  chip: {
    backgroundColor: '#1E293B',
    paddingVertical: 8,
    paddingHorizontal: 14,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#334155',
  },
  chipActive: {
    backgroundColor: '#2563EB',
    borderColor: '#3B82F6',
  },
  chipText: {
    fontSize: 12,
    fontWeight: '700',
    color: '#94A3B8',
  },
  chipTextActive: {
    color: '#FFFFFF',
  },
  checkoutBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2563EB',
    borderRadius: 16,
    height: 54,
    gap: 10,
  },
  checkoutBtnDisabled: {
    opacity: 0.5,
  },
  checkoutBtnText: {
    fontSize: 15,
    fontWeight: '700',
    color: '#FFFFFF',
  },
});
