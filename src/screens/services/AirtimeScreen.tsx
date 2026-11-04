import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  StatusBar,
  TextInput,
  TouchableOpacity,
  Alert,
  Image,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';;
import { useFocusEffect } from '@react-navigation/native';
import * as Clipboard from 'expo-clipboard';
import {
  ArrowLeft,
  Smartphone,
  Check,
  Zap,
  ClipboardPaste,
  Sparkles,
} from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { apiClient } from '../../api/client';
import { formatNaira } from '../../utils/formatters';
import { triggerHaptic } from '../../utils/haptics';
import { BiometricPinModal } from '../../components/BiometricPinModal';
import { InsufficientBalanceModal } from '../../components/InsufficientBalanceModal';
import { TransactionSuccessModal } from '../../components/TransactionSuccessModal';

const NETWORKS = [
  { id: 'MTN', name: 'MTN', color: '#EAB308', discount: 2, prefixes: ['0803', '0806', '0703', '0706', '0813', '0816', '0810', '0814', '0903', '0906', '0913', '0916'] },
  { id: 'Airtel', name: 'Airtel', color: '#EF4444', discount: 2, prefixes: ['0802', '0808', '0708', '0812', '0701', '0902', '0901', '0904', '0907', '0912'] },
  { id: 'Glo', name: 'Glo', color: '#10B981', discount: 2.5, prefixes: ['0805', '0807', '0705', '0815', '0811', '0905', '0915'] },
  { id: '9mobile', name: '9mobile', color: '#059669', discount: 2.5, prefixes: ['0809', '0817', '0818', '0909', '0908'] },
];

const NETWORK_LOGOS: Record<string, any> = {
  MTN: require('../../../assets/networks/mtn.png'),
  Airtel: require('../../../assets/networks/airtel.png'),
  Glo: require('../../../assets/networks/glo.png'),
  '9mobile': require('../../../assets/networks/9mobile.png'),
};

const PRESET_AMOUNTS = [100, 200, 500, 1000, 2000, 5000];

export const AirtimeScreen = ({ navigation }: any) => {
  const { wallet, refreshData } = useAuth();
  const { colors, isDark } = useTheme();
  const [selectedNetwork, setSelectedNetwork] = useState('MTN');
  const [phone, setPhone] = useState('');
  const [amountStr, setAmountStr] = useState('500');
  const [isPinModalVisible, setIsPinModalVisible] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [insufficientModalVisible, setInsufficientModalVisible] = useState(false);
  const [successModalVisible, setSuccessModalVisible] = useState(false);
  const [lastTxData, setLastTxData] = useState<any>(null);
  const [liveDiscountRate, setLiveDiscountRate] = useState<number>(2);
  const [isServiceActive, setIsServiceActive] = useState<boolean>(true);

  useFocusEffect(
    useCallback(() => {
      fetchLiveConfig();
    }, [])
  );

  const fetchLiveConfig = async () => {
    try {
      const res = await apiClient.get('/services/configs');
      if (res.data?.success && Array.isArray(res.data.services)) {
        const airtime = res.data.services.find((s: any) => s.serviceCode === 'airtime');
        if (airtime) {
          setIsServiceActive(airtime.isActive !== false);
          if (typeof airtime.discountRate === 'number' && airtime.discountRate >= 0) {
            setLiveDiscountRate(airtime.discountRate);
          }
        }
      }
    } catch (e) {
      console.warn('[Fetch Airtime Config Notice]', e);
    }
  };

  const amount = parseInt(amountStr, 10) || 0;
  const currentNet = NETWORKS.find((n) => n.id === selectedNetwork) || NETWORKS[0];
  const discountRate = liveDiscountRate;
  const discountAmount = Math.round((amount * discountRate) / 100);
  const finalDebit = Math.max(0, amount - discountAmount);

  const handlePhoneChange = (val: string) => {
    const cleaned = val.replace(/[^0-9]/g, '').slice(0, 11);
    setPhone(cleaned);

    if (cleaned.length >= 4) {
      const prefix = cleaned.substring(0, 4);
      const match = NETWORKS.find((n) => n.prefixes.includes(prefix));
      if (match && match.id !== selectedNetwork) {
        triggerHaptic('selection');
        setSelectedNetwork(match.id);
      }
    }
  };

  const handlePastePhone = async () => {
    const text = await Clipboard.getStringAsync();
    if (text) {
      triggerHaptic('light');
      handlePhoneChange(text);
    }
  };

  const handleInitPurchase = () => {
    if (!isServiceActive) {
      triggerHaptic('error');
      Alert.alert('Service Offline', 'Airtime recharge service is currently under maintenance or disabled by administrator.');
      return;
    }
    if (!phone || phone.length < 11) {
      triggerHaptic('error');
      Alert.alert('Invalid Phone', 'Please enter a valid 11-digit phone number.');
      return;
    }
    if (amount < 50) {
      triggerHaptic('error');
      Alert.alert('Minimum Amount', 'Minimum airtime recharge is ₦50.');
      return;
    }

    triggerHaptic('medium');
    setIsPinModalVisible(true);
  };

  const handleAuthorizePurchase = async (pin: string) => {
    setIsSubmitting(true);
    try {
      if (wallet.balance < finalDebit) {
        setIsSubmitting(false);
        setIsPinModalVisible(false);
        triggerHaptic('error');
        setInsufficientModalVisible(true);
        return;
      }

      const res = await apiClient.post('/services/airtime', {
        network: selectedNetwork,
        phone,
        amount,
        pin,
      });

      setIsSubmitting(false);
      setIsPinModalVisible(false);

      if (res.data?.success) {
        triggerHaptic('success');
        await refreshData();
        setLastTxData({
          amount,
          recipient: `${phone} (${selectedNetwork})`,
          reference: res.data.transaction?.reference || `AIR-${Date.now().toString().slice(-8)}`,
          title: `${selectedNetwork} Airtime VTU`,
          balanceAfter: res.data.balance || (wallet.balance - finalDebit),
        });
        setSuccessModalVisible(true);
      } else {
        triggerHaptic('error');
        if ((res.data?.message || '').toLowerCase().includes('balance')) {
          setInsufficientModalVisible(true);
        } else {
          Alert.alert('Recharge Failed', res.data?.message || 'Transaction could not be completed.');
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
        Alert.alert('Recharge Failed', msg);
      }
    }
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
          <Text style={[styles.navTitle, { color: colors.text }]}>Airtime VTU Recharge</Text>
          <View style={{ width: 40 }} />
        </View>

        {/* Balance Row */}
        <View style={[styles.balanceRow, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <Text style={[styles.balanceLabel, { color: colors.textSecondary }]}>Wallet Balance:</Text>
          <Text style={[styles.balanceValue, { color: colors.primary }]}>{formatNaira(wallet.balance)}</Text>
        </View>

        {/* Network Selector */}
        <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Select Network</Text>
        <View style={styles.networkGrid}>
          {NETWORKS.map((net) => {
            const isSelected = selectedNetwork === net.id;
            return (
              <TouchableOpacity
                key={net.id}
                style={[
                  styles.networkCard,
                  { backgroundColor: colors.card, borderColor: colors.cardBorder },
                  isSelected && { borderColor: net.color, backgroundColor: isDark ? 'rgba(30, 41, 59, 0.9)' : '#EFF6FF' },
                ]}
                onPress={() => {
                  triggerHaptic('selection');
                  setSelectedNetwork(net.id);
                }}
                activeOpacity={0.7}
              >
                <View style={styles.networkLogoContainer}>
                  {NETWORK_LOGOS[net.id] ? (
                    <Image
                      source={NETWORK_LOGOS[net.id]}
                      style={styles.networkLogo}
                      resizeMode="contain"
                    />
                  ) : (
                    <View style={[styles.networkDot, { backgroundColor: net.color }]} />
                  )}
                </View>
                <Text style={[styles.networkName, { color: colors.text }, isSelected && { color: net.color, fontWeight: '800' }]}>
                  {net.name}
                </Text>
                <Text style={[styles.discountBadge, { color: colors.success }]}>{net.discount}% OFF</Text>
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Recipient Phone */}
        <View style={styles.inputGroup}>
          <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Recipient Phone Number</Text>
          <View style={[styles.phoneInputWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <Smartphone size={20} color={colors.textMuted} />
            <TextInput
              style={[styles.phoneInput, { color: colors.text }]}
              placeholder="0802 345 6789"
              placeholderTextColor={colors.textMuted}
              value={phone}
              onChangeText={handlePhoneChange}
              keyboardType="phone-pad"
              maxLength={11}
            />
            <TouchableOpacity
              style={[styles.pasteBtn, { backgroundColor: colors.primaryBg }]}
              onPress={handlePastePhone}
            >
              <ClipboardPaste size={16} color={colors.primary} />
              <Text style={[styles.pasteText, { color: colors.primary }]}>Paste</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Amount Input */}
        <View style={styles.inputGroup}>
          <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Recharge Amount (₦)</Text>
          <View style={[styles.amountInputWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <Text style={[styles.nairaSymbol, { color: colors.primary }]}>₦</Text>
            <TextInput
              style={[styles.amountInput, { color: colors.text }]}
              placeholder="500"
              placeholderTextColor={colors.textMuted}
              value={amountStr}
              onChangeText={(t) => setAmountStr(t.replace(/[^0-9]/g, ''))}
              keyboardType="numeric"
            />
          </View>
        </View>

        {/* Fast Chips */}
        <View style={styles.chipsRow}>
          {PRESET_AMOUNTS.map((p) => (
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

        {/* Discount Breakdown Card */}
        {amount > 0 && (
          <View style={[styles.breakdownCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <View style={styles.breakdownRow}>
              <Text style={[styles.breakdownLabel, { color: colors.textSecondary }]}>Face Value</Text>
              <Text style={[styles.breakdownValue, { color: colors.text }]}>₦{amount.toLocaleString()}</Text>
            </View>
            <View style={styles.breakdownRow}>
              <Text style={[styles.breakdownLabel, { color: colors.textSecondary }]}>Instant Cashback ({discountRate}%)</Text>
              <Text style={[styles.discountValue, { color: colors.success }]}>- ₦{discountAmount.toLocaleString()}</Text>
            </View>
            <View style={[styles.breakdownRow, styles.totalRow, { borderTopColor: colors.cardBorder }]}>
              <Text style={[styles.totalLabel, { color: colors.text }]}>Amount to Pay</Text>
              <Text style={[styles.totalValue, { color: colors.primary }]}>{formatNaira(finalDebit)}</Text>
            </View>
          </View>
        )}

        {/* Checkout Button */}
        <TouchableOpacity
          style={[styles.checkoutBtn, { backgroundColor: colors.primary }, (!phone || amount < 50) && styles.checkoutBtnDisabled]}
          onPress={handleInitPurchase}
          disabled={!phone || amount < 50}
          activeOpacity={0.8}
        >
          <View style={styles.checkoutBtnContent}>
            <Zap size={20} color="#FFFFFF" />
            <Text style={styles.checkoutBtnText}>
              Pay {formatNaira(finalDebit)} with 1-Tap Biometric
            </Text>
          </View>
        </TouchableOpacity>
      </ScrollView>

      {/* Biometric & 4-Digit PIN Authorization Modal */}
      <BiometricPinModal
        visible={isPinModalVisible}
        onClose={() => setIsPinModalVisible(false)}
        onSuccess={handleAuthorizePurchase}
        title={`${selectedNetwork} Airtime VTU`}
        amount={finalDebit}
        recipient={phone}
        subtitle={`Face Value: ₦${amount.toLocaleString()} (Saved ₦${discountAmount})`}
        loading={isSubmitting}
      />

      {/* Insufficient Balance Attractive Modal */}
      <InsufficientBalanceModal
        visible={insufficientModalVisible}
        onClose={() => setInsufficientModalVisible(false)}
        onFundWallet={() => navigation.navigate('FundWallet')}
        requiredAmount={finalDebit}
        currentBalance={wallet.balance}
        serviceTitle={`${selectedNetwork} ₦${amount.toLocaleString()} Airtime`}
      />

      {/* Transaction Success Celebratory Modal */}
      <TransactionSuccessModal
        visible={successModalVisible}
        onClose={() => setSuccessModalVisible(false)}
        serviceTitle={lastTxData?.title || `${selectedNetwork} Airtime`}
        amount={lastTxData?.amount || amount}
        recipient={lastTxData?.recipient}
        reference={lastTxData?.reference}
        balanceAfter={lastTxData?.balanceAfter}
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
  sectionTitle: {
    fontSize: 13,
    fontWeight: '700',
    color: '#94A3B8',
    textTransform: 'uppercase',
    letterSpacing: 0.6,
    marginBottom: 10,
  },
  networkGrid: {
    flexDirection: 'row',
    gap: 10,
    marginBottom: 20,
  },
  networkCard: {
    flex: 1,
    backgroundColor: '#1E293B',
    borderRadius: 14,
    paddingVertical: 12,
    alignItems: 'center',
    borderWidth: 1.5,
    borderColor: '#334155',
  },
  networkDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginBottom: 6,
  },
  networkLogoContainer: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 6,
    overflow: 'hidden',
  },
  networkLogo: {
    width: 26,
    height: 26,
    borderRadius: 13,
  },
  networkName: {
    fontSize: 12,
    fontWeight: '700',
    color: '#CBD5E1',
  },
  discountBadge: {
    fontSize: 9,
    color: '#34D399',
    fontWeight: '800',
    marginTop: 2,
  },
  inputGroup: {
    marginBottom: 18,
  },
  phoneInputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1E293B',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#334155',
    paddingHorizontal: 14,
    height: 52,
    gap: 10,
  },
  phoneInput: {
    flex: 1,
    fontSize: 16,
    color: '#F8FAFC',
    fontWeight: '600',
  },
  pasteBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(56, 189, 248, 0.1)',
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 8,
    gap: 4,
  },
  pasteText: {
    fontSize: 12,
    color: '#38BDF8',
    fontWeight: '700',
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
    marginBottom: 20,
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
  breakdownCard: {
    backgroundColor: '#1E293B',
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: '#334155',
    gap: 10,
    marginBottom: 24,
  },
  breakdownRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  breakdownLabel: {
    fontSize: 13,
    color: '#94A3B8',
  },
  breakdownValue: {
    fontSize: 13,
    fontWeight: '600',
    color: '#F8FAFC',
  },
  discountValue: {
    fontSize: 13,
    fontWeight: '700',
    color: '#10B981',
  },
  totalRow: {
    borderTopWidth: 1,
    borderTopColor: '#334155',
    paddingTop: 10,
  },
  totalLabel: {
    fontSize: 14,
    fontWeight: '700',
    color: '#F8FAFC',
  },
  totalValue: {
    fontSize: 18,
    fontWeight: '800',
    color: '#38BDF8',
  },
  checkoutBtn: {
    backgroundColor: '#2563EB',
    borderRadius: 16,
    paddingVertical: 16,
    alignItems: 'center',
  },
  checkoutBtnDisabled: {
    opacity: 0.5,
  },
  checkoutBtnContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  checkoutBtnText: {
    fontSize: 15,
    fontWeight: '700',
    color: '#FFFFFF',
  },
});
