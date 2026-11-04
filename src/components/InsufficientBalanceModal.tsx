import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TouchableOpacity,
  Pressable,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { AlertCircle, Wallet, ArrowRight, X } from 'lucide-react-native';
import { useTheme } from '../context/ThemeContext';
import { formatNaira } from '../utils/formatters';
import { triggerHaptic } from '../utils/haptics';

interface InsufficientBalanceModalProps {
  visible: boolean;
  onClose: () => void;
  onFundWallet: () => void;
  requiredAmount: number;
  currentBalance: number;
  serviceTitle?: string;
}

export const InsufficientBalanceModal: React.FC<InsufficientBalanceModalProps> = ({
  visible,
  onClose,
  onFundWallet,
  requiredAmount,
  currentBalance,
  serviceTitle = 'this service',
}) => {
  const { colors, isDark } = useTheme();
  const shortfall = Math.max(0, requiredAmount - currentBalance);

  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
      <Pressable style={styles.overlay} onPress={onClose}>
        <Pressable
          style={[
            styles.card,
            { backgroundColor: colors.surface, borderColor: isDark ? '#EF4444' : '#FCA5A5' },
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

          {/* Glowing Alert Icon */}
          <View style={styles.iconContainer}>
            <View style={styles.iconGlow} />
            <View style={styles.iconCircle}>
              <AlertCircle size={36} color="#EF4444" />
            </View>
          </View>

          <Text style={[styles.title, { color: colors.text }]}>Insufficient Balance</Text>
          <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
            You need <Text style={{ color: colors.text, fontWeight: '700' }}>{formatNaira(requiredAmount)}</Text> to complete {serviceTitle}, but your current wallet balance is <Text style={{ color: colors.text, fontWeight: '700' }}>{formatNaira(currentBalance)}</Text>.
          </Text>

          {/* Breakdown Card */}
          <View style={[styles.breakdownCard, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
            <View style={styles.breakdownRow}>
              <Text style={[styles.breakdownLabel, { color: colors.textSecondary }]}>Required Amount:</Text>
              <Text style={[styles.breakdownValue, { color: colors.text }]}>{formatNaira(requiredAmount)}</Text>
            </View>
            <View style={styles.breakdownRow}>
              <Text style={[styles.breakdownLabel, { color: colors.textSecondary }]}>Your Balance:</Text>
              <Text style={[styles.breakdownValue, { color: colors.textSecondary }]}>{formatNaira(currentBalance)}</Text>
            </View>
            <View style={[styles.breakdownRow, styles.shortfallRow, { borderTopColor: colors.cardBorder }]}>
              <Text style={[styles.shortfallLabel, { color: '#EF4444' }]}>Shortfall:</Text>
              <Text style={[styles.shortfallValue, { color: '#EF4444' }]}>-{formatNaira(shortfall)}</Text>
            </View>
          </View>

          {/* Fund Wallet Action */}
          <TouchableOpacity
            style={styles.actionBtn}
            onPress={() => {
              triggerHaptic('medium');
              onClose();
              onFundWallet();
            }}
            activeOpacity={0.85}
          >
            <LinearGradient
              colors={['#2563EB', '#1D4ED8']}
              style={styles.actionGradient}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
            >
              <Wallet size={20} color="#FFFFFF" />
              <Text style={styles.actionBtnText}>Fund Wallet Now</Text>
              <ArrowRight size={18} color="#FFFFFF" />
            </LinearGradient>
          </TouchableOpacity>

          {/* Cancel */}
          <TouchableOpacity
            style={[styles.cancelBtn, { borderColor: colors.cardBorder }]}
            onPress={onClose}
            activeOpacity={0.7}
          >
            <Text style={[styles.cancelBtnText, { color: colors.textSecondary }]}>Maybe Later</Text>
          </TouchableOpacity>
        </Pressable>
      </Pressable>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(15, 23, 42, 0.75)',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 22,
  },
  card: {
    width: '100%',
    maxWidth: 380,
    borderRadius: 28,
    paddingHorizontal: 22,
    paddingTop: 28,
    paddingBottom: 22,
    alignItems: 'center',
    borderWidth: 1.5,
    shadowColor: '#EF4444',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.15,
    shadowRadius: 20,
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
    width: 76,
    height: 76,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  iconGlow: {
    position: 'absolute',
    width: 76,
    height: 76,
    borderRadius: 38,
    backgroundColor: 'rgba(239, 68, 68, 0.2)',
  },
  iconCircle: {
    width: 58,
    height: 58,
    borderRadius: 29,
    backgroundColor: 'rgba(239, 68, 68, 0.12)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 20,
    fontWeight: '800',
    textAlign: 'center',
    letterSpacing: -0.3,
  },
  subtitle: {
    fontSize: 13,
    lineHeight: 19,
    textAlign: 'center',
    marginTop: 8,
    paddingHorizontal: 8,
  },
  breakdownCard: {
    width: '100%',
    borderRadius: 16,
    borderWidth: 1,
    padding: 14,
    marginVertical: 18,
    gap: 8,
  },
  breakdownRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  breakdownLabel: {
    fontSize: 12,
    fontWeight: '500',
  },
  breakdownValue: {
    fontSize: 13,
    fontWeight: '700',
  },
  shortfallRow: {
    borderTopWidth: 1,
    paddingTop: 8,
    marginTop: 2,
  },
  shortfallLabel: {
    fontSize: 13,
    fontWeight: '700',
  },
  shortfallValue: {
    fontSize: 14,
    fontWeight: '800',
  },
  actionBtn: {
    width: '100%',
    borderRadius: 16,
    overflow: 'hidden',
    marginBottom: 10,
  },
  actionGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    height: 52,
    gap: 10,
  },
  actionBtnText: {
    fontSize: 15,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  cancelBtn: {
    paddingVertical: 10,
    paddingHorizontal: 20,
  },
  cancelBtnText: {
    fontSize: 13,
    fontWeight: '600',
  },
});
