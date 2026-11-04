import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  StatusBar,
  RefreshControl,
  TouchableOpacity,
  Linking,
} from 'react-native';
import {
  Wifi,
  Smartphone,
  Tv,
  Zap,
  ArrowUpRight,
  ArrowDownLeft,
  ChevronRight,
  CreditCard,
  Clock,
  Sparkles,
} from 'lucide-react-native';
import { useAuth, MobileTransaction } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { apiClient } from '../../api/client';
import { Header } from '../../components/Header';
import { WalletCard } from '../../components/WalletCard';
import { QuickActionsGrid } from '../../components/QuickActionsGrid';
import { HomeBannerCarousel } from '../../components/HomeBannerCarousel';
import { formatNaira, formatDate } from '../../utils/formatters';
import { triggerHaptic } from '../../utils/haptics';

export const HomeScreen = ({ navigation }: any) => {
  const { user, wallet, transactions, refreshData } = useAuth();
  const { colors, isDark } = useTheme();
  const [refreshing, setRefreshing] = useState(false);
  const [supportPhone, setSupportPhone] = useState('2349047050681');

  React.useEffect(() => {
    apiClient.get('/admin/bank').then((res) => {
      const p = res.data?.bank?.whatsappNotificationPhone || res.data?.data?.whatsappNotificationPhone;
      if (p) setSupportPhone(p.replace(/[^0-9]/g, ''));
    }).catch(() => {});
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    triggerHaptic('light');
    await refreshData();
    setRefreshing(false);
  };

  const handleSupport = () => {
    triggerHaptic('light');
    Linking.openURL(`https://wa.me/${supportPhone}?text=Hello%20MBKDATASUB%20Support,%20I%20have%20an%20inquiry.`);
  };

  const handleServiceSelect = (serviceId: string) => {
    triggerHaptic('selection');
    const s = (serviceId || '').toLowerCase();
    switch (s) {
      case 'data':
        navigation.navigate('Data');
        break;
      case 'airtime':
        navigation.navigate('Airtime');
        break;
      case 'fund':
      case 'fundwallet':
        navigation.navigate('FundWallet');
        break;
      case 'cable':
        navigation.navigate('Cable');
        break;
      case 'electricity':
        navigation.navigate('Electricity');
        break;
      case 'airtime2cash':
        navigation.navigate('Airtime2Cash');
        break;
      case 'exampin':
      case 'exam':
      case 'waec':
        navigation.navigate('ExamPin');
        break;
      case 'smile':
        navigation.navigate('Smile');
        break;
      default:
        navigation.navigate('ServicesTab');
        break;
    }
  };

  const handleBannerPress = (targetRoute: string) => {
    triggerHaptic('selection');
    navigation.navigate(targetRoute);
  };



  const renderTransactionIcon = (tx: MobileTransaction) => {
    const code = (tx.serviceCode || tx.title || '').toLowerCase();
    if (code.includes('data')) {
      return <Wifi size={18} color="#38BDF8" />;
    }
    if (code.includes('airtime')) {
      return <Smartphone size={18} color="#10B981" />;
    }
    if (code.includes('cable') || code.includes('dstv') || code.includes('gotv')) {
      return <Tv size={18} color="#A855F7" />;
    }
    if (code.includes('power') || code.includes('elect') || code.includes('disco')) {
      return <Zap size={18} color="#F59E0B" />;
    }
    if (tx.type === 'credit') {
      return <ArrowDownLeft size={18} color="#10B981" />;
    }
    return <ArrowUpRight size={18} color="#94A3B8" />;
  };

  const recentList = transactions.slice(0, 5);

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.bg }]}>
      <StatusBar
        barStyle={colors.statusBar === 'dark' ? 'dark-content' : 'light-content'}
        backgroundColor={colors.bg}
      />
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary, colors.accent]}
          />
        }
      >
        {/* Top Header */}
        <Header
          onNotificationPress={() => {
            triggerHaptic('light');
            navigation.navigate('History');
          }}
          onSupportPress={handleSupport}
        />

        {/* Swipeable Wallet Cards (PalmPay, Paga, Balance) */}
        <View style={styles.sectionSpacing}>
          <WalletCard
            onFundPress={() => {
              triggerHaptic('selection');
              navigation.navigate('FundWallet');
            }}
            onHistory={() => {
              triggerHaptic('selection');
              navigation.navigate('History');
            }}
          />
        </View>

        {/* Quick Actions Grid */}
        <View style={styles.sectionSpacing}>
          <QuickActionsGrid onSelectService={handleServiceSelect} />
        </View>

        {/* Official Ambassador Hero Carousel */}
        <View style={styles.sectionSpacing}>
          <HomeBannerCarousel onBannerPress={handleBannerPress} />
        </View>

        {/* Recent Transactions Section */}
        <View style={styles.recentSection}>
          <View style={styles.sectionHeaderRow}>
            <View style={styles.titleWithIcon}>
              <Clock size={18} color={colors.primary} />
              <Text style={[styles.sectionTitle, { color: colors.text }]}>Recent Activity</Text>
            </View>
            <TouchableOpacity
              onPress={() => {
                triggerHaptic('light');
                navigation.navigate('History');
              }}
              style={styles.seeAllBtn}
            >
              <Text style={[styles.seeAllText, { color: colors.primary }]}>View All</Text>
              <ChevronRight size={16} color={colors.primary} />
            </TouchableOpacity>
          </View>

          {recentList.length === 0 ? (
            <View style={[styles.emptyCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
              <CreditCard size={36} color={colors.textMuted} />
              <Text style={[styles.emptyTitle, { color: colors.text }]}>No transactions yet</Text>
              <Text style={[styles.emptyDesc, { color: colors.textSecondary }]}>
                Your data topups, airtime recharges, and wallet funding will appear here in real-time.
              </Text>
              <TouchableOpacity
                style={[styles.emptyAction, { backgroundColor: colors.primaryBg, borderColor: colors.primary }]}
                onPress={() => navigation.navigate('Data')}
              >
                <Sparkles size={16} color={colors.primary} />
                <Text style={[styles.emptyActionText, { color: colors.primary }]}>Buy Data Bundle</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <View style={[styles.transactionsCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
              {recentList.map((tx, idx) => {
                const isCredit = tx.type === 'credit';
                return (
                  <TouchableOpacity
                    key={tx.id || `tx-${idx}`}
                    style={[
                      styles.txRow,
                      idx < recentList.length - 1 && [styles.txBorder, { borderBottomColor: colors.cardBorder }],
                    ]}
                    activeOpacity={0.7}
                    onPress={() => {
                      triggerHaptic('light');
                      navigation.navigate('History');
                    }}
                  >
                    <View style={[styles.txIconBox, { backgroundColor: colors.surface }]}>
                      {renderTransactionIcon(tx)}
                    </View>

                    <View style={styles.txInfo}>
                      <Text style={[styles.txTitle, { color: colors.text }]} numberOfLines={1}>
                        {tx.title}
                      </Text>
                      <Text style={[styles.txDate, { color: colors.textSecondary }]}>
                        {formatDate(tx.date)}
                      </Text>
                    </View>

                    <View style={styles.txAmountCol}>
                      <Text
                        style={[
                          styles.txAmount,
                          isCredit ? styles.txCredit : { color: colors.text },
                        ]}
                      >
                        {isCredit ? '+' : '-'} {formatNaira(tx.amount)}
                      </Text>
                      <View
                        style={[
                          styles.statusBadge,
                          tx.status === 'success'
                            ? styles.statusSuccess
                            : tx.status === 'pending'
                            ? styles.statusPending
                            : styles.statusFailed,
                        ]}
                      >
                        <Text
                          style={[
                            styles.statusText,
                            tx.status === 'success'
                              ? styles.statusTextSuccess
                              : tx.status === 'pending'
                              ? styles.statusTextPending
                              : styles.statusTextFailed,
                          ]}
                        >
                          {tx.status}
                        </Text>
                      </View>
                    </View>
                  </TouchableOpacity>
                );
              })}
            </View>
          )}
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
    paddingBottom: 40,
  },
  sectionSpacing: {
    marginTop: 18,
  },
  recentSection: {
    marginTop: 24,
    paddingHorizontal: 20,
  },
  sectionHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 14,
  },
  titleWithIcon: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  sectionTitle: {
    fontSize: 17,
    fontWeight: '700',
    color: '#F8FAFC',
  },
  seeAllBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 2,
  },
  seeAllText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#38BDF8',
  },
  transactionsCard: {
    backgroundColor: '#1E293B',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#334155',
    overflow: 'hidden',
  },
  txRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    paddingHorizontal: 16,
    gap: 12,
  },
  txBorder: {
    borderBottomWidth: 1,
    borderBottomColor: '#334155',
  },
  txIconBox: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: 'rgba(15, 23, 42, 0.6)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  txInfo: {
    flex: 1,
  },
  txTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#F8FAFC',
    marginBottom: 3,
  },
  txDate: {
    fontSize: 11,
    color: '#94A3B8',
  },
  txAmountCol: {
    alignItems: 'flex-end',
  },
  txAmount: {
    fontSize: 14,
    fontWeight: '700',
    marginBottom: 3,
  },
  txCredit: {
    color: '#10B981',
  },
  txDebit: {
    color: '#F8FAFC',
  },
  statusBadge: {
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 6,
  },
  statusSuccess: {
    backgroundColor: 'rgba(16, 185, 129, 0.15)',
  },
  statusPending: {
    backgroundColor: 'rgba(245, 158, 11, 0.15)',
  },
  statusFailed: {
    backgroundColor: 'rgba(239, 68, 68, 0.15)',
  },
  statusText: {
    fontSize: 10,
    fontWeight: '700',
    textTransform: 'uppercase',
  },
  statusTextSuccess: {
    color: '#34D399',
  },
  statusTextPending: {
    color: '#FBBF24',
  },
  statusTextFailed: {
    color: '#F87171',
  },
  emptyCard: {
    backgroundColor: '#1E293B',
    borderRadius: 20,
    padding: 28,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#334155',
  },
  emptyTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#F8FAFC',
    marginTop: 12,
  },
  emptyDesc: {
    fontSize: 13,
    color: '#94A3B8',
    textAlign: 'center',
    marginTop: 6,
    lineHeight: 18,
    paddingHorizontal: 10,
  },
  emptyAction: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(56, 189, 248, 0.1)',
    borderWidth: 1,
    borderColor: 'rgba(56, 189, 248, 0.3)',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 10,
    gap: 8,
    marginTop: 18,
  },
  emptyActionText: {
    fontSize: 13,
    fontWeight: '700',
    color: '#38BDF8',
  },
});
