import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
  ScrollView,
  NativeSyntheticEvent,
  NativeScrollEvent,
  ActivityIndicator,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { LinearGradient } from 'expo-linear-gradient';
import * as Clipboard from 'expo-clipboard';
import { Eye, EyeOff, Plus, Copy, Check, Landmark, ArrowRight, RefreshCw, Sparkles } from 'lucide-react-native';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../context/ThemeContext';
import { formatNaira } from '../utils/formatters';
import { triggerHaptic } from '../utils/haptics';

interface WalletCardProps {
  onAddMoney?: () => void;
  onFundPress?: () => void;
  onHistory?: () => void;
}

const { width } = Dimensions.get('window');
const CARD_WIDTH = width - 40;

export const WalletCard: React.FC<WalletCardProps> = ({ onAddMoney, onFundPress, onHistory }) => {
  const handleAddMoney = onFundPress || onAddMoney || (() => {});
  const handleHistory = onHistory || (() => {});
  const { wallet, generateDedicatedAccounts } = useAuth();
  const { colors, isDark } = useTheme();
  const [showBalance, setShowBalance] = useState(true);
  const [copiedPalm, setCopiedPalm] = useState(false);
  const [copiedPaga, setCopiedPaga] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const [generating, setGenerating] = useState(false);

  useEffect(() => {
    loadBalanceVisibility();
  }, []);

  const loadBalanceVisibility = async () => {
    try {
      const saved = await AsyncStorage.getItem('mbk_show_balance');
      if (saved !== null) {
        setShowBalance(saved === 'true');
      }
    } catch {}
  };

  const toggleBalance = async () => {
    triggerHaptic('selection');
    const next = !showBalance;
    setShowBalance(next);
    await AsyncStorage.setItem('mbk_show_balance', String(next));
  };

  const handleGenerateAccounts = async () => {
    triggerHaptic('medium');
    setGenerating(true);
    await generateDedicatedAccounts();
    setGenerating(false);
  };


  const accounts = wallet.accounts && wallet.accounts.length > 0 ? wallet.accounts : [wallet.virtualAccount];

  const palmpayAcc =
    accounts.find((a) => (a.bankName || '').toLowerCase().includes('palm') || a.type === 'palmpay') ||
    wallet.virtualAccount;

  const pagaAcc =
    accounts.find((a) => (a.bankName || '').toLowerCase().includes('paga') || a.type === 'paga') ||
    (accounts.length > 1 && !accounts[1].bankName?.toLowerCase().includes('palm')
      ? accounts[1]
      : { bankName: 'Paga', accountNumber: '', accountName: '', type: 'paga' });

  const copyNumber = async (num: string, type: 'palm' | 'paga') => {
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

  const handleScroll = (event: NativeSyntheticEvent<NativeScrollEvent>) => {
    const slide = Math.round(event.nativeEvent.contentOffset.x / CARD_WIDTH);
    if (slide !== activeIndex) {
      setActiveIndex(slide);
    }
  };

  return (
    <View style={styles.wrapper}>
      <ScrollView
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={handleScroll}
        decelerationRate="fast"
        snapToInterval={CARD_WIDTH + 12}
        contentContainerStyle={styles.scrollContainer}
      >
        {/* CARD 1: MAIN BALANCE CARD */}
        <LinearGradient
          colors={['#4F46E5', '#6366F1', '#7C3AED']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={[styles.card, { width: CARD_WIDTH }]}
        >
          {/* Header Row */}
          <View style={styles.cardHeader}>
            <View style={styles.labelWithEye}>
              <Text style={styles.balanceLabel}>Total Balance</Text>
              <TouchableOpacity
                onPress={toggleBalance}
                hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
              >
                {showBalance ? <Eye size={16} color="#E0E7FF" /> : <EyeOff size={16} color="#E0E7FF" />}
              </TouchableOpacity>
            </View>

            <TouchableOpacity style={styles.historyBtn} onPress={handleHistory} activeOpacity={0.7}>
              <Text style={styles.historyText}>History</Text>
              <ArrowRight size={13} color="#E0E7FF" />
            </TouchableOpacity>
          </View>

          {/* Balance Amount & +Add Money */}
          <View style={styles.balanceRow}>
            <Text style={styles.balanceAmount} numberOfLines={1}>
              {showBalance ? formatNaira(wallet.balance) : '₦ • • • • • •'}
            </Text>

            <TouchableOpacity style={styles.addMoneyBtn} onPress={handleAddMoney} activeOpacity={0.85}>
              <Plus size={16} color="#4F46E5" strokeWidth={3} />
              <Text style={styles.addMoneyText}>Add Money</Text>
            </TouchableOpacity>
          </View>

          {/* Sub Metrics: Funded & Spent */}
          <View style={styles.metricsRow}>
            <View style={styles.metricItem}>
              <Text style={styles.metricLabel}>Total Funded</Text>
              <Text style={styles.metricVal}>{formatNaira(wallet.totalFunded)}</Text>
            </View>
            <View style={styles.metricDivider} />
            <View style={styles.metricItem}>
              <Text style={styles.metricLabel}>Total Spent</Text>
              <Text style={styles.metricVal}>{formatNaira(wallet.totalSpent)}</Text>
            </View>
          </View>
        </LinearGradient>

        {/* CARD 2: DEDICATED PALMPAY VIRTUAL ACCOUNT CARD */}
        <LinearGradient
          colors={['#6366F1', '#4F46E5', '#3730A3']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={[styles.card, { width: CARD_WIDTH }]}
        >
          <View style={styles.cardHeader}>
            <View style={styles.bankTitleRow}>
              <Landmark size={18} color="#C7D2FE" />
              <Text style={styles.bankNameHeader}>PalmPay Dedicated Account</Text>
            </View>
            <View style={styles.instantPill}>
              <Text style={styles.instantPillText}>INSTANT 24/7</Text>
            </View>
          </View>

          <Text style={styles.vaInstructions}>
            Transfer from any Nigerian bank app or USSD code. Automatic 5-sec wallet credit.
          </Text>

          <View style={styles.accountNumberBox}>
            <View style={{ flex: 1 }}>
              <Text style={styles.accNumLabel}>Account Number</Text>
              {palmpayAcc.accountNumber ? (
                <Text style={styles.accNumText}>{palmpayAcc.accountNumber}</Text>
              ) : (
                <TouchableOpacity
                  style={styles.assignRow}
                  onPress={handleGenerateAccounts}
                  disabled={generating}
                >
                  {generating ? (
                    <ActivityIndicator size="small" color="#FFFFFF" />
                  ) : (
                    <RefreshCw size={14} color="#C7D2FE" />
                  )}
                  <Text style={styles.assignText}>
                    {generating ? 'Assigning...' : 'Tap to Assign Account'}
                  </Text>
                </TouchableOpacity>
              )}
            </View>

            {palmpayAcc.accountNumber ? (
              <TouchableOpacity
                style={[styles.copyBtn, copiedPalm && styles.copiedBtn]}
                onPress={() => copyNumber(palmpayAcc.accountNumber, 'palm')}
                activeOpacity={0.8}
              >
                {copiedPalm ? <Check size={14} color="#FFFFFF" /> : <Copy size={14} color="#4F46E5" />}
                <Text style={[styles.copyBtnText, copiedPalm && styles.copiedBtnText]}>
                  {copiedPalm ? 'Copied' : 'Copy'}
                </Text>
              </TouchableOpacity>
            ) : null}
          </View>

          <View style={styles.accNameRow}>
            <Text style={styles.accNameLabel}>Beneficiary:</Text>
            <Text style={styles.accNameText} numberOfLines={1}>
              {palmpayAcc.accountName || 'MBK Customer'}
            </Text>
          </View>
        </LinearGradient>

        {/* CARD 3: DEDICATED PAGA VIRTUAL ACCOUNT CARD */}
        <LinearGradient
          colors={['#7C3AED', '#6D28D9', '#4C1D95']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={[styles.card, { width: CARD_WIDTH }]}
        >
          <View style={styles.cardHeader}>
            <View style={styles.bankTitleRow}>
              <Landmark size={18} color="#FED7AA" />
              <Text style={styles.bankNameHeader}>Paga Dedicated Account</Text>
            </View>
            <View style={[styles.instantPill, { backgroundColor: '#F97316' }]}>
              <Text style={styles.instantPillText}>INSTANT 24/7</Text>
            </View>
          </View>

          <Text style={styles.vaInstructions}>
            Dedicated backup account for instant automated bank transfer deposits.
          </Text>

          <View style={styles.accountNumberBox}>
            <View style={{ flex: 1 }}>
              <Text style={styles.accNumLabel}>Account Number</Text>
              {pagaAcc.accountNumber ? (
                <Text style={styles.accNumText}>{pagaAcc.accountNumber}</Text>
              ) : (
                <TouchableOpacity
                  style={styles.assignRow}
                  onPress={handleGenerateAccounts}
                  disabled={generating}
                >
                  {generating ? (
                    <ActivityIndicator size="small" color="#FFFFFF" />
                  ) : (
                    <RefreshCw size={14} color="#FED7AA" />
                  )}
                  <Text style={styles.assignText}>
                    {generating ? 'Assigning...' : 'Tap to Assign Account'}
                  </Text>
                </TouchableOpacity>
              )}
            </View>

            {pagaAcc.accountNumber ? (
              <TouchableOpacity
                style={[styles.copyBtn, copiedPaga && styles.copiedBtn]}
                onPress={() => copyNumber(pagaAcc.accountNumber, 'paga')}
                activeOpacity={0.8}
              >
                {copiedPaga ? <Check size={14} color="#FFFFFF" /> : <Copy size={14} color="#7C3AED" />}
                <Text style={[styles.copyBtnText, copiedPaga && styles.copiedBtnText]}>
                  {copiedPaga ? 'Copied' : 'Copy'}
                </Text>
              </TouchableOpacity>
            ) : null}
          </View>

          <View style={styles.accNameRow}>
            <Text style={styles.accNameLabel}>Beneficiary:</Text>
            <Text style={styles.accNameText} numberOfLines={1}>
              {pagaAcc.accountName || 'MBK Customer'}
            </Text>
          </View>
        </LinearGradient>
      </ScrollView>

      {/* Pagination Dots */}
      <View style={styles.pagination}>
        {[0, 1, 2].map((idx) => (
          <View
            key={idx}
            style={[
              styles.dot,
              activeIndex === idx
                ? { backgroundColor: colors.primary, width: 22 }
                : { backgroundColor: isDark ? 'rgba(255,255,255,0.2)' : 'rgba(0,0,0,0.15)', width: 6 },
            ]}
          />
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    marginBottom: 8,
  },
  scrollContainer: {
    paddingHorizontal: 20,
    gap: 12,
  },
  card: {
    borderRadius: 24,
    padding: 20,
    minHeight: 185,
    justifyContent: 'space-between',
    shadowColor: '#4F46E5',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.25,
    shadowRadius: 18,
    elevation: 8,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  labelWithEye: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  balanceLabel: {
    fontSize: 13,
    fontWeight: '700',
    color: '#E0E7FF',
    letterSpacing: 0.2,
  },
  historyBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 20,
  },
  historyText: {
    fontSize: 11,
    fontWeight: '800',
    color: '#FFFFFF',
  },
  balanceRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginVertical: 12,
  },
  balanceAmount: {
    fontSize: 28,
    fontWeight: '900',
    color: '#FFFFFF',
    letterSpacing: -0.5,
    flex: 1,
  },
  addMoneyBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.12,
    shadowRadius: 8,
    elevation: 3,
  },
  addMoneyText: {
    color: '#4F46E5',
    fontSize: 13,
    fontWeight: '900',
  },
  metricsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.15)',
    paddingTop: 10,
  },
  metricItem: {
    flex: 1,
  },
  metricDivider: {
    width: 1,
    height: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    marginHorizontal: 12,
  },
  metricLabel: {
    fontSize: 10,
    color: '#C7D2FE',
    fontWeight: '600',
  },
  metricVal: {
    fontSize: 13,
    color: '#FFFFFF',
    fontWeight: '800',
    marginTop: 2,
  },
  bankTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  bankNameHeader: {
    fontSize: 14,
    fontWeight: '900',
    color: '#FFFFFF',
  },
  instantPill: {
    backgroundColor: '#10B981',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 8,
  },
  instantPillText: {
    color: '#FFFFFF',
    fontSize: 9,
    fontWeight: '900',
    letterSpacing: 0.5,
  },
  vaInstructions: {
    fontSize: 11,
    color: '#E0E7FF',
    lineHeight: 16,
    marginTop: 4,
  },
  accountNumberBox: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: 'rgba(0, 0, 0, 0.2)',
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 14,
    marginVertical: 8,
  },
  accNumLabel: {
    fontSize: 9,
    color: '#C7D2FE',
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  accNumText: {
    fontSize: 20,
    fontWeight: '900',
    color: '#FFFFFF',
    fontFamily: 'monospace',
    letterSpacing: 1.5,
    marginTop: 2,
  },
  assignRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    marginTop: 4,
  },
  assignText: {
    fontSize: 13,
    fontWeight: '700',
    color: '#FED7AA',
    textDecorationLine: 'underline',
  },
  copyBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 10,
  },
  copiedBtn: {
    backgroundColor: '#10B981',
  },
  copyBtnText: {
    fontSize: 11,
    fontWeight: '800',
    color: '#4F46E5',
  },
  copiedBtnText: {
    color: '#FFFFFF',
  },
  accNameRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  accNameLabel: {
    fontSize: 11,
    color: '#C7D2FE',
    fontWeight: '500',
  },
  accNameText: {
    fontSize: 11,
    color: '#FFFFFF',
    fontWeight: '800',
    flex: 1,
  },
  pagination: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 6,
    marginTop: 10,
  },
  dot: {
    height: 5,
    borderRadius: 3,
  },
  activeDot: {
    width: 20,
    backgroundColor: '#4F46E5',
  },
  inactiveDot: {
    width: 6,
    backgroundColor: '#CBD5E1',
  },
});
