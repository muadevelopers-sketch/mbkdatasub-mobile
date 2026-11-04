import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  ScrollView,
  Image,
  TouchableOpacity,
  NativeSyntheticEvent,
  NativeScrollEvent,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Sparkles, ArrowRight, Zap, RefreshCw } from 'lucide-react-native';
import { apiClient } from '../api/client';
import { triggerHaptic } from '../utils/haptics';

interface HomeBannerCarouselProps {
  onBannerPress: (targetRoute: string) => void;
}

const { width } = Dimensions.get('window');
const BANNER_WIDTH = width - 40;

const BASE_BANNERS = [
  {
    id: 'official-welcome',
    type: 'image',
    image: require('../../assets/banner.png'),
    title: 'Welcome to MBK DATASUB',
    subtitle: 'Nigeria’s #1 Automated Telecom & Data Topup Gateway',
    tag: 'OFFICIAL',
    route: 'Data',
    cta: 'Buy Data Now',
    gradient: ['#0A192F', '#002B5B', '#1A365D'],
  },
  {
    id: 'data-bonanza',
    type: 'promo',
    title: 'Instant Data Bundles',
    subtitle: 'Automated 24/7 delivery on MTN, Airtel, Glo & 9mobile',
    tag: 'FAST DISPATCH',
    route: 'Data',
    cta: 'Get Bundle',
    gradient: ['#1E1B4B', '#312E81', '#4338CA'],
  },
  {
    id: 'airtime2cash',
    type: 'promo',
    title: 'Airtime to Cash',
    subtitle: 'Convert excess airtime directly into instant liquid cash',
    tag: 'FAST PAYOUT',
    route: 'Airtime2Cash',
    cta: 'Convert Now',
    gradient: ['#78350F', '#92400E', '#B45309'],
  },
];

export const HomeBannerCarousel: React.FC<HomeBannerCarouselProps> = ({ onBannerPress }) => {
  const [activeIndex, setActiveIndex] = useState(0);
  const [banners, setBanners] = useState(BASE_BANNERS);
  const scrollRef = useRef<ScrollView>(null);

  useEffect(() => {
    fetchAnnouncements();
  }, []);

  const fetchAnnouncements = async () => {
    try {
      const res = await apiClient.get('/services/announcements');
      if (res.data?.success && Array.isArray(res.data.announcements) && res.data.announcements.length > 0) {
        const activeAnnouncements = res.data.announcements.filter((a: any) => a.isActive !== 0 && a.isActive !== false);
        if (activeAnnouncements.length > 0) {
          const dynamicBanners = activeAnnouncements.map((a: any, idx: number) => ({
            id: `ann-${a.id || idx}`,
            type: 'promo',
            title: a.title,
            subtitle: a.message,
            tag: 'NOTICE',
            route: 'Data',
            cta: 'View More',
            gradient: ['#065F46', '#047857', '#059669'],
          }));
          setBanners([...dynamicBanners, ...BASE_BANNERS]);
        }
      }
    } catch (e) {
      console.warn('[Fetch Carousel Announcements Notice]', e);
    }
  };

  useEffect(() => {
    const timer = setInterval(() => {
      const nextIndex = (activeIndex + 1) % banners.length;
      scrollRef.current?.scrollTo({
        x: nextIndex * (BANNER_WIDTH + 12),
        animated: true,
      });
      setActiveIndex(nextIndex);
    }, 4500);

    return () => clearInterval(timer);
  }, [activeIndex]);

  const handleScroll = (event: NativeSyntheticEvent<NativeScrollEvent>) => {
    const slide = Math.round(event.nativeEvent.contentOffset.x / BANNER_WIDTH);
    if (slide >= 0 && slide < banners.length && slide !== activeIndex) {
      setActiveIndex(slide);
    }
  };

  return (
    <View style={styles.container}>
      <ScrollView
        ref={scrollRef}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={handleScroll}
        decelerationRate="fast"
        snapToInterval={BANNER_WIDTH + 12}
        contentContainerStyle={styles.scrollContent}
      >
        {banners.map((item, index) => {
          if (item.id === 'official-welcome') {
            return (
              <TouchableOpacity
                key={item.id}
                activeOpacity={0.92}
                onPress={() => {
                  triggerHaptic('light');
                  onBannerPress(item.route);
                }}
                style={[styles.bannerCard, { width: BANNER_WIDTH }]}
              >
                {/* Official Ambassador Background Poster */}
                <Image
                  source={item.image}
                  style={styles.officialPoster}
                  resizeMode="cover"
                />

                {/* Dark Vignette Overlay for readability */}
                <LinearGradient
                  colors={['transparent', 'rgba(10, 25, 47, 0.4)', 'rgba(10, 25, 47, 0.95)']}
                  style={styles.overlayGradient}
                >
                  <View style={styles.overlayContent}>
                    <View style={styles.badgeRow}>
                      <View style={styles.officialBadge}>
                        <Sparkles size={11} color="#38BDF8" />
                        <Text style={styles.officialBadgeText}>VERIFIED GATEWAY</Text>
                      </View>
                    </View>

                    <Text style={styles.officialTitle}>Instant 5-Second Automated Topups</Text>
                    <Text style={styles.officialSubtitle}>
                      Direct telecom API connections with 99.9% uptime
                    </Text>

                    <View style={styles.ctaPill}>
                      <Text style={styles.ctaPillText}>{item.cta}</Text>
                      <ArrowRight size={13} color="#FFFFFF" />
                    </View>
                  </View>
                </LinearGradient>
              </TouchableOpacity>
            );
          }

          return (
            <TouchableOpacity
              key={item.id}
              activeOpacity={0.9}
              onPress={() => {
                triggerHaptic('light');
                onBannerPress(item.route);
              }}
              style={[styles.bannerCard, { width: BANNER_WIDTH }]}
            >
              <LinearGradient
                colors={item.gradient as [string, string, ...string[]]}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={styles.promoCardGradient}
              >
                <View style={styles.badgeRow}>
                  <View style={styles.tagBadge}>
                    <Zap size={11} color="#FBBF24" fill="#FBBF24" />
                    <Text style={styles.tagText}>{item.tag}</Text>
                  </View>
                </View>

                <View style={styles.promoMiddle}>
                  <Text style={styles.promoTitle}>{item.title}</Text>
                  <Text style={styles.promoSubtitle}>{item.subtitle}</Text>
                </View>

                <View style={styles.ctaPill}>
                  <Text style={styles.ctaPillText}>{item.cta}</Text>
                  <ArrowRight size={13} color="#FFFFFF" />
                </View>
              </LinearGradient>
            </TouchableOpacity>
          );
        })}
      </ScrollView>

      {/* Pagination Dots */}
      <View style={styles.pagination}>
        {banners.map((_, idx) => (
          <View
            key={idx}
            style={[styles.dot, activeIndex === idx ? styles.activeDot : styles.inactiveDot]}
          />
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: 14,
  },
  scrollContent: {
    paddingHorizontal: 20,
    gap: 12,
  },
  bannerCard: {
    height: 155,
    borderRadius: 22,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.12,
    shadowRadius: 10,
    elevation: 4,
    backgroundColor: '#0F172A',
  },
  officialPoster: {
    width: '100%',
    height: '100%',
    position: 'absolute',
  },
  overlayGradient: {
    ...StyleSheet.absoluteFill,
    justifyContent: 'flex-end',
    padding: 16,
  },
  overlayContent: {
    gap: 4,
  },
  promoCardGradient: {
    flex: 1,
    padding: 16,
    justifyContent: 'space-between',
  },
  badgeRow: {
    flexDirection: 'row',
  },
  officialBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: 'rgba(56, 189, 248, 0.2)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: 'rgba(56, 189, 248, 0.4)',
  },
  officialBadgeText: {
    color: '#38BDF8',
    fontSize: 9,
    fontWeight: '900',
    letterSpacing: 0.6,
  },
  tagBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: 'rgba(251, 191, 36, 0.2)',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: 'rgba(251, 191, 36, 0.4)',
  },
  tagText: {
    color: '#FBBF24',
    fontSize: 9,
    fontWeight: '900',
    letterSpacing: 0.6,
  },
  officialTitle: {
    fontSize: 15,
    fontWeight: '900',
    color: '#FFFFFF',
    letterSpacing: -0.3,
  },
  officialSubtitle: {
    fontSize: 11,
    color: '#CBD5E1',
    lineHeight: 15,
  },
  promoMiddle: {
    marginVertical: 4,
  },
  promoTitle: {
    fontSize: 16,
    fontWeight: '900',
    color: '#FFFFFF',
    letterSpacing: -0.3,
  },
  promoSubtitle: {
    fontSize: 11,
    color: '#E2E8F0',
    lineHeight: 15,
    marginTop: 2,
  },
  ctaPill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
    alignSelf: 'flex-start',
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingHorizontal: 12,
    paddingVertical: 5,
    borderRadius: 14,
    marginTop: 4,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.3)',
  },
  ctaPillText: {
    color: '#FFFFFF',
    fontSize: 11,
    fontWeight: '800',
  },
  pagination: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 5,
    marginTop: 8,
  },
  dot: {
    height: 4,
    borderRadius: 2,
  },
  activeDot: {
    width: 16,
    backgroundColor: '#6366F1',
  },
  inactiveDot: {
    width: 5,
    backgroundColor: '#CBD5E1',
  },
});
