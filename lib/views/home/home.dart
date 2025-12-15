import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/home_data.dart';
import '../../services/firebase_service.dart';
import '../../state/user_state.dart';
import '../chat/health_chat.dart';
import '../logs/mood_log.dart';
import '../logs/notes_log.dart';
import '../logs/symptoms_log.dart';
import '../insights/cycle_insights.dart';
import '../health/health_goals.dart';
import '../wellness/personalized_tips.dart';
import '../community/community_hub.dart';
import '../../theme/design_system.dart';
import '../../theme/responsive_helper.dart';

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

    // Responsive padding based on screen width
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final verticalSpacing = ResponsiveHelper.getSpacing(
      context,
      small: 12,
      medium: 16,
      large: 20,
    );
    final bottomPadding = media.viewInsets.bottom + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3FA),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDF3FA), Color(0xFFF7E7F4), Color(0xFFF0F4FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: verticalSpacing,
              bottom: bottomPadding,
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
                _buildFeatureCards(theme, media),
                SizedBox(height: verticalSpacing),
                _buildAdditionalFeatures(theme, media),
                SizedBox(height: verticalSpacing),
                _buildTodaysInsights(theme, media),
                SizedBox(height: verticalSpacing),
                _buildTodaysTip(theme, media),
                SizedBox(height: verticalSpacing),
                _buildHealthTips(theme, media),
                SizedBox(height: verticalSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isLarge) {
    return _surfaceCard(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 28 : 20,
        vertical: isLarge ? 22 : 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
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
          ),
          const SizedBox(width: 12),
          Container(
            width: isLarge ? 54 : 48,
            height: isLarge ? 54 : 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF8C4DA)),
            ),
            child: const Icon(
              Icons.favorite,
              color: Color(0xFFD946A6),
              size: 24,
            ),
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
      return _surfaceCard(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 28 : 20,
          vertical: isLarge ? 22 : 18,
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
    return _surfaceCard(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 28 : 20,
        vertical: isLarge ? 24 : 20,
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
                  backgroundColor: Colors.grey[200],
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
    final isPhaseBox = subtitle.contains('Phase');

    return GestureDetector(
      onTap: isPhaseBox ? () => _showPhaseInfo(title) : null,
      child: Tooltip(
        message: isPhaseBox ? _getPhaseDescription(title) : '',
        showDuration: const Duration(seconds: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.20),
              width: 1.4,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isPhaseBox)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.info_outline, size: 14, color: color),
                    ),
                ],
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
        ),
      ),
    );
  }

  String _getPhaseDescription(String phase) {
    switch (phase) {
      case 'Menstruation':
        return 'Menstruation (Days 1-5): Your period. Energy may be lower. Focus on rest and self-care.';
      case 'Follicular':
        return 'Follicular (Days 6-13): Rising estrogen. Energy increases, mood improves. Great for new projects.';
      case 'Ovulation':
        return 'Ovulation (Days 14-15): Peak fertility. High energy and confidence. Most fertile days.';
      case 'Luteal':
        return 'Luteal (Days 16-28): Progesterone rises. Energy may dip. Practice self-compassion and rest.';
      default:
        return 'Tap to learn about your cycle phase.';
    }
  }

  void _showPhaseInfo(String phase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$phase Phase'),
        content: Text(_getPhaseDescription(phase)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(ThemeData theme, MediaQueryData media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: media.size.width * 0.02),
          child: Text(
            'Explore Features',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: media.size.height * 0.02),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                theme,
                'Cycle Insights',
                'View patterns & trends',
                Icons.analytics_outlined,
                const Color(0xFFFF6B6B),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CycleInsightsPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                theme,
                'Health Goals',
                'Track wellness',
                Icons.favorite_outline,
                const Color(0xFF51CF66),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HealthGoalsPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.arrow_forward_ios, size: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalFeatures(ThemeData theme, MediaQueryData media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: media.size.width * 0.02),
          child: Text(
            'More Features',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: media.size.height * 0.02),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                theme,
                'Wellness Tips',
                'Phase-specific advice',
                Icons.lightbulb_outline,
                const Color(0xFFFFD93D),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PersonalizedTipsPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                theme,
                'Community',
                'Surveys & challenges',
                Icons.people_outline,
                const Color(0xFF9C27B0),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CommunityHubPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
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
              color: AppColors.textPrimary,
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
    return _surfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderRadius: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.70)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.soft(
                    color: color.withValues(alpha: 0.25),
                    blur: 18,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
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
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysInsights(ThemeData theme, MediaQueryData media) {
    return _surfaceCard(
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
              color: AppColors.primary.withValues(alpha: 0.08),
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
                      color: AppColors.primary.withValues(alpha: 0.35),
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
    return _surfaceCard(
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
            boxShadow: AppShadows.soft(
              color: color.withValues(alpha: 0.30),
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
    );
  }

  Widget _buildHealthTips(ThemeData theme, MediaQueryData media) {
    final padding = ResponsiveHelper.getHorizontalPadding(context);
    return _surfaceCard(
      padding: EdgeInsets.all(padding),
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
            final int? mapped = HomeData.healthTipColors[tip.category];
            final Color color = mapped != null
                ? Color(mapped)
                : AppColors.primary;
            final iconName =
                HomeData.healthTipIcons[tip.category] ?? 'favorite';
            return Padding(
              padding: EdgeInsets.only(
                bottom: ResponsiveHelper.getSpacing(
                  context,
                  small: 10,
                  medium: 12,
                  large: 14,
                ),
              ),
              child: _buildHealthTipCard(
                theme,
                tip.title,
                tip.description,
                _getIconData(iconName),
                color.withValues(alpha: 0.12),
                color,
              ),
            );
          }).toList(),
          SizedBox(
            height: ResponsiveHelper.getSpacing(
              context,
              small: 8,
              medium: 12,
              large: 16,
            ),
          ),
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
    final padding = ResponsiveHelper.getHorizontalPadding(context);
    return Container(
      padding: EdgeInsets.all(padding),
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
                color: iconColor.withValues(alpha: 0.30),
                blur: 18,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(
            width: ResponsiveHelper.getSpacing(
              context,
              small: 10,
              medium: 12,
              large: 12,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      small: 13,
                      medium: 14,
                      large: 15,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getSpacing(
                    context,
                    small: 3,
                    medium: 4,
                    large: 4,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.4,
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      small: 11,
                      medium: 12,
                      large: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _surfaceCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    double borderRadius = 20,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
      ),
      padding: padding,
      child: child,
    );
  }
}
