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
} from 'react-native';
import {
  Search,
  Wifi,
  Smartphone,
  Tv,
  Zap,
  Repeat,
  GraduationCap,
  Radio,
  ChevronRight,
  ShieldCheck,
  Flame,
} from 'lucide-react-native';
import { useTheme } from '../../context/ThemeContext';
import { triggerHaptic } from '../../utils/haptics';

interface ServiceItem {
  id: string;
  title: string;
  description: string;
  icon: any;
  iconBg: string;
  iconColor: string;
  tag?: string;
  route: string;
  category: 'telecom' | 'bills' | 'education';
}

export const ServicesScreen = ({ navigation }: any) => {
  const { colors, isDark } = useTheme();
  const [searchQuery, setSearchQuery] = useState('');

  const services: ServiceItem[] = [
    {
      id: 'data',
      title: 'Mobile Data Bundles',
      description: 'MTN, Airtel, Glo & 9mobile SME, Gifting & Corporate plans.',
      icon: Wifi,
      iconBg: 'rgba(56, 189, 248, 0.15)',
      iconColor: '#38BDF8',
      tag: 'INSTANT',
      route: 'Data',
      category: 'telecom',
    },
    {
      id: 'airtime',
      title: 'Airtime VTU Recharge',
      description: 'Instant recharge with up to 2% cash discount on all networks.',
      icon: Smartphone,
      iconBg: 'rgba(16, 185, 129, 0.15)',
      iconColor: '#10B981',
      tag: '2% OFF',
      route: 'Airtime',
      category: 'telecom',
    },
    {
      id: 'airtime2cash',
      title: 'Airtime to Cash',
      description: 'Convert excess airtime balance into instant liquid bank cash.',
      icon: Repeat,
      iconBg: 'rgba(245, 158, 11, 0.15)',
      iconColor: '#F59E0B',
      tag: '82% RATE',
      route: 'Airtime2Cash',
      category: 'telecom',
    },
    {
      id: 'cable',
      title: 'Cable TV Subscription',
      description: 'DSTV, GOtv, and StarTimes instant activation & renewal.',
      icon: Tv,
      iconBg: 'rgba(168, 85, 247, 0.15)',
      iconColor: '#A855F7',
      route: 'Cable',
      category: 'bills',
    },
    {
      id: 'electricity',
      title: 'Electricity Token & Bills',
      description: 'Prepaid & Postpaid meters (IKEDC, EKEDC, AEDC, IBEDC & more).',
      icon: Zap,
      iconBg: 'rgba(234, 179, 8, 0.15)',
      iconColor: '#EAB308',
      route: 'Electricity',
      category: 'bills',
    },
    {
      id: 'exam',
      title: 'Exam Result Checkers',
      description: 'WAEC, NECO & NABTEB scratch cards and result checking tokens.',
      icon: GraduationCap,
      iconBg: 'rgba(236, 72, 153, 0.15)',
      iconColor: '#EC4899',
      route: 'ExamPin',
      category: 'education',
    },
    {
      id: 'smile',
      title: 'Smile & Spectranet 4G/5G',
      description: 'Broadband router bundles and direct Voice recharge.',
      icon: Radio,
      iconBg: 'rgba(99, 102, 241, 0.15)',
      iconColor: '#6366F1',
      route: 'Smile',
      category: 'telecom',
    },
  ];

  const filtered = services.filter(
    (s) =>
      s.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      s.description.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const telecomServices = filtered.filter((s) => s.category === 'telecom');
  const billsServices = filtered.filter((s) => s.category === 'bills');
  const educationServices = filtered.filter((s) => s.category === 'education');

  const handlePress = (route: string) => {
    triggerHaptic('selection');
    navigation.navigate(route);
  };

  const renderServiceCard = (item: ServiceItem) => {
    const IconComp = item.icon;
    return (
      <TouchableOpacity
        key={item.id}
        style={[styles.serviceCard, { borderBottomColor: colors.cardBorder }]}
        onPress={() => handlePress(item.route)}
        activeOpacity={0.7}
      >
        <View style={[styles.iconBox, { backgroundColor: item.iconBg }]}>
          <IconComp size={22} color={item.iconColor} />
        </View>

        <View style={styles.serviceInfo}>
          <View style={styles.titleRow}>
            <Text style={[styles.serviceTitle, { color: colors.text }]}>{item.title}</Text>
            {item.tag ? (
              <View style={[styles.tagBadge, { backgroundColor: colors.primaryBg }]}>
                <Text style={[styles.tagText, { color: colors.primary }]}>{item.tag}</Text>
              </View>
            ) : null}
          </View>
          <Text style={[styles.serviceDesc, { color: colors.textSecondary }]}>{item.description}</Text>
        </View>

        <ChevronRight size={18} color={colors.textMuted} />
      </TouchableOpacity>
    );
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.bg }]}>
      <StatusBar
        barStyle={colors.statusBar === 'dark' ? 'dark-content' : 'light-content'}
        backgroundColor={colors.bg}
      />
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={[styles.headerTitle, { color: colors.text }]}>Services Catalog</Text>
          <Text style={[styles.headerSubtitle, { color: colors.textSecondary }]}>
            Instant automated services powered by direct telecom integrations.
          </Text>
        </View>

        {/* Search Input */}
        <View style={[styles.searchWrapper, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
          <Search size={18} color={colors.textMuted} />
          <TextInput
            style={[styles.searchInput, { color: colors.text }]}
            placeholder="Search data, airtime, electricity, cables..."
            placeholderTextColor={colors.textMuted}
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
        </View>

        {/* Categories */}
        {telecomServices.length > 0 && (
          <View style={styles.categoryBlock}>
            <Text style={[styles.categoryTitle, { color: colors.textMuted }]}>Telecom & Data Networks</Text>
            <View style={[styles.cardGroup, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
              {telecomServices.map(renderServiceCard)}
            </View>
          </View>
        )}

        {billsServices.length > 0 && (
          <View style={styles.categoryBlock}>
            <Text style={[styles.categoryTitle, { color: colors.textMuted }]}>Utility Bills & Cable TV</Text>
            <View style={[styles.cardGroup, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
              {billsServices.map(renderServiceCard)}
            </View>
          </View>
        )}

        {educationServices.length > 0 && (
          <View style={styles.categoryBlock}>
            <Text style={[styles.categoryTitle, { color: colors.textMuted }]}>Educational PINs</Text>
            <View style={[styles.cardGroup, { backgroundColor: colors.card, borderColor: colors.cardBorder }]}>
              {educationServices.map(renderServiceCard)}
            </View>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 40,
  },
  header: {
    marginBottom: 16,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: '800',
    letterSpacing: -0.5,
  },
  headerSubtitle: {
    fontSize: 13,
    marginTop: 4,
    lineHeight: 18,
  },
  searchWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 14,
    borderWidth: 1,
    paddingHorizontal: 14,
    height: 48,
    marginBottom: 20,
    gap: 10,
  },
  searchInput: {
    flex: 1,
    fontSize: 14,
  },
  categoryBlock: {
    marginBottom: 20,
  },
  categoryTitle: {
    fontSize: 14,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 0.6,
    marginBottom: 10,
  },
  cardGroup: {
    borderRadius: 20,
    borderWidth: 1,
    overflow: 'hidden',
  },
  serviceCard: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    gap: 12,
  },
  iconBox: {
    width: 44,
    height: 44,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
  },
  serviceInfo: {
    flex: 1,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  serviceTitle: {
    fontSize: 15,
    fontWeight: '700',
  },
  tagBadge: {
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 6,
  },
  tagText: {
    fontSize: 10,
    fontWeight: '700',
  },
  serviceDesc: {
    fontSize: 12,
    marginTop: 2,
    lineHeight: 16,
  },
});
