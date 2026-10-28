import 'package:flutter/material.dart';

class ProviderLogoWidget extends StatelessWidget {
  final String providerName;
  final double size;
  final double borderRadius;
  final String? customImageUrl;

  const ProviderLogoWidget({
    super.key,
    required this.providerName,
    this.size = 44,
    this.borderRadius = 12,
    this.customImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (customImageUrl != null && customImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          customImageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildBrandedLogo(),
        ),
      );
    }
    return _buildBrandedLogo();
  }

  Widget _buildBrandedLogo() {
    final clean = providerName.trim().toUpperCase();

    // ================= 1. MOBILE TELECOM NETWORKS =================
    // MTN: Official Sunflower Yellow + Black Oval + Bold MTN
    if (clean.contains('MTN')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFFCC00), // Official MTN Yellow
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x33FFCC00), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Container(
          width: size * 0.82,
          height: size * 0.52,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: size * 0.05),
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          alignment: Alignment.center,
          child: Text(
            'MTN',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'sans-serif',
              fontSize: size * 0.28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              height: 1.0,
            ),
          ),
        ),
      );
    }

    // AIRTEL: Official Crimson Red + White Circle + airtel lowercase
    if (clean.contains('AIRTEL')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE60000), // Official Airtel Red
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x33E60000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.74,
              height: size * 0.74,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'airtel',
                  style: TextStyle(
                    color: const Color(0xFFE60000),
                    fontFamily: 'sans-serif',
                    fontSize: size * 0.23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    height: 1.0,
                  ),
                ),
                Container(
                  width: size * 0.36,
                  height: size * 0.04,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE60000),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // GLO: Official Emerald Green + Neon Green Circle + glo italic
    if (clean.contains('GLO')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF008751), // Official Glo Green
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x33008751), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.76,
              height: size * 0.76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF70C922), width: size * 0.06),
              ),
            ),
            Text(
              'glo',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'sans-serif',
                fontSize: size * 0.34,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                height: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    // 9MOBILE: Official Forest Green + Lime Circle '9' + mobile
    if (clean.contains('9MOBILE') || clean.contains('ETISALAT')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF005C42), // Official 9mobile Forest Green
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x33005C42), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size * 0.44,
              height: size * 0.44,
              decoration: BoxDecoration(
                color: const Color(0xFFA0D300), // 9mobile Lime
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: size * 0.03),
              ),
              alignment: Alignment.center,
              child: Text(
                '9',
                style: TextStyle(
                  color: const Color(0xFF005C42),
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'mobile',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                height: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    // ================= 2. CABLE TELEVISION PROVIDERS =================
    // DStv
    if (clean.contains('DSTV')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0057B8), // DStv Blue
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x330057B8), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'DStv',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    // GOtv
    if (clean.contains('GOTV')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A), // GOtv Green
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x3316A34A), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'GOtv',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
      );
    }

    // StarTimes
    if (clean.contains('STARTIMES')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6600), // StarTimes Orange
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x33FF6600), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, color: Colors.white, size: size * 0.36),
            Text(
              'StarTimes',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    // Showmax
    if (clean.contains('SHOWMAX')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          'show\nmax',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFE50914),
            fontSize: size * 0.22,
            fontWeight: FontWeight.w900,
            height: 0.9,
          ),
        ),
      );
    }

    // ================= 3. EXAM BOARD CERTIFICATE EMBLEMS =================
    // WAEC: West African Examinations Council
    if (clean.contains('WAEC')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF002D62), // WAEC Deep Navy
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: const Color(0xFFFFD700), width: size * 0.04),
          boxShadow: const [
            BoxShadow(color: Color(0x33002D62), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_rounded, color: const Color(0xFFFFD700), size: size * 0.32),
            Text(
              'WAEC',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      );
    }

    // NECO: National Examinations Council
    if (clean.contains('NECO')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF006633), // NECO Emerald Green
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: size * 0.04),
          boxShadow: const [
            BoxShadow(color: Color(0x33006633), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_rounded, color: const Color(0xFFFFD700), size: size * 0.32),
            Text(
              'NECO',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      );
    }

    // NABTEB
    if (clean.contains('NABTEB')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0D234C), // NABTEB Navy
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: const Color(0xFFF37021), width: size * 0.04),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.engineering_rounded, color: const Color(0xFFF37021), size: size * 0.32),
            Text(
              'NABTEB',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.19,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      );
    }

    // JAMB
    if (clean.contains('JAMB')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF008000), // JAMB Green
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: const Color(0xFFFFD700), width: size * 0.04),
        ),
        alignment: Alignment.center,
        child: Text(
          'JAMB',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.28,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    // ================= 4. BROADBAND & INTERNET =================
    // SMILE 4G LTE
    if (clean.contains('SMILE')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x33A855F7), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_rounded, color: Colors.white, size: size * 0.32),
            Text(
              'smile',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      );
    }

    // ALPHA (GLO ALPHA)
    if (clean.contains('ALPHA')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF064E3B),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: const Color(0xFF34D399), width: size * 0.04),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.all_inclusive_rounded, color: const Color(0xFF34D399), size: size * 0.32),
            Text(
              'ALPHA',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    // ================= 5. ELECTRICITY DISCOS =================
    final isDisco = clean.contains('ELECTRIC') ||
        clean.contains('IKEDC') ||
        clean.contains('EKEDC') ||
        clean.contains('AEDC') ||
        clean.contains('IBEDC') ||
        clean.contains('PHED') ||
        clean.contains('KEDCO') ||
        clean.contains('EEDC') ||
        clean.contains('JED') ||
        clean.contains('KAEDCO') ||
        clean.contains('BEDC') ||
        clean.contains('YEDC');

    if (isDisco) {
      Color discoColor = const Color(0xFF0A1C6A);
      String label = 'DISCO';

      if (clean.contains('IKEDC') || clean.contains('IKEJA')) {
        discoColor = const Color(0xFF003366);
        label = 'IKEDC';
      } else if (clean.contains('EKEDC') || clean.contains('EKO')) {
        discoColor = const Color(0xFF006633);
        label = 'EKEDC';
      } else if (clean.contains('AEDC') || clean.contains('ABUJA')) {
        discoColor = const Color(0xFFE65100);
        label = 'AEDC';
      } else if (clean.contains('IBEDC') || clean.contains('IBADAN')) {
        discoColor = const Color(0xFF007799);
        label = 'IBEDC';
      } else if (clean.contains('PHED') || clean.contains('PORT HARCOURT')) {
        discoColor = const Color(0xFF008080);
        label = 'PHED';
      } else if (clean.contains('KEDCO') || clean.contains('KANO')) {
        discoColor = const Color(0xFFD35400);
        label = 'KEDCO';
      } else if (clean.contains('EEDC') || clean.contains('ENUGU')) {
        discoColor = const Color(0xFF6A1B9A);
        label = 'EEDC';
      } else if (clean.contains('JED') || clean.contains('JOS')) {
        discoColor = const Color(0xFF37474F);
        label = 'JED';
      } else if (clean.contains('KAEDCO') || clean.contains('KADUNA')) {
        discoColor = const Color(0xFF880E4F);
        label = 'KAEDCO';
      } else if (clean.contains('BEDC') || clean.contains('BENIN')) {
        discoColor = const Color(0xFFB71C1C);
        label = 'BEDC';
      } else if (clean.contains('YEDC') || clean.contains('YOLA')) {
        discoColor = const Color(0xFFF57F17);
        label = 'YEDC';
      }

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: discoColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(color: discoColor.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, color: const Color(0xFFFFD700), size: size * 0.4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    // ================= 6. VIRTUAL BANKS (PALMPAY & PAGA) =================
    if (clean.contains('PALMPAY')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF4A10D9), // PalmPay Brand Purple
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          'PalmPay',
          style: TextStyle(
            color: const Color(0xFFFFD200),
            fontSize: size * 0.24,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    if (clean.contains('PAGA')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFA6400), // Paga Orange
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          'paga',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.28,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    // Default Fallback
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1C6A),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        clean.isNotEmpty ? clean.substring(0, clean.length >= 3 ? 3 : clean.length) : 'MBK',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
