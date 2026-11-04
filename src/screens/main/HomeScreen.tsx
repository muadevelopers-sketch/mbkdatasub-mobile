import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  StatusBar,
  RefreshControl,
  TouchableOpacity,
  Linking,
  Modal,
  Pressable,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';;
import { useFocusEffect } from '@react-navigation/native';
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
  Bell,
  X,
  Megaphone,
  CheckCircle2,
  AlertCircle,
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
  const [announcements, setAnnouncements] = useState<any[]>([]);
  const [isNotificationModalVisible, setIsNotificationModalVisible] = useState(false);
  const [activePopupAnnouncement, setActivePopupAnnouncement] = useState<any | null>(null);

  useFocusEffect(
    useCallback(() => {
      fetchLiveSettingsAndAnnouncements();
    }, [])
  );

  const fetchLiveSettingsAndAnnouncements = async () => {
    try {
      const [bankRes, brandRes, annRes] = await Promise.all([
        apiClient.get('/admin/bank').catch(() => null),
        apiClient.get('/admin/branding').catch(() => null),
        apiClient.get('/services/announcements').catch(() => null),
      ]);
      const p =
        brandRes?.data?.branding?.supportWhatsapp ||
        brandRes?.data?.supportWhatsapp ||
        brandRes?.data?.branding?.supportPhone ||
        bankRes?.data?.bank?.whatsappNotificationPhone ||
        bankRes?.data?.data?.whatsappNotificationPhone;
      if (p) setSupportPhone(p.replace(/[^0-9]/g, ''));

      if (annRes?.data?.success && Array.isArray(annRes.data.announcements)) {
        const active = annRes.data.announcements.filter((a: any) => a.isActive !== 0 && a.isActive !== false);
        setAnnouncements(active);
        const popup = active.find((a: any) => (a.displayType || '').toLowerCase() === 'popup');
        if (popup && !activePopupAnnouncement) {
          setActivePopupAnnouncement(popup);
        }
      }
    } catch {}
  };

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
            setIsNotificationModalVisible(true);
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

      {/* Priority Popup Announcement Modal from Admin */}
      <Modal
        visible={!!activePopupAnnouncement}
        transparent
        animationType="fade"
        onRequestClose={() => setActivePopupAnnouncement(null)}
      >
        <Pressable style={styles.modalOverlay} onPress={() => setActivePopupAnnouncement(null)}>
          <Pressable
            style={[styles.modalCard, { backgroundColor: colors.surface, borderColor: colors.primary }]}
            onPress={(e) => e.stopPropagation()}
          >
            <View style={styles.modalHeader}>
              <View style={[styles.modalIconCircle, { backgroundColor: 'rgba(56, 189, 248, 0.15)' }]}>
                <Megaphone size={22} color={colors.primary} />
              </View>
              <Text style={[styles.modalTitle, { color: colors.text }]}>{activePopupAnnouncement?.title || 'Announcement'}</Text>
              <TouchableOpacity onPress={() => setActivePopupAnnouncement(null)} hitSlop={10}>
                <X size={20} color={colors.textSecondary} />
              </TouchableOpacity>
            </View>
            <Text style={[styles.modalMessage, { color: colors.textSecondary }]}>
              {activePopupAnnouncement?.message}
            </Text>
            <TouchableOpacity
              style={[styles.modalDismissBtn, { backgroundColor: colors.primary }]}
              onPress={() => {
                triggerHaptic('light');
                setActivePopupAnnouncement(null);
              }}
            >
              <Text style={styles.modalDismissBtnText}>Got it, Thank You</Text>
            </TouchableOpacity>
          </Pressable>
        </Pressable>
      </Modal>

      {/* Notifications & Admin Broadcasts List Modal */}
      <Modal
        visible={isNotificationModalVisible}
        transparent
        animationType="slide"
        onRequestClose={() => setIsNotificationModalVisible(false)}
      >
        <Pressable style={styles.modalOverlay} onPress={() => setIsNotificationModalVisible(false)}>
          <Pressable
            style={[styles.sheetCard, { backgroundColor: colors.surface, borderColor: colors.cardBorder }]}
            onPress={(e) => e.stopPropagation()}
          >
            <View style={styles.sheetHeader}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                <Bell size={20} color={colors.primary} />
                <Text style={[styles.sheetTitle, { color: colors.text }]}>Notifications & Updates</Text>
              </View>
              <TouchableOpacity onPress={() => setIsNotificationModalVisible(false)} hitSlop={10}>
                <X size={20} color={colors.textSecondary} />
              </TouchableOpacity>
            </View>
            <ScrollView style={{ maxHeight: 380 }} showsVerticalScrollIndicator={false}>
              {announcements.length === 0 ? (
                <View style={{ paddingVertical: 30, alignItems: 'center' }}>
                  <Bell size={32} color={colors.textMuted} style={{ marginBottom: 8 }} />
                  <Text style={{ color: colors.textSecondary, fontSize: 14 }}>No new broadcasts at this time.</Text>
                </View>
              ) : (
                announcements.map((ann, idx) => (
                  <View
                    key={ann.id || idx}
                    style={[styles.announcementItem, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}
                  >
                    <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 4 }}>
                      <Text style={[styles.announcementTitle, { color: colors.text }]}>{ann.title}</Text>
                      <View style={[styles.announcementTag, { backgroundColor: colors.primary + '22' }]}>
                        <Text style={[styles.announcementTagText, { color: colors.primary }]}>{ann.targetGroup || 'BROADCAST'}</Text>
                      </View>
                    </View>
                    <Text style={[styles.announcementMessage, { color: colors.textSecondary }]}>{ann.message}</Text>
                  </View>
                ))
              )}
            </ScrollView>
          </Pressable>
        </Pressable>
      </Modal>
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
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalCard: {
    width: '100%',
    maxWidth: 380,
    borderRadius: 20,
    padding: 20,
    borderWidth: 1.5,
  },
  modalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginBottom: 12,
  },
  modalIconCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalTitle: {
    flex: 1,
    fontSize: 16,
    fontWeight: '700',
  },
  modalMessage: {
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 20,
  },
  modalDismissBtn: {
    paddingVertical: 12,
    borderRadius: 12,
    alignItems: 'center',
  },
  modalDismissBtnText: {
    color: '#FFFFFF',
    fontWeight: '700',
    fontSize: 14,
  },
  sheetCard: {
    width: '100%',
    maxWidth: 420,
    borderRadius: 24,
    padding: 20,
    borderWidth: 1,
  },
  sheetHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(150, 150, 150, 0.1)',
  },
  sheetTitle: {
    fontSize: 16,
    fontWeight: '700',
  },
  announcementItem: {
    padding: 14,
    borderRadius: 14,
    marginBottom: 10,
    borderWidth: 1,
  },
  announcementTitle: {
    fontSize: 14,
    fontWeight: '700',
    flex: 1,
  },
  announcementTag: {
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 6,
  },
  announcementTagText: {
    fontSize: 10,
    fontWeight: '700',
  },
  announcementMessage: {
    fontSize: 13,
    lineHeight: 18,
  },
});
