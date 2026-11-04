import React, { useState } from 'react';
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
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';;
import {
  ArrowLeft,
  Radio,
  Wifi,
  Phone,
  Check,
  ShieldCheck,
  Receipt,
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

const SMILE_BUNDLES = [
  { id: 'sm-1_5gb', name: '1.5GB Bigga', validity: '30 Days', price: 1000 },
  { id: 'sm-3gb', name: '3GB Bigga', validity: '30 Days', price: 1500 },
  { id: 'sm-5gb', name: '5GB Bigga', validity: '30 Days', price: 2000 },
  { id: 'sm-7gb', name: '7GB Bigga', validity: '30 Days', price: 2500 },
  { id: 'sm-10gb', name: '10GB Bigga', validity: '30 Days', price: 3000 },
  { id: 'sm-15gb', name: '15GB Bigga', validity: '30 Days', price: 4000 },
  { id: 'sm-20gb', name: '20GB Bigga', validity: '30 Days', price: 5000 },
  { id: 'sm-40gb', name: '40GB Jumbo', validity: '30 Days', price: 9000 },
  { id: 'sm-unlimited', name: 'Unlimited Lite', validity: '30 Days', price: 12000 },
];

const SPECTRANET_BUNDLES = [
  { id: 'spec-10gb', name: '10GB Unified Stay Connected', validity: '30 Days', price: 3500 },
  { id: 'spec-25gb', name: '25GB Unified Value', validity: '30 Days', price: 7500 },
  { id: 'spec-50gb', name: '50GB Mega Value', validity: '30 Days', price: 13000 },
  { id: 'spec-unlimited', name: 'Unlimited Bronze Plan', validity: '30 Days', price: 20000 },
];

export const SmileScreen = ({ navigation }: any) => {
  const { wallet, refreshData } = useAuth();
  const { colors, isDark } = useTheme();

  const [provider, setProvider] = useState<'smile' | 'spectranet'>('smile');
  const [serviceType, setServiceType] = useState<'data' | 'voice'>('data');
  const [accountId, setAccountId] = useState('');
  const [selectedPlan, setSelectedPlan] = useState<any>(SMILE_BUNDLES[0]);
  const [voiceAmount, setVoiceAmount] = useState('1000');

  const [isPinModalVisible, setIsPinModalVisible] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [insufficientModalVisible, setInsufficientModalVisible] = useState(false);
  const [successModalVisible, setSuccessModalVisible] = useState(false);
  const [lastTxData, setLastTxData] = useState<any>(null);

  const activeBundles = provider === 'smile' ? SMILE_BUNDLES : SPECTRANET_BUNDLES;
  const currentPrice = serviceType === 'data' ? selectedPlan?.price || 0 : parseFloat(voiceAmount) || 0;

  const handleInitPurchase = () => {
    if (!accountId.trim()) {
      triggerHaptic('error');
      Alert.alert('Missing Account', 'Please enter your Smile/Spectranet Account Number or ID.');
      return;
    }

    if (serviceType === 'voice' && (!voiceAmount || parseFloat(voiceAmount) < 100)) {
      triggerHaptic('error');
      Alert.alert('Invalid Amount', 'Minimum recharge amount is ₦100.');
      return;
    }

    triggerHaptic('medium');
    setIsPinModalVisible(true);
  };

  const handleAuthorizePurchase = async (pin: string) => {
    setIsSubmitting(true);
    try {
      // Check balance - allow user up to auth step, then display attractive modal if insufficient
      if (wallet.balance < currentPrice) {
        setIsSubmitting(false);
        setIsPinModalVisible(false);
        triggerHaptic('error');
        setInsufficientModalVisible(true);
        return;
      }

      const res = await apiClient.post('/services/smile', {
        provider,
        type: serviceType,
        accountId: accountId.trim(),
        planId: serviceType === 'data' ? selectedPlan.id : undefined,
        amount: currentPrice,
        pin,
      });

      setIsSubmitting(false);
      setIsPinModalVisible(false);

      if (res.data?.success) {
        triggerHaptic('success');
        await refreshData();
        setLastTxData({
          amount: currentPrice,
          recipient: `${accountId.trim()} (${provider.toUpperCase()})`,
          reference: res.data.transaction?.reference || `SML-${Date.now().toString().slice(-8)}`,
          title: serviceType === 'data' ? `${provider.toUpperCase()} ${selectedPlan.name}` : `${provider.toUpperCase()} Voice Recharge`,
          balanceAfter: res.data.balance || (wallet.balance - currentPrice),
        });
        setSuccessModalVisible(true);
      } else {
        triggerHaptic('error');
        if ((res.data?.message || '').toLowerCase().includes('balance')) {
          setInsufficientModalVisible(true);
        } else {
          Alert.alert('Purchase Failed', res.data?.message || 'Could not complete transaction.');
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
      <StatusBar barStyle={colors.statusBar === 'dark' ? 'dark-content' : 'light-content'} />
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
          <Text style={[styles.navTitle, { color: colors.text }]}>Broadband & 4G/5G</Text>
          <View style={{ width: 40 }} />
        </View>

        {/* Balance Row */}
        <View style={[styles.balanceRow, { backgroundColor: colors.primaryBg, borderColor: colors.primary }]}>
          <Text style={[styles.balanceLabel, { color: colors.textSecondary }]}>Available Balance:</Text>
          <Text style={[styles.balanceValue, { color: colors.primary }]}>{formatNaira(wallet.balance)}</Text>
        </View>

        {/* Provider Toggle (Smile vs Spectranet) */}
        <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>Select Network Provider</Text>
        <View style={styles.providerRow}>
          <TouchableOpacity
            style={[
              styles.providerBtn,
              { backgroundColor: colors.card, borderColor: provider === 'smile' ? '#E11D48' : colors.cardBorder },
              provider === 'smile' && { backgroundColor: isDark ? 'rgba(225, 29, 72, 0.15)' : '#FFF1F2' },
            ]}
            onPress={() => {
              triggerHaptic('selection');
              setProvider('smile');
              setSelectedPlan(SMILE_BUNDLES[0]);
            }}
            activeOpacity={0.8}
          >
            <View style={[styles.providerDot, { backgroundColor: '#E11D48' }]} />
            <Text style={[styles.providerText, { color: provider === 'smile' ? '#E11D48' : colors.text }]}>
              Smile 4G LTE
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[
              styles.providerBtn,
              { backgroundColor: colors.card, borderColor: provider === 'spectranet' ? '#2563EB' : colors.cardBorder },
              provider === 'spectranet' && { backgroundColor: isDark ? 'rgba(37, 99, 235, 0.15)' : '#EFF6FF' },
            ]}
            onPress={() => {
              triggerHaptic('selection');
              setProvider('spectranet');
              setSelectedPlan(SPECTRANET_BUNDLES[0]);
            }}
            activeOpacity={0.8}
          >
            <View style={[styles.providerDot, { backgroundColor: '#2563EB' }]} />
            <Text style={[styles.providerText, { color: provider === 'spectranet' ? '#2563EB' : colors.text }]}>
              Spectranet 4G
            </Text>
          </TouchableOpacity>
        </View>

        {/* Service Type (Smile only supports voice) */}
        {provider === 'smile' && (
          <View style={[styles.serviceTypeTabs, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <TouchableOpacity
              style={[styles.typeTab, serviceType === 'data' && { backgroundColor: colors.inputBg }]}
              onPress={() => {
                triggerHaptic('selection');
                setServiceType('data');
              }}
            >
              <Wifi size={16} color={serviceType === 'data' ? colors.primary : colors.textMuted} />
              <Text style={[styles.typeTabText, { color: serviceType === 'data' ? colors.primary : colors.textMuted }]}>
                Data Bundles
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.typeTab, serviceType === 'voice' && { backgroundColor: colors.inputBg }]}
              onPress={() => {
                triggerHaptic('selection');
                setServiceType('voice');
              }}
            >
              <Phone size={16} color={serviceType === 'voice' ? colors.primary : colors.textMuted} />
              <Text style={[styles.typeTabText, { color: serviceType === 'voice' ? colors.primary : colors.textMuted }]}>
                Voice Airtime
              </Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Account ID / Phone Input with Special Placeholder */}
        <View style={styles.formGroup}>
          <Text style={[styles.inputLabel, { color: colors.textSecondary }]}>
            {provider === 'smile' ? 'Smile Account ID or Phone Number' : 'Spectranet User ID'}
          </Text>
          <View style={[styles.inputWrapper, { backgroundColor: colors.inputBg, borderColor: colors.inputBorder }]}>
            <Radio size={18} color={colors.textSecondary} style={{ marginRight: 10 }} />
            <TextInput
              style={[styles.textInput, { color: colors.text }]}
              placeholder={provider === 'smile' ? 'e.g. 07020000000 or 10-digit ID' : 'e.g. 1029384756'}
              placeholderTextColor={colors.textMuted}
              value={accountId}
              onChangeText={setAccountId}
              keyboardType="numeric"
              autoCapitalize="none"
            />
          </View>
        </View>

        {/* Data Plans Grid / List */}
        {serviceType === 'data' ? (
          <View style={styles.plansSection}>
            <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>Select Data Package</Text>
            <View style={styles.plansList}>
              {activeBundles.map((b) => {
                const isSelected = selectedPlan?.id === b.id;
                return (
                  <TouchableOpacity
                    key={b.id}
                    style={[
                      styles.planCard,
                      { backgroundColor: colors.card, borderColor: isSelected ? colors.primary : colors.cardBorder },
                      isSelected && { backgroundColor: colors.primaryBg },
                    ]}
                    onPress={() => {
                      triggerHaptic('selection');
                      setSelectedPlan(b);
                    }}
                    activeOpacity={0.7}
                  >
                    <View>
                      <Text style={[styles.planName, { color: colors.text }]}>{b.name}</Text>
                      <Text style={[styles.planValidity, { color: colors.textSecondary }]}>{b.validity}</Text>
                    </View>
                    <View style={styles.planRight}>
                      <Text style={[styles.planPrice, { color: isSelected ? colors.primary : colors.text }]}>
                        {formatNaira(b.price)}
                      </Text>
                      {isSelected && (
                        <View style={[styles.checkCircle, { backgroundColor: colors.primary }]}>
                          <Check size={12} color="#FFFFFF" />
                        </View>
                      )}
                    </View>
                  </TouchableOpacity>
                );
              })}
            </View>
          </View>
        ) : (
          <View style={styles.formGroup}>
            <Text style={[styles.inputLabel, { color: colors.textSecondary }]}>Recharge Amount (₦)</Text>
            <View style={[styles.inputWrapper, { backgroundColor: colors.inputBg, borderColor: colors.inputBorder }]}>
              <TextInput
                style={[styles.textInput, { color: colors.text }]}
                placeholder="e.g. 1000"
                placeholderTextColor={colors.textMuted}
                value={voiceAmount}
                onChangeText={setVoiceAmount}
                keyboardType="numeric"
              />
            </View>
          </View>
        )}

        {/* Total & Checkout */}
        <View style={[styles.summaryCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <View style={styles.summaryRow}>
            <Text style={[styles.summaryLabel, { color: colors.textSecondary }]}>Order Total:</Text>
            <Text style={[styles.summaryTotal, { color: colors.primary }]}>{formatNaira(currentPrice)}</Text>
          </View>
        </View>

        <TouchableOpacity
          style={[styles.checkoutBtn, { backgroundColor: colors.accent }, !accountId && styles.btnDisabled]}
          onPress={handleInitPurchase}
          disabled={!accountId}
          activeOpacity={0.8}
        >
          <Radio size={20} color="#FFFFFF" />
          <Text style={styles.checkoutBtnText}>Pay {formatNaira(currentPrice)} with Biometrics</Text>
        </TouchableOpacity>
      </ScrollView>

      {/* Biometric PIN Modal */}
      <BiometricPinModal
        visible={isPinModalVisible}
        onClose={() => setIsPinModalVisible(false)}
        onSuccess={handleAuthorizePurchase}
        title={serviceType === 'data' ? `${provider.toUpperCase()} ${selectedPlan?.name}` : `${provider.toUpperCase()} Voice`}
        amount={currentPrice}
        recipient={`Account: ${accountId}`}
        loading={isSubmitting}
      />

      {/* Insufficient Balance Modal */}
      <InsufficientBalanceModal
        visible={insufficientModalVisible}
        onClose={() => setInsufficientModalVisible(false)}
        onFundWallet={() => navigation.navigate('FundWallet')}
        requiredAmount={currentPrice}
        currentBalance={wallet.balance}
        serviceTitle={provider === 'smile' ? 'Smile 4G' : 'Spectranet'}
      />

      {/* Transaction Success Modal */}
      <TransactionSuccessModal
        visible={successModalVisible}
        onClose={() => setSuccessModalVisible(false)}
        serviceTitle={lastTxData?.title || 'Broadband Service'}
        amount={lastTxData?.amount || currentPrice}
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
    fontSize: 17,
    fontWeight: '700',
  },
  balanceRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderRadius: 14,
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderWidth: 1,
    marginBottom: 18,
  },
  balanceLabel: {
    fontSize: 13,
    fontWeight: '500',
  },
  balanceValue: {
    fontSize: 15,
    fontWeight: '800',
  },
  sectionTitle: {
    fontSize: 13,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 0.6,
    marginBottom: 10,
  },
  providerRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 16,
  },
  providerBtn: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    borderRadius: 14,
    borderWidth: 1.5,
    gap: 8,
  },
  providerDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  providerText: {
    fontSize: 14,
    fontWeight: '700',
  },
  serviceTypeTabs: {
    flexDirection: 'row',
    borderRadius: 12,
    padding: 4,
    borderWidth: 1,
    marginBottom: 16,
  },
  typeTab: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 8,
    borderRadius: 8,
    gap: 6,
  },
  typeTabText: {
    fontSize: 13,
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
  textInput: {
    flex: 1,
    fontSize: 15,
  },
  plansSection: {
    marginBottom: 16,
  },
  plansList: {
    gap: 10,
  },
  planCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 14,
    borderRadius: 14,
    borderWidth: 1.5,
  },
  planName: {
    fontSize: 14,
    fontWeight: '700',
  },
  planValidity: {
    fontSize: 11,
    marginTop: 2,
  },
  planRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  planPrice: {
    fontSize: 15,
    fontWeight: '800',
  },
  checkCircle: {
    width: 18,
    height: 18,
    borderRadius: 9,
    justifyContent: 'center',
    alignItems: 'center',
  },
  summaryCard: {
    padding: 16,
    borderRadius: 16,
    borderWidth: 1,
    marginBottom: 18,
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  summaryLabel: {
    fontSize: 14,
    fontWeight: '600',
  },
  summaryTotal: {
    fontSize: 22,
    fontWeight: '800',
  },
  checkoutBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 16,
    height: 54,
    gap: 10,
  },
  btnDisabled: {
    opacity: 0.5,
  },
  checkoutBtnText: {
    fontSize: 15,
    fontWeight: '700',
    color: '#FFFFFF',
  },
});
