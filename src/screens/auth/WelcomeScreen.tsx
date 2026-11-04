import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
  ScrollView,
  StatusBar,
  Dimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';;
import { LinearGradient } from 'expo-linear-gradient';
import { ArrowRight, ShieldCheck, Zap, ScanFace, Fingerprint } from 'lucide-react-native';
import { useAuth } from '../../context/AuthContext';
import { triggerHaptic } from '../../utils/haptics';
import { getStoredBiometricPin } from '../../utils/biometrics';

const { width } = Dimensions.get('window');

export const WelcomeScreen = ({ navigation }: any) => {
  const { biometricInfo, loginWithBiometrics } = useAuth();
  const [canQuickBioLogin, setCanQuickBioLogin] = useState(false);

  useEffect(() => {
    checkQuickBio();
  }, []);

  const checkQuickBio = async () => {
    const stored = await getStoredBiometricPin();
    if (stored.pin && biometricInfo?.isAvailable) {
      setCanQuickBioLogin(true);
    }
  };

  const handleQuickBioLogin = async () => {
    triggerHaptic('medium');
    const res = await loginWithBiometrics();
    if (!res.success) {
      // Biometrics failed or cancelled, navigate to login
      navigation.navigate('Login');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#0F172A" />
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Brand Header */}
        <View style={styles.brandRow}>
          <Image
            source={require('../../../assets/icon.png')}
            style={styles.logo}
            resizeMode="contain"
          />
          <View>
            <Text style={styles.brandTitle}>MBK DATASUB</Text>
            <Text style={styles.brandSubtitle}>Automated VTU & Telecom Hub</Text>
          </View>
        </View>

        {/* Hero Visual Banner (Ambassador Poster) */}
        <View style={styles.bannerWrapper}>
          <Image
            source={require('../../../assets/banner.png')}
            style={styles.heroBanner}
            resizeMode="cover"
          />
          <LinearGradient
            colors={['transparent', 'rgba(15, 23, 42, 0.95)']}
            style={styles.bannerGradient}
          >
            <View style={styles.badgeRow}>
              <View style={styles.liveBadge}>
                <View style={styles.pulseDot} />
                <Text style={styles.liveBadgeText}>100% AUTOMATED 24/7</Text>
              </View>
            </View>
            <Text style={styles.heroHeadline}>Smart, Cheaper & Instant Telecom Services</Text>
          </LinearGradient>
        </View>

        {/* Feature Cards */}
        <View style={styles.featuresList}>
          <View style={styles.featureItem}>
            <View style={[styles.featureIconBox, { backgroundColor: 'rgba(37, 99, 235, 0.15)' }]}>
              <Zap size={20} color="#3B82F6" />
            </View>
            <View style={styles.featureTextCol}>
              <Text style={styles.featureTitle}>Sub-Second Data & VTU</Text>
              <Text style={styles.featureDesc}>Direct API dispatch for MTN, Airtel, Glo & 9mobile.</Text>
            </View>
          </View>

          <View style={styles.featureItem}>
            <View style={[styles.featureIconBox, { backgroundColor: 'rgba(16, 185, 129, 0.15)' }]}>
              <ShieldCheck size={20} color="#10B981" />
            </View>
            <View style={styles.featureTextCol}>
              <Text style={styles.featureTitle}>PalmPay & Paga Virtual Accounts</Text>
              <Text style={styles.featureDesc}>Unique dedicated bank accounts with zero stamp duty fees.</Text>
            </View>
          </View>
        </View>

        {/* CTA Buttons */}
        <View style={styles.ctaContainer}>
          {canQuickBioLogin && (
            <TouchableOpacity
              style={styles.bioLoginButton}
              onPress={handleQuickBioLogin}
              activeOpacity={0.8}
            >
              {biometricInfo?.sensorName === 'Apple Face ID' ? (
                <ScanFace size={22} color="#38BDF8" />
              ) : (
                <Fingerprint size={22} color="#38BDF8" />
              )}
              <Text style={styles.bioLoginText}>
                Instant Sign In with {biometricInfo?.sensorName || 'Biometrics'}
              </Text>
            </TouchableOpacity>
          )}

          <TouchableOpacity
            style={styles.primaryButton}
            onPress={() => {
              triggerHaptic('medium');
              navigation.navigate('Register');
            }}
            activeOpacity={0.8}
          >
            <LinearGradient
              colors={['#2563EB', '#1D4ED8']}
              style={styles.primaryGradient}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
            >
              <Text style={styles.primaryButtonText}>Create Free Account</Text>
              <ArrowRight size={20} color="#FFFFFF" />
            </LinearGradient>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.secondaryButton}
            onPress={() => {
              triggerHaptic('light');
              navigation.navigate('Login');
            }}
            activeOpacity={0.8}
          >
            <Text style={styles.secondaryButtonText}>I already have an account • Sign In</Text>
          </TouchableOpacity>
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
    maxWidth: 640,
    width: '100%',
    alignSelf: 'center',
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 36,
  },
  brandRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
    gap: 12,
  },
  logo: {
    width: 44,
    height: 44,
    borderRadius: 12,
  },
  brandTitle: {
    fontSize: 20,
    fontWeight: '800',
    color: '#F8FAFC',
    letterSpacing: 0.5,
  },
  brandSubtitle: {
    fontSize: 12,
    color: '#94A3B8',
    fontWeight: '500',
  },
  bannerWrapper: {
    width: '100%',
    height: 320,
    borderRadius: 24,
    overflow: 'hidden',
    position: 'relative',
    borderWidth: 1,
    borderColor: '#1E293B',
    marginBottom: 24,
  },
  heroBanner: {
    width: '100%',
    height: '100%',
  },
  bannerGradient: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    padding: 20,
    justifyContent: 'flex-end',
  },
  badgeRow: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  liveBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(16, 185, 129, 0.2)',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(16, 185, 129, 0.4)',
    gap: 6,
  },
  pulseDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#10B981',
  },
  liveBadgeText: {
    fontSize: 10,
    fontWeight: '700',
    color: '#34D399',
    letterSpacing: 0.5,
  },
  heroHeadline: {
    fontSize: 20,
    fontWeight: '800',
    color: '#F8FAFC',
    lineHeight: 28,
  },
  featuresList: {
    gap: 12,
    marginBottom: 28,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1E293B',
    padding: 14,
    borderRadius: 16,
    gap: 14,
    borderWidth: 1,
    borderColor: '#334155',
  },
  featureIconBox: {
    width: 42,
    height: 42,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  featureTextCol: {
    flex: 1,
  },
  featureTitle: {
    fontSize: 15,
    fontWeight: '700',
    color: '#F8FAFC',
  },
  featureDesc: {
    fontSize: 12,
    color: '#94A3B8',
    marginTop: 2,
    lineHeight: 16,
  },
  ctaContainer: {
    gap: 12,
  },
  bioLoginButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(56, 189, 248, 0.1)',
    borderWidth: 1.5,
    borderColor: '#38BDF8',
    borderRadius: 16,
    paddingVertical: 14,
    gap: 10,
  },
  bioLoginText: {
    fontSize: 15,
    fontWeight: '700',
    color: '#38BDF8',
  },
  primaryButton: {
    borderRadius: 16,
    overflow: 'hidden',
  },
  primaryGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    gap: 8,
  },
  primaryButtonText: {
    fontSize: 16,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  secondaryButton: {
    paddingVertical: 14,
    alignItems: 'center',
  },
  secondaryButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#94A3B8',
  },
});
