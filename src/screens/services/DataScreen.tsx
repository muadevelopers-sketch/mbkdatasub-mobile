import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  StatusBar,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  Image,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';;
import { useFocusEffect } from '@react-navigation/native';
import * as Clipboard from 'expo-clipboard';
import {
  ArrowLeft,
  Wifi,
  Smartphone,
  Check,
  ShieldCheck,
  Sparkles,
  ClipboardPaste,
  ScanFace,
  Fingerprint,
} from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { apiClient } from '../../api/client';
import { formatNaira } from '../../utils/formatters';
import { triggerHaptic } from '../../utils/haptics';
import { BiometricPinModal } from '../../components/BiometricPinModal';
import { InsufficientBalanceModal } from '../../components/InsufficientBalanceModal';
import { TransactionSuccessModal } from '../../components/TransactionSuccessModal';

interface Plan {
  id: string | number;
  planId?: string | number;
  name: string;
  network: string;
  type?: string;
  price: number;
  validity?: string;
}

const DEFAULT_PLANS: Plan[] = [
  // MTN
  { id: 'mtn-500mb', planId: '1001', name: '500MB SME', network: 'MTN', type: 'SME', price: 150, validity: '30 Days' },
  { id: 'mtn-1gb', planId: '1002', name: '1.0GB SME', network: 'MTN', type: 'SME', price: 275, validity: '30 Days' },
  { id: 'mtn-2gb', planId: '1003', name: '2.0GB SME', network: 'MTN', type: 'SME', price: 550, validity: '30 Days' },
  { id: 'mtn-3gb', planId: '1004', name: '3.0GB SME', network: 'MTN', type: 'SME', price: 825, validity: '30 Days' },
  { id: 'mtn-5gb', planId: '1005', name: '5.0GB SME', network: 'MTN', type: 'SME', price: 1375, validity: '30 Days' },
  { id: 'mtn-10gb', planId: '1006', name: '10.0GB SME', network: 'MTN', type: 'SME', price: 2750, validity: '30 Days' },
  // Airtel
  { id: 'airtel-500mb', planId: '2001', name: '500MB Gifting', network: 'Airtel', type: 'Gifting', price: 160, validity: '30 Days' },
  { id: 'airtel-1gb', planId: '2002', name: '1.0GB Corporate', network: 'Airtel', type: 'Corporate', price: 285, validity: '30 Days' },
  { id: 'airtel-2gb', planId: '2003', name: '2.0GB Corporate', network: 'Airtel', type: 'Corporate', price: 570, validity: '30 Days' },
  { id: 'airtel-5gb', planId: '2004', name: '5.0GB Corporate', network: 'Airtel', type: 'Corporate', price: 1425, validity: '30 Days' },
  // Glo
  { id: 'glo-1gb', planId: '3001', name: '1.0GB Corporate', network: 'Glo', type: 'Corporate', price: 260, validity: '30 Days' },
  { id: 'glo-2gb', planId: '3002', name: '2.0GB Corporate', network: 'Glo', type: 'Corporate', price: 520, validity: '30 Days' },
  { id: 'glo-5gb', planId: '3003', name: '5.0GB Corporate', network: 'Glo', type: 'Corporate', price: 1300, validity: '30 Days' },
  // 9mobile
  { id: '9mob-1gb', planId: '4001', name: '1.0GB Corporate', network: '9mobile', type: 'Corporate', price: 220, validity: '30 Days' },
  { id: '9mob-2gb', planId: '4002', name: '2.0GB Corporate', network: '9mobile', type: 'Corporate', price: 440, validity: '30 Days' },
];

const NETWORKS = [
  { id: 'MTN', name: 'MTN', color: '#EAB308', prefixes: ['0803', '0806', '0703', '0706', '0813', '0816', '0810', '0814', '0903', '0906', '0913', '0916'] },
  { id: 'Airtel', name: 'Airtel', color: '#EF4444', prefixes: ['0802', '0808', '0708', '0812', '0701', '0902', '0901', '0904', '0907', '0912'] },
  { id: 'Glo', name: 'Glo', color: '#10B981', prefixes: ['0805', '0807', '0705', '0815', '0811', '0905', '0915'] },
  { id: '9mobile', name: '9mobile', color: '#059669', prefixes: ['0809', '0817', '0818', '0909', '0908'] },
];

const NETWORK_LOGOS: Record<string, any> = {
  MTN: require('../../../assets/networks/mtn.png'),
  Airtel: require('../../../assets/networks/airtel.png'),
  Glo: require('../../../assets/networks/glo.png'),
  '9mobile': require('../../../assets/networks/9mobile.png'),
};

export const DataScreen = ({ navigation }: any) => {
  const { wallet, refreshData } = useAuth();
  const { colors, isDark } = useTheme();
  const [selectedNetwork, setSelectedNetwork] = useState('MTN');
  const [planType, setPlanType] = useState('SME');
  const [phone, setPhone] = useState('');
  const [plans, setPlans] = useState<Plan[]>(DEFAULT_PLANS);
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null);
  const [loadingPlans, setLoadingPlans] = useState(false);
  const [isPinModalVisible, setIsPinModalVisible] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [insufficientModalVisible, setInsufficientModalVisible] = useState(false);
  const [successModalVisible, setSuccessModalVisible] = useState(false);
  const [lastTxData, setLastTxData] = useState<any>(null);

  useFocusEffect(
    useCallback(() => {
      fetchLivePlans();
    }, [])
  );

  const fetchLivePlans = async () => {
    setLoadingPlans(true);
    try {
      // Single source of truth: fetch live admin/backend plans
      const res = await apiClient.get('/services/data/plans');
      const incoming = res.data?.plans || res.data?.data;
      if (res.data?.success && Array.isArray(incoming) && incoming.length > 0) {
        const mapped: Plan[] = incoming.map((p: any) => ({
          id: String(p.id),
          planId: String(p.planId || p.id),
          name: p.name,
          network: p.network,
          type: (p.type || 'SME').toUpperCase(),
          price: Number(p.userPrice ?? p.price ?? 0),
          validity: p.validity || '30 Days',
          isActive: p.isActive !== false,
        }));
        setPlans(mapped);
      }
    } catch {
      // Keep existing plans in state
    } finally {
      setLoadingPlans(false);
    }
  };

  const handlePhoneChange = (val: string) => {
    const cleaned = val.replace(/[^0-9]/g, '').slice(0, 11);
    setPhone(cleaned);

    // Auto detect network by prefix
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

  // Filter plans by selected network and plan type
  const networkPlans = plans.filter((p) => {
    const netMatch = (p.network || '').toLowerCase() === selectedNetwork.toLowerCase();
    if (!netMatch) return false;
    const planTypeUpper = (p.type || '').toUpperCase();
    return planTypeUpper === planType || planTypeUpper.includes(planType);
  });

  const handleCheckoutInit = () => {
    if (!phone || phone.length < 11) {
      triggerHaptic('error');
      Alert.alert('Invalid Phone', 'Please enter a valid 11-digit recipient phone number.');
      return;
    }
    if (!selectedPlan) {
      triggerHaptic('error');
      Alert.alert('Select Plan', 'Please select a data bundle to purchase.');
      return;
    }

    triggerHaptic('medium');
    setIsPinModalVisible(true);
  };

  const handleAuthorizePurchase = async (pin: string) => {
    if (!selectedPlan) return;
    setIsSubmitting(true);
    try {
      if (wallet.balance < selectedPlan.price) {
        setIsSubmitting(false);
        setIsPinModalVisible(false);
        triggerHaptic('error');
        setInsufficientModalVisible(true);
        return;
      }

      const res = await apiClient.post('/services/data', {
        network: selectedNetwork,
        phone,
        planId: selectedPlan.planId || selectedPlan.id,
        pin,
      });

      setIsSubmitting(false);
      setIsPinModalVisible(false);

      if (res.data?.success) {
        triggerHaptic('success');
        await refreshData();
        setLastTxData({
          amount: selectedPlan.price,
          recipient: `${phone} (${selectedNetwork})`,
          reference: res.data.transaction?.reference || `DAT-${Date.now().toString().slice(-8)}`,
          title: `${selectedNetwork} ${selectedPlan.name}`,
          balanceAfter: res.data.balance || (wallet.balance - selectedPlan.price),
        });
        setSuccessModalVisible(true);
      } else {
        triggerHaptic('error');
        if ((res.data?.message || '').toLowerCase().includes('balance')) {
          setInsufficientModalVisible(true);
        } else {
          Alert.alert('Purchase Failed', res.data?.message || 'Transaction could not be completed.');
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
        Alert.alert('Purchase Failed', msg);
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
          <Text style={[styles.navTitle, { color: colors.text }]}>Buy Mobile Data</Text>
          <View style={{ width: 40 }} />
        </View>

        {/* Balance Badge */}
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
                  setSelectedPlan(null);
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
                {isSelected && (
                  <View style={[styles.checkCircle, { backgroundColor: net.color }]}>
                    <Check size={12} color="#0F172A" />
                  </View>
                )}
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Recipient Phone Input */}
        {/* Recipient Phone with Special Auto-detect Placeholder */}
        <View style={styles.inputGroup}>
          <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Recipient Phone Number</Text>
          <View style={[styles.phoneInputWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <Smartphone size={20} color={colors.textMuted} />
            <TextInput
              style={[styles.phoneInput, { color: colors.text }]}
              placeholder="0803 123 4567"
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

        {/* Plan Type Selector */}
        <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Plan Type</Text>
        <View style={styles.typeTabs}>
          {['SME', 'GIFTING', 'CORPORATE'].map((t) => (
            <TouchableOpacity
              key={t}
              style={[
                styles.typeTab,
                { backgroundColor: colors.card, borderColor: colors.cardBorder },
                planType === t && { backgroundColor: colors.primary, borderColor: colors.primary },
              ]}
              onPress={() => {
                triggerHaptic('selection');
                setPlanType(t);
              }}
            >
              <Text style={[styles.typeTabText, { color: colors.textSecondary }, planType === t && { color: '#FFFFFF', fontWeight: '800' }]}>
                {t}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Plans Grid */}
        <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Select Data Plan</Text>
        {loadingPlans ? (
          <ActivityIndicator size="small" color={colors.primary} style={{ marginVertical: 20 }} />
        ) : (
          <View style={styles.plansList}>
            {networkPlans.length === 0 ? (
              <View style={[styles.planCard, { backgroundColor: colors.card, borderColor: colors.cardBorder, justifyContent: 'center', alignItems: 'center', paddingVertical: 28 }]}>
                <Text style={{ color: colors.textMuted, fontSize: 13, fontWeight: '500', textAlign: 'center' }}>
                  No {planType} plans currently listed for {selectedNetwork}.
                </Text>
              </View>
            ) : (
              networkPlans.map((plan) => {
                const isSelected = selectedPlan?.id === plan.id;
                return (
                  <TouchableOpacity
                    key={plan.id}
                    style={[
                      styles.planCard,
                      { backgroundColor: colors.card, borderColor: colors.cardBorder },
                      isSelected && { borderColor: colors.primary, backgroundColor: colors.primaryBg },
                    ]}
                    onPress={() => {
                      triggerHaptic('selection');
                      setSelectedPlan(plan);
                    }}
                    activeOpacity={0.7}
                  >
                    <View style={styles.planInfo}>
                      <Text style={[styles.planName, { color: colors.text }]}>{plan.name}</Text>
                      <Text style={[styles.planValidity, { color: colors.textSecondary }]}>
                        {plan.validity || '30 Days Validity'} • {plan.type || 'SME'}
                      </Text>
                    </View>
                    <View style={styles.planPriceCol}>
                      <Text style={[styles.planPrice, { color: colors.text }, isSelected && { color: colors.primary }]}>
                        {formatNaira(plan.price)}
                      </Text>
                      {isSelected && (
                        <View style={[styles.planCheck, { backgroundColor: colors.primary }]}>
                          <Check size={14} color="#FFFFFF" />
                        </View>
                      )}
                    </View>
                  </TouchableOpacity>
                );
              })
            )}
          </View>
        )}

        {/* Checkout Button */}
        <TouchableOpacity
          style={[styles.checkoutBtn, { backgroundColor: colors.primary }, (!phone || !selectedPlan) && styles.checkoutBtnDisabled]}
          onPress={handleCheckoutInit}
          disabled={!phone || !selectedPlan}
          activeOpacity={0.8}
        >
          <View style={styles.checkoutBtnContent}>
            <Wifi size={20} color="#FFFFFF" />
            <Text style={styles.checkoutBtnText}>
              {selectedPlan
                ? `Pay ${formatNaira(selectedPlan.price)} with 1-Tap Biometric`
                : 'Select a Bundle to Proceed'}
            </Text>
          </View>
        </TouchableOpacity>
      </ScrollView>

      {/* Biometric & 4-Digit PIN Authorization Modal */}
      {selectedPlan && (
        <BiometricPinModal
          visible={isPinModalVisible}
          onClose={() => setIsPinModalVisible(false)}
          onSuccess={handleAuthorizePurchase}
          title={`${selectedNetwork} Data Topup`}
          amount={selectedPlan.price}
          recipient={phone}
          subtitle={selectedPlan.name}
          loading={isSubmitting}
        />
      )}

      {/* Insufficient Balance Attractive Modal */}
      {selectedPlan && (
        <InsufficientBalanceModal
          visible={insufficientModalVisible}
          onClose={() => setInsufficientModalVisible(false)}
          onFundWallet={() => navigation.navigate('FundWallet')}
          requiredAmount={selectedPlan.price}
          currentBalance={wallet.balance}
          serviceTitle={`${selectedNetwork} ${selectedPlan.name}`}
        />
      )}

      {/* Transaction Success Celebratory Modal */}
      <TransactionSuccessModal
        visible={successModalVisible}
        onClose={() => setSuccessModalVisible(false)}
        serviceTitle={lastTxData?.title || `${selectedNetwork} Data`}
        amount={lastTxData?.amount || (selectedPlan?.price || 0)}
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
    position: 'relative',
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
  checkCircle: {
    position: 'absolute',
    top: 4,
    right: 4,
    width: 16,
    height: 16,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  inputGroup: {
    marginBottom: 20,
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
  typeTabs: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 20,
  },
  typeTab: {
    flex: 1,
    backgroundColor: '#1E293B',
    paddingVertical: 8,
    borderRadius: 10,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#334155',
  },
  typeTabActive: {
    backgroundColor: '#2563EB',
    borderColor: '#3B82F6',
  },
  typeTabText: {
    fontSize: 11,
    fontWeight: '700',
    color: '#94A3B8',
  },
  typeTabTextActive: {
    color: '#FFFFFF',
  },
  plansList: {
    gap: 10,
    marginBottom: 24,
  },
  planCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#1E293B',
    borderRadius: 16,
    padding: 14,
    borderWidth: 1.5,
    borderColor: '#334155',
  },
  planCardSelected: {
    borderColor: '#38BDF8',
    backgroundColor: 'rgba(56, 189, 248, 0.08)',
  },
  planInfo: {
    flex: 1,
  },
  planName: {
    fontSize: 15,
    fontWeight: '700',
    color: '#F8FAFC',
  },
  planValidity: {
    fontSize: 12,
    color: '#94A3B8',
    marginTop: 2,
  },
  planPriceCol: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  planPrice: {
    fontSize: 16,
    fontWeight: '800',
    color: '#CBD5E1',
  },
  planPriceSelected: {
    color: '#38BDF8',
  },
  planCheck: {
    width: 22,
    height: 22,
    borderRadius: 11,
    backgroundColor: '#2563EB',
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkoutBtn: {
    backgroundColor: '#2563EB',
    borderRadius: 16,
    paddingVertical: 16,
    alignItems: 'center',
    marginBottom: 20,
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
