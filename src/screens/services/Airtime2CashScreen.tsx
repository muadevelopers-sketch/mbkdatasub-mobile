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
  Linking,
  Alert,
  Image,
} from 'react-native';
import {
  ArrowLeft,
  Repeat,
  Check,
  Smartphone,
  MessageCircle,
  HelpCircle,
  ShieldCheck,
  Zap,
} from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { formatNaira } from '../../utils/formatters';
import { triggerHaptic } from '../../utils/haptics';

const NETWORKS = [
  { id: 'MTN', name: 'MTN', rate: 82, color: '#EAB308', transferCode: '*321*AdminNum*Amount*PIN#' },
  { id: 'Airtel', name: 'Airtel', rate: 80, color: '#EF4444', transferCode: '*432*1*AdminNum*Amount*PIN#' },
  { id: 'Glo', name: 'Glo', rate: 75, color: '#10B981', transferCode: '*131*AdminNum*Amount*PIN#' },
  { id: '9mobile', name: '9mobile', rate: 75, color: '#059669', transferCode: '*223*PIN*Amount*AdminNum#' },
];

const NETWORK_LOGOS: Record<string, any> = {
  MTN: require('../../../assets/networks/mtn.png'),
  Airtel: require('../../../assets/networks/airtel.png'),
  Glo: require('../../../assets/networks/glo.png'),
  '9mobile': require('../../../assets/networks/9mobile.png'),
};

export const Airtime2CashScreen = ({ navigation }: any) => {
  const { user } = useAuth();
  const { colors, isDark } = useTheme();
  const [selectedNetwork, setSelectedNetwork] = useState('MTN');
  const [senderPhone, setSenderPhone] = useState('');
  const [amountStr, setAmountStr] = useState('5000');

  const amount = parseInt(amountStr, 10) || 0;
  const currentNet = NETWORKS.find((n) => n.id === selectedNetwork) || NETWORKS[0];
  const cashToReceive = Math.round((amount * currentNet.rate) / 100);

  const handleStartConversion = () => {
    if (!senderPhone || senderPhone.length < 11) {
      triggerHaptic('error');
      Alert.alert('Invalid Phone', 'Please enter your sending phone number.');
      return;
    }
    if (amount < 1000) {
      triggerHaptic('error');
      Alert.alert('Minimum Amount', 'Minimum airtime for conversion is ₦1,000.');
      return;
    }

    triggerHaptic('medium');
    const msg = encodeURIComponent(
      `Hello MBKDATASUB Admin, I want to convert ₦${amount.toLocaleString()} ${selectedNetwork} airtime to cash (Receiving ₦${cashToReceive.toLocaleString()} at ${currentNet.rate}%).\nSender Phone: ${senderPhone}\nAccount Name: ${user?.fullName || 'Customer'}`
    );
    Linking.openURL(`https://wa.me/2347063462998?text=${msg}`);
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
          <Text style={[styles.navTitle, { color: colors.text }]}>Airtime to Cash</Text>
          <View style={{ width: 40 }} />
        </View>

        {/* Hero Rate Highlight */}
        <View style={[styles.heroCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <View style={styles.rateBadge}>
            <Zap size={14} color="#F59E0B" />
            <Text style={styles.rateBadgeText}>HIGH CONVERSION RATE</Text>
          </View>
          <Text style={[styles.heroTitle, { color: colors.text }]}>Convert Excess Airtime to Cash</Text>
          <Text style={[styles.heroDesc, { color: colors.textSecondary }]}>
            Accidentally overcharged or have unused balance? Liquidate it directly to your bank account in 5 minutes.
          </Text>
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
                <Text style={styles.rateText}>{net.rate}% Payout</Text>
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Sender Phone */}
        <View style={styles.inputGroup}>
          <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Sending SIM Phone Number</Text>
          <View style={[styles.inputWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <Smartphone size={20} color={colors.textMuted} />
            <TextInput
              style={[styles.textInput, { color: colors.text }]}
              placeholder="e.g. 0803 123 4567 (Sending SIM)"
              placeholderTextColor={colors.textMuted}
              value={senderPhone}
              onChangeText={(t) => setSenderPhone(t.replace(/[^0-9]/g, '').slice(0, 11))}
              keyboardType="phone-pad"
            />
          </View>
        </View>

        {/* Amount Input */}
        <View style={styles.inputGroup}>
          <Text style={[styles.sectionTitle, { color: colors.textMuted }]}>Airtime Amount to Transfer (₦)</Text>
          <View style={[styles.amountWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <Text style={[styles.nairaSymbol, { color: colors.primary }]}>₦</Text>
            <TextInput
              style={[styles.amountInput, { color: colors.text }]}
              placeholder="Minimum ₦1,000"
              placeholderTextColor={colors.textMuted}
              value={amountStr}
              onChangeText={(t) => setAmountStr(t.replace(/[^0-9]/g, ''))}
              keyboardType="numeric"
            />
          </View>
        </View>

        {/* Calculation Card */}
        {amount > 0 && (
          <View style={[styles.calcCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <View style={styles.calcRow}>
              <Text style={[styles.calcLabel, { color: colors.textSecondary }]}>Airtime Sent</Text>
              <Text style={[styles.calcVal, { color: colors.text }]}>₦{amount.toLocaleString()}</Text>
            </View>
            <View style={styles.calcRow}>
              <Text style={[styles.calcLabel, { color: colors.textSecondary }]}>Conversion Rate</Text>
              <Text style={styles.rateVal}>{currentNet.rate}%</Text>
            </View>
            <View style={[styles.calcRow, styles.calcTotalRow, { borderTopColor: colors.cardBorder }]}>
              <Text style={[styles.totalLabel, { color: colors.text }]}>Cash You Receive</Text>
              <Text style={[styles.totalVal, { color: colors.primary }]}>{formatNaira(cashToReceive)}</Text>
            </View>
          </View>
        )}

        {/* Instructions */}
        <View style={[styles.guideCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <Text style={[styles.guideTitle, { color: colors.text }]}>Transfer Instructions:</Text>
          <Text style={[styles.guideText, { color: colors.textSecondary }]}>
            1. Tap the button below to initiate your conversion request.
          </Text>
          <Text style={[styles.guideText, { color: colors.textSecondary }]}>
            2. You will receive the admin designated receiving phone number.
          </Text>
          <Text style={[styles.guideText, { color: colors.textSecondary }]}>
            3. Transfer airtime via your network Share'N'Sell USSD code.
          </Text>
          <Text style={[styles.guideText, { color: colors.textSecondary }]}>
            4. Instant payout will be credited directly to your bank account or MBK wallet.
          </Text>
        </View>

        {/* Action Button */}
        <TouchableOpacity
          style={[styles.actionBtn, (!senderPhone || amount < 1000) && styles.actionBtnDisabled]}
          onPress={handleStartConversion}
          disabled={!senderPhone || amount < 1000}
          activeOpacity={0.8}
        >
          <MessageCircle size={20} color="#FFFFFF" />
          <Text style={styles.actionBtnText}>
            Proceed via WhatsApp Admin (Receive {formatNaira(cashToReceive)})
          </Text>
        </TouchableOpacity>
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
  heroCard: {
    backgroundColor: '#1E293B',
    borderRadius: 20,
    padding: 18,
    borderWidth: 1,
    borderColor: '#334155',
    marginBottom: 20,
  },
  rateBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(245, 158, 11, 0.15)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 8,
    alignSelf: 'flex-start',
    gap: 4,
    marginBottom: 8,
  },
  rateBadgeText: {
    fontSize: 10,
    fontWeight: '800',
    color: '#FBBF24',
    letterSpacing: 0.5,
  },
  heroTitle: {
    fontSize: 18,
    fontWeight: '800',
    color: '#F8FAFC',
  },
  heroDesc: {
    fontSize: 13,
    color: '#94A3B8',
    marginTop: 4,
    lineHeight: 18,
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
  rateText: {
    fontSize: 10,
    color: '#34D399',
    fontWeight: '800',
    marginTop: 2,
  },
  inputGroup: {
    marginBottom: 18,
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
  textInput: {
    flex: 1,
    fontSize: 16,
    color: '#F8FAFC',
    fontWeight: '600',
  },
  amountWrapper: {
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
  calcCard: {
    backgroundColor: '#1E293B',
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: '#334155',
    gap: 10,
    marginBottom: 20,
  },
  calcRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  calcLabel: {
    fontSize: 13,
    color: '#94A3B8',
  },
  calcVal: {
    fontSize: 13,
    fontWeight: '600',
    color: '#F8FAFC',
  },
  rateVal: {
    fontSize: 13,
    fontWeight: '700',
    color: '#F59E0B',
  },
  calcTotalRow: {
    borderTopWidth: 1,
    borderTopColor: '#334155',
    paddingTop: 10,
  },
  totalLabel: {
    fontSize: 14,
    fontWeight: '700',
    color: '#F8FAFC',
  },
  totalVal: {
    fontSize: 18,
    fontWeight: '800',
    color: '#10B981',
  },
  guideCard: {
    backgroundColor: '#1E293B',
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: '#334155',
    gap: 6,
    marginBottom: 24,
  },
  guideTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: '#F8FAFC',
    marginBottom: 4,
  },
  guideText: {
    fontSize: 12,
    color: '#94A3B8',
    lineHeight: 18,
  },
  actionBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2563EB',
    borderRadius: 16,
    height: 54,
    gap: 10,
  },
  actionBtnDisabled: {
    opacity: 0.5,
  },
  actionBtnText: {
    fontSize: 14,
    fontWeight: '700',
    color: '#FFFFFF',
  },
});
