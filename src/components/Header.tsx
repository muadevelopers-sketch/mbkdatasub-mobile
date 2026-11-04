import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { ShieldCheck, Bell, MessageCircle, Sun, Moon } from 'lucide-react-native';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../context/ThemeContext';
import { triggerHaptic } from '../utils/haptics';

interface HeaderProps {
  onNotificationPress?: () => void;
  onSupportPress?: () => void;
}

export const Header: React.FC<HeaderProps> = ({ onNotificationPress, onSupportPress }) => {
  const { user } = useAuth();
  const { colors, isDark, toggleTheme } = useTheme();

  const getInitials = (name?: string) => {
    if (!name) return 'MB';
    const parts = name.trim().split(' ');
    if (parts.length >= 2) return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
    return name.slice(0, 2).toUpperCase();
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.bg }]}>
      {/* User Avatar & Greeting */}
      <View style={styles.userSection}>
        <View style={[styles.avatar, { backgroundColor: colors.primary }]}>
          <Text style={styles.avatarText}>{getInitials(user?.fullName)}</Text>
        </View>
        <View style={styles.textContainer}>
          <View style={styles.nameRow}>
            <Text style={[styles.greeting, { color: colors.textSecondary }]}>Welcome back,</Text>
            <View style={[styles.tierBadge, { backgroundColor: colors.successBg }]}>
              <ShieldCheck size={11} color={colors.success} />
              <Text style={[styles.tierText, { color: colors.success }]}>Tier {user?.kycTier || 1}</Text>
            </View>
          </View>
          <Text style={[styles.fullName, { color: colors.text }]} numberOfLines={1}>
            {user?.fullName || 'Valued Customer'}
          </Text>
        </View>
      </View>

      {/* Action Buttons: Theme Toggle, WhatsApp & Notifications */}
      <View style={styles.actions}>
        <TouchableOpacity
          style={[styles.iconButton, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}
          onPress={toggleTheme}
          activeOpacity={0.7}
        >
          {isDark ? <Sun size={19} color="#F59E0B" /> : <Moon size={19} color="#0284C7" />}
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.iconButton, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}
          onPress={() => {
            triggerHaptic('light');
            onSupportPress?.();
          }}
          activeOpacity={0.7}
        >
          <MessageCircle size={19} color="#10B981" />
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.iconButton, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}
          onPress={() => {
            triggerHaptic('light');
            onNotificationPress?.();
          }}
          activeOpacity={0.7}
        >
          <Bell size={19} color={colors.primary} />
          <View style={styles.notificationBadge} />
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 8,
  },
  userSection: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    flex: 1,
  },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 4,
    elevation: 3,
  },
  avatarText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '800',
  },
  textContainer: {
    justifyContent: 'center',
    flex: 1,
  },
  nameRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  greeting: {
    fontSize: 12,
    fontWeight: '500',
  },
  tierBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 6,
    paddingVertical: 1,
    borderRadius: 10,
    gap: 3,
  },
  tierText: {
    fontSize: 9,
    fontWeight: '800',
    letterSpacing: 0.2,
  },
  fullName: {
    fontSize: 16,
    fontWeight: '800',
    marginTop: 1,
  },
  actions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  iconButton: {
    width: 38,
    height: 38,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    position: 'relative',
  },
  notificationBadge: {
    position: 'absolute',
    top: 8,
    right: 8,
    width: 7,
    height: 7,
    borderRadius: 3.5,
    backgroundColor: '#EF4444',
  },
});
