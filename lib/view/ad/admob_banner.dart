import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobBanner extends StatefulWidget {
  const AdmobBanner({super.key});

  @override
  State<AdmobBanner> createState() => _AdmobBannerState();
}
class _AdmobBannerState extends State<AdmobBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  double adWidth = double.infinity;
  double adHeight = 0;

  final adUnitId = Platform.isAndroid
      // ? 'ca-app-pub-3991510386003471/1231433020'
      ? 'ca-app-pub-3940256099942544/6300978111' // 테스트 광고
      : 'ca-app-pub-3940256099942544/2435281174';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadAd();
  }

  void loadAd() async {
    print("loadAd 실행 중");
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.sizeOf(context).width.truncate());

    if (size == null) {
      debugPrint('Failed to get banner ad size.');
      return;
    }
    print('width: ${size.width}, height: ${size.height}');

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            adWidth = size.width.toDouble();
            adHeight = size.height.toDouble();
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded
        ? Container(
            width: adWidth,
            height: adHeight,
            alignment: Alignment.bottomCenter,
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
