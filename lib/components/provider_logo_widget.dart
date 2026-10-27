import 'package:flutter/material.dart';

class ProviderLogoWidget extends StatelessWidget {
  final String providerName;
  final double size;
  final double borderRadius;
  final String? customImageUrl;

  const ProviderLogoWidget({
    super.key,
    required this.providerName,
    this.size = 48,
    this.borderRadius = 14,
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

    // 1. MOBILE NETWORKS
    if (clean.contains('MTN')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFFCC00), // Official MTN Yellow
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x26FFCC00), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: size * 0.12, vertical: size * 0.06),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: size * 0.04),
            borderRadius: BorderRadius.circular(size * 0.5),
          ),
          child: Text(
            'MTN',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'sans-serif',
              fontSize: size * 0.32,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    if (clean.contains('AIRTEL')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE60000), // Official Airtel Red
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x33E60000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxCircle,
              ),
            ),
            Text(
              'airtel',
              style: TextStyle(
                color: const Color(0xFFE60000),
                fontFamily: 'sans-serif',
                fontSize: size * 0.24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      );
    }

    if (clean.contains('GLO')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF008751), // Official Glo Green
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x33008751), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: BoxDecoration(
                shape: BoxCircle,
                border: Border.all(color: const Color(0xFF70C922), width: size * 0.05),
              ),
            ),
            Text(
              'glo',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'sans-serif',
                fontSize: size * 0.36,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (clean.contains('9MOBILE') || clean.contains('ETISALAT')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF005C42), // Official 9mobile Forest Green
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x33005C42), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(
                color: const Color(0xFFA0D300), // 9mobile Lime
                shape: BoxCircle,
                border: Border.all(color: Colors.white, width: size * 0.03),
              ),
              alignment: Alignment.center,
              child: Text(
                '9',
                style: TextStyle(
                  color: const Color(0xFF005C42),
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. CABLE TV
    if (clean.contains('DSTV')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0057B8), // DStv Blue
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x330057B8), blurRadius: 8, offset: Offset(0, 3)),
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

    if (clean.contains('GOTV')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF22B14C), // GOtv Green
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x3322B14C), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'GOtv',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      );
    }

    if (clean.contains('STARTIMES')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6600), // StarTimes Orange
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x33FF6600), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.white, size: size * 0.35),
            Text(
              'StarTimes',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

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

    // 3. ELECTRICITY DISCOS
    final isDisco = clean.contains('ELECTRIC') ||
        clean.contains('IKEDC') ||
        clean.contains('EKEDC') ||
        clean.contains('AEDC') ||
        clean.contains('IBEDC') ||
        clean.contains('PHED') ||
        clean.contains('KEDCO') ||
        clean.contains('EEDC') ||
        clean.contains('JED') ||
        clean.contains('KAEDCO');

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
      }

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: discoColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(color: discoColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, color: const Color(0xFFFFD700), size: size * 0.4),
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

    // 4. BANKS (PALMPAY & PAGA)
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
