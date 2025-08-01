import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/theme/app_color.dart' show AppColors;
import 'package:hijri/hijri_calendar.dart';
import '../../../utils/widgets/loader.dart';
import '../../../viewmodels/agent_view_model.dart';
import '../../../providers/auth_providers.dart';
import '../agents/agent_detail_screen.dart';
import '../agents/all_agents_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HijriCalendar _hijriDate;

  @override
  void initState() {
    super.initState();
    _hijriDate = HijriCalendar.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAgents();
    });
  }

  void _loadAgents() {
    final authState = ref.read(authViewModelProvider);
    final agentViewModel = ref.read(agentViewModelProvider);
    agentViewModel.loadAgents(authState.user!.token);
  }

  final List<Map<String, String>> xadiithList = [
    {
      'text': 'خذ من أموالهم صدقة تطهرهم وتزكيهم بها',
      'translation':
          'Ka qaado xoolahooda sadaqo aad ku daahiriso oo ku saafiso. - Suuratul Tawbah 9:103',
    },
    {
      'text': 'وأقيموا الصلاة وآتوا الزكاة',
      'translation':
          'Aqiimaa salaadda oo bixiya Zakaadda. - Suuratul Baqarah 2:43',
    },
    {
      'text': 'الصدقة تطفئ غضب الرب وتدفع ميتة السوء',
      'translation':
          'Sadaqadu way damisaa xanaaqa Rabbiga waxayna ka ilaalisaa dhimashada xun. - Xadiithka Tirmidhi',
    },
    {
      'text': 'ما نقص مال من صدقة',
      'translation': 'Hanti kama yaraato sadaqo darteed. - Sahih Muslim',
    },
    {
      'text': 'والذين في أموالهم حق معلوم للسائل والمحروم',
      'translation':
          'Kuwa xoolahooda ku jira xaq la yaqaan oo loogu talagalay masaakiinta iyo baahiyaysan. - Suuratul Ma\'aarij 70:24-25',
    },
    {
      'text': 'مثل الذين ينفقون أموالهم في سبيل الله كمثل حبة أنبتت سبع سنابل',
      'translation':
          'Kuwa xoolahooda jidka Allaah ugu bixiya waxay u ekaadaan sida iniino baxday toddoba sabuul. - Suuratul Baqarah 2:261',
    },
    {
      'text': 'من أدى زكاة ماله فقد ذهب عنه شره',
      'translation':
          'Kii bixiyay Zakaadda maalkiisa, waxaa ka tagay xumaantiisa. - Xadiithka Ibn Khuzaymah',
    },
    {
      'text': 'وما تنفقوا من خير فلأنفسكم',
      'translation':
          'Wax kasta oo wanaagsan oo aad bixisaan, waxaa loo bixiyaa naftiinna. - Suuratul Baqarah 2:272',
    },
    {
      'text': 'يمحق الله الربا ويربي الصدقات',
      'translation':
          'Allaah wuxuu baabbi\'iyaa ribada wuxuuna kordhiyaa sadaqooyinka. - Suuratul Baqarah 2:276',
    },
    {
      'text': 'الصدقة برهان',
      'translation': 'Sadaqadu waa caddayn (iimaan). - Sahih Muslim',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 20,
          backgroundImage: AssetImage('assets/images/app.png'),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Gradient Background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryGold.withOpacity(0.15),
                    AppColors.backgroundLight,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text with Animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Text(
                            'Ku soo dhawoow Barnaamijka ZakatFlow!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Description Text
                  Text(
                    'Halkan waxaad ka xisaabin kartaa Zakaat-kaaga maal iyo xoolo, kadibna waxaad u diri kartaa hay\'adaha aad dooratay.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Islamic Date Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBeige.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryGold,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Taariikhda Hijri: ${_hijriDate.hDay} ${_getHijriMonthName(_hijriDate.hMonth)} ${_hijriDate.hYear} AH',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions Section

            // Hay'adaha Section with Enhanced Design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: 'Hay\'adaha',
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllAgentsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildAgentsCarousel(),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Xadiith and Ayat Section with Enhanced Design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aayado iyo Xadiithyo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Ku saabsan Zakaat iyo Sadaqo',
                    style: TextStyle(fontSize: 14, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 15),
                  _buildEnhancedXadiithCarousel(),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedXadiithCarousel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        final isLargeScreen = screenWidth > 900;

        // Fixed height for consistency
        double carouselHeight = 280;

        // Responsive viewport fraction
        double viewportFraction = isLargeScreen ? 0.75 : (isTablet ? 0.8 : 0.9);

        // Responsive font sizes
        double arabicFontSize = isLargeScreen ? 20 : (isTablet ? 18 : 16);
        double translationFontSize = isLargeScreen ? 14 : (isTablet ? 13 : 12);

        return CarouselSlider(
          options: CarouselOptions(
            height: carouselHeight,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 8),
            enlargeCenterPage: true,
            viewportFraction: viewportFraction,
            enableInfiniteScroll: true,
            autoPlayCurve: Curves.fastOutSlowIn,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
          ),
          items: xadiithList.map((xadiith) {
            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? 8.0 : 5.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryBeige,
                    AppColors.secondaryBeige.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative quote icon
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Icon(
                      Icons.format_quote,
                      color: AppColors.primaryGold.withOpacity(0.15),
                      size: 35,
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Arabic text section
                        Expanded(
                          flex: 5,
                          child: SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Text(
                                xadiith['text']!,
                                style: TextStyle(
                                  fontSize: arabicFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlack,
                                  height: 1.6,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ),
                        ),
                        
                        // Divider
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          height: 1,
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primaryGold.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        
                        // Translation text section
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Text(
                                xadiith['translation']!,
                                style: TextStyle(
                                  fontSize: translationFontSize,
                                  color: AppColors.textGray,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAgentsCarousel() {
    final agentViewModel = ref.watch(agentViewModelProvider);
    final agents = agentViewModel.agents;
    final isLoading = agentViewModel.isLoading;

    if (isLoading) {
      return SizedBox(height: 180, child: const Center(child: Loader()));
    }

    if (agents.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentLightGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business_outlined,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hay\'ad lama helin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fadlan ku soo noqo mar dambe',
                style: TextStyle(fontSize: 14, color: AppColors.textGray),
              ),
            ],
          ),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enlargeCenterPage: true,
        viewportFraction: 0.8,
      ),
      items:
          agents.take(5).map((agent) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgentDetailScreen(agentId: agent.id),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Background Image or Color
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image:
                              agent.profileImageUrl != null
                                  ? DecorationImage(
                                    image: NetworkImage(agent.profileImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                          color:
                              agent.profileImageUrl == null
                                  ? AppColors.accentLightGold.withOpacity(0.2)
                                  : null,
                        ),
                        child:
                            agent.profileImageUrl == null
                                ? Center(
                                  child: Icon(
                                    Icons.business,
                                    size: 50,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                                : null,
                      ),

                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),

                      // Agent Name with improved styling
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agent.fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3.0,
                                      color: Colors.black45,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  String _getHijriMonthName(int month) {
    const List<String> hijriMonths = [
      'Muharram',
      'Safar',
      'Rabii al-Awwal',
      'Rabii al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhul Qi\'dah',
      'Dhul Hijjah',
    ];
    return hijriMonths[month - 1];
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dhammaan',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
