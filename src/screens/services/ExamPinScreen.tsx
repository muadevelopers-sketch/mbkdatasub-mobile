import React, { useState } from 'react';
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
import { SafeAreaView } from 'react-native-safe-area-context';
import * as Clipboard from 'expo-clipboard';
import {
  ArrowLeft,
  GraduationCap,
  Check,
  Plus,
  Minus,
  Copy,
  Receipt,
  Sparkles,
  Phone,
  HelpCircle,
  ChevronRight,
} from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { apiClient } from '../../api/client';
import { formatNaira } from '../../utils/formatters';
import { triggerHaptic } from '../../utils/haptics';
import { BiometricPinModal } from '../../components/BiometricPinModal';
import { InsufficientBalanceModal } from '../../components/InsufficientBalanceModal';
import { TransactionSuccessModal } from '../../components/TransactionSuccessModal';

const EXAM_LOGOS: Record<string, any> = {
  waec: require('../../../assets/exams/waec.png'),
  neco: require('../../../assets/exams/neco.png'),
  nabteb: require('../../../assets/exams/nabteb.png'),
  jamb: require('../../../assets/exams/jamb.png'),
};

interface ExamItem {
  id: string;
  name: string;
  body: string;
  price: number;
  badge: string;
  description: string;
}

const EXAMS: ExamItem[] = [
  {
    id: 'waec',
    name: 'WAEC Result Checker',
    body: 'West African Examinations Council',
    price: 3500,
    badge: 'Instant Delivery',
    description: 'Check May/June & GCE candidate results online.',
  },
  {
    id: 'neco',
    name: 'NECO Result Token',
    body: 'National Examinations Council',
    price: 1200,
    badge: 'Most Popular',
    description: 'Direct token for SSCE Internal and External results.',
  },
  {
    id: 'nabteb',
    name: 'NABTEB Result Card',
    body: 'Business & Technical Exam Board',
    price: 1100,
    badge: 'Fast Delivery',
    description: 'Check NBC/NTC technical exam results instantly.',
  },
  {
    id: 'jamb',
    name: 'JAMB UTME / DE PIN',
    body: 'Joint Admissions & Matriculation Board',
    price: 4700,
    badge: 'Official Candidate e-PIN',
    description: 'Registration profile e-PIN for UTME and Direct Entry.',
  },
];

export const ExamPinScreen = ({ navigation }: any) => {
  const { wallet, refreshData, user } = useAuth();
  const { colors, isDark } = useTheme();

  // User selects an exam service first before price and details are revealed
  const [selectedExam, setSelectedExam] = useState<ExamItem | null>(null);
  const [quantity, setQuantity] = useState(1);
  const [recipientPhone, setRecipientPhone] = useState(user?.phone || '');
  const [generatedPins, setGeneratedPins] = useState<Array<{ pin: string; serial: string }> | null>(null);
  const [copiedIdx, setCopiedIdx] = useState<number | null>(null);

  const [isPinModalVisible, setIsPinModalVisible] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [insufficientModalVisible, setInsufficientModalVisible] = useState(false);
  const [successModalVisible, setSuccessModalVisible] = useState(false);
  const [lastTxData, setLastTxData] = useState<any>(null);

  const totalPrice = (selectedExam?.price || 0) * quantity;

  const handleSelectExam = (exam: ExamItem) => {
    triggerHaptic('selection');
    setSelectedExam(exam);
    setQuantity(1);
  };

  const handleInitPurchase = () => {
    if (!selectedExam) {
      triggerHaptic('error');
      Alert.alert('Selection Required', 'Please tap on an examination body to continue.');
      return;
    }

    triggerHaptic('medium');
    setIsPinModalVisible(true);
  };

  const handleAuthorizePurchase = async (pin: string) => {
    if (!selectedExam) return;

    setIsSubmitting(true);
    try {
      // Check balance - allow user up to auth step, then display attractive modal if insufficient
      if (wallet.balance < totalPrice) {
        setIsSubmitting(false);
        setIsPinModalVisible(false);
        triggerHaptic('error');
        setInsufficientModalVisible(true);
        return;
      }

      const res = await apiClient.post('/services/exampin', {
        examName: selectedExam.name,
        quantity,
        recipientPhone: recipientPhone.trim() || user?.phone,
        pin,
      });

      setIsSubmitting(false);
      setIsPinModalVisible(false);

      if (res.data?.success) {
        triggerHaptic('success');
        await refreshData();
        const pins = res.data.pins || [
          {
            pin: `PIN-${Date.now().toString().slice(-8)}`,
            serial: `SN-${Date.now().toString().slice(-6)}`,
          },
        ];
        setGeneratedPins(pins);
        setLastTxData({
          amount: totalPrice,
          recipient: `${recipientPhone.trim() || user?.phone || 'Candidate'} (Qty: ${quantity})`,
          reference: res.data.transaction?.reference || `EXM-${Date.now().toString().slice(-8)}`,
          title: `${selectedExam.name} (x${quantity})`,
          balanceAfter: res.data.balance || (wallet.balance - totalPrice),
          pins,
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

  const handleCopyPin = async (pinText: string, idx: number) => {
    await Clipboard.setStringAsync(pinText);
    triggerHaptic('success');
    setCopiedIdx(idx);
    setTimeout(() => setCopiedIdx(null), 2000);
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
          <Text style={[styles.navTitle, { color: colors.text }]}>Educational Exam PINs</Text>
          <View style={{ width: 40 }} />
        </View>

        {/* Balance Row */}
        <View style={[styles.balanceRow, { backgroundColor: colors.primaryBg, borderColor: colors.primary }]}>
          <Text style={[styles.balanceLabel, { color: colors.textSecondary }]}>Wallet Balance:</Text>
          <Text style={[styles.balanceValue, { color: colors.primary }]}>{formatNaira(wallet.balance)}</Text>
        </View>

        {/* Generated PINs Card if available */}
        {generatedPins && generatedPins.length > 0 && (
          <View style={[styles.pinsCard, { backgroundColor: colors.card, borderColor: '#10B981' }]}>
            <View style={styles.pinsCardHeader}>
              <Receipt size={18} color="#10B981" />
              <Text style={[styles.pinsCardTitle, { color: '#10B981' }]}>YOUR GENERATED PIN(S)</Text>
            </View>
            {generatedPins.map((item, idx) => (
              <View key={idx} style={[styles.pinItem, { borderColor: colors.cardBorder }]}>
                <View>
                  <Text style={[styles.pinVal, { color: colors.text }]}>PIN: {item.pin}</Text>
                  {item.serial ? <Text style={[styles.serialVal, { color: colors.textSecondary }]}>Serial: {item.serial}</Text> : null}
                </View>
                <TouchableOpacity
                  style={[styles.pinCopyBtn, { backgroundColor: colors.primaryBg }]}
                  onPress={() => handleCopyPin(item.pin, idx)}
                >
                  {copiedIdx === idx ? <Check size={14} color="#10B981" /> : <Copy size={14} color={colors.primary} />}
                  <Text style={[styles.pinCopyText, { color: copiedIdx === idx ? '#10B981' : colors.primary }]}>
                    {copiedIdx === idx ? 'Copied' : 'Copy'}
                  </Text>
                </TouchableOpacity>
              </View>
            ))}
          </View>
        )}

        {/* Step 1: Select Examination Body (Only reveals prices after click) */}
        <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>
          Step 1: Choose Examination Body
        </Text>
        <View style={styles.examGrid}>
          {EXAMS.map((item) => {
            const isSelected = selectedExam?.id === item.id;
            return (
              <TouchableOpacity
                key={item.id}
                style={[
                  styles.examCard,
                  { backgroundColor: colors.card, borderColor: isSelected ? colors.primary : colors.cardBorder },
                  isSelected && { backgroundColor: colors.primaryBg, borderWidth: 2 },
                ]}
                onPress={() => handleSelectExam(item)}
                activeOpacity={0.75}
              >
                <View style={styles.examCardHeader}>
                  <View style={[styles.examIconBox, { backgroundColor: '#FFFFFF', borderWidth: 1, borderColor: isSelected ? colors.primary : '#E2E8F0' }]}>
                    {EXAM_LOGOS[item.id] ? (
                      <Image source={EXAM_LOGOS[item.id]} style={styles.examLogo} resizeMode="contain" />
                    ) : (
                      <GraduationCap size={22} color={colors.primary} />
                    )}
                  </View>
                  {isSelected ? (
                    <View style={[styles.checkCircle, { backgroundColor: colors.primary }]}>
                      <Check size={12} color="#FFFFFF" />
                    </View>
                  ) : (
                    <ChevronRight size={18} color={colors.textMuted} />
                  )}
                </View>
                <Text style={[styles.examName, { color: colors.text }]}>{item.name}</Text>
                <Text style={[styles.examBodyText, { color: colors.textSecondary }]}>{item.body}</Text>
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Step 2: Revealed ONLY after an exam is selected */}
        {selectedExam ? (
          <View style={styles.revealedSection}>
            <View style={[styles.selectedHeaderCard, { backgroundColor: colors.card, borderColor: colors.primary }]}>
              <View style={{ flexDirection: 'row', alignItems: 'center', flex: 1, gap: 12 }}>
                {EXAM_LOGOS[selectedExam.id] && (
                  <View style={[styles.selectedLogoBox, { backgroundColor: '#FFFFFF' }]}>
                    <Image source={EXAM_LOGOS[selectedExam.id]} style={styles.selectedExamLogo} resizeMode="contain" />
                  </View>
                )}
                <View style={styles.selectedLeft}>
                  <Text style={[styles.revealedBadge, { color: colors.primary }]}>{selectedExam.badge}</Text>
                  <Text style={[styles.revealedName, { color: colors.text }]}>{selectedExam.name}</Text>
                  <Text style={[styles.revealedDesc, { color: colors.textSecondary }]}>{selectedExam.description}</Text>
                </View>
              </View>
              <View style={styles.selectedRight}>
                <Text style={[styles.unitPriceLabel, { color: colors.textSecondary }]}>Unit Price</Text>
                <Text style={[styles.unitPriceVal, { color: colors.primary }]}>
                  {formatNaira(selectedExam.price)}
                </Text>
              </View>
            </View>

            {/* Candidate Phone Number for SMS notification with Special Placeholder */}
            <View style={styles.formGroup}>
              <Text style={[styles.inputLabel, { color: colors.textSecondary }]}>
                Candidate Phone Number (For Instant SMS Delivery)
              </Text>
              <View style={[styles.inputWrapper, { backgroundColor: colors.inputBg, borderColor: colors.inputBorder }]}>
                <Phone size={18} color={colors.textSecondary} style={{ marginRight: 10 }} />
                <TextInput
                  style={[styles.textInput, { color: colors.text }]}
                  placeholder="e.g. 0801 234 5678 (SMS token delivery)"
                  placeholderTextColor={colors.textMuted}
                  value={recipientPhone}
                  onChangeText={setRecipientPhone}
                  keyboardType="phone-pad"
                />
              </View>
            </View>

            {/* Quantity Selector */}
            <View style={[styles.qtyCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
              <View>
                <Text style={[styles.qtyLabel, { color: colors.text }]}>Token Quantity</Text>
                <Text style={[styles.qtySub, { color: colors.textSecondary }]}>Select number of scratch PINs</Text>
              </View>
              <View style={styles.qtyControls}>
                <TouchableOpacity
                  style={[styles.qtyBtn, { backgroundColor: colors.inputBg }]}
                  onPress={() => {
                    if (quantity > 1) {
                      triggerHaptic('light');
                      setQuantity(quantity - 1);
                    }
                  }}
                >
                  <Minus size={18} color={colors.text} />
                </TouchableOpacity>
                <Text style={[styles.qtyNum, { color: colors.text }]}>{quantity}</Text>
                <TouchableOpacity
                  style={[styles.qtyBtn, { backgroundColor: colors.inputBg }]}
                  onPress={() => {
                    if (quantity < 10) {
                      triggerHaptic('light');
                      setQuantity(quantity + 1);
                    }
                  }}
                >
                  <Plus size={18} color={colors.text} />
                </TouchableOpacity>
              </View>
            </View>

            {/* Order Total Breakdown */}
            <View style={[styles.totalCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
              <View style={styles.totalRow}>
                <Text style={[styles.totalLabel, { color: colors.textSecondary }]}>Exam Body:</Text>
                <Text style={[styles.totalVal, { color: colors.text }]}>{selectedExam.name}</Text>
              </View>
              <View style={styles.totalRow}>
                <Text style={[styles.totalLabel, { color: colors.textSecondary }]}>Price per PIN:</Text>
                <Text style={[styles.totalVal, { color: colors.text }]}>{formatNaira(selectedExam.price)}</Text>
              </View>
              <View style={styles.totalRow}>
                <Text style={[styles.totalLabel, { color: colors.textSecondary }]}>Quantity:</Text>
                <Text style={[styles.totalVal, { color: colors.text }]}>x {quantity}</Text>
              </View>
              <View style={[styles.totalRow, styles.grandTotalRow, { borderTopColor: colors.cardBorder }]}>
                <Text style={[styles.grandTotalLabel, { color: colors.text }]}>Total to Pay:</Text>
                <Text style={[styles.grandTotalVal, { color: colors.primary }]}>{formatNaira(totalPrice)}</Text>
              </View>
            </View>

            {/* Checkout Button */}
            <TouchableOpacity
              style={[styles.checkoutBtn, { backgroundColor: colors.accent }]}
              onPress={handleInitPurchase}
              activeOpacity={0.8}
            >
              <GraduationCap size={20} color="#FFFFFF" />
              <Text style={styles.checkoutBtnText}>
                Generate {quantity} {selectedExam.id.toUpperCase()} PIN ({formatNaira(totalPrice)})
              </Text>
            </TouchableOpacity>
          </View>
        ) : (
          /* Empty Placeholder State when no exam is selected */
          <View style={[styles.promptCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <HelpCircle size={28} color={colors.primary} />
            <Text style={[styles.promptTitle, { color: colors.text }]}>Tap Any Exam Above to Continue</Text>
            <Text style={[styles.promptSub, { color: colors.textSecondary }]}>
              Select WAEC, NECO, NABTEB or JAMB to view current price, choose token quantity, and proceed with 1-tap checkout.
            </Text>
          </View>
        )}
      </ScrollView>

      {/* Biometric PIN Modal */}
      {selectedExam && (
        <BiometricPinModal
          visible={isPinModalVisible}
          onClose={() => setIsPinModalVisible(false)}
          onSuccess={handleAuthorizePurchase}
          title={selectedExam.name}
          amount={totalPrice}
          recipient={`Qty: ${quantity} Token(s)`}
          subtitle={`${selectedExam.name} Instant Generator`}
          loading={isSubmitting}
        />
      )}

      {/* Insufficient Balance Modal */}
      <InsufficientBalanceModal
        visible={insufficientModalVisible}
        onClose={() => setInsufficientModalVisible(false)}
        onFundWallet={() => navigation.navigate('FundWallet')}
        requiredAmount={totalPrice}
        currentBalance={wallet.balance}
        serviceTitle={selectedExam?.name || 'Exam PIN'}
      />

      {/* Transaction Success Modal */}
      <TransactionSuccessModal
        visible={successModalVisible}
        onClose={() => setSuccessModalVisible(false)}
        serviceTitle={lastTxData?.title || 'Educational Exam PIN'}
        amount={lastTxData?.amount || totalPrice}
        recipient={lastTxData?.recipient}
        reference={lastTxData?.reference}
        balanceAfter={lastTxData?.balanceAfter}
        pins={lastTxData?.pins}
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
    marginBottom: 12,
  },
  examGrid: {
    gap: 12,
    marginBottom: 18,
  },
  examCard: {
    padding: 16,
    borderRadius: 18,
    borderWidth: 1.5,
  },
  examCardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  examIconBox: {
    width: 44,
    height: 44,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    overflow: 'hidden',
    padding: 3,
  },
  examLogo: {
    width: 34,
    height: 34,
  },
  selectedLogoBox: {
    width: 46,
    height: 46,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E2E8F0',
    overflow: 'hidden',
    padding: 3,
  },
  selectedExamLogo: {
    width: 38,
    height: 38,
  },
  checkCircle: {
    width: 22,
    height: 22,
    borderRadius: 11,
    justifyContent: 'center',
    alignItems: 'center',
  },
  examName: {
    fontSize: 16,
    fontWeight: '800',
  },
  examBodyText: {
    fontSize: 12,
    marginTop: 3,
  },
  revealedSection: {
    marginTop: 4,
  },
  selectedHeaderCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderRadius: 18,
    borderWidth: 1.5,
    marginBottom: 18,
  },
  selectedLeft: {
    flex: 1,
    paddingRight: 10,
  },
  revealedBadge: {
    fontSize: 11,
    fontWeight: '800',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 2,
  },
  revealedName: {
    fontSize: 16,
    fontWeight: '800',
  },
  revealedDesc: {
    fontSize: 12,
    marginTop: 2,
  },
  selectedRight: {
    alignItems: 'flex-end',
  },
  unitPriceLabel: {
    fontSize: 11,
    fontWeight: '600',
  },
  unitPriceVal: {
    fontSize: 18,
    fontWeight: '800',
    marginTop: 2,
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
  qtyCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderRadius: 16,
    borderWidth: 1,
    marginBottom: 16,
  },
  qtyLabel: {
    fontSize: 15,
    fontWeight: '700',
  },
  qtySub: {
    fontSize: 11,
    marginTop: 2,
  },
  qtyControls: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
  },
  qtyBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
  },
  qtyNum: {
    fontSize: 18,
    fontWeight: '800',
    minWidth: 24,
    textAlign: 'center',
  },
  totalCard: {
    padding: 16,
    borderRadius: 16,
    borderWidth: 1,
    gap: 10,
    marginBottom: 22,
  },
  totalRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  totalLabel: {
    fontSize: 13,
  },
  totalVal: {
    fontSize: 13,
    fontWeight: '600',
  },
  grandTotalRow: {
    borderTopWidth: 1,
    paddingTop: 10,
  },
  grandTotalLabel: {
    fontSize: 15,
    fontWeight: '700',
  },
  grandTotalVal: {
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
  checkoutBtnText: {
    fontSize: 15,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  promptCard: {
    padding: 24,
    borderRadius: 18,
    borderWidth: 1,
    alignItems: 'center',
    textAlign: 'center',
    gap: 10,
    marginTop: 6,
  },
  promptTitle: {
    fontSize: 16,
    fontWeight: '800',
    textAlign: 'center',
  },
  promptSub: {
    fontSize: 13,
    lineHeight: 18,
    textAlign: 'center',
  },
  pinsCard: {
    borderRadius: 18,
    padding: 16,
    borderWidth: 1.5,
    marginBottom: 20,
    gap: 10,
  },
  pinsCardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  pinsCardTitle: {
    fontSize: 11,
    fontWeight: '800',
    letterSpacing: 0.5,
  },
  pinItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
    borderTopWidth: 1,
  },
  pinVal: {
    fontSize: 15,
    fontWeight: '800',
    letterSpacing: 1,
  },
  serialVal: {
    fontSize: 12,
    marginTop: 2,
  },
  pinCopyBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 8,
    paddingHorizontal: 10,
    paddingVertical: 6,
    gap: 4,
  },
  pinCopyText: {
    fontSize: 12,
    fontWeight: '700',
  },
});
