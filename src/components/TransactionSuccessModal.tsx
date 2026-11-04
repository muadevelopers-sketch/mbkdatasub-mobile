import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TouchableOpacity,
  Pressable,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import * as Clipboard from 'expo-clipboard';
import {
  CheckCircle2,
  Copy,
  Check,
  Share2,
  Sparkles,
  ArrowRight,
  X,
} from 'lucide-react-native';
import { useTheme } from '../context/ThemeContext';
import { formatNaira } from '../utils/formatters';
import { triggerHaptic } from '../utils/haptics';

interface TransactionSuccessModalProps {
  visible: boolean;
  onClose: () => void;
  serviceTitle: string;
  amount: number;
  recipient?: string;
  reference?: string;
  pins?: Array<{ pin: string; serial?: string }>;
  token?: string;
  balanceAfter?: number;
  onViewReceipt?: () => void;
}

export const TransactionSuccessModal: React.FC<TransactionSuccessModalProps> = ({
  visible,
  onClose,
  serviceTitle,
  amount,
  recipient,
  reference,
  pins,
  token,
  balanceAfter,
  onViewReceipt,
}) => {
  const { colors, isDark } = useTheme();
  const [copiedRef, setCopiedRef] = useState(false);
  const [copiedToken, setCopiedToken] = useState(false);

  const handleCopyRef = async () => {
    if (!reference) return;
    await Clipboard.setStringAsync(reference);
    triggerHaptic('success');
    setCopiedRef(true);
    setTimeout(() => setCopiedRef(false), 2000);
  };

  const handleCopyToken = async (tok: string) => {
    await Clipboard.setStringAsync(tok);
    triggerHaptic('success');
    setCopiedToken(true);
    setTimeout(() => setCopiedToken(false), 2000);
  };

  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
      <Pressable style={styles.overlay} onPress={onClose}>
        <Pressable
          style={[
            styles.card,
            { backgroundColor: colors.surface, borderColor: isDark ? '#10B981' : '#6EE7B7' },
          ]}
          onPress={(e) => e.stopPropagation()}
        >
          {/* Close button */}
          <TouchableOpacity
            style={[styles.closeBtn, { backgroundColor: colors.inputBg }]}
            onPress={onClose}
            hitSlop={10}
          >
            <X size={18} color={colors.textSecondary} />
          </TouchableOpacity>

          {/* Celebratory Glowing Checkmark */}
          <View style={styles.iconContainer}>
            <View style={styles.iconGlow} />
            <View style={styles.iconCircle}>
              <CheckCircle2 size={42} color="#10B981" />
            </View>
          </View>

          <View style={styles.badgeRow}>
            <Sparkles size={14} color="#10B981" />
            <Text style={styles.badgeText}>INSTANTLY DELIVERED</Text>
          </View>

          <Text style={[styles.title, { color: colors.text }]}>Transaction Successful!</Text>
          <Text style={[styles.amountText, { color: colors.primary }]}>{formatNaira(amount)}</Text>
          <Text style={[styles.serviceSub, { color: colors.textSecondary }]}>{serviceTitle}</Text>

          {/* Details Card */}
          <View style={[styles.detailsCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            {recipient ? (
              <View style={styles.detailRow}>
                <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>Recipient / Beneficiary:</Text>
                <Text style={[styles.detailValue, { color: colors.text }]}>{recipient}</Text>
              </View>
            ) : null}

            {token ? (
              <View style={[styles.detailRow, styles.tokenRow, { backgroundColor: colors.primaryBg }]}>
                <View>
                  <Text style={[styles.detailLabel, { color: colors.primary }]}>Electricity Meter Token:</Text>
                  <Text style={[styles.tokenValue, { color: colors.primary }]}>{token}</Text>
                </View>
                <TouchableOpacity
                  style={[styles.copyPill, { backgroundColor: colors.surface }]}
                  onPress={() => handleCopyToken(token)}
                >
                  {copiedToken ? <Check size={13} color="#10B981" /> : <Copy size={13} color={colors.primary} />}
                  <Text style={[styles.copyPillText, { color: copiedToken ? '#10B981' : colors.primary }]}>
                    {copiedToken ? 'Copied' : 'Copy'}
                  </Text>
                </TouchableOpacity>
              </View>
            ) : null}

            {reference ? (
              <View style={styles.detailRow}>
                <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>Reference:</Text>
                <TouchableOpacity style={styles.refRow} onPress={handleCopyRef}>
                  <Text style={[styles.refValue, { color: colors.textSecondary }]}>{reference}</Text>
                  {copiedRef ? <Check size={13} color="#10B981" /> : <Copy size={13} color={colors.textSecondary} />}
                </TouchableOpacity>
              </View>
            ) : null}

            {balanceAfter !== undefined ? (
              <View style={[styles.detailRow, { borderTopWidth: 1, borderTopColor: colors.cardBorder, paddingTop: 8 }]}>
                <Text style={[styles.detailLabel, { color: colors.textSecondary }]}>Updated Wallet Balance:</Text>
                <Text style={[styles.detailValue, { color: colors.text, fontWeight: '700' }]}>
                  {formatNaira(balanceAfter)}
                </Text>
              </View>
            ) : null}
          </View>

          {/* Action Buttons */}
          <TouchableOpacity
            style={styles.doneBtn}
            onPress={() => {
              triggerHaptic('selection');
              onClose();
            }}
            activeOpacity={0.85}
          >
            <LinearGradient
              colors={['#10B981', '#059669']}
              style={styles.doneGradient}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
            >
              <Text style={styles.doneBtnText}>Done</Text>
              <ArrowRight size={18} color="#FFFFFF" />
            </LinearGradient>
          </TouchableOpacity>

          {onViewReceipt ? (
            <TouchableOpacity
              style={[styles.receiptBtn, { borderColor: colors.cardBorder }]}
              onPress={() => {
                triggerHaptic('light');
                onClose();
                onViewReceipt();
              }}
              activeOpacity={0.7}
            >
              <Share2 size={16} color={colors.primary} />
              <Text style={[styles.receiptBtnText, { color: colors.primary }]}>View Detailed Receipt</Text>
            </TouchableOpacity>
          ) : null}
        </Pressable>
      </Pressable>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(15, 23, 42, 0.78)',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 22,
  },
  card: {
    width: '100%',
    maxWidth: 390,
    borderRadius: 28,
    paddingHorizontal: 22,
    paddingTop: 26,
    paddingBottom: 22,
    alignItems: 'center',
    borderWidth: 1.5,
    shadowColor: '#10B981',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.18,
    shadowRadius: 24,
    elevation: 8,
  },
  closeBtn: {
    position: 'absolute',
    top: 16,
    right: 16,
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  iconContainer: {
    width: 80,
    height: 80,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  iconGlow: {
    position: 'absolute',
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(16, 185, 129, 0.22)',
  },
  iconCircle: {
    width: 62,
    height: 62,
    borderRadius: 31,
    backgroundColor: 'rgba(16, 185, 129, 0.12)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  badgeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: 'rgba(16, 185, 129, 0.12)',
    paddingHorizontal: 12,
    paddingVertical: 5,
    borderRadius: 12,
    marginBottom: 8,
  },
  badgeText: {
    fontSize: 11,
    fontWeight: '800',
    color: '#10B981',
    letterSpacing: 0.8,
  },
  title: {
    fontSize: 21,
    fontWeight: '800',
    textAlign: 'center',
    letterSpacing: -0.3,
  },
  amountText: {
    fontSize: 28,
    fontWeight: '900',
    marginTop: 6,
    letterSpacing: -0.5,
  },
  serviceSub: {
    fontSize: 13,
    marginTop: 2,
    fontWeight: '500',
  },
  detailsCard: {
    width: '100%',
    borderRadius: 16,
    borderWidth: 1,
    padding: 14,
    marginVertical: 18,
    gap: 10,
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  detailLabel: {
    fontSize: 12,
    fontWeight: '500',
  },
  detailValue: {
    fontSize: 13,
    fontWeight: '700',
  },
  refRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  refValue: {
    fontSize: 12,
    fontFamily: 'Courier',
    fontWeight: '600',
  },
  tokenRow: {
    padding: 10,
    borderRadius: 12,
  },
  tokenValue: {
    fontSize: 16,
    fontWeight: '800',
    letterSpacing: 1.5,
    marginTop: 2,
  },
  copyPill: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 8,
    gap: 4,
  },
  copyPillText: {
    fontSize: 12,
    fontWeight: '700',
  },
  doneBtn: {
    width: '100%',
    borderRadius: 16,
    overflow: 'hidden',
    marginBottom: 10,
  },
  doneGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    height: 52,
    gap: 10,
  },
  doneBtnText: {
    fontSize: 15,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  receiptBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 12,
    borderWidth: 1,
    gap: 8,
    width: '100%',
  },
  receiptBtnText: {
    fontSize: 13,
    fontWeight: '700',
  },
});
