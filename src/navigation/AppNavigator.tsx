import React, { useState, useEffect, useRef } from 'react';
import { View, StyleSheet, Platform, ActivityIndicator, AppState } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import {
  Home,
  LayoutGrid,
  Clock,
  User,
} from 'lucide-react-native';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../context/ThemeContext';

// Auth Screens
import { WelcomeScreen } from '../screens/auth/WelcomeScreen';
import { LoginScreen } from '../screens/auth/LoginScreen';
import { RegisterScreen } from '../screens/auth/RegisterScreen';
import { PinSetupScreen } from '../screens/auth/PinSetupScreen';

// Main Screens
import { HomeScreen } from '../screens/main/HomeScreen';
import { ServicesScreen } from '../screens/main/ServicesScreen';
import { HistoryScreen } from '../screens/main/HistoryScreen';
import { ProfileScreen } from '../screens/main/ProfileScreen';

// Service Screens
import { DataScreen } from '../screens/services/DataScreen';
import { AirtimeScreen } from '../screens/services/AirtimeScreen';
import { FundWalletScreen } from '../screens/services/FundWalletScreen';
import { CableScreen } from '../screens/services/CableScreen';
import { ElectricityScreen } from '../screens/services/ElectricityScreen';
import { Airtime2CashScreen } from '../screens/services/Airtime2CashScreen';
import { ExamPinScreen } from '../screens/services/ExamPinScreen';
import { SmileScreen } from '../screens/services/SmileScreen';
import { AppLockModal } from '../components/AppLockModal';

const RootStack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

const MainTabs = () => {
  const { colors } = useTheme();

  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: colors.surface,
          borderTopColor: colors.cardBorder,
          borderTopWidth: 1,
          height: Platform.OS === 'ios' ? 88 : 68,
          paddingBottom: Platform.OS === 'ios' ? 28 : 10,
          paddingTop: 8,
          elevation: 8,
          shadowColor: '#000',
          shadowOffset: { width: 0, height: -2 },
          shadowOpacity: 0.1,
          shadowRadius: 4,
        },
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.textMuted,
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: '700',
        },
      }}
    >
      <Tab.Screen
        name="HomeTab"
        component={HomeScreen}
        options={{
          tabBarLabel: 'Home',
          tabBarIcon: ({ color, size }) => <Home size={size} color={color} />,
        }}
      />
      <Tab.Screen
        name="ServicesTab"
        component={ServicesScreen}
        options={{
          tabBarLabel: 'Services',
          tabBarIcon: ({ color, size }) => <LayoutGrid size={size} color={color} />,
        }}
      />
      <Tab.Screen
        name="HistoryTab"
        component={HistoryScreen}
        options={{
          tabBarLabel: 'History',
          tabBarIcon: ({ color, size }) => <Clock size={size} color={color} />,
        }}
      />
      <Tab.Screen
        name="ProfileTab"
        component={ProfileScreen}
        options={{
          tabBarLabel: 'Profile',
          tabBarIcon: ({ color, size }) => <User size={size} color={color} />,
        }}
      />
    </Tab.Navigator>
  );
};

export const AppNavigator = () => {
  const { token, isLoading, refreshData } = useAuth();
  const { colors } = useTheme();
  const [isLocked, setIsLocked] = useState(false);
  const appState = useRef(AppState.currentState);

  useEffect(() => {
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      if (
        appState.current.match(/active/) &&
        (nextAppState === 'inactive' || nextAppState === 'background')
      ) {
        // App minimized or went to background: require Face ID immediately
        if (token) {
          setIsLocked(true);
        }
      } else if (
        appState.current.match(/inactive|background/) &&
        nextAppState === 'active'
      ) {
        // App returned to foreground: keep lock active, auto-refresh balance in background
        if (token) {
          setIsLocked(true);
          try {
            refreshData();
          } catch {}
        }
      }
      appState.current = nextAppState;
    });

    return () => {
      subscription.remove();
    };
  }, [token]);

  if (isLoading) {
    return (
      <View style={[styles.loadingWrapper, { backgroundColor: colors.bg }]}>
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    );
  }

  return (
    <>
      <NavigationContainer>
        <RootStack.Navigator
          screenOptions={{
            headerShown: false,
            animation: 'slide_from_right',
          }}
        >
          {!token ? (
            // Auth Stack
            <>
              <RootStack.Screen name="Welcome" component={WelcomeScreen} />
              <RootStack.Screen name="Login" component={LoginScreen} />
              <RootStack.Screen name="Register" component={RegisterScreen} />
              <RootStack.Screen name="PinSetup" component={PinSetupScreen} />
            </>
          ) : (
            // Authenticated App Stack
            <>
              <RootStack.Screen name="Main" component={MainTabs} />
              <RootStack.Screen name="Data" component={DataScreen} />
              <RootStack.Screen name="Airtime" component={AirtimeScreen} />
              <RootStack.Screen name="FundWallet" component={FundWalletScreen} />
              <RootStack.Screen name="Cable" component={CableScreen} />
              <RootStack.Screen name="Electricity" component={ElectricityScreen} />
              <RootStack.Screen name="Airtime2Cash" component={Airtime2CashScreen} />
              <RootStack.Screen name="ExamPin" component={ExamPinScreen} />
              <RootStack.Screen name="Smile" component={SmileScreen} />
              <RootStack.Screen name="History" component={HistoryScreen} />
              <RootStack.Screen name="PinSetup" component={PinSetupScreen} />
            </>
          )}
        </RootStack.Navigator>
      </NavigationContainer>

      {/* Compulsory Face ID / PIN App Lock Overlay when user leaves and returns */}
      {token ? (
        <AppLockModal visible={isLocked} onUnlock={() => setIsLocked(false)} />
      ) : null}
    </>
  );
};

const styles = StyleSheet.create({
  loadingWrapper: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
