import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import {
  Wifi,
  Smartphone,
  Tv,
  Zap,
  ArrowLeftRight,
  GraduationCap,
  Radio,
  Wallet,
} from 'lucide-react-native';
import { useTheme } from '../context/ThemeContext';
import { triggerHaptic } from '../utils/haptics';

interface QuickActionsGridProps {
  onActionPress?: (serviceName: string) => void;
  onSelectService?: (serviceName: string) => void;
}

export const QuickActionsGrid: React.FC<QuickActionsGridProps> = ({ onActionPress, onSelectService }) => {
  const handlePress = onSelectService || onActionPress || (() => {});
  const { colors, isDark } = useTheme();

  const actions = [
    {
      id: 'data',
      name: 'Buy Data',
      icon: Wifi,
      bgColor: isDark ? 'rgba(37, 99, 235, 0.15)' : '#EFF6FF',
      iconColor: isDark ? '#60A5FA' : '#2563EB',
      badge: 'Fast',
      badgeBg: isDark ? 'rgba(37, 99, 235, 0.3)' : '#DBEAFE',
      badgeColor: isDark ? '#93C5FD' : '#1E40AF',
      route: 'Data',
    },
    {
      id: 'airtime',
      name: 'Buy Airtime',
      icon: Smartphone,
      bgColor: isDark ? 'rgba(234, 88, 12, 0.15)' : '#FFF7ED',
      iconColor: isDark ? '#FB923C' : '#EA580C',
      badge: 'Cashback',
      badgeBg: isDark ? 'rgba(234, 88, 12, 0.3)' : '#FFEDD5',
      badgeColor: isDark ? '#FDBA74' : '#9A3412',
      route: 'Airtime',
    },
    {
      id: 'fund',
      name: 'Fund Wallet',
      icon: Wallet,
      bgColor: isDark ? 'rgba(79, 70, 229, 0.15)' : '#EEF2FF',
      iconColor: isDark ? '#818CF8' : '#4F46E5',
      badge: 'Instant',
      badgeBg: isDark ? 'rgba(79, 70, 229, 0.3)' : '#E0E7FF',
      badgeColor: isDark ? '#A5B4FC' : '#3730A3',
      route: 'FundWallet',
    },
    {
      id: 'airtime2cash',
      name: 'Airtime2Cash',
      icon: ArrowLeftRight,
      bgColor: isDark ? 'rgba(5, 150, 105, 0.15)' : '#ECFDF5',
      iconColor: isDark ? '#34D399' : '#059669',
      badge: '82%',
      badgeBg: isDark ? 'rgba(5, 150, 105, 0.3)' : '#D1FAE5',
      badgeColor: isDark ? '#6EE7B7' : '#065F46',
      route: 'Airtime2Cash',
    },
    {
      id: 'cable',
      name: 'Cable TV',
      icon: Tv,
      bgColor: isDark ? 'rgba(2, 132, 199, 0.15)' : '#F0F9FF',
      iconColor: isDark ? '#38BDF8' : '#0284C7',
      badge: null,
      route: 'Cable',
    },
    {
      id: 'electricity',
      name: 'Electricity',
      icon: Zap,
      bgColor: isDark ? 'rgba(202, 138, 4, 0.15)' : '#FEFCE8',
      iconColor: isDark ? '#FACC15' : '#CA8A04',
      badge: null,
      route: 'Electricity',
    },
    {
      id: 'exam',
      name: 'Exam PINs',
      icon: GraduationCap,
      bgColor: isDark ? 'rgba(147, 51, 234, 0.15)' : '#FAF5FF',
      iconColor: isDark ? '#C084FC' : '#9333EA',
      badge: 'WAEC',
      badgeBg: isDark ? 'rgba(147, 51, 234, 0.3)' : '#F3E8FF',
      badgeColor: isDark ? '#D8B4FE' : '#6B21A8',
      route: 'ExamPin',
    },
    {
      id: 'smile',
      name: 'Smile 4G',
      icon: Radio,
      bgColor: isDark ? 'rgba(225, 29, 72, 0.15)' : '#FFF1F2',
      iconColor: isDark ? '#FB7185' : '#E11D48',
      badge: null,
      route: 'Smile',
    },
  ];

  return (
    <View style={styles.container}>
      <View style={styles.headerRow}>
        <Text style={[styles.sectionTitle, { color: colors.text }]}>Quick Services</Text>
        <Text style={[styles.subtext, { color: colors.textSecondary }]}>Instant automated delivery</Text>
      </View>

      <View style={styles.grid}>
        {actions.map((item) => {
          const Icon = item.icon;
          return (
            <TouchableOpacity
              key={item.id}
              style={[
                styles.actionItem,
                { backgroundColor: colors.card, borderColor: colors.cardBorder },
              ]}
              onPress={() => {
                triggerHaptic('light');
                handlePress(item.route);
              }}
              activeOpacity={0.7}
            >
              <View style={[styles.iconWrapper, { backgroundColor: item.bgColor }]}>
                <Icon size={24} color={item.iconColor} strokeWidth={2.2} />
                {item.badge && (
                  <View style={[styles.badge, { backgroundColor: item.badgeBg }]}>
                    <Text style={[styles.badgeText, { color: item.badgeColor }]}>
                      {item.badge}
                    </Text>
                  </View>
                )}
              </View>
              <Text style={[styles.actionName, { color: colors.text }]} numberOfLines={1}>
                {item.name}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 20,
    marginTop: 8,
    marginBottom: 16,
  },
  headerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '800',
  },
  subtext: {
    fontSize: 11,
    fontWeight: '500',
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    rowGap: 12,
  },
  actionItem: {
    width: '23%',
    borderRadius: 18,
    paddingVertical: 12,
    alignItems: 'center',
    borderWidth: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  iconWrapper: {
    width: 48,
    height: 48,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
    position: 'relative',
  },
  badge: {
    position: 'absolute',
    top: -5,
    right: -7,
    paddingHorizontal: 4,
    paddingVertical: 1,
    borderRadius: 6,
  },
  badgeText: {
    fontSize: 8,
    fontWeight: '800',
    textTransform: 'uppercase',
  },
  actionName: {
    fontSize: 11,
    fontWeight: '700',
    textAlign: 'center',
    letterSpacing: -0.2,
  },
});
