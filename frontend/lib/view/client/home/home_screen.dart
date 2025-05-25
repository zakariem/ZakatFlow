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

  final List<String> agents = [
    'Al-Ihsaan Foundation',
    'Horumar Relief',
    'Rahma Foundation',
    'Tawfiiq Organization',
    'Samafal Society',
  ];

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
        title: Text(
          'ZakatFlow',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome and Intro
              Text(
                'Ku soo dhawoow Barnaamijka ZakatFlow!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Halkan waxaad ka xisaabin kartaa Zakaat-kaaga maal iyo xoolo, kadibna waxaad u diri kartaa hay\'adaha aad dooratay.',
                style: TextStyle(fontSize: 16, color: AppColors.textGray),
              ),
              const SizedBox(height: 24),

              // Islamic Date
              Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Taariikhda Hijri: ${_hijriDate.hDay} ${_getHijriMonthName(_hijriDate.hMonth)} ${_hijriDate.hYear} AH',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hay'adaha Section
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
              const SizedBox(height: 12),
              _buildAgentsCarousel(),
              const SizedBox(height: 24),

              // Xadiith and Ayat Section
              Text(
                'Aayado iyo Xadiithyo ku saabsan Zakaat iyo Sadaqo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 6),
                  enlargeCenterPage: true,
                ),
                items:
                    xadiithList.map((xadiith) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBeige,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              xadiith['text']!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              xadiith['translation']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgentsCarousel() {
    final agentViewModel = ref.watch(agentViewModelProvider);
    final agents = agentViewModel.agents;
    final isLoading = agentViewModel.isLoading;

    if (isLoading) {
      return SizedBox(height: 160, child: const Center(child: Loader()));
    }

    if (agents.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.accentLightGold,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 40,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'Hay\'ad lama helin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 160,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enlargeCenterPage: true,
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
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
                                  ? AppColors.accentLightGold
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
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),

                      // Agent Name
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            agent.fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
          child: Text(
            'Dhammaan',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
