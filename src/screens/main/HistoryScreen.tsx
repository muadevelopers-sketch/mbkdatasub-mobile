import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  StatusBar,
  TextInput,
  TouchableOpacity,
  Modal,
  Share,
  Linking,
  RefreshControl,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';;
import * as Clipboard from 'expo-clipboard';
import {
  Search,
  Wifi,
  Smartphone,
  Tv,
  Zap,
  ArrowUpRight,
  ArrowDownLeft,
  ArrowLeft,
  X,
  Copy,
  Check,
  Share2,
  ShieldCheck,
  CreditCard,
  MessageCircle,
} from 'lucide-react-native';
import { useAuth, MobileTransaction } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { formatNaira, formatDate } from '../../utils/formatters';
import { triggerHaptic } from '../../utils/haptics';
import { apiClient } from '../../api/client';

export const HistoryScreen = ({ navigation }: any) => {
  const { transactions, refreshData } = useAuth();
  const { colors, isDark } = useTheme();
  const [supportPhone, setSupportPhone] = useState('2349047050681');

  useEffect(() => {
    apiClient.get('/admin/branding').then((res) => {
      const p = res.data?.branding?.supportWhatsapp || res.data?.branding?.supportPhone || res.data?.supportWhatsapp || res.data?.supportPhone;
      if (p) setSupportPhone(p.replace(/[^0-9]/g, ''));
    }).catch(() => {});
  }, []);
  const [filterType, setFilterType] = useState<'all' | 'data' | 'airtime' | 'cable' | 'power' | 'fund'>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedTx, setSelectedTx] = useState<MobileTransaction | null>(null);
  const [copied, setCopied] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  const onRefresh = async () => {
    setRefreshing(true);
    triggerHaptic('light');
    await refreshData();
    setRefreshing(false);
  };

  const filterTabs = [
    { id: 'all', label: 'All' },
    { id: 'data', label: 'Data' },
    { id: 'airtime', label: 'Airtime' },
    { id: 'cable', label: 'Cable TV' },
    { id: 'power', label: 'Electricity' },
    { id: 'fund', label: 'Funding' },
  ];

  const txList = Array.isArray(transactions) ? transactions : [];

  const filteredTransactions = txList.filter((tx) => {
    if (!tx) return false;
    const code = (tx.serviceCode || tx.title || '').toLowerCase();
    const query = (searchQuery || '').toLowerCase();

    // Match search
    const matchesSearch =
      !query ||
      (tx.title || '').toLowerCase().includes(query) ||
      (tx.reference || '').toLowerCase().includes(query) ||
      (tx.recipient && String(tx.recipient).includes(query));

    if (!matchesSearch) return false;

    // Match tab
    if (filterType === 'all') return true;
    if (filterType === 'data') return code.includes('data');
    if (filterType === 'airtime') return code.includes('airtime');
    if (filterType === 'cable') return code.includes('cable') || code.includes('dstv') || code.includes('gotv');
    if (filterType === 'power') return code.includes('elect') || code.includes('power') || code.includes('disco');
    if (filterType === 'fund') return tx.type === 'credit' || code.includes('fund') || code.includes('wallet');

    return true;
  });

  const handleCopyRef = async (ref: string) => {
    await Clipboard.setStringAsync(ref);
    triggerHaptic('success');
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleShareReceipt = async (tx: MobileTransaction) => {
    triggerHaptic('light');
    const msg = `🧾 MBK DATASUB RECEIPT\nReference: ${tx.reference}\nService: ${tx.title}\nAmount: ₦${tx.amount.toLocaleString()}\nStatus: ${tx.status.toUpperCase()}\nRecipient: ${tx.recipient || 'N/A'}\nDate: ${formatDate(tx.date)}\nThank you for choosing MBK DATASUB!`;
    try {
      await Share.share({ message: msg });
    } catch {}
  };

  const handleReportIssue = (tx: MobileTransaction) => {
    triggerHaptic('light');
    const msg = encodeURIComponent(
      `Hello MBKDATASUB Support, I need help with transaction ${tx.reference} for ${tx.title} of ₦${tx.amount}.`
    );
    Linking.openURL(`https://wa.me/${supportPhone}?text=${msg}`);
  };

  const renderIcon = (tx: MobileTransaction) => {
    const code = (tx.serviceCode || tx.title || '').toLowerCase();
    if (code.includes('data')) return <Wifi size={18} color="#38BDF8" />;
    if (code.includes('airtime')) return <Smartphone size={18} color="#10B981" />;
    if (code.includes('cable')) return <Tv size={18} color="#A855F7" />;
    if (code.includes('power') || code.includes('elect')) return <Zap size={18} color="#F59E0B" />;
    if (tx.type === 'credit') return <ArrowDownLeft size={18} color="#10B981" />;
    return <ArrowUpRight size={18} color="#94A3B8" />;
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.bg }]}>
      <StatusBar
        barStyle={colors.statusBar === 'dark' ? 'dark-content' : 'light-content'}
        backgroundColor={colors.bg}
      />

      {/* Header */}
      <View style={styles.header}>
        <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 4 }}>
          {navigation?.canGoBack?.() && (
            <TouchableOpacity
              style={{ marginRight: 12, padding: 4 }}
              onPress={() => {
                triggerHaptic('light');
                navigation.goBack();
              }}
            >
              <ArrowLeft size={22} color={colors.text} />
            </TouchableOpacity>
          )}
          <Text style={[styles.headerTitle, { color: colors.text }]}>Transaction History</Text>
        </View>
        <Text style={[styles.headerSubtitle, { color: colors.textSecondary }]}>
          Complete real-time record of all your wallet transactions.
        </Text>
      </View>

      {/* Search Input */}
      <View style={[styles.searchWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
        <Search size={18} color={colors.textMuted} />
        <TextInput
          style={[styles.searchInput, { color: colors.text }]}
          placeholder="Search by recipient or reference..."
          placeholderTextColor={colors.textMuted}
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>

      {/* Horizontal Filter Tabs */}
      <View style={styles.tabsContainer}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.tabsScroll}>
          {filterTabs.map((tab) => {
            const active = filterType === tab.id;
            return (
              <TouchableOpacity
                key={tab.id}
                style={[
                  styles.tabChip,
                  {
                    backgroundColor: active ? colors.primary : colors.card,
                    borderColor: active ? colors.primary : colors.cardBorder,
                  },
                ]}
                onPress={() => {
                  triggerHaptic('selection');
                  setFilterType(tab.id as any);
                }}
              >
                <Text
                  style={[
                    styles.tabChipText,
                    { color: active ? '#FFFFFF' : colors.textSecondary },
                  ]}
                >
                  {tab.label}
                </Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </View>

      {/* Transactions List */}
      <ScrollView
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary, colors.accent]}
          />
        }
      >
        {filteredTransactions.length === 0 ? (
          <View style={[styles.emptyContainer, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <CreditCard size={48} color={colors.textMuted} />
            <Text style={[styles.emptyTitle, { color: colors.text }]}>No transactions found</Text>
            <Text style={[styles.emptySubtitle, { color: colors.textSecondary }]}>
              Try clearing your search or filtering by another category.
            </Text>
          </View>
        ) : (
          <View style={[styles.cardWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            {filteredTransactions.map((tx, idx) => {
              const isCredit = tx.type === 'credit';
              return (
                <TouchableOpacity
                  key={tx.id || `tx-hist-${idx}`}
                  style={[
                    styles.txItem,
                    idx < filteredTransactions.length - 1 && [styles.txBorder, { borderBottomColor: colors.cardBorder }],
                  ]}
                  activeOpacity={0.7}
                  onPress={() => {
                    triggerHaptic('light');
                    setSelectedTx(tx);
                  }}
                >
                  <View style={[styles.iconBox, { backgroundColor: colors.surface }]}>{renderIcon(tx)}</View>

                  <View style={styles.infoCol}>
                    <Text style={[styles.txTitle, { color: colors.text }]} numberOfLines={1}>
                      {tx.title}
                    </Text>
                    <Text style={[styles.txDate, { color: colors.textSecondary }]}>{formatDate(tx.date)}</Text>
                    {tx.recipient ? (
                      <Text style={[styles.txRecipient, { color: colors.primary }]}>To: {tx.recipient}</Text>
                    ) : null}
                  </View>

                  <View style={styles.amountCol}>
                    <Text
                      style={[
                        styles.amountText,
                        isCredit ? styles.amountCredit : { color: colors.text },
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
                          styles.statusBadgeText,
                          tx.status === 'success'
                            ? styles.statusSuccessText
                            : tx.status === 'pending'
                            ? styles.statusPendingText
                            : styles.statusFailedText,
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
      </ScrollView>

      {/* Transaction Details & Receipt Modal */}
      {selectedTx && (
        <Modal
          visible={!!selectedTx}
          transparent
          animationType="slide"
          onRequestClose={() => setSelectedTx(null)}
        >
          <View style={styles.modalOverlay}>
            <View style={[styles.receiptSheet, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
              {/* Receipt Header */}
              <View style={styles.receiptHeader}>
                <View style={styles.receiptTitleRow}>
                  <ShieldCheck size={20} color={colors.success} />
                  <Text style={[styles.receiptModalTitle, { color: colors.text }]}>Transaction Receipt</Text>
                </View>
                <TouchableOpacity
                  onPress={() => setSelectedTx(null)}
                  style={[styles.closeBtn, { backgroundColor: colors.surface }]}
                >
                  <X size={20} color={colors.textMuted} />
                </TouchableOpacity>
              </View>

              {/* Amount Display */}
              <View style={[styles.amountBanner, { backgroundColor: colors.surface }]}>
                <Text style={[styles.receiptAmountLabel, { color: colors.textSecondary }]}>Total Amount</Text>
                <Text style={[styles.receiptAmountValue, { color: colors.text }]}>{formatNaira(selectedTx.amount)}</Text>
                <View
                  style={[
                    styles.receiptStatusPill,
                    selectedTx.status === 'success'
                      ? styles.statusSuccess
                      : styles.statusFailed,
                  ]}
                >
                  <Text
                    style={[
                      styles.receiptStatusText,
                      selectedTx.status === 'success'
                        ? styles.statusSuccessText
                        : styles.statusFailedText,
                    ]}
                  >
                    {selectedTx.status.toUpperCase()}
                  </Text>
                </View>
              </View>

              {/* Details Breakdown */}
              <View style={[styles.receiptDetails, { backgroundColor: colors.surface, borderColor: colors.cardBorder }]}>
                <View style={[styles.detailRow, { borderBottomColor: colors.cardBorder }]}>
                  <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>Service</Text>
                  <Text style={[styles.detailVal, { color: colors.text }]}>{selectedTx.title}</Text>
                </View>

                {selectedTx.recipient ? (
                  <View style={[styles.detailRow, { borderBottomColor: colors.cardBorder }]}>
                    <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>Recipient</Text>
                    <Text style={[styles.detailVal, { color: colors.text }]}>{selectedTx.recipient}</Text>
                  </View>
                ) : null}

                <View style={[styles.detailRow, { borderBottomColor: colors.cardBorder }]}>
                  <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>Date & Time</Text>
                  <Text style={[styles.detailVal, { color: colors.text }]}>{formatDate(selectedTx.date)}</Text>
                </View>

                <View style={[styles.detailRow, { borderBottomColor: colors.cardBorder }]}>
                  <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>Reference</Text>
                  <TouchableOpacity
                    style={styles.refCopyRow}
                    onPress={() => handleCopyRef(selectedTx.reference)}
                  >
                    <Text style={[styles.refVal, { color: colors.primary }]} numberOfLines={1}>
                      {selectedTx.reference}
                    </Text>
                    {copied ? (
                      <Check size={14} color={colors.success} />
                    ) : (
                      <Copy size={14} color={colors.primary} />
                    )}
                  </TouchableOpacity>
                </View>

                {selectedTx.balanceAfter !== undefined && (
                  <View style={styles.detailRow}>
                    <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>Balance After</Text>
                    <Text style={[styles.detailVal, { color: colors.text }]}>{formatNaira(selectedTx.balanceAfter)}</Text>
                  </View>
                )}
              </View>

              {/* Modal Actions */}
              <View style={styles.modalActionRow}>
                <TouchableOpacity
                  style={styles.shareBtn}
                  onPress={() => handleShareReceipt(selectedTx)}
                >
                  <Share2 size={18} color="#FFFFFF" />
                  <Text style={styles.shareBtnText}>Share Receipt</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={styles.supportBtn}
                  onPress={() => handleReportIssue(selectedTx)}
                >
                  <MessageCircle size={18} color="#38BDF8" />
                  <Text style={styles.supportBtnText}>Support</Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        </Modal>
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0F172A',
  },
  header: {
    maxWidth: 640,
    width: '100%',
    alignSelf: 'center',
    paddingHorizontal: 20,
    paddingTop: 16,
    marginBottom: 14,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: '800',
    color: '#F8FAFC',
    letterSpacing: -0.5,
  },
  headerSubtitle: {
    fontSize: 13,
    color: '#94A3B8',
    marginTop: 4,
  },
  searchWrapper: {
    maxWidth: 640,
    width: '92%',
    alignSelf: 'center',
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1E293B',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#334155',
    paddingHorizontal: 14,
    height: 46,
    marginBottom: 12,
    gap: 10,
  },
  searchInput: {
    flex: 1,
    fontSize: 14,
    color: '#F8FAFC',
  },
  tabsContainer: {
    maxWidth: 640,
    width: '100%',
    alignSelf: 'center',
    marginBottom: 14,
  },
  tabsScroll: {
    paddingHorizontal: 20,
    gap: 8,
  },
  tabChip: {
    backgroundColor: '#1E293B',
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#334155',
  },
  tabChipActive: {
    backgroundColor: '#2563EB',
    borderColor: '#3B82F6',
  },
  tabChipText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#94A3B8',
  },
  tabChipTextActive: {
    color: '#FFFFFF',
  },
  listContent: {
    maxWidth: 640,
    width: '100%',
    alignSelf: 'center',
    paddingHorizontal: 20,
    paddingBottom: 40,
  },
  cardWrapper: {
    backgroundColor: '#1E293B',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#334155',
    overflow: 'hidden',
  },
  txItem: {
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
  iconBox: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: 'rgba(15, 23, 42, 0.6)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  infoCol: {
    flex: 1,
  },
  txTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#F8FAFC',
    marginBottom: 2,
  },
  txDate: {
    fontSize: 11,
    color: '#94A3B8',
  },
  txRecipient: {
    fontSize: 11,
    color: '#38BDF8',
    marginTop: 2,
  },
  amountCol: {
    alignItems: 'flex-end',
  },
  amountText: {
    fontSize: 14,
    fontWeight: '700',
    marginBottom: 4,
  },
  amountCredit: {
    color: '#10B981',
  },
  amountDebit: {
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
  statusBadgeText: {
    fontSize: 10,
    fontWeight: '700',
    textTransform: 'uppercase',
  },
  statusSuccessText: {
    color: '#34D399',
  },
  statusPendingText: {
    color: '#FBBF24',
  },
  statusFailedText: {
    color: '#F87171',
  },
  emptyContainer: {
    backgroundColor: '#1E293B',
    borderRadius: 20,
    padding: 36,
    alignItems: 'center',
    marginTop: 20,
    borderWidth: 1,
    borderColor: '#334155',
  },
  emptyTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#F8FAFC',
    marginTop: 12,
  },
  emptySubtitle: {
    fontSize: 13,
    color: '#94A3B8',
    textAlign: 'center',
    marginTop: 6,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(15, 23, 42, 0.8)',
    justifyContent: 'flex-end',
  },
  receiptSheet: {
    backgroundColor: '#0F172A',
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    padding: 24,
    borderTopWidth: 1,
    borderColor: '#1E293B',
  },
  receiptHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  receiptTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  receiptModalTitle: {
    fontSize: 17,
    fontWeight: '700',
    color: '#F8FAFC',
  },
  closeBtn: {
    padding: 6,
    borderRadius: 16,
    backgroundColor: '#1E293B',
  },
  amountBanner: {
    alignItems: 'center',
    backgroundColor: '#1E293B',
    padding: 20,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#334155',
    marginBottom: 20,
  },
  receiptAmountLabel: {
    fontSize: 12,
    color: '#94A3B8',
    textTransform: 'uppercase',
    fontWeight: '600',
    letterSpacing: 0.5,
  },
  receiptAmountValue: {
    fontSize: 28,
    fontWeight: '800',
    color: '#38BDF8',
    marginTop: 6,
    marginBottom: 8,
  },
  receiptStatusPill: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 20,
  },
  receiptStatusText: {
    fontSize: 11,
    fontWeight: '700',
  },
  receiptDetails: {
    backgroundColor: '#1E293B',
    borderRadius: 18,
    padding: 16,
    gap: 14,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: '#334155',
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  detailLabel: {
    fontSize: 13,
    color: '#94A3B8',
  },
  detailVal: {
    fontSize: 13,
    fontWeight: '600',
    color: '#F8FAFC',
  },
  refCopyRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    maxWidth: '60%',
  },
  refVal: {
    fontSize: 12,
    color: '#38BDF8',
    fontWeight: '600',
  },
  modalActionRow: {
    flexDirection: 'row',
    gap: 12,
  },
  shareBtn: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2563EB',
    height: 50,
    borderRadius: 14,
    gap: 8,
  },
  shareBtnText: {
    fontSize: 14,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  supportBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(56, 189, 248, 0.1)',
    borderWidth: 1,
    borderColor: '#38BDF8',
    height: 50,
    paddingHorizontal: 18,
    borderRadius: 14,
    gap: 6,
  },
  supportBtnText: {
    fontSize: 14,
    fontWeight: '700',
    color: '#38BDF8',
  },
});
