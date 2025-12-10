
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'question_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob 사용
import 'package:google_fonts/google_fonts.dart'; // 폰트 사용

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final remoteConfig = FirebaseRemoteConfig.instance;

  String appTitle = '심리 테스트 목록';
  Color appBarColor = Colors.deepPurple; // 기본 색상 설정

  // ==============================================
  // 💡 AdMob 관련 변수 및 로직
  // ==============================================
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // 테스트용 광고 ID (Android/iOS 환경에 따라 분리)
  final String adUnitId =
  Theme.of(context).platform == TargetPlatform.android
      ? 'ca-app-pub-3940256099942544/6300978111' // Android 테스트 배너 ID
      : 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너 ID

  Future<String> loadAsset() async {
    return await rootBundle.loadString('res/api/list.json');
  }

  @override
  void initState() {
    super.initState();
    _initializeRemoteConfig();
    _checkConnectivity();
    _loadBannerAd(); // 💡 광고 로드 시작
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  // 광고 로드 함수
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('BannerAd failed to load: $error');
        },
      ),
    )..load();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    final hasNoConnection = connectivityResult.contains(ConnectivityResult.none);

    if (hasNoConnection && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('네트워크 연결 상태를 확인해주세요.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _initializeRemoteConfig() async {
    await remoteConfig.setDefaults(<String, dynamic>{
      'app_title': '심리 테스트 목록',
      'app_bar_color_hex': '0xFF673AB7', // Colors.deepPurple의 Hex 값
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      print("Remote Config fetch failed: $e");
    }

    _updateUI();
  }

  void _updateUI() {
    setState(() {
      appTitle = remoteConfig.getString('app_title');

      String colorHex = remoteConfig.getString('app_bar_color_hex').toUpperCase();

      if (!colorHex.startsWith('0XFF')) {
        colorHex = '0XFF$colorHex';
      }

      try {
        // Remote Config에서 가져온 Hex 값으로 색상 업데이트
        appBarColor = Color(int.parse(colorHex));
      } catch (e) {
        appBarColor = Colors.deepPurple;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appTitle,
          style: GoogleFonts.gowunBatang(
            fontWeight: FontWeight.w600, // 고운 바탕 폰트 적용
          ),
        ),
        backgroundColor: appBarColor,
      ),
      body: Column(
        children: [

          // 2. 목록 (Expanded로 감싸서 남은 공간 차지)
          Expanded(
            child: FutureBuilder(
              future: loadAsset(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  Map<String, dynamic> list = jsonDecode(snapshot.data!);

                  return ListView.builder(
                    itemCount: list['questions'].length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          // Firebase Analytics 이벤트 기록
                          await FirebaseAnalytics.instance.logEvent(
                            name: 'test_click',
                            parameters: {
                              'test_title': list['questions'][index]['title'].toString(),
                            },
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QuestionPage(
                                filename: list['questions'][index]['filename'].toString(),
                                title: list['questions'][index]['title'].toString(),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          // 💡 카드 디자인 개선
                          elevation: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            title: Text(
                              list['questions'][index]['title'].toString(),
                              style: GoogleFonts.gowunBatang( // 폰트 적용
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: appBarColor,
                              ),
                            ),
                            trailing: Icon(Icons.psychology_outlined, color: appBarColor, size: 28),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),

          // 💡 광고 배너 위젯 배치
          if (_isAdLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          else
            const SizedBox(height: 50.0), // 광고가 로드되지 않았을 때 공간 확보
        ],
      ),
    );
  }
}