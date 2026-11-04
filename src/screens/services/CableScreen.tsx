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
import {
  ArrowLeft,
  Tv,
  Check,
  UserCheck,
  ShieldCheck,
} from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { apiClient } from '../../api/client';
import { formatNaira } from '../../utils/formatters';
import { triggerHaptic } from '../../utils/haptics';
import { BiometricPinModal } from '../../components/BiometricPinModal';
import { InsufficientBalanceModal } from '../../components/InsufficientBalanceModal';
import { TransactionSuccessModal } from '../../components/TransactionSuccessModal';

const PROVIDERS = [
  { id: 'dstv', name: 'DSTV', color: '#0284C7' },
  { id: 'gotv', name: 'GOtv', color: '#16A34A' },
  { id: 'startimes', name: 'StarTimes', color: '#E11D48' },
  { id: 'showmax', name: 'Showmax', color: '#9333EA' },
];

const PACKAGES: Record<string, Array<{ name: string; price: number }>> = {
  dstv: [
    { name: 'DStv Padi', price: 2950 },
    { name: 'DStv Yanga', price: 4200 },
    { name: 'DStv Confam', price: 7400 },
    { name: 'DStv Compact', price: 12500 },
    { name: 'DStv Compact Plus', price: 19800 },
    { name: 'DStv Premium', price: 29500 },
  ],
  gotv: [
    { name: 'GOtv Smallie', price: 1300 },
    { name: 'GOtv Jinja', price: 2700 },
    { name: 'GOtv Jolli', price: 3950 },
    { name: 'GOtv Max', price: 5700 },
    { name: 'GOtv Supa', price: 7600 },
    { name: 'GOtv Supa Plus', price: 12500 },
  ],
  startimes: [
    { name: 'Nova (Weekly)', price: 600 },
    { name: 'Nova (Monthly)', price: 1500 },
    { name: 'Basic (Monthly)', price: 2600 },
    { name: 'Smart (Monthly)', price: 3500 },
    { name: 'Classic (Monthly)', price: 4000 },
    { name: 'Super (Monthly)', price: 6500 },
  ],
  showmax: [
    { name: 'Showmax Mobile Only', price: 1450 },
    { name: 'Showmax Pro Mobile', price: 3200 },
    { name: 'Showmax Standard', price: 2900 },
  ],
};

export const CableScreen = ({ navigation }: any) => {
  const { wallet, refreshData } = useAuth();
  const { colors, isDark } = useTheme();
  const [provider, setProvider] = useState('dstv');
  const [smartcard, setSmartcard] = useState('');
  const [customerName, setCustomerName] = useState('');
  const [verifying, setVerifying] = useState(false);
  const [selectedPkg, setSelectedPkg] = useState<{ name: string; price: number } | null>(null);
  const [isPinModalVisible, setIsPinModalVisible] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [insufficientModalVisible, setInsufficientModalVisible] = useState(false);
  const [successModalVisible, setSuccessModalVisible] = useState(false);
  const [lastTxData, setLastTxData] = useState<any>(null);

  const currentPackages = PACKAGES[provider] || [];

  const handleVerifySmartcard = async (cardNum: string) => {
    if (cardNum.length < 10) return;
    setVerifying(true);
    try {
      const res = await apiClient.post('/services/cable/verify-card', {
        provider,
        smartcard: cardNum,
      });
      if (res.data?.name) {
        setCustomerName(res.data.name);
        triggerHaptic('success');
      } else {
        setCustomerName('');
      }
    } catch {
      setCustomerName('');
    } finally {
      setVerifying(false);
    }
  };

  const handleInitPurchase = () => {
    if (!smartcard || smartcard.length < 10) {
      triggerHaptic('error');
      Alert.alert('Invalid Smartcard', 'Please enter a valid 10 or 11-digit IUC / Smartcard number.');
      return;
    }
    if (!selectedPkg) {
      triggerHaptic('error');
      Alert.alert('Select Package', 'Please choose a bouquet / package to renew.');
      return;
    }

    triggerHaptic('medium');
    setIsPinModalVisible(true);
  };

  const handleAuthorizePurchase = async (pin: string) => {
    if (!selectedPkg) return;
    setIsSubmitting(true);
    try {
      if (wallet.balance < selectedPkg.price) {
        setIsSubmitting(false);
        setIsPinModalVisible(false);
        triggerHaptic('error');
        setInsufficientModalVisible(true);
        return;
      }

      const res = await apiClient.post('/services/cable', {
        provider,
        smartcard,
        packageName: selectedPkg.name,
        price: selectedPkg.price,
        pin,
      });

      setIsSubmitting(false);
      setIsPinModalVisible(false);

      if (res.data?.success) {
        triggerHaptic('success');
        await refreshData();
        setLastTxData({
          amount: selectedPkg.price,
          recipient: `${smartcard} (${customerName || provider.toUpperCase()})`,
          reference: res.data.transaction?.reference || `CAB-${Date.now().toString().slice(-8)}`,
          title: `${provider.toUpperCase()} ${selectedPkg.name}`,
          balanceAfter: res.data.balance || (wallet.balance - selectedPkg.price),
        });
        setSuccessModalVisible(true);
      } else {
        triggerHaptic('error');
        if ((res.data?.message || '').toLowerCase().includes('balance')) {
          setInsufficientModalVisible(true);
        } else {
          Alert.alert('Subscription Failed', res.data?.message || 'Transaction could not be completed.');
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
        Alert.alert('Subscription Failed', msg);
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
          <Text style={[styles.navTitle, { color: colors.text }]}>Cable TV Subscription</Text>
          <View style={{ width: 40 }} />
        </View>

        {/* Balance Row */}
        <View style={[styles.balanceRow, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <Text style={[styles.balanceLabel, { color: colors.textSecondary }]}>Wallet Balance:</Text>
          <Text style={[styles.balanceValue, { color: colors.primary }]}>{formatNaira(wallet.balance)}</Text>
        </View>

        {/* Provider Selector */}
        <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Select Cable Provider</Text>
        <View style={styles.providerGrid}>
          {PROVIDERS.map((p) => {
            const isSelected = provider === p.id;
            return (
              <TouchableOpacity
                key={p.id}
                style={[
                  styles.providerCard,
                  { backgroundColor: colors.card, borderColor: colors.cardBorder },
                  isSelected && { borderColor: p.color, backgroundColor: isDark ? 'rgba(30, 41, 59, 0.9)' : '#EFF6FF' },
                ]}
                onPress={() => {
                  triggerHaptic('selection');
                  setProvider(p.id);
                  setSelectedPkg(null);
                  if (smartcard.length >= 10) handleVerifySmartcard(smartcard);
                }}
                activeOpacity={0.7}
              >
                <Tv size={20} color={isSelected ? p.color : colors.textMuted} />
                <Text style={[styles.providerName, { color: colors.text }, isSelected && { color: p.color, fontWeight: '800' }]}>
                  {p.name}
                </Text>
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Smartcard Input */}
        <View style={styles.inputGroup}>
          <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Smartcard / IUC Number</Text>
          <View style={[styles.inputWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <TextInput
              style={[styles.smartcardInput, { color: colors.text }]}
              placeholder="e.g. 1029384756 (IUC / Smartcard)"
              placeholderTextColor={colors.textMuted}
              value={smartcard}
              onChangeText={(t) => {
                const clean = t.replace(/[^0-9]/g, '');
                setSmartcard(clean);
                if (clean.length >= 10) {
                  handleVerifySmartcard(clean);
                } else {
                  setCustomerName('');
                }
              }}
              keyboardType="numeric"
            />
            {verifying && <ActivityIndicator size="small" color={colors.primary} />}
          </View>
        </View>

        {/* Verified Customer Name Badge */}
        {customerName ? (
          <View style={[styles.verifiedBox, { backgroundColor: colors.successBg, borderColor: colors.success }]}>
            <UserCheck size={18} color={colors.success} />
            <View>
              <Text style={[styles.verifiedLabel, { color: colors.success }]}>VERIFIED SUBSCRIBER</Text>
              <Text style={[styles.verifiedName, { color: colors.text }]}>{customerName}</Text>
            </View>
          </View>
        ) : null}

        {/* Package Selector */}
        <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Select Bouquet / Package</Text>
        <View style={styles.pkgList}>
          {currentPackages.map((pkg) => {
            const isSelected = selectedPkg?.name === pkg.name;
            return (
              <TouchableOpacity
                key={pkg.name}
                style={[
                  styles.pkgCard,
                  { backgroundColor: colors.card, borderColor: colors.cardBorder },
                  isSelected && { borderColor: colors.primary, backgroundColor: colors.primaryBg },
                ]}
                onPress={() => {
                  triggerHaptic('selection');
                  setSelectedPkg(pkg);
                }}
                activeOpacity={0.7}
              >
                <Text style={[styles.pkgName, { color: colors.text }]}>{pkg.name}</Text>
                <View style={styles.pkgRight}>
                  <Text style={[styles.pkgPrice, { color: colors.text }, isSelected && { color: colors.primary }]}>
                    {formatNaira(pkg.price)}
                  </Text>
                  {isSelected && (
                    <View style={[styles.pkgCheck, { backgroundColor: colors.primary }]}>
                      <Check size={14} color="#FFFFFF" />
                    </View>
                  )}
                </View>
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Checkout Button */}
        <TouchableOpacity
          style={[styles.checkoutBtn, { backgroundColor: colors.primary }, (!smartcard || !selectedPkg) && styles.checkoutBtnDisabled]}
          onPress={handleInitPurchase}
          disabled={!smartcard || !selectedPkg}
          activeOpacity={0.8}
        >
          <Tv size={20} color="#FFFFFF" />
          <Text style={styles.checkoutBtnText}>
            {selectedPkg
              ? `Renew ${selectedPkg.name} (${formatNaira(selectedPkg.price)})`
              : 'Select a Package to Proceed'}
          </Text>
        </TouchableOpacity>
      </ScrollView>

      {/* Biometric & 4-Digit PIN Authorization Modal */}
      {selectedPkg && (
        <BiometricPinModal
          visible={isPinModalVisible}
          onClose={() => setIsPinModalVisible(false)}
          onSuccess={handleAuthorizePurchase}
          title={`${provider.toUpperCase()} Subscription`}
          amount={selectedPkg.price}
          recipient={smartcard}
          subtitle={`${selectedPkg.name} • ${customerName || 'Subscriber'}`}
          loading={isSubmitting}
        />
      )}

      {/* Insufficient Balance Attractive Modal */}
      {selectedPkg && (
        <InsufficientBalanceModal
          visible={insufficientModalVisible}
          onClose={() => setInsufficientModalVisible(false)}
          onFundWallet={() => navigation.navigate('FundWallet')}
          requiredAmount={selectedPkg.price}
          currentBalance={wallet.balance}
          serviceTitle={`${provider.toUpperCase()} ${selectedPkg.name}`}
        />
      )}

      {/* Transaction Success Celebratory Modal */}
      <TransactionSuccessModal
        visible={successModalVisible}
        onClose={() => setSuccessModalVisible(false)}
        serviceTitle={lastTxData?.title || `${provider.toUpperCase()} TV`}
        amount={lastTxData?.amount || (selectedPkg?.price || 0)}
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
  providerGrid: {
    flexDirection: 'row',
    gap: 10,
    marginBottom: 20,
  },
  providerCard: {
    flex: 1,
    backgroundColor: '#1E293B',
    borderRadius: 14,
    paddingVertical: 12,
    alignItems: 'center',
    borderWidth: 1.5,
    borderColor: '#334155',
    gap: 6,
  },
  providerName: {
    fontSize: 12,
    fontWeight: '700',
    color: '#CBD5E1',
  },
  inputGroup: {
    marginBottom: 14,
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
  },
  smartcardInput: {
    flex: 1,
    fontSize: 16,
    color: '#F8FAFC',
    fontWeight: '600',
  },
  verifiedBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(16, 185, 129, 0.1)',
    borderRadius: 14,
    padding: 12,
    borderWidth: 1,
    borderColor: 'rgba(16, 185, 129, 0.3)',
    gap: 10,
    marginBottom: 18,
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
  },
  pkgList: {
    gap: 10,
    marginBottom: 24,
  },
  pkgCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#1E293B',
    borderRadius: 16,
    padding: 14,
    borderWidth: 1.5,
    borderColor: '#334155',
  },
  pkgCardSelected: {
    borderColor: '#38BDF8',
    backgroundColor: 'rgba(56, 189, 248, 0.08)',
  },
  pkgName: {
    fontSize: 15,
    fontWeight: '700',
    color: '#F8FAFC',
  },
  pkgRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  pkgPrice: {
    fontSize: 15,
    fontWeight: '800',
    color: '#CBD5E1',
  },
  pkgPriceSelected: {
    color: '#38BDF8',
  },
  pkgCheck: {
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: '#2563EB',
    justifyContent: 'center',
    alignItems: 'center',
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
