import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/home_data.dart';
import '../../services/firebase_service.dart';
import '../../state/user_state.dart';
import '../chat/health_chat.dart';
import '../logs/mood_log.dart';
import '../logs/notes_log.dart';
import '../logs/symptoms_log.dart';
import '../../theme/design_system.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CycleData? _cycleData;
  bool _loadingCycle = true;

  @override
  void initState() {
    super.initState();
    _loadCycle();
  }

  Future<void> _loadCycle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loadingCycle = false);
      return;
    }

    final latest = await FirebaseService.getCycleData(user.uid);
    final cycleStart = latest?['cycleStart'] as DateTime?;
    final cycleLength = UserState.currentUser.profile.cycleLength;

    if (cycleStart == null) {
      setState(() {
        _loadingCycle = false;
        _cycleData = null;
      });
      return;
    }

    final today = DateTime.now();
    final start = DateTime(cycleStart.year, cycleStart.month, cycleStart.day);
    final daysFromStart = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(start).inDays;
    final currentDay = (daysFromStart + 1).clamp(1, cycleLength);
    final daysLeft = (cycleLength - currentDay).clamp(0, cycleLength);
    final phase = _phaseForDay(currentDay);
    final progress = (currentDay / cycleLength).clamp(0.0, 1.0);

    setState(() {
      _cycleData = CycleData(
        currentDay: currentDay,
        daysLeft: daysLeft,
        currentPhase: phase,
        nextDate: 'Day $cycleLength',
        cycleProgress: progress,
        totalCycleDays: cycleLength,
      );
      _loadingCycle = false;
    });
  }

  String _phaseForDay(int currentDay) {
    if (currentDay <= 5) {
      return 'Menstruation';
    } else if (currentDay <= 13) {
      return 'Follicular';
    } else if (currentDay <= 15) {
      return 'Ovulation';
    } else {
      return 'Luteal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);
    final isLarge = media.size.width >= AppBreakpoints.tablet;
    final horizontalPadding = isLarge ? media.size.width * 0.08 : 24.0;
    final verticalSpacing = isLarge ? 28.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const HealthChatPage()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Health tips'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          ),
          _buildGlow(
            alignment: const Alignment(-1.1, -0.9),
            size: media.size.width * 0.7,
            color: AppColors.secondary,
            opacity: 0.22,
          ),
          _buildGlow(
            alignment: const Alignment(1.05, -0.1),
            size: media.size.width * 0.8,
            color: AppColors.tertiary,
            opacity: 0.18,
          ),
          _buildGlow(
            alignment: const Alignment(-0.2, 1.1),
            size: media.size.width * 0.6,
            color: Colors.white,
            opacity: 0.16,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalSpacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, isLarge),
                  SizedBox(height: verticalSpacing),
                  _buildCycleOverview(theme, media),
                  SizedBox(height: verticalSpacing),
                  _buildQuickActions(theme, media),
                  SizedBox(height: verticalSpacing),
                  _buildTodaysInsights(theme, media),
                  SizedBox(height: verticalSpacing),
                  _buildTodaysTip(theme, media),
                  SizedBox(height: verticalSpacing),
                  _buildHealthTips(theme, media),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isLarge) {
    return GlassPanel(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 32 : 24,
        vertical: isLarge ? 28 : 22,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${UserState.currentUser.profile.firstName}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Here’s your personalised health overview for today',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          Container(
            width: isLarge ? 60 : 52,
            height: isLarge ? 60 : 52,
            decoration: BoxDecoration(
              gradient: AppColors.glassGradient(0.28),
              shape: BoxShape.circle,
              boxShadow: AppShadows.soft(
                color: AppColors.primary.withOpacity(0.32),
                blur: 26,
              ),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleOverview(ThemeData theme, MediaQueryData media) {
    final spacing = media.size.height * 0.02;
    final isLarge = media.size.width >= AppBreakpoints.tablet;
    final data = _cycleData;

    if (_loadingCycle) {
      return GlassPanel(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 32 : 24,
          vertical: isLarge ? 28 : 22,
        ),
        child: SizedBox(
          height: 120,
          child: Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
      );
    }
    return GlassPanel(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 32 : 24,
        vertical: isLarge ? 30 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (data != null)
            Text(
              'Current cycle: ${data.totalCycleDays} days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            )
          else
            Text(
              'No cycle data yet. Mark your cycle start in Calendar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          SizedBox(height: spacing),
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: data?.cycleProgress ?? 0,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFD946A6),
                  ),
                ),
              ),
              SizedBox(height: spacing * 0.75),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Day 1',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    'Day ${data?.currentDay ?? 1} (Today)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Day ${data?.totalCycleDays ?? 28}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: spacing),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildCycleInfoBox(
                    theme,
                    '${data?.currentDay ?? 1}',
                    'Current\nDay',
                    const Color(0xFFFF6B6B),
                  ),
                ),
                SizedBox(width: media.size.width * 0.03),
                Expanded(
                  child: _buildCycleInfoBox(
                    theme,
                    '${data?.daysLeft ?? 27}',
                    'Days to\nPeriod',
                    const Color(0xFF4DABF7),
                  ),
                ),
                SizedBox(width: media.size.width * 0.03),
                Expanded(
                  child: _buildCycleInfoBox(
                    theme,
                    data?.currentPhase ?? 'Follicular',
                    'Current\nPhase',
                    const Color(0xFF51CF66),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleInfoBox(
    ThemeData theme,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, MediaQueryData media) {
    final actions = HomeData.quickActions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: media.size.width * 0.02),
          child: Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: media.size.height * 0.02),
        ...actions.asMap().entries.map((entry) {
          final action = entry.value;
          final showPrediction = entry.key > 0;

          VoidCallback onTap;
          final titleLower = action.title.toLowerCase();
          if (titleLower.contains('period')) {
            onTap = () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Open Calendar to log today\'s period.'),
                ),
              );
            };
          } else if (titleLower.contains('symptom')) {
            onTap = () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SymptomsLogPage(),
                ),
              );
            };
          } else if (titleLower.contains('mood')) {
            onTap = () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MoodLogPage()),
              );
            };
          } else if (titleLower.contains('note')) {
            onTap = () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotesLogPage()),
              );
            };
          } else {
            onTap = () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Action: ${action.title}')),
              );
            };
          }

          return Padding(
            padding: EdgeInsets.only(bottom: media.size.height * 0.015),
            child: _buildActionCard(
              theme,
              action.title,
              _getIconData(action.iconName),
              Color(action.colorValue),
              showPrediction,
              onTap,
            ),
          );
        }),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'description':
        return Icons.description;
      case 'favorite':
        return Icons.favorite;
      case 'emoji_emotions':
        return Icons.emoji_emotions;
      default:
        return Icons.circle;
    }
  }

  Widget _buildActionCard(
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
    bool showPrediction,
    VoidCallback onTap,
  ) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.soft(
                    color: color.withOpacity(0.35),
                    blur: 22,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (showPrediction)
                      Text(
                        'Includes predictions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysInsights(ThemeData theme, MediaQueryData media) {
    return GlassPanel(
      padding: EdgeInsets.all(media.size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Insights',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: media.size.height * 0.015),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.soft(
                      color: AppColors.primary.withOpacity(0.35),
                      blur: 18,
                    ),
                  ),
                  child: const Icon(
                    Icons.wb_sunny,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        HomeData.todaysInsight.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        HomeData.todaysInsight.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysTip(ThemeData theme, MediaQueryData media) {
    return GlassPanel(
      padding: EdgeInsets.all(media.size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Tip',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: media.size.height * 0.015),
          _buildTipRow(
            theme,
            HomeData.todaysTip.title,
            HomeData.todaysTip.description,
            Icons.water_drop,
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft(color: color.withOpacity(0.3), blur: 18),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTips(ThemeData theme, MediaQueryData media) {
    return GlassPanel(
      padding: EdgeInsets.all(media.size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Tips',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: media.size.height * 0.015),
          ...HomeData.healthTips.map((tip) {
            final color = Color(
              HomeData.healthTipColors[tip.category] ?? AppColors.primary.value,
            );
            final iconName =
                HomeData.healthTipIcons[tip.category] ?? 'favorite';
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildHealthTipCard(
                theme,
                tip.title,
                tip.description,
                _getIconData(iconName),
                color.withOpacity(0.12),
                color,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHealthTipCard(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
              boxShadow: AppShadows.soft(
                color: iconColor.withOpacity(0.3),
                blur: 18,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow({
    required Alignment alignment,
    required double size,
    required Color color,
    double opacity = 0.25,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}
